Transition = require('./transition')
_ = require('underscore')
utils = require('../lib/utils')
i18n = require('../i18n')

module.exports = new Transition(
  code: 'ohw_danger_sign'
  form: 'ODGR'
  required_fields: 'patient_id related_entities.clinic'
  onMatch: (change) ->
    { doc } = change
    { danger_sign, from, patient_id, patient_name, tasks } = doc
    parent_phone = utils.getParentPhone(doc)
    utils.getOHWRegistration(patient_id, (err, registration) =>
      if registration
        { danger_signs, patient_name, scheduled_tasks } = registration

        name = utils.getClinicName(doc)
        utils.addMessage(doc, from, i18n("Thank you. Danger sign %1$s has been recorded.", danger_sign))

        danger_signs ?= []
        danger_signs.push(doc.danger_sign)
        registration.danger_signs = _.unique(danger_signs)

        _.each(scheduled_tasks, (task) ->
          { messages, type } = task
          if type is 'upcoming_delivery'
            messages[0].message = i18n("Greetings, %1$s. %2$s is due to deliver soon. This pregnancy has been flagged as high-risk.", name, patient_name)
        )
        if parent_phone
          utils.addMessage(doc, parent_phone, i18n("%1$s has reported danger sign %2$s is present in %3$s. Please follow up.", name, danger_sign, patient_name))
        @db.saveDoc(registration, (err) =>
          @complete(err, doc)
        )
      else
        clinic_phone = utils.getClinicPhone(doc)
        if clinic_phone
          utils.addMessage(doc, clinic_phone, i18n("No patient with id '%1$s' found.", patient_id))
          @complete(null, doc)
    )
)
