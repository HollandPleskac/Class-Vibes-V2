import 'package:flutter/material.dart';

import '../constant.dart';
import './chat_student.dart';
import './class_meetings_student.dart';

class ViewClassStudent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kWetAsphaltColor,
          title: Text('className'),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Meetings'),
              Tab(text: 'Announcements'),
              Tab(text: 'Chat',)
            ],
          ),
        ),
        body: TabBarView(children: [
          Container(),
          Container(
            child: ClassMeetingsStudent(),
          ),
          Container(
          
          ),
          Container(
            child: ChatStudent(),
          ),
        ]),
      ),
    );
  }
}