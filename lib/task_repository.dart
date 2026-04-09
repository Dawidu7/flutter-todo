class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class TaskRepository {
  static List<Task> tasks = [
    Task(
      title: "Przygotować prezentację",
      deadline: "jutro",
      done: false,
      priority: "wysoki",
    ),
    Task(
      title: "Oddać raport z laboratoriów",
      deadline: "dzisiaj",
      done: true,
      priority: "wysoki",
    ),
    Task(
      title: "Powtórzyć widgety Flutter",
      deadline: "w piątek",
      done: false,
      priority: "średni",
    ),
    Task(
      title: "Napisać notatki do kolokwium",
      deadline: "w weekend",
      done: false,
      priority: "niski",
    ),
  ];
}
