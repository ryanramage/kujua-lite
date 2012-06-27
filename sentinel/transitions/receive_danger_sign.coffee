Transition = require('./transition')
_ = require('underscore')
utils = require('../lib/utils')
i18n = require('../i18n')

module.exports = new Transition(
  filter: (doc) ->
    { form, tasks } = doc
    form is 'ODGR' and tasks.length is 0
  onMatch: (change) ->
    { doc } = change
    { danger_sign, from, patient_name, tasks } = doc
    name = utils.getClinicName(doc)
    tasks.push(
      messages: [
        {
          to: from
          message: i18n("Thank you. Danger sign %1$s has been recorded.", danger_sign)
        }
      ]
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
            messages[0].message = i18n("Greetings, %1$s. %2$s is due to deliver soon. This pregnancy has been flagged as high-risk.", name, patient_name)
        )
        @db.saveDoc(registration)
        if parent_phone
          tasks.push(
            messages: [
              {
                to: parent_phone
                message: i18n("%1$s has reported danger sign %2$s is present in %3$s. Please follow up.", name, danger_sign, patient_name)
              }
            ]
            state: 'pending'
          )
          @db.saveDoc(doc, @callback)
        else
          @callback(null, false)
      else
        @callback(null, false)
    )
)
