Transition = require('./transition')
_ = require('underscore')

module.exports = new Transition(
  filter: (doc) ->
    { form, related_entities } = doc
    { clinic } = related_entities or {}
    'ORPT OANC ODGR OLAB OBIR'.split(' ').indexOf(form) >= 0 and not clinic?.name
  onMatch: (change) ->
    { doc } = change
    { from, related_entities } = doc
    @db.view('kujua-base', 'clinic_by_phone', key: [from], limit: 1, (err, data) =>
      if err
        @callback(err, false)
      else
        clinic = _.first(data.rows)?.value
        existing = related_entities.clinic or {}
        { _id, _rev } = existing
        if clinic and (clinic._id isnt _id or clinic._rev isnt _rev)
            related_entities.clinic = clinic
            @db.saveDoc(doc, @callback)
        else
          @callback(null, false)
    )
    true
)

