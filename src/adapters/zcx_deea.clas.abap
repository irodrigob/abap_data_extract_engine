class ZCX_DEEA definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_DYN_MSG .
  interfaces IF_T100_MESSAGE .

  constants:
    begin of EXTRACTOR_TYPE_NOT_DEFINED,
      msgid type symsgid value 'ZDEEA',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'MV_MSGV1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EXTRACTOR_TYPE_NOT_DEFINED .
  constants:
    begin of INSTANCE_CLASS_ERROR,
      msgid type symsgid value 'ZDEEA',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'MV_MSGV1',
      attr2 type scx_attrname value 'MV_MSGV2',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INSTANCE_CLASS_ERROR .
  data MV_MSGV1 type STRING .
  data MV_MSGV2 type STRING .
  data MV_MSGV3 type STRING .
  data MV_MSGV4 type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MV_MSGV1 type STRING optional
      !MV_MSGV2 type STRING optional
      !MV_MSGV3 type STRING optional
      !MV_MSGV4 type STRING optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_DEEA IMPLEMENTATION.


  method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MV_MSGV1 = MV_MSGV1 .
me->MV_MSGV2 = MV_MSGV2 .
me->MV_MSGV3 = MV_MSGV3 .
me->MV_MSGV4 = MV_MSGV4 .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
