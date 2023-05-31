import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_app/widgets/Flashcard.dart';

class FlashCardView extends StatefulWidget {
  const FlashCardView({super.key, required this.folder});

  final String folder;

  @override
  State<FlashCardView> createState() => FlashCardViewState();
}

class FlashCardViewState extends State<FlashCardView> {
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController textController1 = TextEditingController();
  final TextEditingController textController2 = TextEditingController();

  Future<void> _addFlashcard(FlashCard fc) async {
    CollectionReference location =
        db.collection('Users').doc(uid).collection(widget.folder);

    await location.add(fc.toMap());
  }

  void _showpopup2(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController1,
                decoration: const InputDecoration(hintText: 'Enter Title'),
              ),
              TextField(
                controller: textController2,
                decoration:
                    const InputDecoration(hintText: 'Enter Description'),
              )
            ],
          ),
          actions: [
            TextButton(
              child: Text('CANCEL', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
                textController1.clear();
                textController2.clear();
              },
            ),
            TextButton(
                child: Text('ADD', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  if ((textController1.text.trim().isEmpty ||
                          textController1.text.trim() == null) &
                      (textController2.text.trim().isEmpty ||
                          textController2.text.trim() == null)) {
                    Navigator.pop(context);
                    textController1.clear();
                    textController2.clear();
                  } else {
                    _addFlashcard(
                        FlashCard(textController1.text, textController2.text));
                    Navigator.pop(context);
                    textController1.clear();
                    textController2.clear();
                  }
                })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('Users')
            .doc(uid)
            .collection(widget.folder)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final temp =
                    FlashCard.fromJson(doc.data() as Map<String, dynamic>);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      temp.title,
                      style: const TextStyle(color: Colors.blue, fontSize: 20),
                    ),
                    subtitle: Text(
                      temp.content,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: $snapshot.error'),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showpopup2(context);
        },
        tooltip: 'Add FlashCard',
        child: const Icon(Icons.add),
      ),
    );
  }
}
