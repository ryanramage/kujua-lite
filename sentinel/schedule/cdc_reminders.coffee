_ = require('underscore')
db = require('../db')

module.exports = ->
  db.view('kujua-base', 'clinic_by_phone', (err, data) ->
    throw err if err
    clinics = _.map(data.rows, (row) ->
      row.value
    )
    db.view('kujua-sentinel', 'sent_cdc_reminders', (err, data) ->
      throw err if err
      sent = _.map(data.rows, (row) ->
        row.value?._id
      )
      unsent = _.reject(clinics, (clinic) ->
        _.include(sent, clinic._id)
      )
      console.log("Unsent: #{unsent.length}")
    )
  )
