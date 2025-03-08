import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

// Modelo de tarea
class Task {
  String title;
  bool isCompleted;

  Task(this.title, {this.isCompleted = false});
}

// Provider para manejar el estado
class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  double _fontSize = 16.0;
  Color _textColor = Colors.white;
  Color _backgroundColor = Colors.black;
  Color _appBarColor = Colors.blueAccent; // Color de la AppBar
  Color _menuColor = Colors.black87; // Color del menú desplegable

  List<Task> get tasks => _tasks;
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  double get progress =>
      totalTasks == 0 ? 0 : (completedTasks / totalTasks) * 100;
  double get fontSize => _fontSize;
  Color get textColor => _textColor;
  Color get backgroundColor => _backgroundColor;
  Color get appBarColor => _appBarColor;
  Color get menuColor => _menuColor;

  void addTask(String title) {
    _tasks.add(Task(title));
    notifyListeners();
  }

  void toggleTask(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    notifyListeners();
  }

  void removeTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void setTextColor(Color color) {
    _textColor = color;
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  void setAppBarColor(Color color) {
    _appBarColor = color;
    notifyListeners();
  }

  void setMenuColor(Color color) {
    _menuColor = color;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: taskProvider.backgroundColor,
            ),
            home: const TaskScreen(),
          );
        },
      ),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final TextEditingController taskController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
        backgroundColor: taskProvider.appBarColor, // Fondo de la AppBar
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isMenuOpen = !_isMenuOpen;
            });
          },
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _isMenuOpen ? MediaQuery.of(context).size.width * 0.2 : 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Input para agregar tareas
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: taskController,
                          style: TextStyle(
                              color: taskProvider.textColor,
                              fontSize: taskProvider.fontSize),
                          decoration: const InputDecoration(
                            hintText: 'Nueva tarea...',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: () {
                          if (taskController.text.isNotEmpty) {
                            taskProvider.addTask(taskController.text);
                            taskController.clear();
                          }
                        },
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Lista de tareas
                Expanded(
                  child: ListView.builder(
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      return Card(
                        color: Colors.black54,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            activeColor: Colors.blueAccent,
                            onChanged: (_) => taskProvider.toggleTask(index),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              color: taskProvider.textColor,
                              fontSize: taskProvider.fontSize,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon:
                                const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => taskProvider.removeTask(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Sección de estadísticas (ahora transparente)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.transparent, // Ahora es transparente
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total: ${taskProvider.totalTasks}',
                        style: TextStyle(
                            color: taskProvider.textColor, fontSize: 16),
                      ),
                      Text(
                        'Completadas: ${taskProvider.completedTasks}',
                        style: TextStyle(
                            color: taskProvider.textColor, fontSize: 16),
                      ),
                      Text(
                        'Progreso: ${taskProvider.progress.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Menú lateral
          if (_isMenuOpen)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: double.infinity,
                color: taskProvider.menuColor, // Color del menú
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text('Tamaño de Fuente', style: TextStyle(color: Colors.white)),
                    Slider(
                      value: taskProvider.fontSize,
                      min: 10,
                      max: 30,
                      onChanged: (value) => taskProvider.setFontSize(value),
                    ),
                    const Divider(color: Colors.white54),
                    const Text('Color de Texto', style: TextStyle(color: Colors.white)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _colorOption(Colors.red, taskProvider.setTextColor),
                        _colorOption(Colors.white, taskProvider.setTextColor),
                        _colorOption(Colors.black, taskProvider.setTextColor),
                        _colorOption(Colors.blue, taskProvider.setTextColor),
                        _colorOption(Colors.green, taskProvider.setTextColor),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _colorOption(Colors.purple, taskProvider.setTextColor),
                        _colorOption(Colors.orange, taskProvider.setTextColor),
                        _colorOption(Colors.grey, taskProvider.setTextColor),
                        _colorOption(Colors.brown, taskProvider.setTextColor),
                        _colorOption(Colors.yellow, taskProvider.setTextColor),
                      ],
                    ),
                    const Divider(color: Colors.white54),
                    const Text('Color de Fondo', style: TextStyle(color: Colors.white)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _colorOption(Colors.red, taskProvider.setBackgroundColor),
                        _colorOption(Colors.white, taskProvider.setBackgroundColor),
                        _colorOption(Colors.black, taskProvider.setBackgroundColor),
                        _colorOption(Colors.blue, taskProvider.setBackgroundColor),
                        _colorOption(Colors.green, taskProvider.setBackgroundColor),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _colorOption(Colors.purple, taskProvider.setBackgroundColor),
                        _colorOption(Colors.orange, taskProvider.setBackgroundColor),
                        _colorOption(Colors.grey, taskProvider.setBackgroundColor),
                        _colorOption(Colors.brown, taskProvider.setBackgroundColor),
                        _colorOption(Colors.yellow, taskProvider.setBackgroundColor),
                      ],
                    ),
                    const Divider(color: Colors.white54),
                    const Text('Color de la Barra', style: TextStyle(color: Colors.white)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _colorOption(Colors.blueAccent, taskProvider.setAppBarColor),
                        _colorOption(Colors.green, taskProvider.setAppBarColor),
                        _colorOption(Colors.purple, taskProvider.setAppBarColor),
                        _colorOption(Colors.orange, taskProvider.setAppBarColor),
                        _colorOption(Colors.red, taskProvider.setAppBarColor),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _colorOption(Colors.black, taskProvider.setAppBarColor),
                        _colorOption(Colors.grey, taskProvider.setAppBarColor),
                        _colorOption(Colors.blue, taskProvider.setAppBarColor),
                        _colorOption(Colors.brown, taskProvider.setAppBarColor),
                        _colorOption(Colors.yellow, taskProvider.setAppBarColor),
                      ],
                    ),
                    const Divider(color: Colors.white54),
                    const Text('Color del Menú', style: TextStyle(color: Colors.white)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _colorOption(Colors.black87, taskProvider.setMenuColor),
                        _colorOption(Colors.grey, taskProvider.setMenuColor),
                        _colorOption(Colors.blueGrey, taskProvider.setMenuColor),
                        _colorOption(Colors.redAccent, taskProvider.setMenuColor),
                        _colorOption(Colors.green, taskProvider.setMenuColor),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _colorOption(Colors.purple, taskProvider.setMenuColor),
                        _colorOption(Colors.orange, taskProvider.setMenuColor),
                        _colorOption(Colors.brown, taskProvider.setMenuColor),
                        _colorOption(Colors.blue, taskProvider.setMenuColor),
                        _colorOption(Colors.yellow, taskProvider.setMenuColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _colorOption(Color color, Function(Color) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        margin: const EdgeInsets.all(5),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
