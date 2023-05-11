library ieee;
use ieee.std_logic_1164.all;
use work.accelerator_pkg.all;

entity accelerator_tb is
    generic(threshold_size          :natural := 31; -- THRESHOLD_SIZE;
            feature_address_size    :natural := 4;  -- FEATURE_ADDRESS_SIZE;
            class_amount            :natural := 3;  -- CLASS_AMOUNT;
            levels_in_memory        :natural := 6;  -- LEVELS_IN_MEMORY;
            levels_in_parallel      :natural := 1;  -- LEVELS_IN_PARALLEL;
            prefetch                :natural := 0   -- PREFETCH
    );
end accelerator_tb;

architecture tb of accelerator_tb is
component accelerator is
    generic(threshold_size          :natural := threshold_size;
            feature_address_size    :natural := feature_address_size;
            class_amount            :natural := class_amount;
            levels_in_memory        :natural := levels_in_memory;
            levels_in_parallel      :natural := levels_in_parallel;
            prefetch                :natural := prefetch
    );
    port(
        clk         : in  std_logic;
        features    : in  std_logic_vector(threshold_size * feature_address_size - 1 downto 0);
        class       : out std_logic_vector(Bit_lenght(class_amount) downto 0)
    );
end component;

signal clk      : std_logic;
signal features : std_logic_vector(threshold_size * feature_address_size - 1 downto 0); -- inputs
signal class    : std_logic_vector(Bit_lenght(class_amount) downto 0); -- outputs

begin
    UUT: entity work.accelerator 
    port map(
        clk         => clk,
        features    => features,
        class       => class
    );

    clk         <= '0';
    features    <= "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";

end tb;