_ = require('underscore')
util = require('util')

db = require('./db')
config = require('./config')

{ filters, transitions, views } = require('./transitions')

_.each(require('./views'), (view, key) ->
  views[key] = map: view.map.toString()
  if view.reduce
    views[key].reduce = view.reduce.toString()
)

completeSetup = (err, ok) ->
  throw err if err

  config.load(->
    _.each(transitions, (transition) ->
      transition.attach()
    )
    require('./schedule') # start schedule after everything setup
  )

db.getDoc('_design/kujua-sentinel', (err, doc) ->
  if err
    if err.error is 'not_found'
      db.saveDesign('kujua-sentinel',
        filters: filters
        views: views
      , completeSetup)
    else
      throw err
  else
    if util.inspect(doc.filters) isnt util.inspect(filters) or
        util.inspect(doc.views) isnt util.inspect(views)
      doc.filters = filters
      doc.views = views
      db.saveDoc(doc, completeSetup)
    else
      completeSetup(null, true)
)
