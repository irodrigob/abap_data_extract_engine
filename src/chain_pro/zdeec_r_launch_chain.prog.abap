*&---------------------------------------------------------------------*
*& Report ZDEEC_R_LAUNCH_CHAIN
*&---------------------------------------------------------------------*
*& Descripción: Programa para el lanzamiento para las cadenas de proceso
*&---------------------------------------------------------------------*
REPORT zdeec_r_launch_chain MESSAGE-ID zdeec.

CLASS lcl_controller DEFINITION DEFERRED.
DATA mo_controller TYPE REF TO lcl_controller.

*----------------------------------------------------------------------*
* Pantalla de selección
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.
PARAMETERS: p_chain TYPE zdeec_t001-chain_process OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-t02.
PARAMETERS: p_test AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK bl2.

INCLUDE zdeec_r_launch_chain_c01.

*----------------------------------------------------------------------*
* Inicialización de datos
*----------------------------------------------------------------------*
INITIALIZATION.
  DATA(lo_ctrl) = NEW lcl_controller( ).

*----------------------------------------------------------------------*
* Validación pantalla selección
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON BLOCK bl1.
  lo_ctrl->set_chain_process( iv_chain_process = p_chain ).

*----------------------------------------------------------------------*
* Inicio de selección
*----------------------------------------------------------------------*
START-OF-SELECTION.

  lo_ctrl->run( ).
