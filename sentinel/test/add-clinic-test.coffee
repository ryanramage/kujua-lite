vows = require('vows')
should = require('should')

{ transitions } = require('../transitions')

vows.describe('test adding clinic details').addBatch(
  'filter generated':
    topic: ->
      filter = undefined
      eval("""filter = #{transitions['add_clinic'].filter} """)
    'filter should trip on doc with form and no clinic': (filter) ->
      filter(
        form: 'ORPT'
        related_entities:
          clinic: null
      ).should.eql(true)
    'filter should not trip on doc without form': (filter) ->
      filter(
        related_entities:
          clinic: null
      ).should.eql(false)
    'filter should not trip on doc with form and truthy clinic': (filter) ->
      filter(
        form: 'ZZ'
        related_entities:
          clinic: {}
      ).should.eql(false)
).export(module)
