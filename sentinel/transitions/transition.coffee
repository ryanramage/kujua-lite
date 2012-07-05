_ = require('underscore')

class Transition
  constructor: (options = {}) ->
    { @code, @dependencies, @form, @onMatch, @required_fields } = options

    throw new Error('Code is a required field for a Transition.') unless @code

    @required_fields ?= []
    @required_fields = [ @required_fields ] if _.isString(@required_fields)

    @dependencies ?= []
    @dependencies = [ @dependencies ] if _.isString(@dependencies)

    @generateFilter()

    @db = require('../db')
    _.extend(@, options)
    @onMatch ?= (change) ->
      @complete(null, change.doc)
  complete: (err, doc) ->
    throw JSON.stringify(err) if err

    if doc
      doc.transitions ?= []
      doc.transitions.push(@code)
      doc.transitions = _.unique(doc.transitions)
      @db.saveDoc(doc, (err, result) ->
        console.error(JSON.stringify(err)) if err
      )
  generateFilter: ->
    @filter = ((doc)->
      transitions = doc.transitions ?= []

      return false if transitions.indexOf('__CODE__') >= 0

      form = '__FORM__'
      return false if form and doc.form isnt form

      test = (obj, fields, negate) ->
        fields = fields.split('.') unless Array.isArray(fields)
        field = fields.shift()
        if obj?[field] and fields.length
          test(obj[field], fields, negate)
        else
          result = !!obj?[field]
          if negate then !result else result

      required_fields = '__REQUIRED_FIELDS__'
      if required_fields is ''
        required_fields = []
      else
        required_fields = required_fields.split(' ')

      fields_match = required_fields.every((field) ->
        negate = field.indexOf('!') is 0
        test(doc, field.replace(/^!/, ''), negate)
      )

      deps = '__DEPENDS__'.split(' ')
      deps_met = deps.every((dependency) ->
        dependency is '' or transitions.indexOf(dependency) >= 0
      )
      deps_met and fields_match
    ).toString()
      .replace(/'__FORM__'/g, "'#{@form or ''}'")
      .replace(/'__CODE__'/g, "'#{@code}'")
      .replace(/'__DEPENDS__'/g, "'#{@dependencies.join(' ')}'")
      .replace(/'__REQUIRED_FIELDS__'/g, "'#{@required_fields.join(' ')}'")
  checkChanges: ->
    @db.changes(filter: "kujua-sentinel/#{@code}", include_docs: true, (err, data) =>
      _.map(data.results, (change) ->
        @onMatch(change)
      , @)
    )
  attach: ->
    @checkChanges()
    setInterval(=>
      @checkChanges()
    , 1000 * 60 * 15)
    stream = @db.changesStream(filter: "kujua-sentinel/#{@code}", include_docs: true)
    # TODO add couchdb error handling e.g. if the stream closes
    stream.on('data', (change) =>
      @onMatch(change)
    )
module.exports = Transition
