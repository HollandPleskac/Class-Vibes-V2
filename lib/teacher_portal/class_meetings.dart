import 'package:class_vibes_v2/widgets/no_documents_message.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constant.dart';
import '../logic/fire.dart';
import '../widgets/meetings.dart';

final _fire = Fire();

final Firestore _firestore = Firestore.instance;

class ClassMeetings extends StatelessWidget {
  final String classId;
  final String teacherEmail;

  ClassMeetings({this.classId, this.teacherEmail});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: StreamBuilder(
        stream: _firestore
            .collection("UserData")
            .document(teacherEmail)
            .collection('Meetings')
            .where('class id', isEqualTo: classId)
            .orderBy("timestamp")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.1,
                          right: MediaQuery.of(context).size.width * 0.1,
                          top: MediaQuery.of(context).size.height * 0.035,
                          bottom: MediaQuery.of(context).size.height * 0.032),
                      child: TeacherMeeting(
                        dateAndTime: document['date and time'],
                        length: document['time'],
                        message: document['content'],
                        title: document['title'],
                        teacherEmail: teacherEmail,
                        classId: classId,
                        meetingId: document.documentID,
                        studentEmail: document['student email'],
                      ),
                    );
                  }).toList(),
                );
              } else {
                return Center(
                  child: NoDocsMeetingsClassTeacher(),
                );
              }
          }
        },
      ),
    );
  }
}
