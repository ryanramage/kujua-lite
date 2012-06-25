module.exports =
  getClinicName: (doc) ->
    doc.related_entities?.clinic?.name or 'health volunteer'
  getParentPhone: (doc) ->
    doc.related_entities?.clinic?.parent?.contact?.phone
