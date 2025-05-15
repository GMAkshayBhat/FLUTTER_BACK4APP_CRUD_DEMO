import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/task.dart' as model;
import '../widgets/task_item.dart';
import '../widgets/add_task_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<model.Task> _tasks = [];
  bool _isLoading = true;
  late ParseUser _currentUser;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getCurrentUser();
    await _loadTasks();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = await ParseUser.currentUser() as ParseUser;
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QueryBuilder<ParseObject> queryBuilder =
          QueryBuilder<ParseObject>(ParseObject('Task'))
            ..whereEqualTo('user', _currentUser)
            ..orderByDescending('createdAt');

      final ParseResponse response = await queryBuilder.query();

      if (response.success && response.results != null) {
        final now = DateTime.now();
        final todayTasks = response.results!.map((task) => model.Task.fromParse(task)).toList();

        for (var task in todayTasks) {
          if (task.dueDate != null &&
              !task.completed &&
              task.dueDate!.difference(now).inHours <= 24 &&
              task.dueDate!.isAfter(now)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reminder: "${task.title}" is due soon!')),
            );
            break;
          }
        }

        setState(() {
          _tasks = todayTasks;
          _isLoading = false;
        });
      } else {
        setState(() {
          _tasks = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTask(String title, String description, DateTime? dueDate) async {
    try {
      final task = ParseObject('Task')
        ..set('title', title)
        ..set('description', description)
        ..set('completed', false)
        ..set('user', _currentUser);

      if (dueDate != null) {
        task.set('dueDate', dueDate);
      }

      final response = await task.save();

      if (response.success && response.results != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
        _loadTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.error!.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateTask(model.Task task) async {
    try {
      final parseObject = ParseObject('Task')
        ..objectId = task.id
        ..set('title', task.title)
        ..set('description', task.description)
        ..set('completed', task.completed);

      if (task.dueDate != null) {
        parseObject.set('dueDate', task.dueDate);
      }

      final response = await parseObject.save();

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully!')),
        );
        _loadTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.error!.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onAddTask: _addTask,
      ),
    );
  }

  void _showEditTaskDialog(model.Task task) {
  final titleController = TextEditingController(text: task.title);
  final descriptionController = TextEditingController(text: task.description);
  DateTime? selectedDueDate = task.dueDate; // ⬅️ Declare this outside

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDueDate == null
                            ? 'No due date selected'
                            : 'Due: ${selectedDueDate?.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      tooltip: 'Change Due Date',
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          // ✅ update outer variable for saving
                          selectedDueDate = pickedDate;

                          // ✅ update UI in dialog
                          setModalState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedTask = model.Task(
                    id: task.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    completed: task.completed,
                    dueDate: selectedDueDate, // ✅ uses latest updated value
                  );
                  _updateTask(updatedTask);
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    },
  );
}

  void _deleteTask(String taskId) async {
    try {
      final parseObject = ParseObject('Task')..objectId = taskId;
      final response = await parseObject.delete();

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully!')),
        );
        _loadTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.error!.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _signOut() async {
    try {
      final user = await ParseUser.currentUser() as ParseUser;
      final response = await user.logout();

      if (response.success) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.error!.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  elevation: 0,
  backgroundColor: Color.fromARGB(255, 245, 226, 245),
  title: Row(
    children: const [
      Icon(Icons.checklist, color: Colors.black),
      SizedBox(width: 8),
      Text(
        'Tasks',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 8, 8, 8),
          fontSize: 20,
        ),
      ),
    ],
  ),
  actions: [
    PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle, color: Color.fromARGB(255, 9, 9, 9)),
      onSelected: (value) {
        if (value == 'profile') {
          // _showProfileDialog();
          Navigator.pushNamed(context, '/profile');
        } else if (value == 'logout') {
          _signOut();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'profile', child: Text('Profile')),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
    ),
  ],
),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('No tasks found. Add a task!'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return TaskItem(
                      task: task,
                      onToggleCompleted: (bool value) {
                        final updatedTask = model.Task(
                          id: task.id,
                          title: task.title,
                          description: task.description,
                          completed: value,
                          dueDate: task.dueDate,
                        );
                        _updateTask(updatedTask);
                      },
                      onDelete: () => _deleteTask(task.id),
                      onEdit: () => _showEditTaskDialog(task), onEditDueDate: () {  },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
  onPressed: _showAddTaskDialog,
  child: const Icon(Icons.add),
),

    );
  }
}
