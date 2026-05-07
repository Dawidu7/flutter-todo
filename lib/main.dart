import "package:flutter/material.dart";
import "task_repository.dart";

const title = "Todo";

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFilter = "wszystkie";

  void _clearAllTasks() {
    if (TaskRepository.tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lista zadań jest już pusta.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Potwierdzenie"),
          content: const Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anuluj"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  TaskRepository.tasks.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Wszystkie zadania zostały usunięte"),
                  ),
                );
              },
              child: const Text("Usuń", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final int completedTasks = TaskRepository.tasks
        .where((task) => task.done)
        .length;

    List<Task> filteredTasks = TaskRepository.tasks;
    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks.where((task) => !task.done).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: TaskRepository.tasks.isEmpty ? null : _clearAllTasks,
            tooltip: 'Usuń wszystkie',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Masz dziś ${TaskRepository.tasks.length} zadania"),
            Text("Wykonano: $completedTasks"),
            const SizedBox(height: 16),

            FilterBar(
              currentFilter: selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),

            const SizedBox(height: 10),
            const Text(
              "Dzisiejsze zadania",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (ctx, index) {
                  final task = filteredTasks[index];
                  // Znalezienie rzeczywistego indeksu na głównej liście do zapisu po edycji
                  final originalIndex = TaskRepository.tasks.indexOf(task);

                  return Dismissible(
                    key: ValueKey(
                      task.title + task.deadline + originalIndex.toString(),
                    ),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        TaskRepository.tasks.remove(task);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Usunięto zadanie: ${task.title}"),
                        ),
                      );
                    },
                    child: TaskCard(
                      task: task,
                      onChanged: (value) {
                        setState(() {
                          task.done = value!;
                        });
                      },
                      onTap: () async {
                        final Task? updatedTask = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskScreen(task: task),
                          ),
                        );

                        if (updatedTask != null) {
                          setState(() {
                            TaskRepository.tasks[originalIndex] = updatedTask;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            ctx,
            PageRouteBuilder(
              pageBuilder: (ctx, anim, secAnim) => const AddTaskScreen(),
              transitionsBuilder: (ctx, anim, secAnim, child) {
                return FadeTransition(opacity: anim, child: child);
              },
            ),
          );

          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterButton("wszystkie", "Wszystkie"),
          _buildFilterButton("do zrobienia", "Do zrobienia"),
          _buildFilterButton("wykonane", "Wykonane"),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filterValue, String label) {
    final isActive = currentFilter == filterValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.deepPurple : Colors.grey[300],
          foregroundColor: isActive ? Colors.white : Colors.black,
        ),
        onPressed: () => onFilterChanged(filterValue),
        child: Text(label),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final deadlineController = TextEditingController();
  final priorityController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    deadlineController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nowe zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: false,
                );
                Navigator.pop(context, newTask);
              },
              child: const Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController titleController;
  late final TextEditingController deadlineController;
  late final TextEditingController priorityController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    deadlineController = TextEditingController(text: widget.task.deadline);
    priorityController = TextEditingController(text: widget.task.priority);
  }

  @override
  void dispose() {
    titleController.dispose();
    deadlineController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edytuj zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: widget.task.done, // Zachowaj poprzedni status
                );
                Navigator.pop(context, updatedTask);
              },
              child: const Text("Zapisz zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onChanged, this.onTap});

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "wysoki":
        return Colors.red;
      case "średni":
      case "sredni":
        return Colors.orange;
      case "niski":
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          onTap: onTap,
          leading: Checkbox(value: task.done, onChanged: onChanged),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: task.done ? Colors.grey : Colors.black,
              decoration: task.done
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              children: [
                TextSpan(text: "termin: ${task.deadline} | priorytet: "),
                TextSpan(
                  text: task.priority,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getPriorityColor(task.priority),
                  ),
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
