Transition = require('./transition')
ids = require('../lib/ids')
i18n = require('../i18n')
_ = require('underscore')
date = require('../date')
utils = require('../lib/utils')
config = require('../config')

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

      utils.addMessage(doc, from, i18n("Thank you for registering {{patient_name}}. Patient ID is {{patient_id}}. Next ANC visit is in {{weeks}} weeks.",
        patient_name: patient_name, patient_id: _.first(patient_identifiers), weeks: weeks
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
    _.each(config.get('anc_reminder_schedule_weeks'), (weeks) ->
      reminder_date = @calculateDate(doc, weeks)
      if reminder_date > now
        utils.addScheduledMessage(doc,
          due: reminder_date
          message: i18n("Greetings, {{clinic_name}}. {{patient_name}} is due for an ANC visit this week.", clinic_name: name, patient_name: patient_name)
          phone: from
          type: 'anc_visit'
        )
    , @)
    utils.addScheduledMessage(doc,
      due: @calculateDate(doc, config.get('miso_reminder_weeks'))
      message: i18n("Greetings, {{clinic_name}}. It's now {{patient_name}}'s 8th month of pregnancy. If you haven't given Miso, please distribute. Make birth plan now. Thank you!",
        clinic_name: name, patient_name: patient_name
      )
      phone: from
      type: 'miso_reminder'
    )
    utils.addScheduledMessage(doc,
      due: @calculateDate(doc, config.get('upcoming_delivery_weeks'))
      message: i18n("Greetings, {{clinic_name}}. {{patient_name}} is due to deliver soon.", clinic_name: name, patient_name: patient_name)
      phone: from
      type: 'upcoming_delivery'
    )
    utils.addScheduledMessage(doc,
      due: @calculateDate(doc, config.get('outcome_request_weeks'))
      message: i18n("Greetings, {{clinic_name}}. Please submit the birth report for {{patient_name}}.", clinic_name: name, patient_name: patient_name)
      phone: from
      type: 'outcome_request'
    )
)
