Transition = require('./transition')
i18n = require('../i18n')
_ = require('underscore')
utils = require('../lib/utils')

module.exports = new Transition(
  filter: (doc) ->
    { related_entities, form, tasks } = doc
    { clinic } = related_entities or {}
    tasks ?= []
    form is 'OLAB' and clinic and tasks.length is 0
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
          utils.addMessage(doc, clinic_phone, i18n("Thank you %1$s. This pregnancy is high-risk. Call nearest health worker or SBA.", clinic_name))
          utils.addMessage(doc, parent_phone, i18n("%1$s has reported labor has started for %2$s. This pregnancy is high-risk.", clinic_name, patient_name))
        else
          utils.addMessage(doc, clinic_phone, i18n("Thank you %1$s. Please submit birth report after baby is delivered.", clinic_name))
      else if clinic_phone
        utils.addMessage(doc, clinic_phone, i18n("No patient with id '%1$s' found.", patient_id))

      # save messages on the report so it doesn't trip this change again
      @db.saveDoc(doc)
    )
)

