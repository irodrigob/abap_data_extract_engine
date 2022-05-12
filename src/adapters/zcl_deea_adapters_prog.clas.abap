CLASS zcl_deea_adapters_prog DEFINITION
  PUBLIC
  INHERITING FROM zcl_deea_adapters_base
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS zif_deea_adapters~execute REDEFINITION.
  PROTECTED SECTION.
    "! <p class="shorttext synchronized">Devuelve los parámetros de impresion</p>
    "! @parameter es_print_params | <p class="shorttext synchronized">Parámetros de impresion</p>
    "! @parameter es_archive_params | <p class="shorttext synchronized">Parámetros de archivado</p>
    METHODS get_print_parameters
      EXPORTING
        es_print_params   TYPE pri_params
        es_archive_params TYPE arc_params.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_deea_adapters_prog IMPLEMENTATION.
  METHOD zif_deea_adapters~execute.
    CLEAR: et_return, eo_data.

    DATA(lv_error_launch) = abap_false.
    TRY.

        " Saco los parámetros de impresión para enviar el posible listado al spool
        get_print_parameters( IMPORTING es_print_params = DATA(ls_print_params)
                                        es_archive_params = DATA(ls_archive_params) ).

        IF ms_configurarion-variant IS INITIAL.
          SUBMIT (ms_configurarion-object_name)
                 TO SAP-SPOOL
                 SPOOL PARAMETERS ls_print_params
                 ARCHIVE PARAMETERS ls_archive_params
                 WITHOUT SPOOL DYNPRO
                 AND RETURN.
        ELSE.
          SUBMIT (ms_configurarion-object_name)
           USING SELECTION-SET ms_configurarion-variant
           TO SAP-SPOOL
           SPOOL PARAMETERS ls_print_params
           ARCHIVE PARAMETERS ls_archive_params
           WITHOUT SPOOL DYNPRO
           AND RETURN.
        ENDIF.
      CATCH cx_root.
        lv_error_launch = abap_true.
    ENDTRY.

    IF ms_configurarion-variant IS INITIAL.
      INSERT zcl_dee_utilities=>fill_return(  iv_type      = COND #( WHEN lv_error_launch = abap_true
                                                                     THEN zif_dee_data=>cs_messages-type_error
                                                                     ELSE zif_dee_data=>cs_messages-type_success )
                                             iv_id         = zif_dee_data=>cs_messages-id_adapters
                                             iv_number     = COND #( WHEN lv_error_launch = abap_true
                                                                     THEN '006'
                                                                     ELSE '004' )
                                             iv_message_v1 = ms_configurarion-object_name
                                             iv_langu      = mv_langu ) INTO TABLE et_return.
    ELSE.
      INSERT zcl_dee_utilities=>fill_return(  iv_type     =  COND #( WHEN lv_error_launch = abap_true
                                                                     THEN zif_dee_data=>cs_messages-type_error
                                                                     ELSE zif_dee_data=>cs_messages-type_success )
                                            iv_id         = zif_dee_data=>cs_messages-id_adapters
                                            iv_number     = COND #( WHEN lv_error_launch = abap_true
                                                                     THEN '005'
                                                                     ELSE '003' )
                                            iv_message_v1 = ms_configurarion-object_name
                                            iv_message_v2 = ms_configurarion-variant
                                            iv_langu      = mv_langu ) INTO TABLE et_return.
    ENDIF.

  ENDMETHOD.


  METHOD get_print_parameters.
    DATA lv_valid_flag TYPE c LENGTH 1.

    CLEAR: es_archive_params, es_print_params.

    DATA(lv_repid) = CONV sy-repid( ms_configurarion-object_name ).

    CALL FUNCTION 'GET_PRINT_PARAMETERS'
      EXPORTING
        report                 = lv_repid
        no_dialog              = abap_true
      IMPORTING
        out_parameters         = es_print_params
        out_archive_parameters = es_archive_params
        valid                  = lv_valid_flag
      EXCEPTIONS
        invalid_print_params   = 2
        OTHERS                 = 4.

  ENDMETHOD.

ENDCLASS.
