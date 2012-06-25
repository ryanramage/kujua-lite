Transition = require('./transition')
_ = require('underscore')
utils = require('../lib/utils')

module.exports = new Transition(
  filter: (doc) ->
    { form, tasks } = doc
    form is 'ODGR' and tasks.length is 0
  onMatch: (change) ->
    { doc } = change
    { danger_sign, from, patient_name, tasks } = doc
    name = utils.getClinicName(doc)
    tasks.push(
      messages: [ to: from, message: "Thank you. Danger sign #{danger_sign} has been recorded." ]
      state: 'pending'
    )
    parent_phone = utils.getParentPhone(doc)
    @db.view('kujua-sentinel', 'ohw_registered_patients', key: doc.patient_id, limit: 1, (err, data) =>
      { rows } = data
      if rows.length is 1
        row = rows[0]
        registration = row.value
        { danger_signs, patient_name, scheduled_tasks } = registration

        name = utils.getClinicName(doc)

        danger_signs ?= []
        danger_signs.push(doc.danger_sign)
        registration.danger_signs = _.unique(danger_signs)

        _.each(scheduled_tasks, (task) ->
          { messages, type } = task
          if type is 'upcoming_delivery'
            messages[0].message = "Greetings, #{name}. #{patient_name} is due to deliver soon. This pregnancy has been flagged as high-risk."
        )
        @db.saveDoc(registration)
        if parent_phone
          tasks.push(
            messages: [ to: parent_phone, message: "#{name} has reported danger sign #{danger_sign} is present in #{patient_name}. Please follow up." ]
            state: 'pending'
          )
          @db.saveDoc(doc, @callback)
        else
          @callback(null, false)
      else
        @callback(null, false)
    )
)
