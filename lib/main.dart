import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String input = '';
  var shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30.0),
  );
  Color mid = Colors.white;
  Createtodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Mytodos").doc(input);
    Map<String, String> todos = {"input": input};
    documentReference.set(todos).whenComplete(() => print("$input created"));
  }

  Deletetodos(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Mytodos").doc(item);
    documentReference.delete().whenComplete(() => print("$item deleted"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("To-do", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black45,
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance.collection("Mytodos").snapshots(),
            builder: (context, snapshots) {
              if (snapshots.hasData) {
                if (snapshots.data!.docs.isEmpty) {
                  return Center(
                    child: Container(
                      height: 220.0,
                      child: MaterialButton(
                        shape: shape,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.black54,
                              size: 50,
                            ),
                            Text(
                              "No tasks yet...\n\nAdd new task?",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: shape,
                                  title: Text(
                                    "Add todo",
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  content: TextField(
                                    cursorColor: Colors.black54,
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black54),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black54),
                                      ),
                                    ),
                                    autofocus: true,
                                    onChanged: (value) {
                                      input = value;
                                    },
                                  ),
                                  actions: [
                                    MaterialButton(
                                      shape: shape,
                                      color: Colors.black54,
                                      onPressed: () {
                                        Createtodos();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "Add",
                                        style: TextStyle(
                                          color: mid,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              });
                        },
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshots.data!.docs.length,
                      itemBuilder: (context, index) {
                        QueryDocumentSnapshot<Map<String, dynamic>>
                            documentSnapshot = snapshots.data!.docs[index];
                        return Dismissible(
                          onDismissed: (direction) {
                            Deletetodos(documentSnapshot.data()["input"] ?? '');
                          },
                          key: Key(documentSnapshot.data()["input"] ?? ''),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                            child: Card(
                              shape: shape,
                              color: mid,
                              borderOnForeground: true,
                              elevation: 20.0,
                              child: ListTile(
                                  trailing: MaterialButton(
                                    shape: CircleBorder(),
                                    height: 40.0,
                                    minWidth: 40.0,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: shape,
                                              title: Text(
                                                "Confirm Delete task \"${documentSnapshot.data()["input"] ?? ''}\" ?",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              actions: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    MaterialButton(
                                                      shape: shape,
                                                      color: Colors.black54,
                                                      onPressed: () {
                                                        Deletetodos(
                                                            documentSnapshot
                                                                        .data()[
                                                                    "input"] ??
                                                                '');
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: mid,
                                                        ),
                                                      ),
                                                    ),
                                                    MaterialButton(
                                                      shape: shape,
                                                      color: Colors.black54,
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color: mid,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                  title: Row(
                                    children: [
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      Text(
                                        documentSnapshot.data()["input"] ?? '',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        );
                      });
                }
              } else {
                return Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
      floatingActionButton: MaterialButton(
        height: 40.0,
        shape: shape,
        color: Colors.white,
        child: Text(
          "Add new task",
          style: TextStyle(color: Colors.black54),
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: shape,
                  title: Text(
                    "Add todo",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  content: TextField(
                    cursorColor: Colors.black54,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                      ),
                    ),
                    autofocus: true,
                    onChanged: (value) {
                      input = value;
                    },
                  ),
                  actions: [
                    MaterialButton(
                      shape: shape,
                      color: Colors.black54,
                      onPressed: () {
                        Createtodos();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Add",
                        style: TextStyle(
                          color: mid,
                        ),
                      ),
                    )
                  ],
                );
              });
        },
      ),
    );
  }
}
