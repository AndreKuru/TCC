library ieee;
use ieee.std_logic_1164.all;

entity mux_n_to_m is
    generic(
        elements_amount     : natural;  -- has to be power of 2 and at least 2
        elements_size       : natural;
        selectors_amount    : natural;
        selectors_size      : natural   -- has to be log2(elements_amount)
    
    );
    port(
        elements_a, elements_b  : in  std_logic_vector(elements_size * (elements_amount / 2) - 1 downto 0);
        selectors               : in  std_logic_vector(selectors_size * selectors_amount - 1 downto 0);
        y                       : out std_logic_vector(selectors_amount * elements_size - 1 downto 0)
    );
end mux_n_to_m;

architecture arch of mux_n_to_m is

begin

    M_mux : for i in 0 to selectors_amount - 1 generate
        N_mux : entity work.mux_n_to_1
        generic map(
            elements_amount => elements_amount,
            elements_size   => elements_size,
            selector_size   =>  selectors_size
        )
        port map(
            elements_a  => elements_a,
            elements_b  => elements_b,
            selector    => selector(selectors_size * (i + 1) - 1 downto selectors_size * i),
            y           => y(elements_size * (i + 1) - 1 downto elements_size * i)
        );
    end generate M_mux;

end arch;