import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(bool) onToggleCompleted;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onToggleCompleted,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          leading: Checkbox(
            value: task.completed,
            onChanged: (value) => onToggleCompleted(value ?? false),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            task.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}