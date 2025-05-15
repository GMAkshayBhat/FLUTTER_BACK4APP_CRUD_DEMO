import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    this.dueDate,
  });

  factory Task.fromParse(ParseObject parseObject) {
    return Task(
      id: parseObject.objectId!,
      title: parseObject.get<String>('title') ?? '',
      description: parseObject.get<String>('description') ?? '',
      completed: parseObject.get<bool>('completed') ?? false,
      dueDate: parseObject.get<DateTime>('dueDate'),
    );
  }
}
