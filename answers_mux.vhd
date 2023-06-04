library ieee;
use ieee.std_logic_1164.all;

entity answers_mux is
    generic(
        level_to_compute    :natural -- first level is 0 and this generic must be at least 1
    );
    port(
        previous_answers    : in  std_logic_vector(2**level_to_compute - 2 downto 0);
        answers_to_select   : in  std_logic_vector(2**level_to_compute - 1 downto 0);
        answers_selected    : out std_logic_vector(level_to_compute downto 0)
    );
end answers_mux;

architecture arch of answers_mux is
signal answer_selected : std_logic;

begin

    Initials_level_to_compute : if level_to_compute = 1 generate
        First_mux : entity work.mux_2_to_1
            generic map(n => 1)
            port map(
                a(0)        => answers_to_select(0),
                b(0)        => answers_to_select(1),
                selector    => previous_answers(0),
                y(0)        => answer_selected
            );

    answers_selected <= previous_answers & answer_selected;
    end generate Initials_level_to_compute;

    Several_levels_to_compute : if level_to_compute > 1 generate
    constant last_level_previous_answers_amount : natural := 2**(level_to_compute - 1);
    constant last_level_previous_answers_start  : natural := last_level_previous_answers_amount - 1;
    constant last_level_previous_answers_end    : natural := last_level_previous_answers_start + last_level_previous_answers_amount - 1;

    signal last_level_previous_answers  : std_logic_vector(last_level_previous_answers_amount - 1 downto 0);
    signal initials_previous_answers    : std_logic_vector(last_level_previous_answers_amount - 2 downto 0);
    signal previous_answers_selected    : std_logic_vector(level_to_compute - 1 downto 0);
    begin
        last_level_previous_answers <= previous_answers(last_level_previous_answers_end downto last_level_previous_answers_start);
        initials_previous_answers   <= previous_answers(last_level_previous_answers_start - 1 downto 0);

        Previous_mux : entity work.answers_mux
            generic map(level_to_compute => level_to_compute - 1)
            port map(
                previous_answers    => initials_previous_answers,
                answers_to_select   => last_level_previous_answers,
                answers_selected    => previous_answers_selected
            );
        
        Current_mux : entity work.mux_n_unified_to_1
            generic map(
                elements_amount     => 2**level_to_compute,
                elements_size       => 1,
                selector_size       => level_to_compute
            )
            port map(
                elements    => answers_to_select,
                selector    => previous_answers_selected,
                y(0)        => answer_selected
            );

    answers_selected <= previous_answers_selected & answer_selected;
    end generate Several_levels_to_compute;


end arch;