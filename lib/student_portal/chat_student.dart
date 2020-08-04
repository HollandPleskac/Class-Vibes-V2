import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constant.dart';
import '../widgets/no_documents_message.dart';
import '../logic/fire.dart';

final Firestore _firestore = Firestore.instance;
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

final _fire = Fire();

class ChatStudent extends StatefulWidget {
  static const routeName = 'student-chat';
  final String email;
  final String classId;
  ChatStudent({
    this.email,
    this.classId,
  });
  @override
  _ChatStudentState createState() => _ChatStudentState();
}

class _ChatStudentState extends State<ChatStudent> {
  final TextEditingController _controller = TextEditingController();
  void _showModalSheet() {
    showModalBottomSheet(
        barrierColor: Colors.white.withOpacity(0),
        elevation: 0,
        context: context,
        builder: (builder) {
          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade300.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Options',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    ListTile(
                      onTap: () {},
                      leading: Icon(
                        Icons.do_not_disturb,
                        color: Colors.black87,
                      ),
                      title: Text(
                        'Mute Messages',
                        style: TextStyle(color: Colors.black87),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  String _studentName;

  Future getStudentName() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final name = user.displayName;

    _studentName = name;
  }

  @override
  void initState() {
    getStudentName().then((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: StreamBuilder(
                stream: _firestore
                    .collection("Class-Chats")
                    .document(widget.classId)
                    .collection('Students')
                    .document(widget.email)
                    .collection('Messages')
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      if (snapshot.data != null &&
                          snapshot.data.documents.isEmpty == false) {
                        return Center(
                          //lazy loading
                          child: ListView.builder(
                            reverse: true,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              return snapshot.data.documents[index]
                                          ['sent type'] ==
                                      'teacher'
                                  ? RecievedChat(
                                      title: snapshot.data.documents[index]
                                          ['user'],
                                      content: snapshot.data.documents[index]
                                          ['message'],
                                    )
                                  : SentChat(
                                      title: snapshot.data.documents[index]
                                          ['user'],
                                      content: snapshot.data.documents[index]
                                          ['message'],
                                    );
                            },
                          ),
                        );
                      } else {
                        return Center(
                          child: NoDocsChat(),
                        );
                      }
                  }
                },
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 50,
                          height: 50,
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: Colors.black,
                                  ),
                                  onPressed: () async {
                                    _fire.incrementTeacherUnreadCount(
                                        classId: widget.classId,
                                        studentEmail: widget.email,
                                        
                                       );
                                    await _firestore
                                        .collection('Class-Chats')
                                        .document(widget.classId)
                                        .collection('Students')
                                        .document(widget.email)
                                        .collection('Messages')
                                        .document()
                                        .setData({
                                      'timestamp': DateTime.now(),
                                      'message': _controller.text,
                                      'user': _studentName,
                                      'sent type': 'student',
                                    });
                                    _controller.clear();
                                  }),
                              //SIZE THIS
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.675,
                                    child: TextField(
                                      controller: _controller,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SentChat extends StatelessWidget {
  final String title;
  final String content;

  SentChat({
    this.title,
    this.content,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 100, bottom: 30),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15)),
          color: kPrimaryColor.withOpacity(0.5),
          // color: Colors.redAccent.shade400.withOpacity(0.3),
        ),
        width: 100,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              Text(
                content,
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RecievedChat extends StatelessWidget {
  final String title;
  final String content;

  RecievedChat({this.title, this.content});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 100, bottom: 30),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(15),
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15)),
            color: Colors.grey.shade200),
        width: 100,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                    color: Colors.grey[800], fontWeight: FontWeight.w800),
              ),
              Text(
                content,
                style: TextStyle(color: Colors.grey[800]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
