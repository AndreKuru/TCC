library ieee;
use ieee.std_logic_1164.all;

entity mux_n_bits_to_1_bit is
    generic(
        elements_amount  : natural; --n and has to be (power of 2) - 2 and greater or equal to 2
        selectors_amount : natural  --has to be log2(n + 2)
    );
    port(
        elements_a, elements_b  : in  std_logic_vector(elements_amount / 2 - 1 downto 0);
        selector                : in  std_logic;
        selectors_output        : out std_logic_vector(selectors_amount - 1 downto 0)
    );
end mux_n_bits_to_1_bit;

architecture arch of mux_n_bits_to_1_bit is

constant half_elements_amount : natural := elements_amount / 2;
constant higher_bit_element   : natural := half_elements_amount - 1;
constant middle_element       : natural := (half_elements_amount - 1)  / 2;

signal a_mux_output, b_mux_output, final_mux_output : std_logic_vector(selectors_amount - 2 downto 0);

begin
    
    Single_mux : if elements_amount / 2 < 3 generate

        Single_mux_2_to_1_Istance : entity work.mux_2_to_1
        generic map(n => 1)
        port map(
            a           =>  elements_a,
            b           =>  elements_b,
            selector    =>  selector,
            y           =>  final_mux_output
        );
    
    end generate Single_mux;

    Initials_mux : if elements_amount / 2 = 3 generate

        A_mux_2_to_1_Istance : entity work.mux_2_to_1
        generic map(n => 1)
        port map(
            a(0)        =>  elements_a(2),
            b(0)        =>  elements_a(0),
            selector    =>  elements_a(1), --middle_element
            y(0)        =>  a_mux_output(1)
        );

        B_mux_2_to_1_Istance : entity work.mux_2_to_1
        generic map(n => 1)
        port map(
            a(0)        =>  elements_b(2),
            b(0)        =>  elements_b(0),
            selector    =>  elements_b(1), --middle_element
            y(0)        =>  b_mux_output(1)
        );

        a_mux_output(0) <= elements_a(1); --middle_element
        b_mux_output(0) <= elements_b(1); --middle_element

    end generate Initials_mux;
    
    Intermediares_mux : if elements_amount / 2 > 3 generate

    signal first_elements_a, first_elements_b, last_elements_a, last_elements_b : std_logic_vector(elements_amount / 4 - 1 downto 0);
    signal first_selector, last_selector                                        : std_logic;

    begin
        first_elements_a    <= elements_a(middle_element - 1 downto 0);
        first_elements_b    <= elements_a(higher_bit_element downto middle_element + 1);
        last_elements_a     <= elements_b(middle_element - 1 downto 0);
        last_elements_b     <= elements_b(higher_bit_element downto middle_element + 1);

        first_selector      <= elements_a(middle_element);
        last_selector       <= elements_b(middle_element);

        A_mux_n_bits_to_1_bit_Istance : entity work.mux_n_bits_to_1_bit
        generic map(
            elements_amount  => elements_amount / 2 - 1, -- a:n/2 + b:n/2 + selector:1
            selectors_amount => selectors_amount - 1
        )
        port map(
            elements_a          => first_elements_a,
            elements_b          => first_elements_b,
            selector            => first_selector,
            selectors_output    => a_mux_output
        );

        B_mux_n_bits_to_1_bit_Istance : entity work.mux_n_bits_to_1_bit
        generic map(
            elements_amount  => elements_amount / 2 - 1, -- a:n/2 + b:n/2 + selector:1
            selectors_amount => selectors_amount - 1
        )
        port map(
            elements_a          => last_elements_a,
            elements_b          => last_elements_b,
            selector            => last_selector,
            selectors_output    => b_mux_output
        );

    end generate Intermediares_mux;

    Multiple_mux : if elements_amount / 2 >= 3 generate

        Final_mux : entity work.mux_2_to_1
        generic map(n => selectors_amount - 1)
        port map(
            a           => a_mux_output,
            b           => b_mux_output,
            selector    => selector,
            y           => final_mux_output
        );

    end generate Multiple_mux;

    selectors_output <= final_mux_output & selector;

end arch;