vows = require('vows')
should = require('should')

{ transitions, Transition } = require('../transitions')

getTransition = (weight) ->
  transition = new Transition('ohw_pnc_report', transitions.ohw_pnc_report)
  transition.db =
    saveDoc: (registration, callback) ->
      callback()

  transition.getOHWRegistration = (patient_id, callback) ->
    obsolete_date = new Date()
    obsolete_date.setDate(obsolete_date.getDate() + 20)

    okay_date = new Date()
    okay_date.setDate(okay_date.getDate() + 22)

    if patient_id is 'AA'
      callback(null,
        child_weight: weight
        patient_name: 'Patient'
        scheduled_tasks: [
          {
            due: obsolete_date.getTime()
            marker: 'obsolete'
            state: 'scheduled'
            messages: []
            type: 'anc_visit'
          }
          {
            due: okay_date.getTime()
            marker: 'okay'
            state: 'scheduled'
            messages: []
            type: 'anc_visit'
          }
          {
            due: obsolete_date.getTime()
            marker: 'other'
            state: 'scheduled'
            messages: []
            type: 'other_thing'
          }
        ]
      )
    else
      callback(null, false)
  transition

vows.describe('test receiving pnc reports').addBatch(
  'filter generated for pnc reports':
    topic: ->
      filter = undefined
      transition = new Transition('ohw_pnc_report', transitions.ohw_pnc_report)
      eval("""filter = #{transition.filter} """)
    'filter should require a clinic': (filter) ->
      filter(
        form: 'OPNC'
        related_entities:
          clinic: null
      ).should.eql(false)
    'filter should require the right form': (filter) ->
      filter(
        form: 'OQT'
        related_entities:
          clinic: {}
      ).should.eql(false)
    'filter should work with right form and clinic': (filter) ->
      filter(
        form: 'OPNC'
        related_entities:
          clinic: {}
      ).should.eql(true)
  'onMatch adds Normal acknowledgement':
    topic: ->
      getTransition('Normal')
    'tasks added for normal weight': (transition) ->
      transition.complete = (err, doc) ->
        doc.tasks.length.should.eql(1)
        message = doc.tasks[0].messages[0].message
        message.should.be.eql('Thank you, foo. PNC counseling visit has been recorded for Patient.')
      transition.onMatch(
        doc:
          child_weight: 'Normal'
          patient_id: 'AA'
          related_entities:
            clinic:
              contact:
                phone: '1234'
              name: 'foo'
      )
  'onMatch adds low weight acknowledgement':
    topic: ->
      getTransition('Normal')
    'tasks added for low weight': (transition) ->
      transition.complete = (err, doc) ->
        doc.tasks.length.should.eql(1)
        message = doc.tasks[0].messages[0].message
        /low birth weight/.test(message).should.be.ok
      transition.onMatch(
        doc:
          child_weight: 'Low - Yellow'
          patient_id: 'AA'
          related_entities:
            clinic:
              contact:
                phone: '1234'
              name: 'foo'
      )
  'onMatch does not add low weight acknowledgement if already sent':
    topic: ->
      getTransition('Low - Yellow')
    'tasks added for low weight': (transition) ->
      transition.complete = (err, doc) ->
        doc.tasks.length.should.eql(1)
        message = doc.tasks[0].messages[0].message
        message.should.be.eql('Thank you, foo. PNC counseling visit has been recorded for Patient.')
      transition.onMatch(
        doc:
          child_weight: 'Low - Yellow'
          patient_id: 'AA'
          related_entities:
            clinic:
              contact:
                phone: '1234'
              name: 'foo'
      )
).export(module)
