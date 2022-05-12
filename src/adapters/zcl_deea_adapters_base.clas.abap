CLASS zcl_deea_adapters_base DEFINITION
  PUBLIC
  CREATE PROTECTED .

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_types_list,
             adapter     TYPE zdeea_t001-adapter,
             description TYPE zdeea_t001-description,
           END OF ts_types_list.
    TYPES: tt_types_list TYPE STANDARD TABLE OF ts_types_list WITH DEFAULT KEY.

    INTERFACES zif_deea_adapters .
    "! <p class="shorttext synchronized">CONSTRUCTOR</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    "! @parameter iv_adapter | <p class="shorttext synchronized">Tipo de adaptador</p>
    METHODS constructor
      IMPORTING iv_langu   TYPE sylangu DEFAULT sy-langu
                iv_adapter TYPE zdeea_e_adapter_name OPTIONAL.
    "! <p class="shorttext synchronized">Devuelve la instancia de un tipo de extractor</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    "! @parameter iv_adapter | <p class="shorttext synchronized">Tipo de adaptador</p>
    "! @parameter ro_adapter | <p class="shorttext synchronized">Instancia del adaptador</p>
    CLASS-METHODS get_instance
      IMPORTING iv_langu          TYPE sylangu DEFAULT sy-langu
                iv_adapter        TYPE zdeea_e_adapter_name
      RETURNING VALUE(ro_adapter) TYPE REF TO zif_deea_adapters
      RAISING   zcx_deea.
    "! <p class="shorttext synchronized">Devuelve el listado de tipos de extractores</p>
    "! @parameter rt_list | <p class="shorttext synchronized">Listado</p>
    CLASS-METHODS get_types_list_static
      RETURNING VALUE(rt_list) TYPE tt_types_list.

  PROTECTED SECTION.
    DATA mv_langu TYPE sylangu.
    DATA mv_adapter TYPE zdeea_e_adapter_name.
    DATA ms_configurarion TYPE zif_deea_adapters=>ts_configuration.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_deea_adapters_base IMPLEMENTATION.


  METHOD constructor.
    mv_langu = iv_langu.
    mv_adapter = COND #( WHEN iv_adapter IS SUPPLIED THEN iv_adapter ELSE mv_adapter ).

  ENDMETHOD.


  METHOD get_instance.

    CLEAR: ro_adapter.

    SELECT SINGLE classname INTO @DATA(lv_class)
           FROM zdeea_t001
           WHERE adapter = @iv_adapter.
    IF sy-subrc = 0.
      TRY.

          CREATE OBJECT ro_adapter TYPE (lv_class)
                EXPORTING iv_langu = iv_langu
                          iv_adapter = iv_adapter.

        CATCH cx_root.
          RAISE EXCEPTION TYPE zcx_deea
            EXPORTING
              textid  = zcx_deea=>instance_class_error
              mv_msgv1 = CONV #( lv_class )
              mv_msgv2 = CONV #( iv_adapter ).
      ENDTRY.

    ELSE.
      RAISE EXCEPTION TYPE zcx_deea
        EXPORTING
          textid  = zcx_deea=>extractor_type_not_defined
          mv_msgv1 = CONV #( iv_adapter ).
    ENDIF.

  ENDMETHOD.


  METHOD get_types_list_static.
    CLEAR: rt_list.
    SELECT adapter description INTO TABLE rt_list
           FROM zdeea_t001.
  ENDMETHOD.
  METHOD zif_deea_adapters~set_configuration.
    ms_configurarion = is_configuration.
  ENDMETHOD.
ENDCLASS.
