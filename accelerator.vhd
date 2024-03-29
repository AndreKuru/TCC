library ieee;
library work;
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
        prefetch                    : natural := PREFETCH;
        nodes_to_write              : natural := NODES_TO_WRITE
    );
    port(
        clk, reset, write_in    : in  std_logic;
        features                : in  std_logic_vector(threshold_size * features_amount - 1 downto 0);
        data_to_write           : in  std_logic_vector(node_size * nodes_to_write - 1 downto 0);
        base_address_to_write   : in  std_logic_vector(levels_in_memory - 1 downto 0);
        ready                   : out std_logic;
        class                   : out std_logic_vector(class_size - 1 downto 0)
    );
end accelerator;

architecture arch of accelerator is

constant class_full_size            : natural := class_size + class_size_complement;
constant threshold_full_size        : natural := threshold_size + threshold_size_complement;
constant nodes_in_parallel          : natural := 2**levels_in_parallel - 1;
constant last_level_nodes_amount    : natural := 2**(levels_in_parallel - 1);

-- Data from node
signal node_from_memory         : std_logic_vector(nodes_in_parallel * node_size - 1 downto 0);
signal features_selectors       : std_logic_vector(nodes_in_parallel * features_index_size - 1 downto 0);
signal mux_output, thresholds   : std_logic_vector(nodes_in_parallel * threshold_size - 1 downto 0);
signal last_level_leaves        : std_logic_vector(last_level_nodes_amount  - 1 downto 0);
signal last_level_classes       : std_logic_vector(last_level_nodes_amount * class_size - 1 downto 0);

-- Address calculator
signal address_to_fetch         : std_logic_vector(nodes_in_parallel * levels_in_memory - 1 downto 0);

-- Pathfinder
signal path_found               : std_logic_vector(levels_in_parallel - 1 downto 0);

-- Class
signal result                   : std_logic_vector(class_size - 1 downto 0);
signal class_found, compute     : std_logic;

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
            load            => compute,
            path_found      => path_found,
            node_addresses  => address_to_fetch
        );

    features_complement <= (others => '0');
    total_features <= features_complement & features;

    
    Register_bank_unit : entity work.register_bank
        generic map(
            node_address_size   => levels_in_memory,
            node_size           => node_size,
            nodes_to_write      => nodes_to_write,
            nodes_in_parallel   => nodes_in_parallel
        )
        port map(
            clk                     => clk,
            write_in                => write_in,
            node_data_write         => data_to_write,
            base_address_to_write   => base_address_to_write,
            node_addresses_read     => address_to_fetch,
            node_data_read          => node_from_memory
        );


    Compute_data_extraction : for i in 0 to nodes_in_parallel - 1 generate
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

    Output_data_extraction : for i in nodes_in_parallel - last_level_nodes_amount to nodes_in_parallel - 1 generate
    constant i_shifted : natural := i - (nodes_in_parallel - last_level_nodes_amount);
    begin
        last_level_leaves(i_shifted) <= node_from_memory(node_size * (i + 1) - 1);

        last_level_classes(class_size * (i_shifted + 1) - 1 downto class_size * i_shifted) <=
            node_from_memory(
                node_size * i + class_size - 1                       
                downto 
                node_size * i
                );
    end generate;

    Features_mux : entity work.mux_n_unified_to_m
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
    
    Path_finder_unit : entity work.path_finder
        generic map(
            threshold_size      => threshold_size,
            nodes_in_parallel   => nodes_in_parallel,
            levels_in_parallel  => levels_in_parallel
        )
        port map(
            features    => mux_output,
            thresholds  => thresholds,
            path_found  => path_found
        );

    Multilevel_in_parallel : if levels_in_parallel > 1 generate
    signal last_level_selector   : std_logic_vector(levels_in_parallel - 2 downto 0);
    begin
        last_level_selector <= path_found(levels_in_parallel - 1 downto 1);

        Class_Mux : entity work.mux_n_unified_to_1
            generic map(
                elements_amount     => last_level_nodes_amount,
                elements_size       => class_size,
                selector_size       => levels_in_parallel - 1
            )
            port map(
                elements    => last_level_classes,
                selector    => last_level_selector,
                y           => result
            );

        Leaf_mux : entity work.mux_n_unified_to_1
            generic map(
                elements_amount     => last_level_nodes_amount,
                elements_size       => 1,
                selector_size       => levels_in_parallel - 1
            )
            port map(
                elements    => last_level_leaves,
                selector    => last_level_selector,
                y(0)        => class_found
            );

    end generate Multilevel_in_parallel;

    Singlelevel : if levels_in_parallel <= 1 generate
        result      <= last_level_classes;
        class_found <= last_level_leaves(0);
    end generate;

    Result_register : entity work.register_with_load_and_reset
        generic map(data_size => class_size)
        port map(
            clk         => clk,
            reset       => reset,
            load        => class_found,
            data_in     => result,
            data_out    => class
        );

    Ready_register : entity work.register_with_load_and_reset
        generic map(data_size => 1)
        port map(
            clk         => clk,
            reset       => reset,
            load        => class_found,
            data_in(0)  => '1',
            data_out(0) => ready
        );
    
    compute <= not class_found;

end arch;