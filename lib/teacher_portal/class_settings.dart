import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constant.dart';
import '../logic/fire.dart';
import './classview_teacher.dart';

final _fire = Fire();
final Firestore _firestore = Firestore.instance;

class ClassSettings extends StatefulWidget {
  static const routeName = 'individual-class-settings-teacher';
  String classId;
  String email;
  ClassSettings({
    this.classId,
    this.email,
  });
  @override
  _ClassSettingsState createState() => _ClassSettingsState();
}

class _ClassSettingsState extends State<ClassSettings> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _classNameController = TextEditingController();
  bool isSwitched;
  int maxDaysInactive;

  Future getInitialSwitchValue() async {
    bool initialSwitchVal = await _firestore
        .collection("Classes")
        .document(widget.classId)
        .get()
        .then((docSnap) => docSnap.data['allow join']);
    print('initial val of switch ' + initialSwitchVal.toString());
    isSwitched = initialSwitchVal;
  }

  Future getDaysInactive() async {
    int daysInactive = await _firestore
        .collection("Classes")
        .document(widget.classId)
        .get()
        .then((docSnap) => docSnap.data['max days inactive']);
    maxDaysInactive = daysInactive;
  }

  @override
  void initState() {
    getInitialSwitchValue().then((_) {
      print(isSwitched);
      getDaysInactive().then((_) {
        print(maxDaysInactive);
        setState(() {});
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          EditClassName(
            controller: _classNameController,
            classId: widget.classId,
            teacherEmail: widget.email,
          ),
          SizedBox(
            height: 50,
          ),
          IsAcceptingJoin(
            isSwitched: isSwitched,
            updateSwitch: () {
              setState(() {
                isSwitched == false ? isSwitched = true : isSwitched = false;
              });
            },
            classId: widget.classId,
            email: widget.email,
          ),
          SizedBox(
            height: 50,
          ),
          ClassCode(widget.classId),
          SizedBox(
            height: 25,
          ),
          InactiveDaysPicker(
            maxDaysInactive,
            widget.email,
            widget.classId,
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DeleteClass(
                classId: widget.classId,
                teacherEmail: widget.email,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class EditClassName extends StatelessWidget {
  final TextEditingController controller;
  final String teacherEmail;
  final String classId;

  EditClassName({
    this.controller,
    this.teacherEmail,
    this.classId,
  });
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
        ),
        Form(
          key: _formKey,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.725,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Class Name',
                labelStyle: TextStyle(fontSize: 16, color: kWetAsphaltColor),
              ),
              validator: (value) {
                if (value == null || value == '') {
                  return 'Class name cannot be blank';
                } else if (value.length > 16) {
                  return 'Class name cannot be greater than 16 characters';
                } else {
                  return null;
                }
              },
            ),
          ),
        ),
        Spacer(),
        ClipOval(
          child: Material(
            color: Colors.transparent, // button color

            child: InkWell(
              splashColor: Colors.blue,
              child: SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.check,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              onTap: () {
                if (_formKey.currentState.validate()) {
                  _fire.updateClassName(teacherEmail, classId, controller.text);
                }
              },
            ),
          ),
        ),
        SizedBox(
          width: 25,
        ),
      ],
    );
  }
}

class IsAcceptingJoin extends StatefulWidget {
  final bool isSwitched;
  Function updateSwitch;
  final String classId;
  final String email;
  IsAcceptingJoin({
    this.isSwitched,
    this.updateSwitch,
    this.classId,
    this.email,
  });
  @override
  _IsAcceptingJoinState createState() => _IsAcceptingJoinState();
}

class _IsAcceptingJoinState extends State<IsAcceptingJoin> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
        ),
        Text(
          'Allow students to join',
          style: TextStyle(
            color: kWetAsphaltColor,
            fontSize: 18,
          ),
        ),
        Spacer(),
        widget.isSwitched == null
            ? CircularProgressIndicator()
            : CupertinoSwitch(
                value: widget.isSwitched,
                onChanged: (value) {
                  widget.updateSwitch();
                  _fire.updateAllowJoin(widget.email, widget.classId, value);
                },
                activeColor: kPrimaryColor,
              ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}

class DeleteClass extends StatefulWidget {
  final String classId;
  final String teacherEmail;

  DeleteClass({this.classId, this.teacherEmail});
  @override
  _DeleteClassState createState() => _DeleteClassState();
}

class _DeleteClassState extends State<DeleteClass> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        child: Text(
          'Delete Class',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        color: Colors.grey[300],
        onPressed: () {
          _fire.deleteClass(
              classId: widget.classId, teacherEmail: widget.teacherEmail);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ClassViewTeacher(),
            ),
          );
        },
      ),
    );
  }
}

class InactiveDaysPicker extends StatefulWidget {
  int maxDaysInactive;
  String email;
  String classId;
  InactiveDaysPicker(
    this.maxDaysInactive,
    this.email,
    this.classId,
  );
  @override
  _InactiveDaysPickerState createState() => _InactiveDaysPickerState();
}

class _InactiveDaysPickerState extends State<InactiveDaysPicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
        ),
        Text(
          'Max Student Inactive Days',
          style: TextStyle(fontSize: 18, color: kWetAsphaltColor),
        ),
        Spacer(),
        widget.maxDaysInactive == null
            ? CircularProgressIndicator()
            : NumberPicker.integer(
                initialValue: widget.maxDaysInactive,
                minValue: 1,
                maxValue: 7,
                onChanged: (value) {
                  setState(() {
                    widget.maxDaysInactive = value;
                  });
                },
              ),
        Spacer(),
        ClipOval(
          child: Material(
            color: Colors.transparent, // button color

            child: InkWell(
              splashColor: Colors.blue,
              child: SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.check,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              onTap: () {
                _fire.updateMaxDaysInactive(
                    widget.email, widget.classId, widget.maxDaysInactive);
              },
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}

class ClassCode extends StatefulWidget {
  String classId;

  ClassCode(this.classId);
  @override
  _ClassCodeState createState() => _ClassCodeState();
}

class _ClassCodeState extends State<ClassCode> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
        ),
        Text(
          'Class Code',
          style: TextStyle(
            color: kWetAsphaltColor,
            fontSize: 18,
          ),
        ),
        Spacer(),
        StreamBuilder(
            stream: _firestore
                .collection('Classes')
                .document(widget.classId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: Container(),
                  );

                default:
                  try {
                    String code = snapshot.data['class code'];
                    List codeLetters = code.split("");
                    if (snapshot.data != null) {
                      return Row(
                        children: codeLetters.map((letter) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  letter,
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Container(
                                  color: kPrimaryColor,
                                  height: 2,
                                  width: 25,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      return Center(
                        child: Text('no data'),
                      );
                    }
                  } catch (error) {
                    return Padding(
                      padding: EdgeInsets.only(right:20),
                      // class code always exists - used when delete class is called and streambuilder doesnt have a classcode and throws an error
                      child: Container(),
                    );
                  }
              }

              // return Row(
              //   children: codeLetters.map((letter) {
              //     return Padding(
              //       padding: const EdgeInsets.only(right: 15),
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text(
              //             letter,
              //             style: TextStyle(
              //                 color: kPrimaryColor,
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.bold),
              //           ),
              //           SizedBox(
              //             height: 6,
              //           ),
              //           Container(
              //             color: kPrimaryColor,
              //             height: 2,
              //             width: 25,
              //           ),
              //         ],
              //       ),
              //     );
              //   }).toList(),
              // );
            }),
      ],
    );
  }
}
