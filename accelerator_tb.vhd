library ieee;
use ieee.std_logic_1164.all;
use work.accelerator_pkg.all;

entity accelerator_tb is
    generic(
        threshold_size          :natural := THRESHOLD_SIZE;
        feature_index           :natural := FEATURE_ADDRESS_SIZE;
        class_size              :natural := class_size;
        levels_in_memory        :natural := LEVELS_IN_MEMORY;
        levels_in_parallel      :natural := LEVELS_IN_PARALLEL;
        prefetch                :natural := PREFETCH
    );
end accelerator_tb;

architecture tb of accelerator_tb is
component accelerator is
    generic(threshold_size          :natural;
            feature_index           :natural;
            class_size              :natural;
            levels_in_memory        :natural;
            levels_in_parallel      :natural;
            prefetch                :natural
    );
    port(
        clk         : in  std_logic;
        features    : in  std_logic_vector(threshold_size * feature_index - 1 downto 0);
        class       : out std_logic_vector(Bit_lenght(class_size) downto 0)
    );
end component;

signal clk      : std_logic;
signal features : std_logic_vector(threshold_size * feature_index - 1 downto 0); -- inputs
signal class    : std_logic_vector(Bit_lenght(class_size) downto 0); -- outputs

begin
    UUT: entity work.accelerator 
    generic map(
        threshold_size          => threshold_size, 
        feature_index           => feature_index,
        class_size              => class_size,
        levels_in_memory        => levels_in_memory,
        levels_in_parallel      => levels_in_parallel,
        prefetch                => prefetch
    )
    port map(
        clk         => clk,
        features    => features,
        class       => class
    );

    clk         <= '0';
    features    <= (0 => '1', others => '0');

end tb;