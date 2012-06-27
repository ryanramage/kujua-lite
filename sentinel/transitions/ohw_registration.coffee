Transition = require('./transition')
ids = require('../lib/ids')
i18n = require('../i18n')
_ = require('underscore')

module.exports = new Transition(
  filter: (doc) ->
    { related_entities, form, patient_identifiers } = doc
    form is 'ORPT' and related_entities?.clinic and (not patient_identifiers or patient_identifiers.length is 0)
  onMatch: (change) ->
    { doc } = change
    doc.patient_identifiers = []
    doc.patient_identifiers.push(ids.generate(doc.patient_name))

    # set conception/expected date
    weeks = Number(doc.last_menstrual_period)
    if _.isNumber(weeks)
      lmp = new Date()
      lmp.setHours(0, 0, 0, 0) # "midnight" it
      lmp.setDate(lmp.getDate() - (7 * weeks))
      expected_date = new Date(lmp.getTime())
      expected_date.setDate(expected_date.getDate() + (7 * 40))
      doc.lmp_date = lmp.getTime()
      doc.expected_date = expected_date.getTime()
      @scheduleReminders(doc)
      @addAcknowledgement(doc)
    @db.saveDoc(doc, @callback)
  addAcknowledgement: (doc) ->
    { from, patient_identifiers, patient_name, scheduled_tasks, tasks } = doc
    visit = _.find(scheduled_tasks, (task) ->
      task.type is 'anc_visit'
    )
    if visit
      interval = visit.due - new Date().getTime()
      weeks = Math.round(interval / ( 7 * 24 * 60 * 60 * 1000))

      tasks.unshift(
        messages: [
          {
            to: from
            message: i18n('Thank you for registering %1$s. Patient ID is %2$s. Next ANC visit is in %3$s weeks.',
              patient_name, _.first(patient_identifiers), weeks
            )
          }
        ]
        state: 'pending'
      )
  calculateDate: (doc, weeks) ->
    reminder_date = new Date(doc.lmp_date)
    reminder_date.setDate(reminder_date.getDate() + (weeks * 7))
    reminder_date
  scheduleReminders: (doc) ->
    doc.scheduled_tasks ?= []
    { from, lmp_date, patient_name, related_entities, scheduled_tasks, tasks } = doc
    lmp = new Date(lmp_date)
    now = new Date()
    name = related_entities?.clinic?.name or 'health volunteer'
    _.each([16, 24, 32, 36], (weeks) ->
      reminder_date = @calculateDate(doc, weeks)
      if reminder_date > now
        scheduled_tasks.push(
          due: reminder_date.getTime()
          messages: [
            {
              to: from
              message: i18n('Greetings, %1$s. %2$s is due for an ANC visit this week.', name, patient_name)
            }

          ]
          state: 'scheduled'
          type: 'anc_visit'
        )
    , @)
    scheduled_tasks.push(
      due: @calculateDate(doc, 32).getTime()
      messages: [
        {
          to: from
          message: i18n("Greetings, %1$s. It's now %2$s's 8th month of pregnancy. If you haven't given Miso, please distribute. Make birth plan now. Thank you!",
            name, patient_name
          )
        }
      ]
      state: 'scheduled'
      type: 'miso_reminder'
    )
    scheduled_tasks.push(
      due: @calculateDate(doc, 37).getTime()
      messages: [
        {
          to: from
          message: i18n("Greetings, %1$s. %2$s is due to deliver soon.", name, patient_name)
        }
      ]
      state: 'scheduled'
      type: 'upcoming_delivery'
    )
    scheduled_tasks.push(
      due: @calculateDate(doc, 41).getTime()
      messages: [
        {
          to: from
          message: i18n("Greetings, %1$s. Please submit the birth report for %2$s.", name, patient_name)
        }
      ]
      state: 'scheduled'
      type: 'outcome_request'
    )
)
