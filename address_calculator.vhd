library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity address_calculator is
    generic(levels_in_parallel  :natural := 0;
            prefetch            :natural := 0;
            node_address_size   :natural); -- levels_in_memory
    port(
        clk, reset  : in  std_logic;
        next_nodes  : in  std_logic_vector(levels_in_parallel downto 0);
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
        clk, next_node_left           : in  std_logic;
        node_address_in               : in  std_logic_vector(node_address_size downto 0);
        adder1_output, adder2_output  : out std_logic_vector(node_address_size downto 0));
end component;

component mux2to1 is
    generic(n:natural);
    port(a, b     : in  std_logic_vector(n-1 downto 0);
        selector  : in  std_logic;
        y         : out std_logic_vector(n-1 downto 0)
        );
end component;
	
signal index_output, shifter_output, single_address1_output, single_address2_output, mux_output : std_logic_vector(n-1 downto 0);

begin
    Index : registrator
        generic map(node_address_size => n)
        port map(
          clk         => clk,
          load        => load,
          mux_output   => d,
          index_output => q
        );

    Single_address_calculator : single_address_calculator
        generic map(node_address_size => node_address_size)
        port map(
          clk                     => clk,
          next_nodes(0)           => next_node_left,
          index_output            => node_address_in,
          single_address1_output  => adder1_output,
          single_address2_output  => adder2_output
        );

    MuxFromAdders : mux2to1
        generic map(node_address_size => n)
        port map(
          single_adder1_output  => a,
          single_adder2_output  => b,
          next_node_left        => selector,
          mux_output            => y
        );

    node_addresses <= index_output;

end arch;