library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;

entity adder is
    generic(n : natural);
    port(
        a, b            : in  std_logic_vector(n - 1 downto 0);
        cin             : in  std_logic := '0';
        cout, overflow  : out std_logic;
        y               : out std_logic_vector(n - 1 downto 0)
    );
end adder;

architecture arch of adder is

signal temp  : std_logic_vector(n downto 0);

begin
    temp(0) <= cin;

    Full_adder_array : for i in 0 to n - 1 generate
        Instante_full_adder : entity work.full_adder
        port map(
            a     => a(i),
            b     => b(i),
            cin   => temp(i),
            s     => y(i),
            cout  => temp(i + 1)
        );
    end generate Full_adder_array;
  
    cout <= temp(n);
    overflow <= temp(n) xor temp(n - 1);
end arch;