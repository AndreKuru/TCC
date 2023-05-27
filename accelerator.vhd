library ieee;
use ieee.std_logic_1164.all;
use work.accelerator_pkg.all;

entity accelerator is
    generic(
        features_amount             : natural := FEATURES_AMOUNT;
        features_index_size         : natural := FEATURE_INDEX_SIZE;
        features_amount_remaining   : natural := FEATURES_AMOUNT_REMAINING;
        threshold_size              : natural := THRESHOLD_SIZE;
        threshold_size_complement   : natural := THRESHOLD_SIZE_COMPLEMENT;
        class_size                  : natural := CLASS_SIZE;
        class_size_complement       : natural := CLASS_SIZE_COMPLEMENT;
        nodes_amount                : natural := NODES_AMOUNT;
        node_size                   : natural := NODE_SIZE;
        levels_in_memory            : natural := LEVELS_IN_MEMORY;
        levels_in_parallel          : natural := LEVELS_IN_PARALLEL;
        prefetch                    : natural := PREFETCH
    );
    port(
        clk, reset      : in  std_logic;
        features        : in  std_logic_vector(threshold_size * features_amount - 1 downto 0);
        -- nodes_data_in   : in  std_logic_vector(nodes_amount * node_size - 1 downto 0);
        ready           : out std_logic;
        class           : out std_logic_vector(class_size - 1 downto 0)
    );
end accelerator;

architecture arch of accelerator is

constant class_full_size            : natural := class_size + class_size_complement;
constant threshold_full_size        : natural := threshold_size + threshold_size_complement;
constant memory_size                : natural := node_size * nodes_amount;
constant nodes_in_parallel          : natural := 2**levels_in_parallel - 1;
constant last_level_nodes_amount    : natural := 2**(levels_in_parallel - 1);

-- Data from node
signal leaves                   : std_logic_vector(nodes_in_parallel - 1 downto 0);
signal features_selectors       : std_logic_vector(nodes_in_parallel * features_index_size - 1 downto 0);
signal mux_output, thresholds   : std_logic_vector(nodes_in_parallel * threshold_size - 1 downto 0);
signal last_level_classes       : std_logic_vector(last_level_nodes_amount * class_size - 1 downto 0);
signal node_from_memory         : std_logic_vector(node_size-1 downto 0);

-- Address calculator
signal address_to_fetch         : std_logic_vector(levels_in_memory - 1 downto 0);

-- Kernel
signal kernel_output            : std_logic_vector(levels_in_parallel - 1 downto 0);

-- Class
signal result                   : std_logic_vector(class_size - 1 downto 0);
signal class_found              : std_logic;

-- Extended signals
signal features_complement      : std_logic_vector(threshold_size *                     features_amount_remaining - 1 downto 0);
signal total_features           : std_logic_vector(threshold_size * (features_amount + features_amount_remaining) - 1 downto 0);

begin
    AddressCalculator0 : entity work.address_calculator
        generic map(
            levels_in_parallel          => levels_in_parallel,
            prefetch                    => prefetch,
            addresses_to_fetch_amount   => nodes_in_parallel,
            node_address_size           => levels_in_memory
        )
        port map(
            clk             => clk,
            reset           => reset,
            next_nodes      => kernel_output,
            node_addresses  => address_to_fetch
        );

    features_complement <= (others => '0');
    total_features <= features_complement & features;

    Memory0 : entity work.memory
        generic map(
            node_address_size   => levels_in_memory,
            -- nodes_amount        => nodes_amount,
            node_size           => node_size,
            nodes_in_parallel   => nodes_in_parallel
        )
        port map(
            clk             => clk,
            -- write_in        => '0',
            node_addresses  => address_to_fetch,
            -- node_data_in    => nodes_data_in,
            node_data_out   => node_from_memory
        );


    Compute_data_extraction : for i in 0 to nodes_in_parallel - 1 generate
        leaves(i) <= node_from_memory(node_size * (i + 1) - 1);

        features_selectors(features_index_size * (i + 1) - 1 downto features_index_size * i) <= 
            node_from_memory(
                node_size * i + threshold_full_size + features_index_size - 1 
                downto 
                node_size * i + threshold_full_size
                );

        thresholds(threshold_size * (i + 1) - 1 downto threshold_size * i) <= 
            node_from_memory(
                node_size * i + threshold_size - 1                       
                downto 
                node_size * i
                );
    end generate;

    Output_data_extraction : for i in 0 to last_level_nodes_amount - 1 generate
        last_level_classes(class_size * (i + 1) - 1 downto class_size * i) <=
            node_from_memory(
                node_size * i + class_size - 1                       
                downto 
                node_size * i
                );
    end generate;

    N_to_m_mux : entity work.mux_n_unified_to_m
        generic map(
            elements_amount     =>  features_amount + features_amount_remaining, -- has to be power of 2 and at least 2
            elements_size       =>  threshold_size,
            selectors_amount    =>  nodes_in_parallel,
            selectors_size      =>  features_index_size
        
        )
        port map(
            elements    => total_features,
            selectors   => features_selectors,
            y           => mux_output
        );
    
    Kernel0 : entity work.kernel
        generic map(
            threshold_size      => threshold_size,
            nodes_in_parallel   => nodes_in_parallel,
            levels_in_parallel  => levels_in_parallel
        )
        port map(
            features     => mux_output,
            thresholds   => thresholds,
            next_nodes  => kernel_output
        );

    Multilevel_classes : if levels_in_parallel > 1 generate
    signal class_selector   : std_logic_vector(levels_in_parallel - 2 downto 0);
    begin
        class_selector <= kernel_output(levels_in_parallel - 2 downto 0);

        Class_Mux : entity work.mux_n_unified_to_1
            generic map(
                elements_amount     => last_level_nodes_amount,
                elements_size       => class_size,
                selector_size       => levels_in_parallel - 1
            )
            port map(
                elements    => last_level_classes,
                selector    => class_selector,
                y           => result
            );
    end generate Multilevel_classes;

    Multilevel_leaf : if levels_in_parallel > 1 generate
    signal leaf_bits_acumulated : std_logic_vector(levels_in_parallel downto 0);
    signal past_nodes_leaf_bit  : std_logic_vector(levels_in_parallel - 1 downto 0);
    signal leaf_selector        : std_logic_vector(levels_in_parallel - 2 downto 0);
    begin
        past_nodes_leaf_bit(0) <= leaves(0);
        leaf_selector <= kernel_output(levels_in_parallel - 2 downto 0);

        Leaves_array : for i in 1 to levels_in_parallel - 1 generate
            Leaf_mux : entity work.mux_n_unified_to_1
            generic map(
                elements_amount     => 2**i,
                elements_size       => 1,
                selector_size       => i
            )
            port map(
                elements    => leaves(2**(i + 1) - 2 downto 2**i - 1),
                selector    => leaf_selector(i - 1 downto 0),
                y(0)        => past_nodes_leaf_bit(i)
            );
        end generate Leaves_array;

        leaf_bits_acumulated(0) <= past_nodes_leaf_bit(0);

        Leaves_acumulator : for i in 1 to levels_in_parallel - 1 generate
            Leaf_or : entity work.or_bit
                port map(
                    a   => leaf_bits_acumulated(i - 1),
                    b   => leaf_bits_acumulated(i),
                    y   => leaf_bits_acumulated(i + 1)
                );
        end generate;

        class_found <= leaf_bits_acumulated(levels_in_parallel);
    end generate Multilevel_leaf;

    Singlelevel : if levels_in_parallel <= 1 generate
        result <= last_level_classes;
        class_found <= leaves(0);
    end generate;

    Result_registrator : entity work.registrator
        generic map(data_size => class_size)
        port map(
            clk         => clk,
            reset       => reset,
            load        => class_found,
            data_in     => result,
            data_out    => class
        );

    Ready_registrator : entity work.registrator
        generic map(data_size => 1)
        port map(
            clk         => clk,
            reset       => reset,
            load        => class_found,
            data_in(0)  => '1',
            data_out(0) => ready
        );

end arch;