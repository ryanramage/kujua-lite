Transition = require('./transition')
_ = require('underscore')
i18n = require('../i18n')
utils = require('../lib/utils')

module.exports = new Transition(
  code: 'ohw_notifications'
  form: 'ONOT'
  required_fields: 'related_entities.clinic'
  onMatch: (change) ->
    { doc } = change
    { notifications, patient_id, reason_for_deactivation } = doc

    clinic_phone = utils.getClinicPhone(doc)
    clinic_name = utils.getClinicName(doc)

    utils.getOHWRegistration(patient_id, (err, registration) =>
      if err
        @complete(err, null)
      else
        { patient_name } = registration

        if notifications
          utils.unmuteScheduledMessages(registration)
          utils.addMessage(doc, clinic_phone, i18n("Thank you, {{clinic_name}}. Notifications for {{patient_name}} have been turned on.", clinic_name: clinic_name, patient_name: patient_name))
        else
          utils.muteScheduledMessages(registration)
          utils.addMessage(doc, clinic_phone, i18n("Thank you, {{clinic_name}}. All notifications for {{patient_name}} have been turned off.", clinic_name: clinic_name, patient_name: patient_name))

        registration.muted = not notifications

        @db.saveDoc(registration, (err) =>
          @complete(err, doc)
        )
    )
)
