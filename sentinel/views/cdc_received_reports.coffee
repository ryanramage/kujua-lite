module.exports =
  map: (doc) ->
    { form, related_entities, week, year } = doc
    { clinic } = related_entities or {}
    if form is 'CNPW' and clinic
      emit([clinic, year, week], null)
