Transition = require('./transition')
i18n = require('../i18n')
_ = require('underscore')
utils = require('../lib/utils')
ids = require('../lib/ids')

module.exports = new Transition(
  filter: (doc) ->
    { related_entities, form, tasks } = doc
    { clinic } = related_entities or {}
    tasks ?= []
    form is 'OBIR' and clinic and tasks.length is 0
  onMatch: (change) ->
    { doc } = change
    { birth_weight, days_since_delivery, outcome_child, patient_id, reported_date } = doc
    utils.getOHWRegistration(patient_id, (err, registration) =>
      if registration
        { patient_name } = registration
        clinic_phone = utils.getClinicPhone(registration)
        clinic_name = utils.getClinicName(registration)
        parent_phone = utils.getParentPhone(registration)
        registration.child_id = child_id = ids.generate("child of #{patient_name}")
        registration.child_outcome = outcome_child
        registration.child_birth_weight = birth_weight

        child_birth_date = new Date(reported_date)
        child_birth_date.setHours(0, 0, 0, 0)
        child_birth_date.setDate(child_birth_date.getDate() - days_since_delivery)
        registration.child_birth_date = child_birth_date.getTime()

        if outcome_child is 'Deceased'
          utils.addMessage(doc, clinic_phone, i18n("Thank you for your report."))
          utils.addMessage(doc, parent_phone, i18n("%1$s has reported the child of %2$s as deceased.", clinic_name, patient_name))
        else
          if birth_weight is 'Normal'
            utils.addMessage(doc, clinic_phone, i18n("Thank you, %1$s. Child ID is %2$s", clinic_name, child_id))
            @scheduleReminders(registration, 1, 3, 7)
          else
            utils.addMessage(doc, clinic_phone, i18n("Thank you, %1$s. This child (ID %2$s) is low birth weight. Provide extra thermal protection for baby, feed the baby every two hours, visit the family every day to check the baby for the first week, watch for signs of breathing difficulty. Refer danger signs immediately to health facility.", clinic_name, child_id))
            utils.addMessage(doc, parent_phone, i18n("%1$s has reported the child of %2$s as %3$s birth weight.", clinic_name, patient_name, birth_weight))
            @scheduleReminders(registration, [1..7])
        @db.saveDoc(registration)
      else
        clinic_phone = utils.getClinicPhone(doc)
        if clinic_phone
          utils.addMessage(doc, clinic_phone, i18n("No patient with id '%1$s' found.", patient_id))

      # save messages on the report so it doesn't trip this change again
      @db.saveDoc(doc)
    )
  scheduleReminders: (registration, days...) ->
    utils.clearScheduledMessages(registration, 'anc_visit', 'miso_reminder', 'upcoming_delivery', 'pnc_visit', 'pnc_reminder', 'outcome_request')

    { child_birth_date, patient_name } = registration

    clinic_name = utils.getClinicName(registration)
    clinic_phone = utils.getClinicPhone(registration)

    birth = new Date(child_birth_date)
    now = new Date()
    days = _.flatten(days)
    _.each(days, (day) ->
      marker = new Date(birth.getTime())
      marker.setDate(marker.getDate() + day)
      if marker > now
        utils.addScheduledMessage(registration,
          due: marker
          message: i18n("Greetings, %1$s. %2$s is due for a PNC visit today.", clinic_name, patient_name)
          phone: clinic_phone
          type: 'pnc_visit'
        )
    )
)


