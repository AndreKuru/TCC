library ieee;
use ieee.std_logic_1164.all;

entity mux_n_to_1 is
    generic(
        elements_amount     : natural;  -- has to be power of 2 and at least 2
        elements_size       : natural;
        selector_size       : natural   -- has to be log2(elements_amount)
    
    );
    port(
        elements_a, elements_b  : in  std_logic_vector(elements_size * (elements_amount / 2) - 1 downto 0);
        selector                : in  std_logic_vector(selector_size - 1 downto 0);
        y                       : out std_logic_vector(elements_size - 1 downto 0)
    );
end mux_n_to_1;

architecture arch of mux_n_to_1 is

signal half_elements_amount : natural := elements_amount / 2;

signal middle_element           : natural := half_elements_amount  / 2;
signal first_half_elements_end  : natural := (elements_size * (middle_element)) - 1;
signal last_half_elements_start : natural := (elements_size * (middle_element));
signal last_half_elements_end   : natural := (elements_size * (half_elements_amount) - 1);

signal first_half_mux_output, last_half_mux_output  : std_logic_vector(elements_size - 1 downto 0);

begin

    Initial_mux : if elements_amount <= 2 generate
        Initial_mux_instance : entity work.mux_2_to_1
        generic map(n => elements_size)
        port map(
            a           => elements_a,
            b           => elements_b,
            selector    => selector(0),
            y           => y
        );
    end generate Initial_mux;

    Following_muxes : if elements_amount > 2 generate

    signal first_elements_a, first_elements_b, last_elements_a, last_elements_b   : std_logic_vector(elements_size * elements_amount - 1 downto 0);

    begin
    first_elements_a    <= elements_a(first_half_elements_end downto 0);
    first_elements_b    <= elements_a(last_half_elements_end downto last_half_elements_start);
    last_elements_a     <= elements_b(first_half_elements_end downto 0);
    last_elements_b     <= elements_b(last_half_elements_end downto last_half_elements_start);



        First_half_mux : entity work.mux_n_to_1
        generic map(
            elements_size   => elements_size,
            elements_amount => elements_amount / 2,
            selector_size   => selector_size - 1
        )
        port map(
            elements_a  => first_elements_a,
            elements_b  => first_elements_b,
            selector    => selector(selector_size - 2 downto 0),
            y           => first_half_mux_output
        );

        Last_half_mux : entity work.mux_n_to_1
        generic map(
            elements_size   => elements_size,
            elements_amount => elements_amount / 2,
            selector_size   => selector_size - 1
        )
        port map(
            elements_a  => last_elements_a,
            elements_b  => last_elements_b,
            selector    => selector(selector_size - 2 downto 0),
            y           => last_half_mux_output
        );

        Final_mux : entity work.mux_2_to_1
        generic map(n => elements_size)
        port map(
            a           => first_half_mux_output,
            b           => last_half_mux_output,
            selector    => selector(selector_size - 1),
            y           => y
        );

    end generate Following_muxes;

end arch;