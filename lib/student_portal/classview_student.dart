import 'dart:ui';
import 'package:class_vibes_v2/widgets/server_down.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constant.dart';
import '../logic/fire.dart';
import '../nav_student.dart';
import './view_class_student.dart';
import './chat_student.dart';
import '../widgets/no_documents_message.dart';
import '../widgets/badges.dart';

final Firestore _firestore = Firestore.instance;
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final _fire = Fire();

class ClassViewStudent extends StatefulWidget {
  @override
  _ClassViewStudentState createState() => _ClassViewStudentState();
}

class _ClassViewStudentState extends State<ClassViewStudent> {
  String _email;

  Future getStudentEmail() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final email = user.email;

    _email = email;
  }

  @override
  void initState() {
    getStudentEmail().then((_) {
      print(_email);
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('Application Management')
          .document('ServerManagement')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('');
        } else {
          return snapshot.data['serversAreUp'] == false
              ? ServersDown()
              : Scaffold(
                  drawer: NavStudent(),
                  backgroundColor: Color.fromRGBO(250, 250, 250, 1.0),
                  appBar: AppBar(
                    backgroundColor: kAppBarColor,
                    title: Text(
                      'Classes',
                      style: TextStyle(color: Colors.white),
                    ),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        onPressed: () {
                          print('press question');
                          showStudentInfoPopUp(context);
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.question,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: StreamBuilder(
                      stream: _firestore
                          .collection('UserData')
                          .document(_email)
                          .collection('Classes')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(
                              child: Container(),
                            );
                          default:
                            if (snapshot.data != null &&
                                snapshot.data.documents.isEmpty == false) {
                              return ListView(
                                physics: BouncingScrollPhysics(),
                                children: snapshot.data.documents
                                    .map((DocumentSnapshot document) {
                                  return StudentClass(
                                    classId: document.documentID,
                                    email: _email,
                                    unreadCount: document['student unread'],
                                  );
                                }).toList(),
                              );
                            } else {
                              return Scaffold(
                                backgroundColor: Colors.white,
                                appBar: AppBar(
                                  backgroundColor: Colors.blue[200],
                                  elevation: 6,
                                  leading: SizedBox(),
                                  centerTitle: true,
                                  title: Text(
                                    'Ask your teacher for the class code!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                body: Center(
                                  child: NoDocsClassViewStudent(),
                                ),
                              );
                            }
                        }
                      },
                    ),
                  ),
                );
        }
      },
    );
  }
}

class StudentClass extends StatelessWidget {
  final String classId;
  final String email;
  final int unreadCount;

  StudentClass({
    this.classId,
    this.email,
    this.unreadCount,
  });
  @override
  Widget build(BuildContext context) {
    Future getClassName() async {
      return await _firestore
          .collection('Classes')
          .document(classId)
          .get()
          .then(
            (docSnap) => docSnap.data['class name'],
          );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      // color: Colors.red,
      child: StreamBuilder(
        stream: _firestore.collection('Classes').document(classId).snapshots(),
        builder: (BuildContext context, classSnapshot) {
          if (classSnapshot.data == null) {
            return Center(
              child: Container(),
            );
          }
          return Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      Navigator.pushNamed(context, ViewClassStudent.routename,
                          arguments: {
                            'class id': classId,
                            'class name': await getClassName(),
                            'initial index': 0,
                          });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.1,
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.07,
                      ),
                      child: Center(
                        child: Text(
                          classSnapshot.data['class name'],
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            // fontFamily: 'Nunito',
                            wordSpacing: 2,
                            letterSpacing: 1.25,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: MediaQuery.of(context).size.width * 0.025,
                    child: UnreadMessageBadge(unreadCount),
                  ),
                ],
              ),
              StreamBuilder(
                stream: _firestore
                    .collection('Classes')
                    .document(classId)
                    .collection('Students')
                    .document(email)
                    .snapshots(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: Container(),
                    );
                  }
                  return snapshot.data['accepted'] == true
                      ? SelectStatusRow(
                          classId: classId,
                          lastChangedStatus: snapshot.data['date'],
                          status: snapshot.data['status'],
                          email: email,
                          maxDaysInactive:
                              classSnapshot.data['max days inactive'],
                        )
                      : StatusRowLocked();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// class StudentClass extends StatelessWidget {
//   final String classId;
//   final String email;
//   final int unreadCount;

//   StudentClass({
//     this.classId,
//     this.email,
//     this.unreadCount,
//   });
//   @override
//   Widget build(BuildContext context) {
//     Future getClassName() async {
//       return await _firestore
//           .collection('Classes')
//           .document(classId)
//           .get()
//           .then(
//             (docSnap) => docSnap.data['class name'],
//           );
//     }

//     return Stack(
//       children: [
//         GestureDetector(
//           onTap: () async {
//             _fire.resetStudentUnreadCount(
//               classId: classId,
//               studentEmail: email,
//             );
//             Navigator.pushNamed(context, ViewClassStudent.routename,
//                 arguments: {
//                   'class id': classId,
//                   'class name': await getClassName(),
//                   'initial index': 0,
//                 });
//           },
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.14,
//             width: double.infinity,
//             child: Padding(
//               padding: EdgeInsets.only(
//                 top: MediaQuery.of(context).size.height * 0.035,
//                 left: MediaQuery.of(context).size.width * 0.05,
//                 right: MediaQuery.of(context).size.width * 0.05,
//               ),
//               child: Card(
//                 child: StreamBuilder(
//                     stream: _firestore
//                         .collection('Classes')
//                         .document(classId)
//                         .snapshots(),
//                     builder: (BuildContext context, classSnapshot) {
//                       if (classSnapshot.data == null) {
//                         return Center(
//                           child: Container(),
//                         );
//                       }
//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Padding(
//                             padding: EdgeInsets.only(
//                                 left: MediaQuery.of(context).size.width * 0.05),
//                             child: Container(
//                               width: MediaQuery.of(context).size.width * 0.4,
//                               child: Text(
//                                 classSnapshot.data['class name'],
//                                 overflow: TextOverflow.fade,
//                                 softWrap: false,
//                                 style: TextStyle(
//                                   fontSize:
//                                       MediaQuery.of(context).size.width * 0.046,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.only(right: 20),
//                             child: StreamBuilder(
//                               stream: _firestore
//                                   .collection('Classes')
//                                   .document(classId)
//                                   .collection('Students')
//                                   .document(email)
//                                   .snapshots(),
//                               builder: (BuildContext context, snapshot) {
//                                 if (snapshot.data == null) {
//                                   return Center(
//                                     child: Container(),
//                                   );
//                                 }
//                                 return SelectStatusRow(
//                                   classId: classId,
//                                   lastChangedStatus: snapshot.data['date'],
//                                   status: snapshot.data['status'],
//                                   email: email,
//                                   maxDaysInactive:
//                                       classSnapshot.data['max days inactive'],
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//                     }),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           top: MediaQuery.of(context).size.height * 0.03,
//           right: MediaQuery.of(context).size.width * 0.03,
//           child: UnreadMessageBadge(unreadCount),
//         ),
//       ],
//     );
//   }
// }

void showStudentInfoPopUp(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 200.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(1)),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Current Mood",
                        style: TextStyle(
                            fontSize: 24.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "How do you currently feel about class? ",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width * 0.85 - 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.smile,
                                  size: 43.0,
                                  color: Colors.green,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  "Doing Great",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.meh,
                                  size: 43.0,
                                  color: Colors.orange[600],
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  " Need Help ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.orange[600],
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.frown,
                                  size: 43.0,
                                  color: Colors.red[700],
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  "Frustrated",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: Colors.grey[500].withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ],
                  )),
            ),
          ),
        ),
      );
    },
  );
}

class SelectStatusRow extends StatefulWidget {
  final String classId;
  final Timestamp lastChangedStatus;
  final String status;
  final String email;
  final int maxDaysInactive;

  SelectStatusRow(
      {this.classId,
      this.lastChangedStatus,
      this.status,
      this.email,
      this.maxDaysInactive});
  @override
  _SelectStatusRowState createState() => _SelectStatusRowState();
}

class _SelectStatusRowState extends State<SelectStatusRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () {
            _fire.updateStudentMood(
                uid: widget.email,
                classId: widget.classId,
                newMood: 'doing great');
            print('changing status');
          },
          splashColor: Colors.green[100],
          child: Ink(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.1,
            color: DateTime.now()
                        .difference(
                          DateTime.parse(
                              widget.lastChangedStatus.toDate().toString()),
                        )
                        .inDays >=
                    widget.maxDaysInactive
                ? Colors.grey[300]
                : widget.status == 'doing great'
                    ? Colors.green[100]
                    : Colors.transparent,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.smile,
                color: Colors.green,
                size: MediaQuery.of(context).size.width * 0.0825,
                //used to be 36
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            _fire.updateStudentMood(
                uid: widget.email,
                classId: widget.classId,
                newMood: 'need help');
            print('changing status');
          },
          splashColor: Colors.orange[100],
          child: Ink(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.1,
            color: DateTime.now()
                        .difference(
                          DateTime.parse(
                              widget.lastChangedStatus.toDate().toString()),
                        )
                        .inDays >=
                    widget.maxDaysInactive
                ? Colors.grey[300]
                : widget.status == 'need help'
                    ? Colors.orange[100]
                    : Colors.transparent,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.meh,
                color: Colors.yellow[800],
                size: MediaQuery.of(context).size.width * 0.0825,
                //used to be 36
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            _fire.updateStudentMood(
                uid: widget.email,
                classId: widget.classId,
                newMood: 'frustrated');
            print('changing status');
          },
          splashColor: Colors.red[100],
          child: Ink(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.1,
            color: DateTime.now()
                        .difference(
                          DateTime.parse(
                              widget.lastChangedStatus.toDate().toString()),
                        )
                        .inDays >=
                    widget.maxDaysInactive
                ? Colors.grey[300]
                : widget.status == 'frustrated'
                    ? Colors.red[100]
                    : Colors.transparent,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.frown,
                color: Colors.red,
                size: MediaQuery.of(context).size.width * 0.0825,
                //used to be 36
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class SelectStatusRow extends StatefulWidget {
//   final String classId;
//   final Timestamp lastChangedStatus;
//   final String status;
//   final String email;
//   final int maxDaysInactive;

//   SelectStatusRow(
//       {this.classId,
//       this.lastChangedStatus,
//       this.status,
//       this.email,
//       this.maxDaysInactive});
//   @override
//   _SelectStatusRowState createState() => _SelectStatusRowState();
// }

// class _SelectStatusRowState extends State<SelectStatusRow> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         GestureDetector(
//           onTap: () {
//             _fire.updateStudentMood(
//                 uid: widget.email,
//                 classId: widget.classId,
//                 newMood: 'doing great');
//             print('changing status');
//           },
//           child: DateTime.now()
//                       .difference(
//                         DateTime.parse(
//                             widget.lastChangedStatus.toDate().toString()),
//                       )
//                       .inDays >=
//                   widget.maxDaysInactive
//               ? FaIcon(
//                   FontAwesomeIcons.smile,
//                   color: Colors.grey,
//                   size: MediaQuery.of(context).size.width * 0.0825,
//                   //used to be 36
//                 )
//               : FaIcon(
//                   widget.status == 'doing great'
//                       ? FontAwesomeIcons.solidSmile
//                       : FontAwesomeIcons.smile,
//                   color: Colors.green,
//                   size: MediaQuery.of(context).size.width * 0.0825,
//                   //used to be 36
//                 ),
//         ),
//         // FaIcon(
//         //   FontAwesomeIcons.smile,
//         //   color: Colors.green,
//         //   size: 36,
//         // ),
//         SizedBox(
//           width: 20,
//         ),
//         GestureDetector(
//           onTap: () {
//             _fire.updateStudentMood(
//                 uid: widget.email,
//                 classId: widget.classId,
//                 newMood: 'need help');
//             print('changing status');
//           },
//           child: DateTime.now()
//                       .difference(
//                         DateTime.parse(
//                             widget.lastChangedStatus.toDate().toString()),
//                       )
//                       .inDays >=
//                   widget.maxDaysInactive
//               ? FaIcon(
//                   FontAwesomeIcons.meh,
//                   color: Colors.grey,
//                   size: MediaQuery.of(context).size.width * 0.0825,
//                   //used to be 36
//                 )
//               : FaIcon(
//                   widget.status == 'need help'
//                       ? FontAwesomeIcons.solidMeh
//                       : FontAwesomeIcons.meh,
//                   color: Colors.yellow[800],
//                   size: MediaQuery.of(context).size.width * 0.0825,
//                   //used to be 36
//                 ),
//         ),
//         // FaIcon(
//         //   FontAwesomeIcons.meh,
//         //   color: Colors.yellow[800],
//         //   size: 36,
//         // ),
//         SizedBox(
//           width: 20,
//         ),
//         GestureDetector(
//           onTap: () {
//             _fire.updateStudentMood(
//                 uid: widget.email,
//                 classId: widget.classId,
//                 newMood: 'frustrated');
//             print('changing status');
//           },
//           child: DateTime.now()
//                       .difference(
//                         DateTime.parse(
//                             widget.lastChangedStatus.toDate().toString()),
//                       )
//                       .inDays >=
//                   widget.maxDaysInactive
//               ? FaIcon(
//                   FontAwesomeIcons.frown,
//                   color: Colors.grey,
//                   size: MediaQuery.of(context).size.width * 0.0825,
//                   //used to be 36
//                 )
//               : FaIcon(
//                   widget.status == 'frustrated'
//                       ? FontAwesomeIcons.solidFrown
//                       : FontAwesomeIcons.frown,
//                   color: Colors.red,
//                   size: MediaQuery.of(context).size.width * 0.0825,
//                   //used to be 36
//                 ),
//         ),
//         // FaIcon(
//         //   FontAwesomeIcons.frown,
//         //   color: Colors.red,
//         //   size: 36,
//         // ),
//       ],
//     );
//   }
// }

class StatusRowLocked extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width * 0.6,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.03,
          ),
          //maybe a row with some type of nice loading indicator here or something?
          child: Text(
            'Pending Approval',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.25,
            ),
          ),
        ),
      ),
    );
  }
}
