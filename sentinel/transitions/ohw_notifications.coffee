Transition = require('./transition')
_ = require('underscore')
i18n = require('../i18n')
utils = require('../lib/utils')

module.exports = new Transition(
  filter: (doc) ->
    { related_entities, form, tasks } = doc
    { clinic } = related_entities or {}
    form is 'ONOT' and clinic and tasks.length is 0
  onMatch: (change) ->
    { doc } = change
    { notifications, patient_id, reason_for_deactivation } = doc

    clinic_phone = utils.getClinicPhone(doc)
    clinic_name = utils.getClinicName(doc)

    utils.getOHWRegistration(patient_id, (err, registration) =>
      if err
        @callback(err, null)
      else
        { patient_name } = registration

        if notifications
          utils.unmuteScheduledMessages(registration)
          utils.addMessage(doc, clinic_phone, i18n("Thank you, %1$s. Notifications for %2$s have been turned on.", clinic_name, patient_name))
        else
          utils.muteScheduledMessages(registration)
          utils.addMessage(doc, clinic_phone, i18n("Thank you, %1$s. All notifications for %2$s have been turned off.", clinic_name, patient_name))

        registration.muted = not notifications

        @db.saveDoc(doc, @callback)
        @db.saveDoc(registration)
    )
)



