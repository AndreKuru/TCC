library ieee;
use ieee.std_logic_1164.all;
use work.accelerator_pkg.all;

entity accelerator is
    generic(
        threshold_size              : natural := THRESHOLD_SIZE;
        features_amount             : natural := FEATURES_AMOUNT;
        features_index_size         : natural := FEATURE_INDEX_SIZE;
        class_size                  : natural := CLASS_SIZE;
        levels_in_memory            : natural := LEVELS_IN_MEMORY;
        levels_in_parallel          : natural := LEVELS_IN_PARALLEL;
        prefetch                    : natural := PREFETCH;
        features_amount_remaining   : natural := FEATURES_AMOUNT_REMAINING
    );
        -- node_size        = threshold_size + log2(features_index_size) + leaf_bit + valid_bit   -- q
        -- memory_size = node_size * 2 ** levels_in_memory                                       -- t
        -- nodes_in_parallel = 2 ** levels_in_parallel                                           -- p
    port(
        clk, reset  : in  std_logic;
        features    : in  std_logic_vector(threshold_size * features_amount - 1 downto 0);
        class       : out std_logic_vector(Bit_lenght(class_size) downto 0)
    );
end accelerator;

architecture arch of accelerator is

    -- node_size            = valid_bit + leaf_bit   + threshold_size + log2(features_index_size)
constant node_size            : natural := (1 + 1 + threshold_size + features_index_size);
constant nodes_amount         : natural := (2 ** levels_in_memory);
constant node_address_size    : natural := levels_in_memory;
constant memory_size          : natural := (node_size * nodes_amount);
constant nodes_in_parallel    : natural := (2 ** (levels_in_parallel - 1));

signal kernel_output            : std_logic_vector(levels_in_parallel - 1 downto 0);
signal mux_output, threshold    : std_logic_vector(threshold_size - 1 downto 0);
signal features_selector        : std_logic_vector(features_index_size - 1 downto 0);
signal address_to_fetch         : std_logic_vector(node_address_size-1 downto 0);
signal node_from_memory         : std_logic_vector(node_size-1 downto 0);
signal valid_bit, leaf          : std_logic;
 
signal features_complement      : std_logic_vector(threshold_size *                     features_amount_remaining - 1 downto 0);
signal total_features           : std_logic_vector(threshold_size * (features_amount + features_amount_remaining) - 1 downto 0);

begin
    AddressCalculator0 : entity work.address_calculator
        generic map(
            levels_in_parallel          => levels_in_parallel,
            prefetch                    => prefetch,
            addresses_to_fetch_amount   => nodes_in_parallel,
            node_address_size           => node_address_size
        )
        port map(
            clk             => clk,
            reset           => reset,
            next_nodes      => kernel_output,
            node_addresses  => address_to_fetch
        );

    features_complement <= (others => '0');
    total_features <= features_complement & features;

    N_to_m_mux : entity work.mux_n_unified_to_m
        generic map(
            elements_amount     =>  features_amount + features_amount_remaining, -- has to be power of 2 and at least 2
            elements_size       =>  threshold_size,
            selectors_amount    =>  nodes_in_parallel,
            selectors_size      =>  features_index_size
        
        )
        port map(
            elements    => total_features,
            selectors   => features_selector,
            y           => mux_output
        );
    
    Kernel0 : entity work.kernel
        generic map(
            threshold_size      => threshold_size,
            nodes_in_parallel   => nodes_in_parallel,
            levels_in_parallel  => levels_in_parallel
        )
        port map(
            feature     => mux_output,
            threshold   => threshold,
            next_nodes  => kernel_output
        );

    Memory0 : entity work.memory
        generic map(
            node_address_size   => node_address_size,
            node_size           => node_size,
            nodes_in_parallel   => nodes_in_parallel
        )
        port map(
            clk             => clk,
            write_in        => '0',
            node_addresses  => address_to_fetch,
            node_data_in    => node_from_memory,
            node_data_out   => node_from_memory
        );

    -- valid_bit           <= node_from_memory(node_size - 1);
    -- leaf                <= node_from_memory(node_size - 2);
    threshold           <= node_from_memory(node_size - 3 downto node_size - threshold_size - 2);
    features_selector   <= node_from_memory(features_index_size - 1 downto 0);

    class <= "1010";
end arch;