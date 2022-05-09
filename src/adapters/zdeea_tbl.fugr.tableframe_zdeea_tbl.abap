*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZDEEA_TBL
*   generation date: 04.05.2022 at 11:19:35
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZDEEA_TBL          .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
