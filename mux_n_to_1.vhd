library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all; --TODO

entity mux_n_to_1 is
    generic(
        element_amount_bit_length  : natural;
        element_size               : natural
    );
    port(
        elements         : in  std_logic_vector(element_amount_bit_length * element_size - 1 downto 0);
        selector          : in  std_logic_vector(element_amount_bit_length - 1 downto 0);
        selected_element  : out std_logic_vector(element_size - 1 downto 0)
    );
end mux_n_to_1;

architecture arch of mux_n_to_1 is
signal selector_natural : natural;
begin
    -- selector_natual <= to_integer(unsigned(selector)); --TODO
    selector_natural <= 0;
    selected_element <= elements(element_size * (selector_natural + 1) - 1 downto element_size * selector_natural);
end arch;