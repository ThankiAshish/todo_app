import 'package:flutter/material.dart';
import 'package:todo_app/services/api_calls.dart';
import 'package:todo_app/services/todo_list.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  TextEditingController taskController = TextEditingController();

  List<TaskList> taskList = [];

  @override
  void initState() {
    fetchAllTodos();
    super.initState();
  }

  void fetchAllTodos() async {
    taskList = await APICalls.fetchTasks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todos")),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: "Enter Task"),
              )),
              IconButton(
                  onPressed: () async {
                    if (taskController.text.isNotEmpty) {
                      await APICalls.addTask(taskController.text);
                      taskController.clear();
                      fetchAllTodos();
                    }
                  },
                  icon: const Icon(Icons.add))
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              fetchAllTodos();
            },
            child: ListView.builder(
                itemCount: taskList.length,
                itemBuilder: (context, index) => CheckboxListTile(
                      value: taskList[index].completed,
                      onChanged: (value) async {
                        await APICalls.updateTask(taskList[index].id!, value!);
                        fetchAllTodos();
                      },
                      title: Text(taskList[index].task ?? "",
                          style: TextStyle(
                            decoration: taskList[index].completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: taskList[index].completed
                                ? Colors.red
                                : Colors.black,
                          )),
                      secondary: IconButton(
                          onPressed: () async {
                            await APICalls.deleteTasks(taskList[index].id!);
                            fetchAllTodos();
                          },
                          icon: const Icon(Icons.delete)),
                      controlAffinity: ListTileControlAffinity.leading,
                    )),
          ),
        )
      ]),
    );
  }
}
