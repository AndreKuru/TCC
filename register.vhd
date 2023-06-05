library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;

entity register is
    generic(data_size : natural);
    port(
        clk, reset, load    : in  std_logic;
        data_in             : in  std_logic_vector(data_size - 1 downto 0);
        data_out            : out std_logic_vector(data_size - 1 downto 0)
    );
  end register;

architecture arch of register is
begin
    process(clk, load, reset)
    begin
        if reset = '1' then
            data_out <= (others => '0');
        elsif rising_edge(clk) and load = '1' then
            data_out <= data_in;
        end if;
    end process;
end arch;