INTERFACE zif_dee_data
  PUBLIC .

  CONSTANTS: BEGIN OF cs_messages,
               id_general       TYPE symsgid VALUE 'ZDEE',
               id_adapters      TYPE symsgid VALUE 'ZDEET',
               id_chain_process TYPE symsgid VALUE 'ZDEEC',
               type_error       TYPE symsgty VALUE 'E',
               type_success     TYPE symsgty VALUE 'S',
               type_warning     TYPE symsgty VALUE 'W',
             END OF cs_messages.

ENDINTERFACE.
