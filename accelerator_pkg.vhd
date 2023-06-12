package accelerator_pkg is
    constant FEATURES_AMOUNT            : natural := 15;
    constant FEATURES_AMOUNT_REMAINING  : natural := 1;
    constant FEATURE_INDEX_SIZE         : natural := 4;
    constant THRESHOLD_SIZE             : natural := 16;
    constant THRESHOLD_SIZE_COMPLEMENT  : natural := 0;
    constant CLASS_SIZE                 : natural := 2;
    constant CLASS_SIZE_COMPLEMENT      : natural := 18;
    constant NODES_AMOUNT               : natural := 4095;
    constant NODE_SIZE                  : natural := 21;
    constant LEVELS_IN_MEMORY           : natural := 12;
    constant LEVELS_IN_PARALLEL         : natural := 1;
    constant PREFETCH                   : natural := 0;
    constant NODES_TO_WRITE             : natural := 1;
 -- constants for the tree serialized in the file: principais-imputados

end package accelerator_pkg;
