_ = require('underscore')
util = require('util')

db = require('./db')

transitions = require('./transitions')
Transition = require('./transitions/transition')

views = _.reduce(require('./views'), (memo, view, key) ->
  memo[key] = map: view.map.toString()
  if view.reduce
    memo[key].reduce = view.reduce.toString()
  memo
, {})

require('./schedule')

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
        views: views
      , attachTransitions)
    else
      throw err
  else
    if util.inspect(doc.filters) isnt util.inspect(filters) or
        util.inspect(doc.views) isnt util.inspect(views)
      doc.filters = filters
      doc.views = views
      db.saveDoc(doc, attachTransitions)
    else
      attachTransitions(null, true)
)
