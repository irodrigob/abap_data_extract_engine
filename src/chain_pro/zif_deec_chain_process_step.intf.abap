INTERFACE zif_deec_chain_process_step
  PUBLIC .
  TYPES: BEGIN OF ts_step_configuration.
           INCLUDE TYPE zdeec_s_chain_proc_step_conf.
         TYPES:
                END OF ts_step_configuration.
  "! <p class="shorttext synchronized">Establece la configuración del paso</p>
  "! @parameter is_conf | <p class="shorttext synchronized">Valores</p>
  METHODS set_configuration
    IMPORTING
              is_configuration TYPE ts_step_configuration
    RAISING   zcx_deec.
  "! <p class="shorttext synchronized">Obtiene la configuración del paso</p>
  "! @parameter es_configuration | <p class="shorttext synchronized">Configuración</p>
  METHODS get_configuration
    RETURNING VALUE(rs_configuration) TYPE ts_step_configuration.
  "! <p class="shorttext synchronized">Ejecuta el paso del proceso</p>
  "! @parameter iv_test_mode | <p class="shorttext synchronized">Modo test</p>
  "! @parameter ev_step_error | <p class="shorttext synchronized">Paso erróneo</p>
  "! @parameter et_return | <p class="shorttext synchronized">Resultado del proceso</p>
  METHODS execute
    IMPORTING
      iv_test_mode  TYPE sap_bool DEFAULT abap_false
    EXPORTING
      ev_step_error TYPE sap_bool
      et_return     TYPE bapiret2_t.
ENDINTERFACE.
