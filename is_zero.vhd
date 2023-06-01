library ieee;
use ieee.std_logic_1164.all;


entity is_zero is
    generic(size : natural);
    port(
        number    : in  std_logic_vector(size - 1 downto 0);
        is_zero   : out std_logic
    );
end is_zero;

architecture arch of is_zero is
constant zero : std_logic_vector(size - 1 downto 0) := (others => '0');
begin

    is_zero <= '1' when number = zero else
               '0';

end arch;