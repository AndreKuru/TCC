library ieee;
use ieee.std_logic_1164.all;
use work.accelerator_pkg.all;

entity accelerator is
    generic(
        threshold_size          :natural;                                                        -- n
        feature_index_size      :natural;                                                        -- m
        class_size              :natural;                                                        --  
        levels_in_memory        :natural;                                                        --  
        levels_in_parallel      :natural;                                                        -- d
        prefetch                :natural        
    );
        -- node_size        = threshold_size + log2(feature_index_size) + leaf_bit + valid_bit   -- q
        -- memory_size = node_size * 2 ** levels_in_memory                                       -- t
        -- nodes_in_parallel = 2 ** levels_in_parallel                                           -- p
    port(
        clk         : in  std_logic;
        features    : in  std_logic_vector(threshold_size * feature_index_size - 1 downto 0);
        class       : out std_logic_vector(Bit_lenght(class_size) downto 0)
    );
end accelerator;

architecture arch of accelerator is

    -- node_size            = valid_bit + leaf_bit   + threshold_size + log2(feature_index_size)
signal node_size            : natural := (1 + 1 + threshold_size + Bit_lenght(feature_index_size));
signal nodes_amount         : natural := (2 ** levels_in_memory);
signal node_address_size    : natural := levels_in_memory;
signal memory_size          : natural := (node_size * nodes_amount);
signal nodes_in_parallel    : natural := (2 ** (levels_in_parallel - 1));

component kernel is
    generic(
        threshold_size      :natural;
        nodes_in_parallel   :natural
    );
    port(
        feature, threshold          : in  std_logic_vector(threshold_size * nodes_in_parallel - 1 downto 0);
        next_nodes                  : out std_logic --_vector(nodes_in_parallel - 1 downto 0)
        );
end component;

component address_calculator is
    generic(levels_in_parallel  :natural;
            prefetch            :natural;
            node_address_size   :natural); -- levels_in_memory
    port(
        clk, reset      : in  std_logic;
        next_nodes      : in  std_logic; --_vector(levels_in_parallel-1 downto 0);
        node_addresses  : out std_logic_vector(node_address_size - 1 downto 0));
end component;

component memory is
    generic (node_address_size  :natural;
            node_size           :natural;
            nodes_in_parallel   :natural);
    port(
        clk, write_in   : in  std_logic; 
        -- node_addresses  : in  std_logic_vector(nodes_in_parallel * node_address_size - 1 downto 0);
        -- node_data_in    : in  std_logic_vector(nodes_in_parallel * node_size - 1 downto 0); 
        -- node_data_out   : out std_logic_vector(nodes_in_parallel * node_size - 1 downto 0)
        address0        : in  std_logic_vector(node_address_size-1 downto 0);     --, address1, address2
        data_in0        : in  std_logic_vector(node_size-1 downto 0);             --, data_in1, data_in2
        data_out0       : out std_logic_vector(node_size-1 downto 0)              --, data_out1, data_out2
    ); 
end component;

component mux_n_to_1 is
    generic(
        element_amount_bit_length  : natural;
        element_size               : natural
        );
    port(elements         : in  std_logic_vector(element_amount_bit_length * element_size - 1 downto 0);
        selector          : in  std_logic_vector(element_amount_bit_length - 1 downto 0);
        selected_element  : out std_logic_vector(element_size - 1 downto 0)
        );
end component;

signal kernel_output            : std_logic; --_vector(levels_in_parallel - 1 downto 0);
signal mux_output, threshold    : std_logic_vector(threshold_size - 1 downto 0);
signal features_selector        : std_logic_vector(feature_index_size - 1 downto 0);
signal address_to_fetch         : std_logic_vector(node_address_size-1 downto 0);
signal node_from_memory         : std_logic_vector(node_size-1 downto 0);
signal valid_bit, leaf          : std_logic;
 
begin
    AddressCalculator0 : address_calculator
        generic map(
            levels_in_parallel => levels_in_parallel,
            prefetch => prefetch,
            node_address_size => node_address_size
        )
        port map(
            clk             => clk,
            reset           => '0', -- TODO
            next_nodes      => kernel_output,
            node_addresses  => address_to_fetch
        );

    Mux : mux_n_to_1
        generic map(
        element_amount_bit_length  => feature_index_size,
        element_size               => threshold_size
        )
        port map(
            elements         => features,
            selector         => features_selector,
            selected_element => mux_output
        );
    
    Kernel0 : kernel
        generic map(
            threshold_size      => threshold_size,
            nodes_in_parallel   => nodes_in_parallel
            levels_in_parallel  => levels_in_parallel
        )
        port map(
            feature     => mux_output,
            threshold   => threshold,
            next_nodes  => kernel_output
        );

    Memory0 : memory
        generic map(
            node_address_size   => node_address_size,
            node_size           => node_size,
            nodes_in_parallel   => nodes_in_parallel
        )
        port map(
            clk             => clk,
            write_in        => '0', --TODO
            address0        => address_to_fetch,
            data_in0        => node_from_memory, --TODO
            data_out0       => node_from_memory
        );

    valid_bit           <= node_from_memory(node_size - 1);
    leaf                <= node_from_memory(node_size - 2);
    threshold           <= node_from_memory(node_size - 3 downto node_size - threshold_size - 2);
    features_selector   <= node_from_memory(feature_index_size - 1 downto 0);

    class <= "1111";
end arch;