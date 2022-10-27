library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tree_comparator is
    generic(n : natural);
    port(isLesserOrEqual            : in  std_logic;
        feature, constantFromMemory : in  std_logic_vector(n-1 downto 0);
        isNextLeft                  : out std_logic);
        --                          : out std_logic_vector(n-1 downto 0));
end tree_comparator;

architecture arch of tree_comparator is

component subtractor is
  generic(n:natural);
  port(a, b : in  std_logic_vector(n-1 downto 0);
      cout  : out std_logic;
      y     : out std_logic_vector(n-1 downto 0));
end component;

component mux2to1 is
  generic(n:natural);
  port(a, b     : in  std_logic_vector(n-1 downto 0);
      selector  : in  std_logic;
      y         : out std_logic_vector(n-1 downto 0));
end component;
 
component isZero is
  generic(n:natural);
  port(x  : in  std_logic_vector(n-1 downto 0);
      y   : out std_logic_vector(n-1 downto 0));
end component;

signal subtractorOoutput : std_logic_vetor(n-1 downto 0);
signal isEqual, isLesser : std_logic;
	
begin
    Subtractor : subtractor
      generic map(n => n)
      port map(
        feature             => a,
        constantFromMemory  => b,
        subtractorOutput    => y
        );

    isLesser <= subtractorOutput(n);

    IsZero : isZero
      generic map(n => n)
      port map(
        subtractorOutput  => x,
        isEqual           => y
      );

    Mux : mux2to1
      generic map(n => n)
      port map(
        isLesser              => a,
        (isLesser or isEqual) => b,
        isLesserOrEqual       => selector,
        isNextLeft            => y
      );

end arch;
