import 'package:flutter/material.dart';
import 'package:list_task/Widgets/tasks_list_item.dart';
import 'package:list_task/models/task.dart';
import 'package:list_task/repositories/repo_tasks.dart';

class TasksList extends StatefulWidget {
  const TasksList({super.key});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  List<Task> tasks = [];
  TextEditingController inputTask = TextEditingController();

  Repo_Tasks repo_tasks = Repo_Tasks();

  Task? deletedTask;
  int? deletedTaskPos;

  String? errText;

/* Codigo reponsável por instanciar apenais uma vez e buscar na lista salva no aparelho. */
  @override
  void initState() {
    super.initState();
    repo_tasks.getTasksList().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Task List',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: inputTask,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Adicionar uma tarefa',
                            hintText: 'Ex: Estudar Flutter',
                            errorText: errText,
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Color(0xff00d7f3),
                              width: 2,
                            ))),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                        onPressed: onClick,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff00d7f3),
                          padding: const EdgeInsets.all(14),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 30,
                        ))
                  ],
                ),
                Flexible(
                  child: ListView(
                    children: [
                      for (Task task in tasks)
                        TaskListItem(
                          task: task,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child:
                          Text('Você possui ${tasks.length} tarefas pendentes'),
                    ),
                    ElevatedButton(
                      onPressed: clearTasksList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00d7f3),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Limpar tudo'),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }

/* Codigo responsável por adicionar a tarefa a lista */
  void onClick() {
    if (inputTask.text.isEmpty) {
      setState(() {
        errText = 'O titulo não pode ser vazio!';
      });
      return;
    }

    setState(
      () {
        tasks.add(
          Task(
            title: inputTask.text,
            date: DateTime.now(),
          ),
        );
        errText = null;
      },
    );
    repo_tasks.saveTasksList(tasks);
    inputTask.clear();
  }

/* Deleta todas as tarefas. */
  void clearTasksList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Tudo'),
        content: const Text('Tem certeza deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff00d7f3),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                tasks.clear();
              });
              repo_tasks.saveTasksList(tasks);
            },
            child: const Text('Limpar Tudo'),
          )
        ],
      ),
    );
  }

/* Função responsável por deletar cada tarefa. */
  void onDelete(Task task) {
    deletedTask = task;
    deletedTaskPos = tasks.indexOf(task);
    setState(() {
      tasks.remove(task);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa: ${task.title} foi removida com sucesso!',
          style: const TextStyle(
            color: Color(0xff060708),
          ),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              tasks.insert(deletedTaskPos!, deletedTask!);
            });
          },
          textColor: const Color(0xff00d7f3),
        ),
      ),
    );
  }
}
