*&---------------------------------------------------------------------*
*&  Include           ZDEEC_R_LAUNCH_CHAIN_C01
*&---------------------------------------------------------------------*
CLASS lcl_controller DEFINITION.
  PUBLIC SECTION.

    METHODS set_chain_process
      IMPORTING
        iv_chain_process TYPE zdeec_t001-chain_process.

    METHODS run.

  PROTECTED SECTION.
    DATA mo_chain_process TYPE REF TO zcl_deec_chain_process.
    DATA mt_data TYPE zcl_deec_chain_process=>tt_process_result.
    DATA mo_alv TYPE REF TO cl_salv_table.
    METHODS show_result.

ENDCLASS.

CLASS lcl_controller IMPLEMENTATION.
  METHOD run.

    mo_chain_process->launch_process(
      EXPORTING
        iv_test_mode = p_test
      IMPORTING
        et_result    = mt_data ).

    IF mt_data IS NOT INITIAL.
      show_result(  ).
    ELSE.
      MESSAGE s006(zdeec).
    ENDIF.

  ENDMETHOD.

  METHOD set_chain_process.
    TRY.
        mo_chain_process = NEW zcl_deec_chain_process( iv_chain_process = iv_chain_process ).
      CATCH zcx_deec INTO DATA(lo_deec).
        MESSAGE ID lo_deec->if_t100_message~t100key-msgid TYPE zif_dee_data=>cs_messages-type_error
                NUMBER lo_deec->if_t100_message~t100key-msgno
                WITH lo_deec->mv_msgv1 lo_deec->mv_msgv2 lo_deec->mv_msgv3 lo_deec->mv_msgv4.
    ENDTRY.
  ENDMETHOD.


  METHOD show_result.

    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = mo_alv
      CHANGING
        t_table      = mt_data ).

    DATA(lo_columns) = mo_alv->get_columns( ).
    lo_columns->set_optimize( abap_true ).

    DATA(lo_column) = lo_columns->get_column( 'ID_EXECUTION' ).
    lo_column->set_long_text( 'ID ejecución'(c01) ).

    DATA(lo_settings) = mo_alv->get_display_settings( ).
    lo_settings->set_list_header( CONV #( sy-title ) ).


    DATA(lo_functions) = mo_alv->get_functions( ).
    lo_functions->set_all( abap_true ).

    mo_alv->display( ).

  ENDMETHOD.

ENDCLASS.
