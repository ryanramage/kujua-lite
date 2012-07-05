_ = require('underscore')
fs = require('fs')

keys = []
filters = {}
views = {}

transitions = _.compact(_.map(fs.readdirSync('./transitions'), (file) ->
  try
    unless _.contains(['index.coffee', 'transition.coffee'], file)
      transition = require("./#{file}")

      key = file.replace(/\.coffee$/, '')
      keys.push(key)

      if transition.filter
        filters[key] = transition.filter.toString()

      if transition.view
        views[key] = transition.view

      transition
  catch e
    # do nothing
    console.error(e)
))

module.exports =
  filters: filters
  keys: keys
  transitions: transitions
  views: views
