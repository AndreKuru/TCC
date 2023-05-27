library ieee;
use ieee.std_logic_1164.all;

entity or_bit is
    port(
        a, b    : in  std_logic;
        y       : out std_logic
    );
  end or_bit;

architecture arch of or_bit is
begin
    process(a, b)
    begin
        if a = '1' or b = '1' then
            y <= '1';
        else
            y <= '0';
        end if;
    end process;
end arch;