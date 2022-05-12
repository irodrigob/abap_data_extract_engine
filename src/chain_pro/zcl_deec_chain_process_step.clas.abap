CLASS zcl_deec_chain_process_step DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_deec_chain_process_step .
    "! <p class="shorttext synchronized">CONSTRUCTOR</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    METHODS constructor
      IMPORTING iv_langu TYPE sylangu DEFAULT sy-langu.
  PROTECTED SECTION.
    DATA mv_langu TYPE sylangu.
    DATA ms_configuration TYPE zdeec_s_chain_proc_step_conf.
    DATA mo_adapter TYPE REF TO zif_deea_adapters.
    DATA mv_test_mode TYPE sap_bool.

    "! <p class="shorttext synchronized">Ejecuta por adaptador</p>
    "! @parameter ev_step_error | <p class="shorttext synchronized">Paso erróneo</p>
    "! @parameter et_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS execute_by_adapter
      EXPORTING
        et_return TYPE bapiret2_t.
    METHODS execute_by_data_source
      EXPORTING
        et_return TYPE bapiret2_t.

  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_deec_chain_process_step IMPLEMENTATION.
  METHOD constructor.
    mv_langu = iv_langu.
  ENDMETHOD.

  METHOD zif_deec_chain_process_step~execute.
    mv_test_mode = iv_test_mode.
    ev_step_error = abap_false.

    " La ejecución depende si el proceso irá por data fuente o adaptador.
    IF ms_configuration-adapter IS NOT INITIAL.
      execute_by_adapter( IMPORTING et_return = et_return ).
    ELSEIF ms_configuration-data_source IS NOT INITIAL.
      execute_by_data_source( IMPORTING et_return = et_return ).
    ENDIF.

    " Si hay mensaje de error el paso se da como erróneo.
    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = zif_dee_data=>cs_messages-type_error.
    IF sy-subrc = 0.
      ev_step_error = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD zif_deec_chain_process_step~set_configuration.
    ms_configuration = is_configuration.

    " Si hay una adaptador en la configuración la instancia
    TRY.
        mo_adapter = zcl_deea_adapters_base=>get_instance( iv_adapter = ms_configuration-adapter
                                                           iv_langu = mv_langu ).
      CATCH zcx_deea.
        RAISE EXCEPTION TYPE zcx_deec
          EXPORTING
            textid   = zcx_deec=>invalid_adapter_step
            mv_msgv1 = CONV #( ms_configuration-adapter ).
    ENDTRY.

  ENDMETHOD.


  METHOD execute_by_adapter.

    CLEAR: et_return.

    TRY.

        DATA(lo_adapter) = zcl_deea_adapters_base=>get_instance( iv_adapter = ms_configuration-adapter
                                                                 iv_langu = mv_langu ).

        lo_adapter->set_configuration( CORRESPONDING #( ms_configuration ) ).

        IF mv_test_mode = abap_false.
          " Nota IRB 12/05/2022 - Como se esta montando para programas y no para tablas no habrá devoluciendo de datos
          lo_adapter->execute( IMPORTING
              "eo_data   =
              et_return = et_return ).
        ELSE.
          INSERT zcl_dee_utilities=>fill_return( iv_type      = zif_dee_data=>cs_messages-type_success
                                                 iv_id        = zif_dee_data=>cs_messages-id_chain_process
                                                 iv_number    = '005'
                                                 iv_message_v1 = ms_configuration-adapter
                                                 iv_langu      = mv_langu ) INTO TABLE et_return.
        ENDIF.

      CATCH zcx_deea INTO DATA(lo_deea).
        INSERT zcl_dee_utilities=>fill_return(  iv_type       = zif_dee_data=>cs_messages-type_error
                                                iv_id         = lo_deea->if_t100_message~t100key-msgid
                                                iv_number     = lo_deea->if_t100_message~t100key-msgno
                                                iv_message_v1 = lo_deea->mv_msgv1
                                                iv_message_v2 = lo_deea->mv_msgv2
                                                iv_message_v3 = lo_deea->mv_msgv3
                                                iv_message_v4 = lo_deea->mv_msgv4
                                                iv_langu      = mv_langu ) INTO TABLE et_return.


    ENDTRY.
  ENDMETHOD.


  METHOD execute_by_data_source.

  ENDMETHOD.

  METHOD zif_deec_chain_process_step~get_configuration.
    rs_configuration = ms_configuration.
  ENDMETHOD.

ENDCLASS.
