Transition = require('./transition')
_ = require('underscore')

module.exports = new Transition(
  code: 'add_clinic'
  required_fields: 'form related_entities !related_entities.clinic'
  onMatch: (change) ->
    debugger
    { doc } = change
    { from, related_entities } = doc
    @db.view('kujua-base', 'clinic_by_phone', key: [from], limit: 1, (err, data) =>
      if err
        @complete(err, false)
      else
        clinic = _.first(data.rows)?.value
        debugger
        existing = related_entities.clinic or {}
        { _id, _rev } = existing
        if clinic and (clinic._id isnt _id or clinic._rev isnt _rev)
          related_entities.clinic = clinic
          @complete(null, doc)
        else
          @complete(null, false)
    )
)
