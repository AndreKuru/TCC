library ieee;
use ieee.std_logic_1164.all;

entity address_calculator is
    generic(levels_in_parallel  :natural; -- := 1;
            prefetch            :natural; -- := 0;
            node_address_size   :natural); -- levels_in_memory
    port(
        clk, reset  : in  std_logic;
        next_nodes  : in  std_logic; --_vector(levels_in_parallel - 1 downto 0);
        node_addresses : out std_logic_vector(node_address_size downto 0));
end address_calculator;

architecture arch of address_calculator is

component registrator is
    generic(n: natural);
    port(clk, load  : in  std_logic;
        d           : in  std_logic_vector(n - 1 downto 0);
        q           : out std_logic_vector(n - 1 downto 0));
end component;

component single_address_calculator is
    generic(node_address_size   :natural); -- levels_in_memory
    port(
        clk, next_node_left           : in  std_logic;
        node_address_in               : in  std_logic_vector(node_address_size downto 0);
        adder1_output, adder2_output  : out std_logic_vector(node_address_size downto 0));
end component;

component mux_2_to_1 is
    generic(n:natural);
    port(a, b     : in  std_logic_vector(n - 1 downto 0);
        selector  : in  std_logic;
        y         : out std_logic_vector(n - 1 downto 0)
        );
end component;
	
signal index_output, shifter_output, single_address1_output, single_address2_output, mux_output : std_logic_vector(node_address_size - 1 downto 0);

begin
    Index_registrator : registrator
        generic map(n => node_address_size)
        port map(
          clk   => clk,
          load  => '1', --TODO
          d     => mux_output,
          q     => index_output
        );

    Single_address_calculator0 : single_address_calculator
        generic map(node_address_size => node_address_size)
        port map(
            clk             => clk,
            next_node_left  => next_nodes, --(0),
            node_address_in => index_output,
            adder1_output   => single_address1_output,
            adder2_output   => single_address2_output
        );

    Mux_from_adders : mux_2_to_1
        generic map(n => node_address_size)
        port map(
            a           => single_address1_output,
            b           => single_address2_output,
            selector    => next_nodes, --(0),
            y           => mux_output
        );

    node_addresses <= index_output;

end arch;