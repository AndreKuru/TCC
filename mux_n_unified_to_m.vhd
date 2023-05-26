library ieee;
use ieee.std_logic_1164.all;

entity mux_n_unified_to_m is
    generic(
        elements_amount     : natural;  -- has to be power of 2 and at least 2
        elements_size       : natural;
        selectors_amount    : natural;
        selectors_size       : natural   -- has to be log2(elements_amount)
    
    );
    port(
        elements                : in  std_logic_vector(elements_size * elements_amount - 1 downto 0);
        selectors               : in  std_logic_vector(selectors_size * selectors_amount - 1 downto 0);
        y                       : out std_logic_vector(selectors_amount * elements_size - 1 downto 0)
    );
end mux_n_unified_to_m;

architecture arch of mux_n_unified_to_m is

constant middle_element           : natural := elements_amount  / 2;
constant first_half_elements_end  : natural := (elements_size * (middle_element)) - 1;
constant last_half_elements_start : natural := (elements_size * (middle_element));
constant last_half_elements_end   : natural := (elements_size * (elements_amount) - 1);

signal first_half_elements, last_half_elements   : std_logic_vector(elements_size * (elements_amount / 2) - 1 downto 0);

begin

    first_half_elements <= elements(first_half_elements_end downto 0);
    last_half_elements  <= elements(last_half_elements_end  downto last_half_elements_start);

    Mux_n_splited_to_1 : entity work.mux_n_to_m
    generic map(
        elements_size       => elements_size,
        elements_amount     => elements_amount,
        selectors_amount    => selectors_amount,
        selectors_size       => selectors_size
    )
    port map(
        elements_a  => first_half_elements,
        elements_b  => last_half_elements,
        selectors    => selectors,
        y           => y
    );

end arch;