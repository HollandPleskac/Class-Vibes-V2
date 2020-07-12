import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../nav_student.dart';
import '../constant.dart';
import '../logic/fire.dart';

final Firestore _firestore = Firestore.instance;
final _fire = Fire();

class ProfileTeacher extends StatefulWidget {
  @override
  _ProfileTeacherState createState() => _ProfileTeacherState();
}

class _ProfileTeacherState extends State<ProfileTeacher> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameEditController = TextEditingController();

  void _showModalSheetEditUserName() {
    showModalBottomSheet(
        barrierColor: Colors.white.withOpacity(0),
        isScrollControlled: true,
        elevation: 0,
        context: context,
        builder: (builder) {
          return SingleChildScrollView(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
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
                        'Edit Username',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Form(
                        key: _formKey,
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            child: TextFormField(
                              controller: _userNameEditController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Color.fromRGBO(126, 126, 126, 1),
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.grey[700],
                                ),
                                hintText: 'new username',
                                icon: FaIcon(
                                  FontAwesomeIcons.userAlt,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value == '') {
                                  return 'Username cannot be blank';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 20,
                          ),
                          child: FlatButton(
                            color: kPrimaryColor,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                print('validated');
                                _fire.editUserName(
                                  newUserName: _userNameEditController.text,
                                  uid: 'new1@gmail.com',
                                );
                                _userNameEditController.text = '';
                                Navigator.pop(context);
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Save',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavStudent(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: kWetAsphaltColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 60,
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.width / 2.5,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 7,
                      color: Colors
                          .grey[200] //                   <--- border width here
                      ),
                  image: DecorationImage(
                      image: NetworkImage(
                          'https://fiverr-res.cloudinary.com/images/q_auto,f_auto/gigs/115909667/original/7d79dd80b9eecaa289de1bc8065ad44aa03e2daf/do-a-simple-but-cool-profile-pic-or-logo-for-u.jpeg'),
                      fit: BoxFit.cover)),
            ),
          ),
          SizedBox(
            height: 80,
          ),
          Center(
            child: Container(
              height: 42,
              width: MediaQuery.of(context).size.width - 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    "Teacher",
                    style: TextStyle(color: Colors.grey[800], fontSize: 18),
                  ),
                  Spacer(),
                  Text(
                    "Created 16 Classes",
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Center(
            child: Container(
              height: 42,
              width: MediaQuery.of(context).size.width - 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  StreamBuilder(
                      stream: _firestore
                          .collection('UserData')
                          .document('new1@gmail.com')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text('');
                        } else {
                          return Text(
                            snapshot.data['email'],
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 18),
                          );
                        }
                      }),
                  Spacer(),
                  Text(
                    "Email Address",
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () {
              _showModalSheetEditUserName();
              print('user name');
            },
            child: Center(
              child: Container(
                height: 42,
                width: MediaQuery.of(context).size.width - 50,
                child: Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    StreamBuilder(
                        stream: _firestore
                            .collection('UserData')
                            .document('new1@gmail.com')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text('');
                          } else {
                            return Text(
                              snapshot.data['display-name'],
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 18),
                            );
                          }
                        }),
                    Spacer(),
                    Text(
                      "UserName",
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.edit,
                      color: Colors.grey[400],
                    ),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
