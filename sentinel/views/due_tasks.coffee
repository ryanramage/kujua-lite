module.exports =
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
