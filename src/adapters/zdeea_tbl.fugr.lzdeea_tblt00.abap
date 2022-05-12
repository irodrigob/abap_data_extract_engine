*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDEEA_T001......................................*
DATA:  BEGIN OF STATUS_ZDEEA_T001                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDEEA_T001                    .
CONTROLS: TCTRL_ZDEEA_T001
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDEEA_T001                    .
TABLES: ZDEEA_T001                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
