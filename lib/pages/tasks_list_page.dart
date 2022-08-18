import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tasks_list/models/task.dart';
import 'package:tasks_list/repositories/task_repository.dart';
import 'package:tasks_list/widgets/task_item.dart';

class TasksListPage extends StatefulWidget {
  const TasksListPage({Key? key}) : super(key: key);

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage> {
  final TextEditingController _taskController = TextEditingController();
  final TaskRepository _taskRepository = TaskRepository();

  List<Task> tasks = [];

  Task? deletedTask;
  int? deletedTaskPos;
  String? errorText;

  @override
  void initState() {
    super.initState();

    _taskRepository.getTaskList().then((items) {
      setState(() {
        tasks = items;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Lista de Tarefas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          decoration: InputDecoration(
                            labelText: 'Criar uma Tarefa',
                            labelStyle: const TextStyle(
                              color: Colors.black,
                            ),
                            hintText: 'Ex. Beber água',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            errorText: errorText,
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 3,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String title = _taskController.text;

                          if (title.isEmpty) {
                            setState(() {
                              errorText =
                                  'Você deve dar um nome para a tarefa.';
                            });
                            return;
                          }

                          setState(() {
                            Task newTask = Task(
                              title: title,
                              dateNow: DateTime.now(),
                              checked: false,
                            );
                            tasks.add(newTask);
                            errorText = null;
                          });

                          _taskController.clear();
                          _taskRepository.saveTaskList(tasks);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(18),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Task task in tasks)
                        TaskItem(
                          task: task,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Você possui ${tasks.length} tarefa(s) pendente(s).'),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: showDeleteAllTasksConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(18),
                        ),
                        child: const Text('Limpar Tarefas'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Task task) {
    deletedTask = task;
    deletedTaskPos = tasks.indexOf(task);

    setState(() {
      tasks.remove(task);
    });
    _taskRepository.saveTaskList(tasks);

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa "${task.title}" foi removida com sucesso!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              tasks.insert(deletedTaskPos!, deletedTask!);
            });
            _taskRepository.saveTaskList(tasks);
          },
        ),
      ),
    );
  }

  void showDeleteAllTasksConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir todas as tarefas?'),
        content:
            const Text('Você tem certeza que deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(primary: Colors.grey),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTasks();
            },
            style: TextButton.styleFrom(primary: Colors.red),
            child: const Text('Limpar Tudo'),
          ),
        ],
      ),
    );
  }

  void deleteAllTasks() {
    setState(() {
      tasks.clear();
    });
    _taskRepository.saveTaskList(tasks);
  }
}
