import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskService {
  static final String baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:8080'
      : 'http://localhost:8080';

  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('Connection failed: Please make sure the backend server is running');
    } on TimeoutException {
      throw Exception('Connection timeout: Please check your internet connection');
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<Task> getTask(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return Task.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Task not found');
      } else {
        throw Exception('Failed to load task: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('Connection failed: Please make sure the backend server is running');
    } on TimeoutException {
      throw Exception('Connection timeout: Please check your internet connection');
    } catch (e) {
      throw Exception('Failed to load task: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 201) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('Connection failed: Please make sure the backend server is running');
    } on TimeoutException {
      throw Exception('Connection timeout: Please check your internet connection');
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return Task.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Task not found');
      } else {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('Connection failed: Please make sure the backend server is running');
    } on TimeoutException {
      throw Exception('Connection timeout: Please check your internet connection');
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('Task not found');
        } else {
          throw Exception('Failed to delete task: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      throw Exception('Connection failed: Please make sure the backend server is running');
    } on TimeoutException {
      throw Exception('Connection timeout: Please check your internet connection');
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
} 