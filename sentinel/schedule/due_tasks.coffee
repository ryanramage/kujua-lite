_ = require('underscore')
db = require('../db')

module.exports = ->
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
