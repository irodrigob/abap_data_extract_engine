*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDEEC_T001......................................*
DATA:  BEGIN OF STATUS_ZDEEC_T001                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDEEC_T001                    .
CONTROLS: TCTRL_ZDEEC_T001
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZDEEC_V001......................................*
TABLES: ZDEEC_V001, *ZDEEC_V001. "view work areas
CONTROLS: TCTRL_ZDEEC_V001
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZDEEC_V001. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZDEEC_V001.
* Table for entries selected to show on screen
DATA: BEGIN OF ZDEEC_V001_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZDEEC_V001.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZDEEC_V001_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZDEEC_V001_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZDEEC_V001.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZDEEC_V001_TOTAL.

*.........table declarations:.................................*
TABLES: *ZDEEC_T001                    .
TABLES: ZDEEC_T001                     .
TABLES: ZDEEC_T002                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
