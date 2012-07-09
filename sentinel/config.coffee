db = require('./db')

config = {}

fetchConfig = (callback, count = 0) ->
  db.getDoc('ohw-configuration', (err, doc) ->
    if err
      if count is 0
        doc =
          anc_reminder_schedule_weeks: [16, 24, 32, 36]
          miso_reminder_weeks: 32
          upcoming_delivery_weeks: 37
          outcome_request_weeks: 41
          pnc_schedule_days: [1, 3, 7]
          low_weight_pnc_schedule_days: [1..7]
          obsolete_anc_reminders_days: 21

        db.saveDoc('ohw-configuration', doc, fetchConfig(count++))
      else
        throw err
    else
      config = doc
      callback()
  )

module.exports =
  get: (key) ->
    config[key]
  load: fetchConfig
