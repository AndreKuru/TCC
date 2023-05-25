library ieee;
use ieee.std_logic_1164.all;

entity mux_n_unified_to_1 is
    generic(
        elements_amount     : natural;  -- has to be power of 2 and at least 2
        elements_size       : natural;
        selector_size       : natural   -- has to be log2(elements_amount)
    
    );
    port(
        elements    : in  std_logic_vector(elements_size * elements_amount - 1 downto 0);
        selector    : in  std_logic_vector(selector_size - 1 downto 0);
        y           : out std_logic_vector(elements_size - 1 downto 0)
    );
end mux_n_unified_to_1;

architecture arch of mux_n_unified_to_1 is

signal middle_element           : natural := elements_amount  / 2;
signal first_half_elements_end  : natural := (element_size * (middle_element)) - 1;
signal last_half_elements_start : natural := (element_size * (middle_element));
signal last_half_elements_end   : natural := (element_size * (elements_amount) - 1);

begin

        Mux_n_splited_to_1 : entity work.mux_n_unified_to_1
        generic map(
            elements_size   => elements_size,
            elements_amount => elements_amount,
            selector_size   => selector_size
        )
        port map(
            elements_a  => elements(first_half_elements_end downto 0),
            elements_b  => elements(last_half_elements_end  downto last_half_elements_start),
            selector    => selector,
            y           => y
        );

end arch;