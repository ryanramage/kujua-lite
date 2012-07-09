Transition = require('./transition')
i18n = require('../i18n')
_ = require('underscore')
utils = require('../lib/utils')

module.exports = new Transition(
  code: 'ohw_labor_report'
  form: 'OLAB'
  required_fields: 'related_entities.clinic patient_id'
  onMatch: (change) ->
    { doc } = change
    { patient_id } = doc
    utils.getOHWRegistration(patient_id, (err, registration) =>
      clinic_phone = utils.getClinicPhone(doc)
      if registration
        { patient_name } = registration
        clinic_phone = utils.getClinicPhone(registration) # in case different?
        clinic_name = utils.getClinicName(registration)
        parent_phone = utils.getParentPhone(registration)
        high_risk = registration.danger_signs?.length > 0
        if high_risk
          utils.addMessage(doc, clinic_phone, i18n("Thank you {{clinic_name}}. This pregnancy is high-risk. Call nearest health worker or SBA.", clinic_name: clinic_name))
          utils.addMessage(doc, parent_phone, i18n("{{clinic_name}} has reported labor has started for {{patient_name}}. This pregnancy is high-risk.", clinic_name: clinic_name, patient_name: patient_name))
        else
          utils.addMessage(doc, clinic_phone, i18n("Thank you {{clinic_name}}. Please submit birth report after baby is delivered.", clinic_name: clinic_name))
      else if clinic_phone
        utils.addMessage(doc, clinic_phone, i18n("No patient with id '{{patient_id}}' found.", patient_id))

      # save messages on the report so it doesn't trip this change again
      @complete(err, doc)
    )
)
