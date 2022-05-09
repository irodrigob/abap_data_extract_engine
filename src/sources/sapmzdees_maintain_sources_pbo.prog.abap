*&---------------------------------------------------------------------*
*& Include          SAPMZDEES_MAINTAIN_SOURCES_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'S9000'.
  SET TITLEBAR 'T9000' WITH mo_ctrl->mv_app_title.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module INIT_PROCESS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_process OUTPUT.
  IF mo_ctrl IS NOT BOUND.
    mo_ctrl = NEW zcl_dees_handler_mnt_sources(  ).

    " Lectura de los datos principales del proceso
    mo_ctrl->load_main_data(  ).

  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE pbo_9000 OUTPUT.
  mo_ctrl->pbo_9000( ).
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE pbo_9001 OUTPUT.
  mo_ctrl->pbo_9001( ).
ENDMODULE.