library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity single_address_calculator is
    generic(node_address_size   :natural); -- levels_in_memory
    port(
        clk, next_node_left : in  std_logic;
        node_address_in     : in  std_logic_vector(node_address_size downto 0);
        node_address_out    : out std_logic_vector(node_address_size downto 0));
end single_address_calculator;

architecture arch of single_address_calculator is

component shiftBy1 is
  generic(n:natural);
  port(x : in  std_logic_vector(n-1 downto 0);
      y  : out std_logic_vector(n-1 downto 0));
end component;

component mux2to1 is
  generic(n:natural);
  port(a, b     : in  std_logic_vector(n-1 downto 0);
      selector  : in  std_logic;
      y         : out std_logic_vector(n-1 downto 0));
end component;
	
component adder is
generic(n:natural);
port(a, b : in  std_logic_vector(n-1 downto 0);
	  cout  : out std_logic;
    y     : out std_logic_vector(n-1 downto 0));
end component;

signal shifter_output, adder1_output, adder2_output : std_logic_vector(n-1 downto 0);

begin
    Shiffter : shiftBy1
      generic map(node_address_size => n)
      port map(
        node_address_in => x,
        shifter_output  => y
      );

    Adder1 : adder
      generic map(node_address_size => n)
      port map(
        to_unsigned(1, a'lenght)  => a,
        shifter_output             => b,
        adder1_output              => y
      );

    Adder2 : adder
      generic map(node_address_size => n)
      port map(
        shifter_output             => a,
        to_unsigned(2, b'lenght)  => b,
        adder2_output              => y
      );

    MuxFromAdders : mux2to1
      generic map(node_address_size => n)
      port map(
        adder1_output        => a,
        adder2_output        => b,
        next_node_left      => selector,
        address_node_out    => y
      );

end arch;