// File: screens/home_screen.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/task.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  late ParseUser _currentUser;

  // @override
  // void initState() {
  //   super.initState();
  //   _getCurrentUser();
  //   _loadTasks();
  // }

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
            // ..whereEqualTo('user', _currentUser.objectId)
            ..whereEqualTo('user', _currentUser)
            ..orderByDescending('createdAt');

      final ParseResponse response = await queryBuilder.query();

      if (response.success && response.results != null) {
        setState(() {
          _tasks = response.results!.map((task) => Task.fromParse(task)).toList();
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

  Future<void> _addTask(String title, String description) async {
    try {
      final task = ParseObject('Task')
        ..set('title', title)
        ..set('description', description)
        ..set('completed', false)
       ..set('user', _currentUser);

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

  Future<void> _updateTask(Task task) async {
    try {
      final parseObject = ParseObject('Task')
        ..objectId = task.id
        ..set('title', task.title)
        ..set('description', task.description)
        ..set('completed', task.completed);

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

  Future<void> _deleteTask(String taskId) async {
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

  Future<void> _signOut() async {
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
Future<void> _showProfileDialog() async {
  final passwordController = TextEditingController();
  XFile? pickedFile;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Upload image section
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Upload Image"),
                onPressed: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    setState(() {
                      pickedFile = file;
                    });
                  }
                },
              ),
              if (pickedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FutureBuilder<Uint8List>(
  future: pickedFile!.readAsBytes(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
      return Image.memory(snapshot.data!, height: 100);
    } else if (snapshot.hasError) {
      return const Text('Error loading image');
    } else {
      return const CircularProgressIndicator();
    }
  },
)

                ),
              const SizedBox(height: 16),
              // Change password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPassword = passwordController.text.trim();

                // Update password if entered
                if (newPassword.isNotEmpty) {
                  _currentUser.set('password', newPassword);
                }

                // Upload image if picked
                if (pickedFile != null) {
                  final parseFile = ParseFile(File(pickedFile!.path));
                  await parseFile.save();
                  _currentUser.set('profileImage', parseFile);
                }

                final response = await _currentUser.save();

                if (response.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${response.error?.message}')),
                  );
                }

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    },
  );
}

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onAddTask: _addTask,
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedTask = Task(
                id: task.id,
                title: titleController.text,
                description: descriptionController.text,
                completed: task.completed,
              );
              _updateTask(updatedTask);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

 // Enhanced home screen with welcome message and progress bar
@override
Widget build(BuildContext context) {
  double completedRatio = _tasks.isEmpty
      ? 0
      : _tasks.where((t) => t.completed).length / _tasks.length;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Tasks'),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          onSelected: (value) {
            if (value == 'profile') {
              _showProfileDialog();
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
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.indigo,
                      child: Text('A',
                          style: TextStyle(
                              color: Colors.white, fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Here are your tasks for today.',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Progress',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: completedRatio,
                      backgroundColor: Colors.grey[300],
                      color: Colors.indigo,
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _tasks.isEmpty
                    ? const Center(child: Text('No tasks found. Add a task!'))
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return TaskItem(
                            task: task,
                            onToggleCompleted: (bool value) {
                              final updatedTask = Task(
                                id: task.id,
                                title: task.title,
                                description: task.description,
                                completed: value,
                              );
                              _updateTask(updatedTask);
                            },
                            onDelete: () => _deleteTask(task.id),
                            onEdit: () => _showEditTaskDialog(task),
                          );
                        },
                      ),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      
      // label: const Text('Add Task'),
      // backgroundColor: Colors.indigo,
    ),
  );
}
}