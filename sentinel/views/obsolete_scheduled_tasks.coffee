module.exports =
  map: (doc) ->
    tasks = doc.scheduled_tasks or []
    { form, patient_identifiers } = doc

    overdue = new Date()
    overdue.setHours(0, 0, 0, 0)
    overdue.setDate(overdue.getDate() + 21)

    indexes = []

    tasks.forEach((task, index) ->
      { due, type } = task
      indexes.push(index) if type is 'anc_visit' and due < overdue.getTime()
    )

    if form is 'ORPT' and indexes.length > 0
      patient_identifiers.forEach((id) ->
        emit(id,
          doc: doc
          indexes: indexes
        )
      )
