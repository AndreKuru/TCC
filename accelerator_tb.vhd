library ieee;
use ieee.std_logic_1164.all;
use work.accelerator_pkg.all;

entity accelerator_tb is
    generic(
        features_amount             : natural := FEATURES_AMOUNT;
        features_index_size         : natural := FEATURE_INDEX_SIZE;
        features_amount_remaining   : natural := FEATURES_AMOUNT_REMAINING;
        threshold_size              : natural := THRESHOLD_SIZE;
        threshold_size_complement   : natural := THRESHOLD_SIZE_COMPLEMENT;
        class_size                  : natural := CLASS_SIZE;
        class_size_complement       : natural := CLASS_SIZE_COMPLEMENT;
        nodes_amount                : natural := NODES_AMOUNT;
        node_size                   : natural := NODE_SIZE;
        levels_in_memory            : natural := LEVELS_IN_MEMORY;
        levels_in_parallel          : natural := LEVELS_IN_PARALLEL;
        prefetch                    : natural := PREFETCH
    );
end accelerator_tb;

architecture tb of accelerator_tb is

signal clk, reset      : std_logic;
signal features        : std_logic_vector(threshold_size * features_amount - 1 downto 0);
signal nodes_data_in   : std_logic_vector(nodes_amount * node_size - 1 downto 0);
signal ready           : std_logic;
signal class           : std_logic_vector(class_size - 1 downto 0);

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
            clk             => clk,
            reset           => reset,
            features        => features,
            nodes_data_in   => nodes_data_in,
            ready           => ready,
            class           => class
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