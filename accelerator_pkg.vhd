package accelerator_pkg is
    constant THRESHOLD_SIZE         : natural := 31
    constant FEATURE_ADDRESS_SIZE   : natural := 4;
    constant CLASS_SIZE             : natural := 3;
    constant LEVELS_IN_MEMORY       : natural := 6;
    constant LEVELS_IN_PARALLEL     : natural := 1;
    constant PREFETCH               : natural := 0;

     
    function Bit_lenght (
        x : positive)
        return natural;
     
end package accelerator_pkg;

-- Package Body Section
package body accelerator_pkg is
    function Bit_lenght (
        x : positive) 
    return natural is
        variable i : natural;
    begin
        i := 0;  
        while (2**i < x) and i < 63 loop
            i := i + 1;
        end loop;
            i := i + 1;
        return i;
    end function;
 
end package body accelerator_pkg;