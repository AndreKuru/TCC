library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity accelerator is
    generic(feature_size        :natural := 64;                                                     -- n
            features_amount     :natural := 10;                                                     -- m
            class_amount        :natural := 10;                                                     --  
            levels_in_memory    :natural := 12;                                                     --  
            levels_in_parallel  :natural := 0);                                                     -- d
            -- node_size        = feature_size + log2(features_amount) + leaf_bit + valid_bit       -- q
            -- memory_size = node_size * 2 ** levels_in_memory                                      -- t
            -- nodes_in_parallel = 2 ** levels_in_parallel                                           -- p
    port(
        features    : in  std_logic_vector(feature_size * features_amount - 1 downto 0);
        class       : out std_logic_vector(Bit_lenght(class_amount) downto 0));
end accelerator;

architecture arch of accelerator is

    -- node_size            = valid_bit + leaf_bit + feature_size + log2(features_amount)
signal node_size            = 1 + 1                + feature_size + Bit_lenght(features_amount)
signal nodes_amount         = 2 ** levels_in_memory
signal memory_size          = node_size * nodes_amount
signal nodes_in_parallel    = 2 ** levels_in_parallel

component kernel is
    generic(feature_size        :natural;
            nodes_in_parallel   :natural);
    port(
        feature, constantFromMemory : in  std_logic_vector(feature_size * nodes_in_parallel - 1 downto 0);
        next_nodes                  : out std_logic_vector(levels_in_parallel downto 0));
end component;

component address_calculator is
    generic(levels_in_parallel  :natural;
            node_address_size   :natural); -- levels_in_memory
    port(
        clk, reset  : in  std_logic;
        next_nodes  : in  std_logic_vector(levels_in_parallel dowto 0);
        node_addresses : out std_logic_vector(node_address_size downto 0));
end component;

component memory is
    generic (node_address_size  :natural;
            node_size           :natural;
            nodes_in_parallel   :natural);
    port(
        clock, write_in : in  std_logic; 
        node_addresses  : in  std_logic_vector(nodes_in_parallel * node_address_size - 1 downto 0);
        node_data_in    : in  std_logic_vector(nodes_in_parallel * node_size - 1 downto 0); 
        node_data_out   : out std_logic_vector(nodes_in_parallel * node_size - 1 downto 0);
    ); 
end component;
 
begin
  AdressCalculator : address_calculator
    generic map()
    port map(
    );
  
  Kernel : kernel
    generic map()
    port map(
    );

  Memory : memory
    generic map()
    port map(
    );

end arch;