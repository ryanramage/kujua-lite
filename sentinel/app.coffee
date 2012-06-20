_ = require('underscore')
util = require('util')

db = require('./db')

transitions = require('./transitions')
Transition = require('./transitions/transition')

filters = _.reduce(transitions, (memo, transition, key) ->
  memo[key] = transition.filter.toString()
  memo
, {})

attachTransitions = (err, ok) ->
  _.each(transitions, (transition, filter) ->
    transition.attach(filter)
  )

db.getDoc('_design/kujua-sentinel', (err, doc) ->
  if err
    if err.error is 'not_found'
      db.saveDesign('kujua-sentinel',
        filters: filters
      , attachTransitions)
    else
      throw err
  else
    if util.inspect(doc.filters) isnt util.inspect(filters)
      doc.filters = filters
      db.saveDoc(doc, attachTransitions)
    else
      attachTransitions(null, true)
)
