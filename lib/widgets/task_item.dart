import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(bool) onToggleCompleted;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onEditDueDate;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onToggleCompleted,
    required this.onDelete,
    required this.onEdit,
    required this.onEditDueDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now()) && !task.completed;

    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: ListTile(
          leading: Checkbox(
            value: task.completed,
            onChanged: (value) => onToggleCompleted(value ?? false),
            activeColor: Colors.indigo,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: task.completed ? TextDecoration.lineThrough : null,
              color: isOverdue ? Colors.red : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              if (task.dueDate != null)
                GestureDetector(
                  onTap: onEditDueDate,
                  child: Text(
                    'Due: ${DateFormat.yMMMd().format(task.dueDate!.toLocal())}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.teal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.indigo),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}
