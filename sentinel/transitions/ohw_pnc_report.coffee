Transition = require('./transition')
_ = require('underscore')
i18n = require('../i18n')
utils = require('../lib/utils')

module.exports = new Transition(
  code: 'ohw_pnc_report'
  form: 'OPNC'
  required_fields: 'related_entities.clinic'
  onMatch: (change) ->
    { doc } = change
    { child_weight, patient_id } = doc

    clinic_phone = utils.getClinicPhone(doc)
    clinic_name = utils.getClinicName(doc)

    utils.getOHWRegistration(patient_id, (err, registration) =>
      if err
        @complete(err, null)
      else
        { child_weight, child_birth_weight, patient_name } = registration
        previous_weight = child_weight or child_birth_weight
        if child_weight isnt 'Normal' and previous_weight is 'Normal'
          utils.addMessage(doc, clinic_phone, i18n("Thank you, {{clinic_name}}. This child is low birth weight. provide extra thermal protection for baby, feed the baby every two hours, visit the family every day to check the baby for the first week, watch for signs of breathing difficulty. Refer danger signs immediately to health facility.", clinic_name: clinic_name))
        else
          utils.addMessage(doc, clinic_phone, i18n("Thank you, {{clinic_name}}. PNC counseling visit has been recorded for {{patient_name}}.", clinic_name: clinic_name, patient_name: patient_name))
        registration.child_weight = child_weight
        @db.saveDoc(registration, (err, result) =>
          @complete(err, doc)
        )
    )
)
