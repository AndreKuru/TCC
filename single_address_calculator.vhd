library ieee;
use ieee.std_logic_1164.all;

entity single_address_calculator is
    generic(node_address_size   :natural); -- levels_in_memory
    port(
        clk, next_node_left           : in  std_logic;
        node_address_in               : in  std_logic_vector(node_address_size downto 0);
        adder1_output, adder2_output  : out std_logic_vector(node_address_size downto 0)
    );
end single_address_calculator;

architecture arch of single_address_calculator is

component shiftBy1 is
    generic(n:natural);
    port(
        x   : in  std_logic_vector(n - 1 downto 0);
        y   : out std_logic_vector(n - 1 downto 0)
    );
end component;

component adder is
    generic(n:natural);
    port(
        a, b    : in  std_logic_vector(n - 1 downto 0);
        cout    : out std_logic;
        y       : out std_logic_vector(n - 1 downto 0)
    );
end component;

signal shifter_output, constant1, constant2 : std_logic_vector(node_address_size - 1 downto 0);

begin

    constant1 <= (0 => '1', others => '0');
    constant1 <= (1 => '1', others => '0');

    Shiffter : shiftBy1
        generic map(n => node_address_size)
        port map(
            x => node_address_in,
            y => shifter_output 
        );

    Adder1 : adder
        generic map(n => node_address_size)
        port map(
            a => constant1,
            b => shifter_output,
            y => adder1_output
        );

    Adder2 : adder
        generic map(n => node_address_size)
        port map(
            a => shifter_output,
            b => constant2,
            y => adder2_output
        );

end arch;