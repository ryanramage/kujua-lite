module.exports =
  map: (doc) ->
    { form, related_entities, week_number, year } = doc
    { clinic } = related_entities or {}
    if form is 'CNPW' and clinic
      emit([clinic, year, week_number], null)
