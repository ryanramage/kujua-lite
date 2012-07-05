Transition = require('./transition')
ids = require('../lib/ids')
i18n = require('../i18n')
_ = require('underscore')
date = require('../date')
utils = require('../lib/utils')

module.exports = new Transition(
  code: 'ohw_registration'
  form: 'ORPT'
  dependencies: 'add_clinic'
  required_fields: 'related_entities.clinic'
  onMatch: (change) ->
    { doc } = change
    doc.patient_identifiers = []
    doc.patient_identifiers.push(ids.generate(doc.patient_name))

    # set conception/expected date
    weeks = Number(doc.last_menstrual_period)
    if _.isNumber(weeks)
      lmp = date.getDate()
      lmp.setHours(0, 0, 0, 0) # "midnight" it
      lmp.setDate(lmp.getDate() - (7 * weeks))
      expected_date = new Date(lmp.getTime())
      expected_date.setDate(expected_date.getDate() + (7 * 40))
      doc.lmp_date = lmp.getTime()
      doc.expected_date = expected_date.getTime()
      @scheduleReminders(doc)
      @addAcknowledgement(doc)
      @complete(null, doc)
  addAcknowledgement: (doc) ->
    { from, patient_identifiers, patient_name, scheduled_tasks, tasks } = doc
    visit = utils.findScheduledMessage(doc, 'anc_visit')
    if visit
      interval = visit.due - date.getDate().getTime()
      weeks = Math.round(interval / ( 7 * 24 * 60 * 60 * 1000))

      utils.addMessage(doc, from, i18n('Thank you for registering %1$s. Patient ID is %2$s. Next ANC visit is in %3$s weeks.',
        patient_name, _.first(patient_identifiers), weeks
      ))
  calculateDate: (doc, weeks) ->
    reminder_date = new Date(doc.lmp_date)
    reminder_date.setDate(reminder_date.getDate() + (weeks * 7))
    reminder_date
  scheduleReminders: (doc) ->
    { from, lmp_date, patient_name, related_entities, scheduled_tasks, tasks } = doc
    lmp = new Date(lmp_date)
    now = date.getDate()
    name = utils.getClinicName(doc)
    _.each([16, 24, 32, 36], (weeks) ->
      reminder_date = @calculateDate(doc, weeks)
      if reminder_date > now
        utils.addScheduledMessage(doc,
          due: reminder_date
          message: i18n('Greetings, %1$s. %2$s is due for an ANC visit this week.', name, patient_name)
          phone: from
          type: 'anc_visit'
        )
    , @)
    utils.addScheduledMessage(doc,
      due: @calculateDate(doc, 32)
      message: i18n("Greetings, %1$s. It's now %2$s's 8th month of pregnancy. If you haven't given Miso, please distribute. Make birth plan now. Thank you!",
        name, patient_name
      )
      phone: from
      type: 'miso_reminder'
    )
    utils.addScheduledMessage(doc,
      due: @calculateDate(doc, 37)
      message: i18n("Greetings, %1$s. %2$s is due to deliver soon.", name, patient_name)
      phone: from
      type: 'upcoming_delivery'
    )
    utils.addScheduledMessage(doc,
      due: @calculateDate(doc, 41)
      message: i18n("Greetings, %1$s. Please submit the birth report for %2$s.", name, patient_name)
      phone: from
      type: 'outcome_request'
    )
)
