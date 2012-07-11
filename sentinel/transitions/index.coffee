_ = require('underscore')
fs = require('fs')

result = _.reduce(fs.readdirSync('./transitions'), (memo, file) ->
  try
    unless _.contains(['index.coffee', 'transition.coffee'], file)
      transition = require("./#{file}")

      key = file.replace(/\.coffee$/, '')
      memo.keys.push(key)

      if transition.filter
        memo.filters[key] = transition.filter.toString()

      if transition.view
        memo.views[key] = transition.view

      memo.transitions[key] = transition
  catch e
    # do nothing
    console.error(e)
  memo
, {
  filters: {}
  keys: []
  transitions: {}
  views: {}
})

module.exports = result
