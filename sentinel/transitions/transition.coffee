_ = require('underscore')

class Transition
  constructor: (options = {}) ->
    @db = require('../db')
    { @callback, @filter, @onMatch } = options
    @callback ?= (err, doc) ->
      # do nothing after updating the document
    @filter ?= (doc, req) ->
      # reject every document from the filter
      false
    @onMatch ?= (change) ->
      # go straight to the callback with false
      @callback(null, false)
  attach: (filter) ->
    @db.changes(filter: "kujua-sentinel/#{filter}", include_docs: true, (err, data) =>
      _.map(data.results, (change) ->
        @onMatch(change)
      , @)
    )
    stream = @db.changesStream(filter: "kujua-sentinel/#{filter}", include_docs: true)
    # TODO add couchdb error handling e.g. if the stream closes
    stream.on('data', (change) =>
      @onMatch(change)
    )

module.exports = Transition
