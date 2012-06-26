module.exports = {
  due_tasks:
    map: (doc) ->
      now = new Date().setHours(0, 0, 0, 0)
      tasks = doc.scheduled_tasks or []
      indexes = []
      tasks.forEach((task, index) ->
        if task.due
          due_date = new Date(task.due)
          overdue = new Date(task.due).setDate(due_date.getDate() + 7)
          if due_date.getTime() < now < overdue
            indexes.push(index)
      )
      emit([doc._id, doc._rev], indexes) if indexes.length > 0
  sent_cdc_reminders:
    map: (doc) ->
      { form, related_entities, week_number } = doc
      { clinic } = related_entities
      if form is 'CNPW' and clinic
        emit(week_number, clinic)
  obsolete_scheduled_tasks:
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
  ohw_registered_patients:
    map: (doc) ->
      { form, patient_identifiers } = doc
      if form is 'ORPT'
        patient_identifiers.forEach((id) ->
          emit(id, doc)
        )
}
