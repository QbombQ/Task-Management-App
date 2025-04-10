import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<TaskProvider>().deleteTask(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TaskProvider>().loadTasks(),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (taskProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${taskProvider.error}',
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => taskProvider.loadTasks(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final tasks = taskProvider.tasks;
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a new task',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          final uncompletedTasks = tasks.where((task) => !task.completed).toList();
          final completedTasks = tasks.where((task) => task.completed).toList();

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 32 : 16,
              vertical: 16,
            ),
            children: [
              if (uncompletedTasks.isNotEmpty) ...[
                _buildSectionHeader('Active Tasks', theme),
                const SizedBox(height: 12),
                ...uncompletedTasks.map((task) => _buildTaskCard(context, task)),
                const SizedBox(height: 24),
              ],
              if (completedTasks.isNotEmpty) ...[
                _buildSectionHeader('Completed Tasks', theme),
                const SizedBox(height: 12),
                ...completedTasks.map((task) => _buildTaskCard(context, task)),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskDetailScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        elevation: 4,
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onBackground,
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Slidable(
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                context.read<TaskProvider>().updateTask(
                      Task(
                        id: task.id,
                        title: task.title,
                        description: task.description,
                        completed: !task.completed,
                      ),
                    );
              },
              backgroundColor: task.completed 
                  ? theme.colorScheme.error 
                  : theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: task.completed ? Icons.undo : Icons.check,
              label: task.completed ? 'Undo' : 'Complete',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _showDeleteConfirmation(context, task),
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isWideScreen ? 20 : 16),
            child: Row(
              children: [
                Checkbox(
                  value: task.completed,
                  onChanged: (value) {
                    context.read<TaskProvider>().updateTask(
                          Task(
                            id: task.id,
                            title: task.title,
                            description: task.description,
                            completed: value ?? false,
                          ),
                        );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                          color: task.completed
                              ? theme.colorScheme.onSurface.withOpacity(0.5)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: theme.colorScheme.error,
                  onPressed: () => _showDeleteConfirmation(context, task),
                ),
                if (task.completed)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 