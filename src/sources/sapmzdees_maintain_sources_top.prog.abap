*&---------------------------------------------------------------------*
*& Include          SAPMZDEES_MAINTAIN_SOURCES_TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Variables
*----------------------------------------------------------------------*
DATA mo_ctrl TYPE REF TO zcl_dees_handler_mnt_sources.

*----------------------------------------------------------------------*
* Variables que se usarán en las dynpro
*----------------------------------------------------------------------*
TABLES: zdees_bo_sc_header.
DATA mv_okcode TYPE syucomm.

*----------------------------------------------------------------------*
* Objetos dynpro
*----------------------------------------------------------------------*
DATA mo_main_container TYPE REF TO cl_gui_custom_container.
DATA mo_adapter_tree TYPE REF TO cl_salv_tree.
