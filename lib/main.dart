import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Connect to emulator
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8081);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController taskController = TextEditingController();

  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask() async {
    if (taskController.text.isEmpty) return;
    await tasks.add({
      'title': taskController.text.trim(),
      'createdAt': Timestamp.now(),
    });
    taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Real-Time Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(labelText: 'Enter task'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addTask,
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: tasks
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return ListTile(title: Text(doc['title']));
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
