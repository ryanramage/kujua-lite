module.exports =
  map: (doc) ->
    { type, recipient } = doc
    if type is 'cdc_reminder' and recipient
      emit(recipient, doc)
