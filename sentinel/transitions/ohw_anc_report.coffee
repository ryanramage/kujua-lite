Transition = require('./transition')
_ = require('underscore')
i18n = require('../i18n')
utils = require('../lib/utils')
date = require('../date')

module.exports = new Transition(
  filter: (doc) ->
    { form, related_entities, tasks } = doc
    { clinic } = related_entities or {}
    form is 'OANC' and clinic and tasks.length is 0
  onMatch: (change) ->
    { doc } = change
    { from, patient_id, tasks } = doc
    clinic_phone = utils.getClinicPhone(doc)
    clinic_name = utils.getClinicName(doc)
    utils.getOHWRegistration(patient_id, (err, registration) =>
      if err
        @callback(err, null)
      else
        if registration
          utils.addMessage(doc, clinic_phone, i18n("Thank you, %1$s. ANC counseling visit has been recorded.", clinic_name))
          before = date.getDate()
          before.setDate(before.getDate() + 21)
          obsoleteMessages = utils.obsoleteScheduledMessages(registration, 'anc_visit', before: before.getTime())
          @db.saveDoc(registration) if obsoleteMessages
        else
          clinic_phone = utils.getClinicPhone(doc)
          if clinic_phone
            utils.addMessage(doc, clinic_phone, i18n("No patient with id '%1$s' found.", patient_id))

        # save messages on the report so it doesn't trip this change again
        @db.saveDoc(doc, @callback)
    )
)

