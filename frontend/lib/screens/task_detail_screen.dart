import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;

  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _isCompleted = widget.task?.completed ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Title cannot be empty'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.task == null) {
        // For new tasks, let the backend assign the ID
        final newTask = Task(
          id: 0, // This will be ignored by the backend
          title: _titleController.text,
          description: _descriptionController.text,
          completed: _isCompleted,
        );
        await context.read<TaskProvider>().addTask(newTask);
      } else {
        // For existing tasks, use the current ID
        final updatedTask = Task(
          id: widget.task!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          completed: _isCompleted,
        );
        await context.read<TaskProvider>().updateTask(updatedTask);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Title',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'Enter task title',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Enter task description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Mark as completed',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Switch(
                            value: _isCompleted,
                            onChanged: (value) {
                              setState(() {
                                _isCompleted = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.task == null ? 'Create Task' : 'Save Changes',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 