db = require('./db')
_ = require('underscore')

check_schedule = ->
  # only send between 9am and 6pm
  return unless 8 < new Date().getHours() < 18

  db.view('kujua-sentinel', 'due_tasks', (err, data) ->
    _.each(data.rows, (row) ->
      { key, value } = row
      [ _id, _rev ] = key
      db.getDoc(_id, _rev, (err, doc) ->
        { scheduled_tasks, tasks } = doc
        updated = false
        _.each(value, (index) ->
          [ to_do ] = scheduled_tasks.splice(index, 1)
          if to_do
            tasks.push(
              messages: to_do.messages
              state: 'pending'
            )
            updated = true
        )
        db.saveDoc(doc) if updated
      )
    )
  )

  next_heartbeat = new Date()
  now = new Date().getTime()
  next_heartbeat.setHours(next_heartbeat.getHours() + 1)
  next_heartbeat.setMinutes(0, 0, 0)
  next_heartbeat = next_heartbeat.getTime() - now
  console.log("Checking again in #{next_heartbeat} milliseconds...")
  setTimeout(check_schedule, next_heartbeat)

check_schedule()
