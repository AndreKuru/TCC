library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity address_calculator is
--   generic(n : natural);
--   port(clk, reset, isNextLeft   : in  std_logic;
--       --                        : in  std_logic_vector(n-1 downto 0);
--       --                        : out std_logic;
--       adress0, adress1, adress2 : out std_logic_vector(n-1 downto 0));
-- end address_calculator;
    generic(levels_in_parallel  :natural = 0;
            node_address_size   :natural); -- levels_in_memory
    port(
        clk, reset  : in  std_logic;
        next_nodes  : in  std_logic_vector(levels_in_parallel dowto 0);
        node_addresses : out std_logic_vector(node_address_size downto 0));
end address_calculator;

architecture arch of address_calculator is

component registrator is
  generic(n: natural);
  port(clk, load  : in  std_logic;
      d           : in  std_logic_vector(n-1 downto 0);
      q           : out std_logic_vector(n-1 downto 0));
  end component;

component single_address_calculator is
    generic(node_address_size   :natural); -- levels_in_memory
    port(
        clk, next_node_left : in  std_logic;
        node_address_in     : in  std_logic_vector(node_address_size downto 0);
        node_address_out    : out std_logic_vector(node_address_size downto 0));
end component;

signal index_output, shifter_output, single_address_calculator_output : std_logic_vector(n-1 downto 0);

begin
    Index : registrator
      generic map(node_address_size => n)
      port map(
        clk         => clk,
        load        => load,
        single_address_calculator_output   => d,
        index_output => q
      );

    Single_address_calculator : single_address_calculator
      generic map(node_address_size => node_address_size)
      port map(
        clk                               => clk,
        next_nodes(0)                     => next_node_left,
        index_output                      => node_address_in,
        single_address_calculator_output  => node_address_out
      );

end arch;