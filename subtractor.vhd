library ieee;
use ieee.std_logic_1164.all;

entity subtractor is
    generic(size : natural);
    port(
        operand0, operand1  : in  std_logic_vector(size - 1 downto 0);
        cout, overflow      : out std_logic;
        y                   : out std_logic_vector(size - 1 downto 0)
    );
end subtractor;

architecture arch of subtractor is

signal not_operand1  : std_logic_vector(size - 1  downto 0);

begin
    not_operand1 <= not operand1;

    Adder0: entity work.adder
    generic map(n => size)
    port map(
        a           => operand0,
        b           => not_operand1,
        cin         => '1',
        cout        => cout,
        overflow    => overflow,
        y           => y
    );

end arch;