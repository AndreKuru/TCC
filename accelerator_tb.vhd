library ieee;
use ieee.std_logic_1164.all;
use work.accelerator_pkg.all;

entity accelerator_tb is
    generic(
        threshold_size              : natural := THRESHOLD_SIZE;
        features_amount             : natural := FEATURES_AMOUNT;
        features_index_size         : natural := FEATURE_INDEX_SIZE;
        class_size                  : natural := class_size;
        levels_in_memory            : natural := LEVELS_IN_MEMORY;
        levels_in_parallel          : natural := LEVELS_IN_PARALLEL;
        prefetch                    : natural := PREFETCH;
        features_amount_remaining   : natural := FEATURES_AMOUNT_REMAINING
    );
end accelerator_tb;

architecture tb of accelerator_tb is

signal clk, reset   : std_logic;
signal features     : std_logic_vector(threshold_size * features_amount - 1 downto 0); -- inputs
signal class        : std_logic_vector(Bit_lenght(class_size) downto 0); -- outputs

constant clkp : time := 5 ns;

begin
    UUT: entity work.accelerator 
        generic map(
            threshold_size              => threshold_size, 
            features_amount             => features_amount,
            features_index_size         => features_index_size,
            class_size                  => class_size,
            levels_in_memory            => levels_in_memory,
            levels_in_parallel          => levels_in_parallel,
            prefetch                    => prefetch,
            features_amount_remaining   => features_amount_remaining
        )
        port map(
            clk         => clk,
            reset       => reset,
            features    => features,
            class       => class
        );

    Inialization : process
    begin
        reset <= '1'; 
        wait for 5 * clkp;
        reset <= '0';
        wait;
    end process;

    Clk_simulation : process
    begin
        clk <= '0'; wait for clkp/2;
        clk <= '1'; wait for clkp/2;
    end process;

    features    <= (0 => '1', others => '0');

end tb;