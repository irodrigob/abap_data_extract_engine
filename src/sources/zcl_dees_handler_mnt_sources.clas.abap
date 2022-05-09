CLASS zcl_dees_handler_mnt_sources DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tv_action TYPE c LENGTH 2.
    CONSTANTS: BEGIN OF cs_function_codes,
                 new_data_source TYPE syucomm VALUE 'NEW_DS',
               END OF cs_function_codes.
    CONSTANTS: BEGIN OF cs_data_source,
                 BEGIN OF actions,
                   create TYPE tv_action VALUE 'CR',
                   change TYPE tv_action VALUE 'CH',
                   delete TYPE tv_action VALUE 'DE',
                 END OF actions,
                 BEGIN OF screens,
                   BEGIN OF number,
                     edit  TYPE sydynnr VALUE '9001',
                     empty TYPE sydynnr VALUE '9999',
                   END OF number,
                 END OF screens,
               END OF cs_data_source.
    TYPES: BEGIN OF ts_adapters_tree,
             adapter              TYPE zdeea_t001-adapter,
             adapter_desc         TYPE zdeea_t001-description,
             data_source          TYPE zdees_bo_sc_header-data_source,
             data_source_desc     TYPE zdees_bo_sc_header-description,
             adapter_node_key     TYPE salv_de_node_key,
             data_source_node_key TYPE salv_de_node_key,
           END OF ts_adapters_tree.
    TYPES tt_adapters_tree TYPE STANDARD TABLE OF ts_adapters_tree WITH DEFAULT KEY.

    DATA mt_adapters_tree TYPE tt_adapters_tree.
    DATA mo_adapters_container TYPE REF TO cl_gui_custom_container.
    DATA mv_data_source_action TYPE tv_action.
    DATA mv_data_source_dynnr TYPE sydynnr.
    DATA mv_app_title TYPE sy-title.

    "! <p class="shorttext synchronized">CONSTRUCTOR</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    METHODS constructor
      IMPORTING iv_langu TYPE sylangu DEFAULT sy-langu.
    "! <p class="shorttext synchronized">Inicio del proceso</p>
    METHODS load_main_data.
    "! <p class="shorttext synchronized">PBO dynpro 9000</p>
    METHODS pbo_9000.
    "! <p class="shorttext synchronized">PBO dynpro 9001</p>
    METHODS pbo_9001.
    "! <p class="shorttext synchronized">Evento de función pulsada en el arbol de adaptadores</p>
    METHODS on_ucomm_adapter_tree FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.
    "! <p class="shorttext synchronized">Evento al pulsar un nodo de tipo enlace en el arbol de adaptadores</p>
    METHODS on_link_adapter_tree FOR EVENT link_click OF cl_salv_events_tree
      IMPORTING columnname node_key.
  PROTECTED SECTION.
    DATA: BEGIN OF ms_app_title,
            initial TYPE sy-title,
            create  TYPE sy-title,
          END OF ms_app_title.
    DATA mv_langu TYPE sylangu.
    DATA mt_adapters_list TYPE zcl_deea_adapters_base=>tt_types_list.
    DATA mt_data_source TYPE zdees_bo_i_header.
    DATA mo_adapter_tree TYPE REF TO cl_salv_tree.
    DATA mt_adapter_tree TYPE tt_adapters_tree.

    "! <p class="shorttext synchronized">Lectura de adaptadores</p>
    METHODS read_adapters.
    "! <p class="shorttext synchronized">Lectura de la fuente de datos</p>
    METHODS read_data_source.
    "! <p class="shorttext synchronized">Construcción del arbol de adaptadores</p>
    METHODS build_adapter_tree.
    "! <p class="shorttext synchronized">Relleno del arbol de adaptadores</p>
    METHODS fill_adapter_tree_data.
    "! <p class="shorttext synchronized">Catalogo de campos del arbol de adaptadores</p>
    METHODS change_fcat_adapter_tree.
    "! <p class="shorttext synchronized">Funciones del arbol de adaptadores</p>
    METHODS set_function_adapter_tree.
    "! <p class="shorttext synchronized">Establece los eventos del arbol de adaptadores</p>
    METHODS set_event_adapter_tree.
    "! <p class="shorttext synchronized">Carga de configuración inicial</p>
    METHODS load_initial_conf.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dees_handler_mnt_sources IMPLEMENTATION.
  METHOD constructor.
    mv_langu = iv_langu.

    " Lectura de configuración inicitial
    load_initial_conf(  ).
  ENDMETHOD.

  METHOD load_main_data.
    " Lectura de los adaptadores
    read_adapters( ).
    " Lecturas de las fuentes de datos
    read_data_source(  ).

  ENDMETHOD.


  METHOD read_adapters.
    mt_adapters_list = zcl_deea_adapters_base=>get_types_list_static( ).
  ENDMETHOD.


  METHOD read_data_source.

  ENDMETHOD.



  METHOD pbo_9000.
    IF mo_adapters_container IS NOT BOUND.
      mo_adapters_container = NEW cl_gui_custom_container( container_name = 'CNT_ADAPTERS' ).

      " Se contruye el arbol de los adaptadores
      build_adapter_tree(  ).

    ENDIF.
  ENDMETHOD.


  METHOD build_adapter_tree.

    TRY.
        cl_salv_tree=>factory(
                 EXPORTING
                   r_container  = mo_adapters_container
                 IMPORTING
                   r_salv_tree = mo_adapter_tree
                 CHANGING
                   t_table      = mt_adapters_tree ).

        " Datos de cabecera
        DATA(lo_settings) = mo_adapter_tree->get_tree_settings( ).
        lo_settings->set_hierarchy_header( TEXT-hd1 ).
        lo_settings->set_hierarchy_tooltip( TEXT-ht1 ).
        lo_settings->set_hierarchy_size( 30 ).
        lo_settings->set_header( CONV #( |{ TEXT-t01 }| ) ).

        " Se añaden los datos al arbol
        fill_adapter_tree_data(  ).
        " Catalogo de campos del arbol
        change_fcat_adapter_tree(  ).
        " Funciones del arbol
        set_function_adapter_tree(  ).
        " Eventos del arbol
        set_event_adapter_tree(  ).


        mo_adapter_tree->display(  ).

      CATCH cx_salv_no_new_data_allowed cx_salv_error.
        EXIT.
    ENDTRY.

  ENDMETHOD.


  METHOD fill_adapter_tree_data.

    CLEAR: mt_adapters_tree.

    DATA(lo_nodes) = mo_adapter_tree->get_nodes( ).


    LOOP AT mt_adapters_list ASSIGNING FIELD-SYMBOL(<ls_adapters>).
      DATA(ls_adapter_tree) = VALUE ts_adapters_tree( adapter = <ls_adapters>-adapter
                                                      adapter_desc = <ls_adapters>-description ).

      DATA(lo_node) = lo_nodes->add_node( related_node = space
                                 data_row     = ls_adapter_tree
                                 relationship = cl_gui_column_tree=>relat_first_child ).
      lo_node->set_text( CONV #( ls_adapter_tree-adapter_desc )  ).

      DATA(lv_adapter_key) = lo_node->get_key( ).

      LOOP AT mt_data_source ASSIGNING FIELD-SYMBOL(<ls_data_source>) WHERE adapter = <ls_adapters>-adapter.
        ls_adapter_tree = VALUE ts_adapters_tree( adapter = <ls_adapters>-adapter
                                                  adapter_desc = <ls_adapters>-description
                                                  adapter_node_key = lv_adapter_key
                                                  data_source = <ls_data_source>-data_source
                                                  data_source_desc = <ls_data_source>-description ).

        lo_node = lo_nodes->add_node( related_node = lv_adapter_key
                                         data_row     = ls_adapter_tree
                                         relationship = cl_gui_column_tree=>relat_last_child ).
        lo_node->set_text( CONV #( ls_adapter_tree-data_source )  ).
        ls_adapter_tree-data_source_node_key = lo_node->get_key(  ).
        DATA(lo_item) = lo_node->get_hierarchy_item( ).
        lo_item->set_type( if_salv_c_item_type=>link ).

        INSERT ls_adapter_tree INTO TABLE mt_adapters_tree.

      ENDLOOP.
      IF sy-subrc NE 0.
        INSERT VALUE ts_adapters_tree( adapter = <ls_adapters>-adapter
                                       adapter_desc = <ls_adapters>-description
                                       adapter_node_key = lv_adapter_key ) INTO TABLE mt_adapters_tree.
      ENDIF.

    ENDLOOP.

    lo_nodes->expand_all(  ).

  ENDMETHOD.


  METHOD change_fcat_adapter_tree.
    DATA(lo_columns) = mo_adapter_tree->get_columns(  ).
*    lo_columns->set_optimize( abap_true ).

    DATA(lo_column) = lo_columns->get_column( 'ADAPTER' ).
    lo_column->set_technical( abap_true ).
    lo_column = lo_columns->get_column( 'ADAPTER_DESC' ).
    lo_column->set_technical( abap_true ).
    DATA(lo_column_data_source) = lo_columns->get_column( 'DATA_SOURCE' ).
    lo_column_data_source->set_technical( abap_true ).
    lo_column = lo_columns->get_column( 'DATA_SOURCE_DESC' ).
    lo_column->set_output_length( 45 ).

    " Pongo el texto de la columna de adaptador a la columna de descripción
    lo_column->set_long_text( lo_column_data_source->get_long_text(  ) ).
    lo_column->set_medium_text( lo_column_data_source->get_medium_text(  ) ).
    lo_column->set_short_text( lo_column_data_source->get_short_text(  ) ).


    lo_column = lo_columns->get_column( 'DATA_SOURCE_NODE_KEY' ).
    lo_column->set_technical( abap_true ).
    lo_column = lo_columns->get_column( 'ADAPTER_NODE_KEY' ).
    lo_column->set_technical( abap_true ).

  ENDMETHOD.


  METHOD set_function_adapter_tree.
    DATA(lo_functions) = mo_adapter_tree->get_functions( ).
    lo_functions->set_all( abap_true ).
    lo_functions->set_group_print( abap_false ).

    lo_functions->add_function(
          name     = cs_function_codes-new_data_source
          tooltip = CONV #( TEXT-f01 )
          icon = CONV #( icon_create )
          position = if_salv_c_function_position=>right_of_salv_functions ).
  ENDMETHOD.

  METHOD set_event_adapter_tree.

    DATA(lo_events) = mo_adapter_tree->get_event( ).

    SET HANDLER on_ucomm_adapter_tree FOR lo_events.
    SET HANDLER on_link_adapter_tree FOR lo_events.
  ENDMETHOD.
  METHOD on_ucomm_adapter_tree.

    CASE e_salv_function.
      WHEN cs_function_codes-new_data_source.
        mv_data_source_dynnr = cs_data_source-screens-number-edit.
        mv_data_source_action = cs_data_source-actions-create.
        mv_app_title = ms_app_title-create.
    ENDCASE.

  ENDMETHOD.
  METHOD on_link_adapter_tree.

  ENDMETHOD.


  METHOD load_initial_conf.
    " titulos de la app, que los inicializo aquí porque no puede crear constantes
    " con TEXT.
    ms_app_title-initial = TEXT-t02.
    ms_app_title-create = TEXT-t03.

    " Titulo inicial de la app
    mv_app_title = ms_app_title-initial.

    " Pantalla inicial.
    mv_data_source_dynnr = cs_data_source-screens-number-empty.
  ENDMETHOD.

  METHOD pbo_9001.

    LOOP AT SCREEN.

*  MODIFY
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
