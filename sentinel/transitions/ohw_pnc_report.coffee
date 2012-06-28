Transition = require('./transition')
_ = require('underscore')
i18n = require('../i18n')
utils = require('../lib/utils')

module.exports = new Transition(
  filter: (doc) ->
    { related_entities, form, tasks } = doc
    { clinic } = related_entities or {}
    form is 'OPNC' and clinic and tasks.length is 0
  onMatch: (change) ->
    { doc } = change
    { child_weight, patient_id } = doc

    clinic_phone = utils.getClinicPhone(doc)
    clinic_name = utils.getClinicName(doc)

    utils.getOHWRegistration(patient_id, (err, registration) =>
      if err
        @callback(err, null)
      else
        previous_weight = registration.child_weight or registration.child_birth_weight
        if child_weight isnt 'Normal' and previous_weight is 'Normal'
          utils.addMessage(doc, clinic_phone, i18n("Thank you, %1$s. This child is low birth weight. provide extra thermal protection for baby, feed the baby every two hours, visit the family every day to check the baby for the first week, watch for signs of breathing difficulty. Refer danger signs immediately to health facility.", clinic_name))
        else
          utils.addMessage(doc, clinic_phone, i18n("Thank you, %1$s. PNC counseling visit has been recorded.", clinic_name))
        @db.saveDoc(doc, @callback)
        registration.child_weight = child_weight
        @db.saveDoc(registration)
    )
)


