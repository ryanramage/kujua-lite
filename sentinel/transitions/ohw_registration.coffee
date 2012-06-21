Transition = require('./transition')
ids = require('../lib/ids')
_ = require('underscore')

module.exports = new Transition(
  filter: (doc) ->
    { form, patient_identifiers } = doc
    form is 'ORPT' and (not patient_identifiers or patient_identifiers.length is 0)
  onMatch: (change) ->
    { doc } = change
    doc.patient_identifiers = []
    doc.patient_identifiers.push(ids.generate(doc.patient_name))

    # set conception/expected date
    weeks = Number(doc.last_menstrual_period)
    if _.isNumber(weeks)
      lmp = new Date()
      lmp.setHours(0, 0, 0, 0) # "midnight" it
      lmp.setDate(lmp.getDate() - (7 * weeks))
      expected_date = new Date(lmp.getTime())
      expected_date.setDate(expected_date.getDate() + (7 * 40))
      doc.lmp_date = lmp.getTime()
      doc.expected_date = expected_date.getTime()

    doc.tasks ?= []
    @db.saveDoc(doc, @callback)
)
