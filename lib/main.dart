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

  void toggleDone(DocumentSnapshot doc) {
    todos.doc(doc.id).update({'done': !doc['done']});
  }

  void deleteTodo(DocumentSnapshot doc) {
    todos.doc(doc.id).delete();
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: todos.snapshots(),
              builder: (context, snapshot) {
                // estado de caregamento
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // caso de erro
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Ocorreu um erro',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                // caso não haja nenhum registro
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma tarefa encontrada',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                // dados disponiveis
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    return ListTile(
                      title: Text(
                        doc['title'],
                        style: TextStyle(
                          decoration: doc['done']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      leading: Checkbox(
                        value: doc['done'],
                        onChanged: (_) => toggleDone(doc),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteTodo(doc),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
