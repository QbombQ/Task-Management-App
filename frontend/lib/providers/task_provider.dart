import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    _error = null;
    notifyListeners();

    try {
      final newTask = await _taskService.createTask(task);
      _tasks.add(newTask);
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    _error = null;
    notifyListeners();

    try {
      final updatedTask = await _taskService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    _error = null;
    notifyListeners();

    try {
      await _taskService.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 