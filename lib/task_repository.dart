import 'package:hive_ce/hive.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'task_api_service.dart';

class Task {
  int id;
  String title;
  String deadline;
  bool done;
  String priority;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "deadline": deadline,
      "done": done,
      "priority": priority,
    };
  }

  factory Task.fromMap(Map map) {
    return Task(
      id: map["id"],
      title: map["title"],
      deadline: map["deadline"],
      done: map["done"],
      priority: map["priority"],
    );
  }
}

class TaskLocalDatabase {
  static Box get _box => Hive.box("tasks");

  static List<Task> getTasks() {
    return _box.values.map((item) {
      return Task.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    await _box.clear();

    for (final task in tasks) {
      await _box.put(task.id, task.toMap());
    }
  }

  static Future<void> addTask(Task task) async {
    await _box.put(task.id, task.toMap());
  }

  static Future<void> updateTask(Task task) async {
    await _box.put(task.id, task.toMap());
  }

  static Future<void> deleteTask(int id) async {
    await _box.delete(id);
  }

  static Future<void> deleteAllTasks() async {
    await _box.clear();
  }

  static bool isEmpty() {
    return _box.isEmpty;
  }
}

class TaskSyncService {
  static Future<void> loadInitialDataIfNeeded() async {
    if (!TaskLocalDatabase.isEmpty()) {
      return;
    }

    try {
      final tasks = await TaskApiService.fetchTasks();
      await TaskLocalDatabase.saveTasks(tasks);
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Błąd podczas pobierania zadań z API',
      );
      rethrow;
    }
  }
}
