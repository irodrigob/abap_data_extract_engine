INTERFACE zif_deea_adapters
  PUBLIC .
  TYPES: BEGIN OF ts_configuration,
           object_name TYPE zdee_e_object_name,
           variant     TYPE zdee_e_variant,
         END OF ts_configuration.
  "! <p class="shorttext synchronized">Establece la configuración del adaptador</p>
  "! @parameter is_conf | <p class="shorttext synchronized">Valores</p>
  METHODS set_configuration
    IMPORTING is_configuration TYPE ts_configuration
    RAISING   zcx_deea.
  "! <p class="shorttext synchronized">Ejecuta el paso del proceso</p>
  "! @parameter eo_data | <p class="shorttext synchronized">Datos obtenidos</p>
  "! @parameter et_return | <p class="shorttext synchronized">Resultado del proceso</p>
  METHODS execute
    EXPORTING
      eo_data      TYPE REF TO data
      et_return    TYPE bapiret2_t.

ENDINTERFACE.
