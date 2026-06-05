import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logTaskOpened(int taskId) async {
    await _analytics.logEvent(
      name: "task_opened",
      parameters: {"task_id": taskId},
    );
  }

  static Future<void> logTaskAdded() async {
    await _analytics.logEvent(name: "task_added");
  }

  static Future<void> logTaskCompleted(int taskId) async {
    await _analytics.logEvent(
      name: "task_completed",
      parameters: {"task_id": taskId},
    );
  }
}
