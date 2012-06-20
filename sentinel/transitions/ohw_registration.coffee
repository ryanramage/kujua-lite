Transition = require('./transition')

module.exports = new Transition(
  filter: (doc) ->
    { form, patient_identifiers } = doc
    form is 'ORPT' and not patient_identifiers
  onMatch: (change) ->
    { doc } = change
    doc.patient_identifiers = []
    doc.patient_identifiers.push
    true
)
