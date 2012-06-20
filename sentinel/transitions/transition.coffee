db = require('../db')
_ = require('underscore')

class Transition
  constructor: (options = {}) ->
    { @callback, @filter, @onMatch } = options
    @callback ?= (err, doc) ->
      # do nothing after updating the document
    @filter ?= (doc, req) ->
      # reject every document from the filter
      false
    @onMatch ?= (change) ->
      # do nothing with the change
      false
  update: (doc) ->
    @db.saveDoc(doc, @callback)
  attach: (filter) ->
    db.changes(filter: "kujua-sentinel/#{filter}", include_docs: true, (err, data) =>
      _.map(data.results, (change) ->
        changed = @onMatch(change)
        if changed
          db.saveDoc(change.doc, @callback)
        else
          @callback(null, false)
      , @)
    )

module.exports = Transition
