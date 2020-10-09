import 'package:class_vibes_v2/logic/auth_service.dart';
import 'package:class_vibes_v2/models/models.dart';
import 'package:class_vibes_v2/widgets/server_down.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../student_portal/classview_student.dart';
import '../logic/auth.dart';
import '../constant.dart';
import '../widgets/forgot_password_popup.dart';

final _auth = Auth();
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final _newAuth = AuthenticationService();

class StudentLogin extends StatelessWidget {
  final _formKey = new GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StudentSignInFeedbackModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        backgroundColor: Colors.white,
        body: StreamBuilder(
            stream: _firestore
                .collection('Application Management')
                .doc('ServerManagement')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text('');
              } else {
                return snapshot.data['serversAreUp'] == false
                    ? ServersDown()
                    : ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.18,
                          ),
                          Center(
                            child: Text(
                              'Student',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 46,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15,
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: TextFormField(
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Email'),
                                          validator: (value) {
                                            if (value == null || value == '') {
                                              return 'Email cannot be blank';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Center(
                                  child: Container(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: TextFormField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Password'),
                                          validator: (value) {
                                            if (value == null || value == '') {
                                              return 'Password cannot be blank';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Center(
                            child: Container(
                              child: new Material(
                                child: new InkWell(
                                  onTap: () async {
                                    if (_formKey.currentState.validate()) {
                                      String res = await _newAuth.signInEmailStudent(_emailController.text,
                                              _passwordController.text);

                                      // notify feedback model listeners
                                      if (res != 'Signed in') {
                                        context
                                            .read<StudentSignInFeedbackModel>()
                                            .updateFeedback(res);
                                      } else {
                                    
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ClassViewStudent(),
                                            ));
                                        print('else');
                                      }
                                    }
                                  },
                                  child: new Container(
                                    child: Center(
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: Colors.transparent,
                              ),
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 0.85,
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.025,
                          ),
                          Center(
                            child: Container(
                              child: new Material(
                                child: new InkWell(
                                  onTap: () async {
                                    print('google sign in');
                                    List result =
                                        await _auth.signInWithGoogleStudent();
                                    if (result[0] == 'failure') {
                                      print('failure');
                                    } else {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ClassViewStudent()),
                                          (Route<dynamic> route) => false);
                                    }
                                    print(result[0]);
                                  },
                                  child: new Container(
                                    child: Center(
                                      child: Text(
                                        'Sign in with Google',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: Colors.transparent,
                              ),
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 0.85,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.025,
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Consumer<StudentSignInFeedbackModel>(
                                builder: (context, feedback, widget) {
                                  print('ACTUAL DISPLAY feedback : ' +
                                      feedback.feedback);
                                  return Text(
                                    feedback.feedback,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 15.5),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.002,
                          ),
                          InkWell(
                            onTap: () {
                              print('sending');
                              showDialog(
                                  context: context,
                                  builder: (context) => ForgotPasswordPopup());
                            },
                            child: Center(
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
              }
            }),
      ),
    );
  }
}
