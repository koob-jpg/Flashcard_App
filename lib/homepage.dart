import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_app/widgets/Flashcard.dart';
import 'package:flashcard_app/flashcardsview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  FirebaseFirestore db = FirebaseFirestore.instance;
  //////NEW
  final TextEditingController textController = TextEditingController();

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninPage()),
    );
  }

  Future<void> _createFolder(String name) async {
    DocumentReference doc = db.collection('Users').doc(uid); //////NEW
    CollectionReference subcollection = doc.collection(name);
    FlashCard def = FlashCard('Title Here', 'Content Here');
    //await subcollection.doc().set({});

    await doc.update({
      'Folders': FieldValue.arrayUnion([name])
    });

    await subcollection.doc().set(def.toMap());

    //await db
    //    .collection('Users')
    //    .doc('$uid')
    //    .collection(name)
    //    .doc()
    //    .set({});
  } //////NEW

  void _showPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Create New Folder'),
            content: TextField(
              controller: textController,
              decoration:
                  const InputDecoration(hintText: 'Input Name of Folder'),
            ),
            actions: [
              TextButton(
                  child: Text('CANCEL', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  }),
              TextButton(
                  child: Text('ADD', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    if (textController.text.trim().isEmpty ||
                        textController.text.trim() == null) {
                      Navigator.pop(context);
                      textController.clear();
                    } else {
                      _createFolder(textController.text.trim());
                      Navigator.pop(context);
                      textController.clear();
                    }
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${FirebaseAuth.instance.currentUser?.email}'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: db.collection('Users').doc('$uid').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final documentdata = snapshot.data!.data();
            final folders = documentdata?['Folders'];

            return folders.isEmpty
                ? const Center(
                    child: Text('Create a Folder!'),
                  )
                : Center(
                    child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListView.builder(
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          final currentfolder = folders[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text('$currentfolder',
                                  style: const TextStyle(color: Colors.blue)),
                              onTap: () {
                                //////NEW
                                Navigator.push(
                                    //////NEW
                                    context, //////NEW
                                    MaterialPageRoute(
                                        builder: (context) => FlashCardView(
                                            folder:
                                                currentfolder)) //////NEW ADD THE CLASS TO REDIRECT TO FLASHCARD VIEW
                                    ); //////NEW
                              },
                            ),
                          );
                        }),
                  ));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //////// MAY NEED TO ADD SETSTATE HERE
          _showPopup(context);
        },
        tooltip: 'Add Folder',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              onPressed: () => _logout(context),
              tooltip: 'LogOut',
              child: const Icon(Icons.adjust),
            )
          ],
        ),
      ),
    );
  }
}
