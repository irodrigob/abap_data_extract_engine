CLASS zcl_deec_chain_process DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_process_result,
             chain_process TYPE zdeec_e_chain_process,
             description   TYPE zdeec_e_chain_process_desc,
             id_execution  TYPE /bobf/conf_key,
             step          TYPE zdeec_e_chain_process_step.
             INCLUDE TYPE zdeec_s_chain_proc_step_conf.
             INCLUDE TYPE zdeec_s_log_dates_fields.
           TYPES:
                    start_user    TYPE zdeec_e_start_user,
                    type          TYPE bapi_mtype,
                    id            TYPE symsgid,
                    number        TYPE symsgno,
                    message_v1    TYPE symsgv,
                    message_v2    TYPE symsgv,
                    message_v3    TYPE symsgv,
                    message_v4    TYPE symsgv,
                    message       TYPE string,
                  END OF ts_process_result.
    TYPES: tt_process_result TYPE STANDARD TABLE OF ts_process_result WITH DEFAULT KEY.

    "! <p class="shorttext synchronized">CONSTRUCTOR</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    "! @parameter iv_chain_process | <p class="shorttext synchronized">Cadena de proceso</p>
    METHODS constructor
      IMPORTING iv_langu         TYPE sylangu DEFAULT sy-langu
                iv_chain_process TYPE zdeec_e_chain_process
      RAISING   zcx_deec.
    "! <p class="shorttext synchronized">Lanzamiento del proceso</p>
    "! @parameter iv_test_mode | <p class="shorttext synchronized">Idioma</p>
    "! @parameter et_result | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS launch_process
      IMPORTING iv_test_mode TYPE sap_bool DEFAULT abap_false
      EXPORTING et_result    TYPE tt_process_result.
  PROTECTED SECTION.
    TYPES: BEGIN OF ts_steps,
             step   TYPE zdeec_e_chain_process_step,
             object TYPE REF TO zif_deec_chain_process_step,
           END OF ts_steps.
    TYPES: tt_steps TYPE STANDARD TABLE OF ts_steps WITH DEFAULT KEY.
    TYPES: tt_step_log TYPE STANDARD TABLE OF zdeec_t004 WITH DEFAULT KEY.
    TYPES: tt_step_messages_log TYPE STANDARD TABLE OF zdeec_t005 WITH DEFAULT KEY.
    DATA mv_langu TYPE sylangu.
    DATA ms_chain_process TYPE zdeec_t001.
    DATA mt_steps TYPE tt_steps.
    DATA ms_header_log TYPE zdeec_t003.
    DATA ms_step_log TYPE zdeec_t004.
    DATA mt_process_result TYPE tt_process_result.
    DATA mv_test_mode TYPE sap_bool.

    "! <p class="shorttext synchronized">Lectura de la parametrización</p>
    METHODS load_steps
      RAISING zcx_deec.

    "! <p class="shorttext synchronized">Inicio log del proceso</p>
    METHODS start_log_process.
    "! <p class="shorttext synchronized">Fin log del proceso</p>
    METHODS end_log_process.
    "! <p class="shorttext synchronized">Inicio del paso en log del proceso</p>
    "! @parameter is_step | <p class="shorttext synchronized">Paso</p>
    METHODS start_step_log_process
      IMPORTING is_step TYPE ts_steps .
    "! <p class="shorttext synchronized">Inicio del paso en log del proceso</p>
    "! @parameter is_step | <p class="shorttext synchronized">Paso</p>
    "! @parameter it_return | <p class="shorttext synchronized">Mensajes del resultado del paso</p>
    METHODS end_step_log_process
      IMPORTING
        is_step   TYPE ts_steps
        it_return TYPE bapiret2_t OPTIONAL.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_deec_chain_process IMPLEMENTATION.
  METHOD constructor.
    mv_langu = iv_langu.

    SELECT SINGLE * INTO ms_chain_process FROM zdeec_t001 WHERE chain_process = iv_chain_process.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE zcx_deec
        EXPORTING
          textid   = zcx_deec=>chain_process_not_exist
          mv_msgv1 = CONV #( iv_chain_process ).
    ENDIF.

    " Lectura de la configuración
    load_steps(  ).

  ENDMETHOD.


  METHOD load_steps.

    SELECT * INTO TABLE @DATA(lt_steps_db)
             FROM zdeec_t002
             WHERE chain_process = @ms_chain_process-chain_process.
    IF sy-subrc = 0.

      LOOP AT lt_steps_db ASSIGNING FIELD-SYMBOL(<ls_steps_db>).
        DATA(ls_step) = VALUE ts_steps( step = <ls_steps_db>-step ).
        DATA(lv_class) = COND #( WHEN <ls_steps_db>-custom_class_step IS NOT INITIAL THEN <ls_steps_db>-custom_class_step ELSE zif_deec_data=>cs_classes-step ).
        TRY.
            CREATE OBJECT ls_step-object TYPE (lv_class)
                 EXPORTING iv_langu = mv_langu.
            TRY.
                ls_step-object->set_configuration( is_configuration = CORRESPONDING #( <ls_steps_db> ) ).

                INSERT ls_step INTO TABLE mt_steps.

              CATCH zcx_deec INTO DATA(lo_excep).
                IF ms_chain_process-nostop_step_error = abap_false.
                  RAISE EXCEPTION TYPE zcx_deec
                    EXPORTING
                      textid   = lo_excep->if_t100_message~t100key
                      mv_msgv1 = lo_excep->mv_msgv1
                      mv_msgv2 = lo_excep->mv_msgv2
                      mv_msgv3 = lo_excep->mv_msgv3
                      mv_msgv4 = lo_excep->mv_msgv4.
                ENDIF.
            ENDTRY.

          CATCH cx_root.
            " Si no esta marcado que se ignoren los errores en los pasos se lanza la excepción que
            " hay un paso con una clase invalida.
            IF ms_chain_process-nostop_step_error = abap_false.
              RAISE EXCEPTION TYPE zcx_deec
                EXPORTING
                  textid   = zcx_deec=>invalid_class_step
                  mv_msgv1 = CONV #( lv_class )
                  mv_msgv2 = CONV #( ls_step-step ).
            ENDIF.
        ENDTRY.
      ENDLOOP.

    ELSE.
      RAISE EXCEPTION TYPE zcx_deec
        EXPORTING
          textid   = zcx_deec=>chain_process_not_steps
          mv_msgv1 = CONV #( ms_chain_process-chain_process ).
    ENDIF.

  ENDMETHOD.

  METHOD launch_process.
    CLEAR: mt_process_result, et_result.

    mv_test_mode = iv_test_mode.

    " Log - Inicio del proceso de la cadena
    start_log_process(  ).

    LOOP AT mt_steps ASSIGNING FIELD-SYMBOL(<ls_steps>).
      start_step_log_process( <ls_steps> ).
      TRY.
          <ls_steps>-object->execute(
          EXPORTING
          iv_test_mode = iv_test_mode
            IMPORTING
              ev_step_error = DATA(lv_step_error)
              et_return     = DATA(lt_return) ).
        CATCH cx_root.
          lv_step_error = abap_true.
      ENDTRY.

      end_step_log_process( is_step = <ls_steps>
                            it_return = lt_return ).

      " Si el paso es erróneo y no esta marcada la opción de continuar pese a los errores se
      " sale del proceso
      IF lv_step_error = abap_true AND ms_chain_process-nostop_step_error = abap_false.
        EXIT.
      ENDIF.

      CLEAR: lt_return.
      lv_step_error = abap_false.

    ENDLOOP.

    end_log_process(  ).

    et_result = mt_process_result.

  ENDMETHOD.


  METHOD start_log_process.

    CLEAR: ms_step_log, ms_header_log.

    GET TIME.
    ms_header_log-chain_process = ms_chain_process-chain_process.
    ms_header_log-id_execution = /bobf/cl_frw_factory=>get_new_key( ).
    ms_header_log-start_date = sy-datum.
    ms_header_log-start_time = sy-uzeit.
    ms_header_log-start_user = sy-uname.

    IF mv_test_mode = abap_false.
      MODIFY zdeec_t003 FROM ms_header_log.
      COMMIT WORK AND WAIT.
    ENDIF.

    " Datos para la tabla global con el resultado del proceso
    DATA(ls_result_process) = CORRESPONDING ts_process_result( ms_header_log ).
    ls_result_process-description = ms_chain_process-description.
    INSERT ls_result_process INTO TABLE mt_process_result.
  ENDMETHOD.


  METHOD end_log_process.

    GET TIME.
    ms_header_log-end_date = sy-datum.
    ms_header_log-end_time = sy-uzeit.

    IF mv_test_mode = abap_false.
      MODIFY zdeec_t003 FROM ms_header_log.
      COMMIT WORK AND WAIT.
    ENDIF.

    " Datos para la tabla global con el resultado del proceso
    READ TABLE mt_process_result ASSIGNING FIELD-SYMBOL(<ls_process_result>) INDEX 1.
    IF sy-subrc = 0.
      <ls_process_result>-end_date = ms_header_log-end_date.
      <ls_process_result>-end_time = ms_header_log-end_time.
    ENDIF.

  ENDMETHOD.


  METHOD start_step_log_process.

    CLEAR: ms_step_log.

    GET TIME.
    ms_step_log-chain_process = ms_header_log-chain_process.
    ms_step_log-id_execution = ms_header_log-id_execution.
    ms_step_log-step = is_step-step.
    ms_step_log-start_date = sy-datum.
    ms_step_log-start_time = sy-uzeit.
    IF mv_test_mode = abap_false.
      MODIFY zdeec_t004 FROM ms_step_log.
      COMMIT WORK AND WAIT.
    ENDIF.

    " Datos para la tabla global con el resultado del proceso
    DATA(ls_result_process) = CORRESPONDING ts_process_result( ms_step_log ).
    ls_result_process = CORRESPONDING #( BASE ( ls_result_process ) is_step-object->get_configuration( ) ).
    ls_result_process-description = ms_chain_process-description.
    INSERT ls_result_process INTO TABLE mt_process_result.

  ENDMETHOD.

  METHOD end_step_log_process.
    DATA lt_msg_db TYPE STANDARD TABLE OF zdeec_t005.
    GET TIME.
    ms_step_log-end_date = sy-datum.
    ms_step_log-end_time = sy-uzeit.

    IF mv_test_mode = abap_false.
      MODIFY zdeec_t004 FROM ms_step_log.
      COMMIT WORK AND WAIT.
    ENDIF.

    " Datos para la tabla global con el resultado del proceso
    READ TABLE mt_process_result ASSIGNING FIELD-SYMBOL(<ls_process_result>)
                                 WITH KEY step = ms_step_log-step.
    IF sy-subrc = 0.
      <ls_process_result>-end_date = ms_step_log-end_date.
      <ls_process_result>-end_time = ms_step_log-end_time.
    ENDIF.

    IF it_return IS NOT INITIAL.
      DATA(ls_step_configuration) = is_step-object->get_configuration( ).
      LOOP AT it_return ASSIGNING FIELD-SYMBOL(<ls_return>).
        DATA(ls_msg_db) = CORRESPONDING zdeec_t005( ms_step_log ).
        ls_msg_db = CORRESPONDING #( BASE ( ls_msg_db ) <ls_return> ).
        ls_msg_db-counter = sy-tabix.
        ls_msg_db-msg_number = <ls_return>-number.
        INSERT ls_msg_db INTO TABLE lt_msg_db.

        " Datos para la tabla global con el resultado del proceso
        DATA(ls_result_process) = CORRESPONDING ts_process_result( ms_step_log ).
        ls_result_process = CORRESPONDING #( base ( ls_result_process ) ls_step_configuration ).
        ls_result_process = CORRESPONDING #( BASE ( ls_result_process ) ls_msg_db ).
        ls_result_process-description = ms_chain_process-description.
        INSERT ls_result_process INTO TABLE mt_process_result.

      ENDLOOP.

      IF mv_test_mode = abap_false.
        MODIFY zdeec_t005 FROM TABLE lt_msg_db.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
