import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/pie_charts.dart';
import '../widgets/filtered_tabs.dart';
import '../widgets/filter_btns.dart';
import '../constant.dart';
import '../logic/fire.dart';
import './class_settings.dart';
import './class_announcements.dart';
import './class_meetings.dart';

final Firestore _firestore = Firestore.instance;
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final _fire = Fire();

class ViewClass extends StatefulWidget {
  static const routeName = 'individual-class-teacher';
  @override
  _ViewClassState createState() => _ViewClassState();
}

class _ViewClassState extends State<ViewClass> {
  String _email;

  Future getTeacherEmail() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final email = user.email;

    _email = email;
  }

  @override
  void initState() {
    getTeacherEmail().then((_) {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final String classId = routeArguments['class id'];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: kWetAsphaltColor,
          title: StreamBuilder(
            stream:
                _firestore.collection('Classes').document(classId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text('');
              } else {
                try {
                  return Text(
                    snapshot.data['class name'],
                  );
                } catch (error) {
                  //this check for classid is used to prevent a red error from occurring when deleting a class
                  return Container();
                }
              }
            },
          ),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Students'),
              Tab(text: 'Meetings'),
              Tab(text: 'Announcements'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(children: [
          Container(
            child: StudentsTab(
              teacherEmail: _email,
              classId: classId,
            ),
          ),
          Container(
            child: ClassMeetings(
              teacherEmail: _email,
              classId: classId,
            ),
          ),
          Container(
            child: ClassAnnouncements(
              classId: classId,
            ),
          ),
          Container(
            child: ClassSettings(
              classId: classId,
              email: _email,
            ),
          ),
        ]),
      ),
    );
  }
}

//filter btns - are the nav btns
//filter tabs - are the content displayed if u click on a btn
//located in widgets

class StudentsTab extends StatefulWidget {
  final String teacherEmail;
  final String classId;
  StudentsTab({this.teacherEmail, this.classId});
  @override
  _StudentsTabState createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  bool _isTouchedAll = true;
  bool _isTouchedDoingGreat = false;
  bool _isTouchedNeedHelp = false;
  bool _isTouchedFrustrated = false;
  bool _isTouchedInactive = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChartSwitch(widget.classId),
        Container(
          height: 32.5,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: FilterAll(
                  isTouched: _isTouchedAll,
                  onClick: () => setState(() {
                    _isTouchedAll = true;
                    _isTouchedDoingGreat = false;
                    _isTouchedNeedHelp = false;
                    _isTouchedFrustrated = false;
                    _isTouchedInactive = false;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterDoingGreat(
                  isTouched: _isTouchedDoingGreat,
                  onClick: () => setState(() {
                    _isTouchedAll = false;
                    _isTouchedDoingGreat = true;
                    _isTouchedNeedHelp = false;
                    _isTouchedFrustrated = false;
                    _isTouchedInactive = false;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterNeedHelp(
                  isTouched: _isTouchedNeedHelp,
                  onClick: () => setState(() {
                    _isTouchedAll = false;
                    _isTouchedDoingGreat = false;
                    _isTouchedNeedHelp = true;
                    _isTouchedFrustrated = false;
                    _isTouchedInactive = false;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterFrustrated(
                  isTouched: _isTouchedFrustrated,
                  onClick: () => setState(() {
                    _isTouchedAll = false;
                    _isTouchedDoingGreat = false;
                    _isTouchedNeedHelp = false;
                    _isTouchedFrustrated = true;
                    _isTouchedInactive = false;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 10),
                child: FilterInactive(
                  isTouched: _isTouchedInactive,
                  onClick: () => setState(() {
                    _isTouchedAll = false;
                    _isTouchedDoingGreat = false;
                    _isTouchedNeedHelp = false;
                    _isTouchedFrustrated = false;
                    _isTouchedInactive = true;
                  }),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          height: 360,
          child: _isTouchedAll == true
              ? AllTab(widget.classId, widget.teacherEmail)
              : _isTouchedDoingGreat
                  ? DoingGreatTab(widget.classId, widget.teacherEmail)
                  : _isTouchedNeedHelp
                      ? NeedHelpTab(widget.classId, widget.teacherEmail)
                      : _isTouchedFrustrated
                          ? FrustratedTab(widget.classId, widget.teacherEmail)
                          : _isTouchedInactive
                              ? InactiveTab(widget.classId, widget.teacherEmail)
                              : Text(
                                  'IMPORTANT - this text will never show since one of the first values will always be true'),
        ),
      ],
    );
  }
}

class DynamicPieChart extends StatelessWidget {
  final String classId;

  DynamicPieChart(this.classId);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('Classes')
          .document(classId)
          .collection('Students')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: AspectRatio(aspectRatio: 1.6),
            );
          default:
            if (snapshot.data != null &&
                snapshot.data.documents.isEmpty == false) {
              double doingGreatStudents = snapshot.data.documents
                  .where((document) => document["status"] == "doing great")
                  .where((documentSnapshot) =>
                      DateTime.now()
                          .difference(
                            DateTime.parse(documentSnapshot.data['date']
                                .toDate()
                                .toString()),
                          )
                          .inDays <
                      5)
                  .length
                  .toDouble();

              double needHelpStudents = snapshot.data.documents
                  .where((documentSnapshot) =>
                      documentSnapshot.data['status'] == 'need help')
                  .where((documentSnapshot) =>
                      DateTime.now()
                          .difference(
                            DateTime.parse(documentSnapshot.data['date']
                                .toDate()
                                .toString()),
                          )
                          .inDays <
                      5)
                  .length
                  .toDouble();
              double frustratedStudents = snapshot.data.documents
                  .where((documentSnapshot) =>
                      documentSnapshot.data['status'] == 'frustrated')
                  .where((documentSnapshot) =>
                      DateTime.now()
                          .difference(
                            DateTime.parse(documentSnapshot.data['date']
                                .toDate()
                                .toString()),
                          )
                          .inDays <
                      5)
                  .length
                  .toDouble();
              double inactiveStudents = snapshot.data.documents
                  .where((documentSnapshot) =>
                      DateTime.now()
                          .difference(
                            DateTime.parse(documentSnapshot.data['date']
                                .toDate()
                                .toString()),
                          )
                          .inDays >=
                      5)
                  .length
                  .toDouble();

              double totalStudents = doingGreatStudents +
                  needHelpStudents +
                  frustratedStudents +
                  inactiveStudents.toDouble();

              var doingGreatPercentage =
                  (doingGreatStudents / totalStudents * 100)
                          .toStringAsFixed(0) +
                      '%';
              var needHelpPercentage =
                  (needHelpStudents / totalStudents * 100).toStringAsFixed(0) +
                      '%';
              var frustratedPercentage =
                  (frustratedStudents / totalStudents * 100)
                          .toStringAsFixed(0) +
                      '%';
              var inactivePercentage =
                  (inactiveStudents / totalStudents * 100).toStringAsFixed(0) +
                      '%';

              print('doing great : ' + doingGreatStudents.toString());
              print('need help : ' + needHelpStudents.toString());
              print('frustrated : ' + frustratedStudents.toString());
              print('inactive : ' + inactiveStudents.toString());
              print('totla : ' + totalStudents.toString());
              return PieChartSampleBig(
                //graph percentage
                doingGreatStudents: doingGreatStudents,
                needHelpStudents: needHelpStudents,
                frustratedStudents: frustratedStudents,
                inactiveStudents: inactiveStudents,
                //graph titles
                doingGreatPercentage: doingGreatPercentage,
                needHelpPercentage: needHelpPercentage,
                frustratedPercentage: frustratedPercentage,
                inactivePercentage: inactivePercentage,
              );
            } else {
              return Center(
                child: AspectRatio(
                  aspectRatio: 1.6,
                  child: Center(
                    child: Text('no students'),
                  ),
                ),
              );
            }
        }
      },
    );
  }
}

class ChartSwitch extends StatefulWidget {
  final String classId;
  ChartSwitch(this.classId);
  @override
  _ChartSwitchState createState() => _ChartSwitchState();
}

class _ChartSwitchState extends State<ChartSwitch> {
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            height: 30,
            child: Switch(
              value: isSwitched,
              onChanged: (value) {
                print(value);
                setState(() {
                  isSwitched = value;
                });
              },
            ),
          ),
        ),
        isSwitched == false
            ? DynamicPieChart(widget.classId)
            : AspectRatio(
                aspectRatio: 1.6,
                child: Center(
                  child: Text('chart'),
                ),
              ),
      ],
    );
  }
}
