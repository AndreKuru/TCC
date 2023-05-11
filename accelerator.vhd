library ieee;
use ieee.std_logic_1164.all;
use work.accelerator_pkg.all;

entity accelerator is
    generic(threshold_size          :natural;                                                        -- n
            feature_address_size    :natural;                                                        -- m
            class_amount            :natural;                                                        --  
            levels_in_memory        :natural;                                                        --  
            levels_in_parallel      :natural;                                                        -- d
            prefetch                :natural        
    );
            -- node_size        = threshold_size + log2(feature_address_size) + leaf_bit + valid_bit -- q
            -- memory_size = node_size * 2 ** levels_in_memory                                       -- t
            -- nodes_in_parallel = 2 ** levels_in_parallel                                           -- p
    port(
        clk         : in  std_logic;
        features    : in  std_logic_vector(threshold_size * feature_address_size - 1 downto 0);
        class       : out std_logic_vector(Bit_lenght(class_amount) downto 0)
    );
end accelerator;

architecture arch of accelerator is

    -- node_size            = valid_bit + leaf_bit   + threshold_size + log2(feature_address_size)
signal node_size            : natural := (1 + 1 + threshold_size + Bit_lenght(feature_address_size));
signal nodes_amount         : natural := (2 ** levels_in_memory);
signal node_address_size    : natural := levels_in_memory;
signal memory_size          : natural := (node_size * nodes_amount);
signal nodes_in_parallel    : natural := (2 ** (levels_in_parallel - 1));

component kernel is
    generic(threshold_size      :natural;
            nodes_in_parallel   :natural);
    port(
        feature, threshold          : in  std_logic_vector(threshold_size * nodes_in_parallel - 1 downto 0);
        next_nodes                  : out std_logic_vector(levels_in_parallel - 1 downto 0));
end component;

component address_calculator is
    generic(levels_in_parallel  :natural;
            prefetch            :natural;
            node_address_size   :natural); -- levels_in_memory
    port(
        clk, reset  : in  std_logic;
        next_nodes  : in  std_logic_vector(levels_in_parallel-1 downto 0);
        node_addresses : out std_logic_vector(node_address_size downto 0));
end component;

component memory is
    generic (node_address_size  :natural;
            node_size           :natural;
            nodes_in_parallel   :natural);
    port(
        clk, write_in : in  std_logic; 
        -- node_addresses  : in  std_logic_vector(nodes_in_parallel * node_address_size - 1 downto 0);
        -- node_data_in    : in  std_logic_vector(nodes_in_parallel * node_size - 1 downto 0); 
        -- node_data_out   : out std_logic_vector(nodes_in_parallel * node_size - 1 downto 0)
        address0, address1, address2          : in  std_logic_vector(node_address_size-1 downto 0);     
        data_in0, data_in1, data_in2          : in  std_logic_vector(node_size-1 downto 0);
        data_out0, data_out1, data_out2       : out std_logic_vector(node_size-1 downto 0)
    ); 
end component;

component mux2to1 is --TODO: implement muxNto1
    generic(n:natural);
    port(a, b     : in  std_logic_vector(n-1 downto 0);
        selector  : in  std_logic;
        y         : out std_logic_vector(n-1 downto 0));
end component;

signal kernel_output         : std_logic_vector(levels_in_parallel - 1 downto 0);
signal mux_ouput, threshold  : std_logic_vector(threshold_size - 1 downto 0);
signal features_selector     : std_logic_vector(0 downto 0); -- 2 ** (levels_in_parallel -1)
 
begin
    AddressCalculator0 : address_calculator
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
        generic map(threshold_size => n)
        port map(
            features(2 * threshold_size - 1 downto threshold_size)  => a,
            features(threshold_size - 1 downto 0)                   => b,
            features_selector                                       => selector,
            mux_output                                              => y
        );
    
    Kernel0 : kernel
        generic map(
            threshold_size        => threshold_size,
            nodes_in_parallel   => nodes_in_parallel
        )
        port map(
            mux_output              => feature,
            threshold   => threshold,
            kernel_output           => next_nodes
        );

    Memory0 : memory
        generic map(
            node_address_size   => node_address_size,
            node_size           => node_size,
            nodes_in_parallel   => nodes_in_parallel
        )
        port map(
            clk                     => clk,
            -- write_in             => write_in,
            address_to_fetch        => address0,
            -- node_data_in         => node_data_in,
            node_from_memory        => data_out0
        );

    valid_bit <= node_from_memory(node_size - 1);
    leaf <= node_from_memory(node_size - 2);
    threshold <= node_from_memory(node_size - 3 downto node_size - threshold_size - 2);
    features_selector <= node_from_memory(feature_address_size downto 0);

    class <= "1111";
end arch;