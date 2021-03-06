CLASS zcl_dee_utilities DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! <p class="shorttext synchronized">Rellena el retorno para la BAPIRET2</p>
    "! @parameter iv_type | <p class="shorttext synchronized">Tipo de mensaje</p>
    "! @parameter iv_id | <p class="shorttext synchronized">ID de mensaje</p>
    "! @parameter iv_number | <p class="shorttext synchronized">Numero de mensaje</p>
    "! @parameter iv_message_v1 | <p class="shorttext synchronized">Variable 1 del mensaje</p>
    "! @parameter iv_message_v2 | <p class="shorttext synchronized">Variable 2 del mensaje</p>
    "! @parameter iv_message_v3 | <p class="shorttext synchronized">Variable 3 del mensaje</p>
    "! @parameter iv_message_v4 | <p class="shorttext synchronized">Variable 4 del mensaje</p>
    "! @parameter iv_field | <p class="shorttext synchronized">Campo</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    "! @parameter iv_row | <p class="shorttext synchronized">Fila</p>
    "! @parameter rs_return | <p class="shorttext synchronized">Retorno</p>
    CLASS-METHODS fill_return
      IMPORTING
        !iv_type         TYPE any DEFAULT zif_dee_data=>cs_messages-id_general
        !iv_id           TYPE any
        !iv_number       TYPE any
        !iv_message_v1   TYPE any OPTIONAL
        !iv_message_v2   TYPE any OPTIONAL
        !iv_message_v3   TYPE any OPTIONAL
        !iv_message_v4   TYPE any OPTIONAL
        !iv_field        TYPE any OPTIONAL
        !iv_langu        TYPE sylangu DEFAULT sy-langu
        !iv_row          TYPE any OPTIONAL
      RETURNING
        VALUE(rs_return) TYPE bapiret2 .
    "! <p class="shorttext synchronized">Se llama desde el motor de extracción datos</p>
    "! @parameter rv_is | <p class="shorttext synchronized">Se llama</p>
    CLASS-METHODS call_from_dee
      RETURNING VALUE(rv_is) TYPE sap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dee_utilities IMPLEMENTATION.
  METHOD fill_return.
    CLEAR rs_return.
    rs_return-field = iv_field.
    rs_return-type = iv_type.
    rs_return-id = iv_id.
    rs_return-number = iv_number.
    rs_return-message_v1 = iv_message_v1.
    rs_return-message_v2 = iv_message_v2.
    rs_return-message_v3 = iv_message_v3.
    rs_return-message_v4 = iv_message_v4.
    rs_return-row = iv_row.

    CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
      EXPORTING
        id         = rs_return-id
        number     = rs_return-number
        language   = iv_langu
        textformat = 'ASC'
        message_v1 = rs_return-message_v1
        message_v2 = rs_return-message_v2
        message_v3 = rs_return-message_v3
        message_v4 = rs_return-message_v4
      IMPORTING
        message    = rs_return-message.
  ENDMETHOD.

  METHOD call_from_dee.
    DATA lt_callstack TYPE abap_callstack.
    DATA lt_r_block TYPE RANGE OF string.

    CALL FUNCTION 'SYSTEM_CALLSTACK'
      IMPORTING
        callstack = lt_callstack.

    lt_r_block = VALUE #( ( sign = 'I' option = 'CP' low = 'ZCL_DEEC_CHAIN_PROCESS*' )
                          ( sign = 'I' option = 'CP' low = 'ZCL_DEEC_CHAIN_PROCESS_STEP*' )
                          ( sign = 'I' option = 'CP' low = 'ZCL_DEEA_ADAPTERS_*' ) ).

    LOOP AT lt_callstack TRANSPORTING NO FIELDS
                            WHERE blocktype = 'METHOD'
                                  AND mainprogram IN lt_r_block.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      rv_is = abap_true.
    ENDIF.


  ENDMETHOD.

ENDCLASS.
