library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity address_calculator is
  generic(n : natural);
  port(clk, reset, isNextLeft   : in  std_logic;
      --                        : in  std_logic_vector(n-1 downto 0);
      --                        : out std_logic;
      adress0, adress1, adress2 : out std_logic_vector(n-1 downto 0));
end address_calculator;

architecture arch of address_calculator is

component registrator is
  generic(n: natural);
  port(clk, load  : in  std_logic
      d           : in  std_logic_vector(n-1 downto 0);
      q           : out std_logic_vector(n-1 downto 0));
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

component shiftBy1 is
  generic(n:natural);
  port(x : in  std_logic_vector(n-1 downto 0);
      y  : out std_logic_vector(n-1 downto 0));
end component;

signal indexOutput, shiffterOutput, adder1Output, adder2Output, muxOutput : std_logic_vector(n-1 downto 0)

begin
    Index : registrator
      generic map(n => n)
      port map(
        clk         => clk,
        load        => load,
        muxOutput   => d,
        indexOutput => q
      );

    Shiffter : shiftBy1
      generic map(n => n)
      port map(
        indexOutput     => x,
        shiffterOutput  => y
      );

    Adder1 : adder
      generic map(n => n)
      port map(
        1             => a,
        shiffterOuput => b,
        adder1Output  => y
      );

    Adder2 : adder
      generic map(n => n)
      port map(
        shiffterOuput   => a,
        2               => b,
        adder2Output    => y
      );

    MuxFromAdders : mux2to1
      generic map(n => n)
      port map(
        adder1Output  => a
        adder2Output  => b
        isNextLeft    => selector,
        muxOutput     => y
      );

      address0 <= indexOutput;
      address1 <= adder1Output;
      address2 <= adder2Output;

end arch;