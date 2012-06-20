couchdb = require('felix-couchdb')
client = couchdb.createClient(5984, 'localhost')
db = client.db('fakedb')

class Transition
  constructor: (@db, options) ->
    _.defaults(options,
      callback: (err, doc) ->
        # do nothing
      when: (doc) ->
        false # never do anything
      then: (doc) ->
        # do nothing
    )
    { @when, @then } = options
  update: (doc) ->
    @db.saveDoc(doc, @callback)
  run: (doc) ->
    if @when(doc) and @then(doc)
      @update(doc)

assign_id = new Transition(db,
  when: (doc) ->
    { patient_identifiers } = doc
    if patient_identifiers and patient_identifiers.length > 0
      false
    else
      true
  then: (doc) ->
    doc.patient_identifiers ?= []
    { patient_identifiers } = doc
    patient_identifiers.push(new Date().getTime() + '')
)
