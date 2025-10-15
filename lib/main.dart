import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/firebase_options.web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseWebOptions);
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      home: ToDoScreen(),
    );
  }
}

class ToDoScreen extends StatelessWidget {
  ToDoScreen({super.key});

  final CollectionReference todos = FirebaseFirestore.instance.collection(
    "todos",
  );

  TextEditingController taskController = TextEditingController();

  void addTodo() {
    final text = taskController.text;
    if (text.isNotEmpty) {
      todos.add({"title": text, "done": false});
      taskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ToDo App')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(hintText: 'Nova tarefa'),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(onPressed: addTodo, icon: Icon(Icons.add)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
