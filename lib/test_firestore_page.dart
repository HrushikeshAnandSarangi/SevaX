import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirestorePage extends StatefulWidget {
  const TestFirestorePage({Key? key}) : super(key: key);

  @override
  _TestFirestorePageState createState() => _TestFirestorePageState();
}

class _TestFirestorePageState extends State<TestFirestorePage> {
  String? message;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchMessage();
  }

  Future<void> fetchMessage() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('test')
          .doc('exampleDoc')
          .get();

      if (doc.exists) {
        setState(() {
          message = doc.data()?['message'] ?? 'No message field found';
        });
      } else {
        setState(() {
          error = 'Document does not exist';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Test')),
      body: Center(
        child: message != null
            ? Text(message!, style: const TextStyle(fontSize: 20))
            : error != null
                ? Text(error!, style: const TextStyle(color: Colors.red))
                : const CircularProgressIndicator(),
      ),
    );
  }
}
