Transition = require('./transition')
ids = require('../lib/ids')

module.exports = new Transition(
  filter: (doc) ->
    { form, patient_identifiers } = doc
    form is 'ORPT' and (not patient_identifiers or patient_identifiers.length is 0)
  onMatch: (change) ->
    { doc } = change
    doc.patient_identifiers = []
    doc.patient_identifiers.push(ids.generate(new Date().getTime() * Math.random(), doc.patient_name))
    @db.saveDoc(doc, @callback)
    true
)
