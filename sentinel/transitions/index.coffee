_ = require('underscore')
fs = require('fs')

module.exports = _.reduce(fs.readdirSync('./transitions'), (memo, file) ->
  try
    unless _.contains(['index.coffee', 'transition.coffee'], file)
      transition = require("./#{file}")
      memo[file.replace(/\.coffee$/, '')] = transition
  catch e
    # do nothing
    console.error(e)
  memo
, {})
