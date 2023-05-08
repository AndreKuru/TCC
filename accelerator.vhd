library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity accelerator is
    generic(feature_size        :natural := 64;                                                     -- n
            features_amount     :natural := 2;                                                     -- m
            class_amount        :natural := 10;                                                     --  
            levels_in_memory    :natural := 12;                                                     --  
            levels_in_parallel  :natural := 0;                                                      -- d
            prefetch            :natural := 0
    );
            -- node_size        = feature_size + log2(features_amount) + leaf_bit + valid_bit       -- q
            -- memory_size = node_size * 2 ** levels_in_memory                                      -- t
            -- nodes_in_parallel = 2 ** levels_in_parallel                                           -- p
    port(
        clk         : in  std_logic;
        features    : in  std_logic_vector(feature_size * features_amount - 1 downto 0);
        class       : out std_logic_vector(Bit_lenght(class_amount) downto 0)
    );
end accelerator;

architecture arch of accelerator is

    -- node_size            = valid_bit + leaf_bit   + feature_size + log2(features_amount)
signal node_size            : std_logic_vector(1 + 1 + feature_size + Bit_lenght(features_amount));
signal nodes_amount         : std_logic_vector(2 ** levels_in_memory);
signal memory_size          : std_logic_vector(node_size * nodes_amount);
signal nodes_in_parallel    : std_logic_vector(2 ** levels_in_parallel);

component kernel is
    generic(feature_size        :natural;
            nodes_in_parallel   :natural);
    port(
        feature, constants_to_compare : in  std_logic_vector(feature_size * nodes_in_parallel - 1 downto 0);
        next_nodes                  : out std_logic_vector(levels_in_parallel downto 0));
end component;

component address_calculator is
    generic(levels_in_parallel  :natural := 0;
            prefetch            :natural := 0;
            node_address_size   :natural); -- levels_in_memory
    port(
        clk, reset  : in  std_logic;
        next_nodes  : in  std_logic_vector(levels_in_parallel downto 0);
        node_addresses : out std_logic_vector(node_address_size downto 0));
end component;

component memory is
    generic (node_address_size  :natural;
            node_size           :natural;
            nodes_in_parallel   :natural);
    port(
        clk, write_in : in  std_logic; 
        node_addresses  : in  std_logic_vector(nodes_in_parallel * node_address_size - 1 downto 0);
        node_data_in    : in  std_logic_vector(nodes_in_parallel * node_size - 1 downto 0); 
        node_data_out   : out std_logic_vector(nodes_in_parallel * node_size - 1 downto 0)
    ); 
end component;

component mux2to1 is --TODO: implement muxNto1
    generic(n:natural);
    port(a, b     : in  std_logic_vector(n-1 downto 0);
        selector  : in  std_logic;
        y         : out std_logic_vector(n-1 downto 0));
end component;

signal kernel_output                    : std_logic_vector(levels_in_parallel downto 0);
signal mux_ouput, constant_from_memory  : std_logic_vector(feature_size - 1 downto 0);
signal features_selector                : std_logic_vector(0 downto 0); -- 2 ** levels_in_parallel
 
begin
    AddressCalculator : address_calculator
        generic map(
            levels_in_parallel => levels_in_parallel,
            prefetch => prefetch,
            node_address_size => node_address_size
        )
        port map(
            clk                 => clk,
            reset               => reset,
            kernel_output       => next_nodes,
            address_to_fetch    => node_addresses
        );

    Mux : mux2to1
        generic map(feature_size => n)
        port map(
            features(2 * feature_size - 1 downto feature_size)  => a,
            features(feature_size - 1 downto 0)                 => b,
            features_selector                                   => selector,
            mux_output                                          => y
        );
    
    Kernel : kernel
        generic map(
            feature_size        => feature_size,
            nodes_in_parallel   => nodes_in_parallel
        )
        port map(
            mux_output              => feature,
            constants_from_memory   => constants_to_compare,
            kernel_output           => next_nodes
        );

    Memory : memory
        generic map(
            node_address_size   => node_address_size,
            node_size           => node_size,
            nodes_in_parallel   => nodes_in_parallel
        )
        port map(
            clk                     => clk,
            -- write_in             => write_in,
            address_to_fetch        => node_addresses,
            -- node_data_in         => node_data_in,
            constants_from_memory   => node_data_out,
            features_selector       => feature_indexes
        );
end arch;