import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firestore = Firestore.instance;

class Auth {
  Future<List> loginAsStudent({String email, String password}) async {
    try {
      AuthResult authResult = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser user = authResult.user;

      if(await checkAccountType(email) == 'Teacher') {
        return ['failure','Account registered as a teacher'];
      }

       if(await checkAccountStatus(email) != 'Activated') {
        return ['failure','Account is Deactivated. If you think this is a mistake contact {class vibes email}'];
      }

      return ['success', email];
    } catch (error) {
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          return ['failure', 'Email is badly formatted'];
        case "ERROR_WRONG_PASSWORD":
          return ['failure', 'Password is incorrect'];
        case "ERROR_USER_NOT_FOUND":
          return ['failure', 'No user exists for this email address'];
        case "ERROR_USER_DISABLED":
          return ['failure', 'Account has been disabled'];
        case "ERROR_TOO_MANY_REQUESTS":
          return [
            'failure',
            'Too many requests to sign in please wait to sign in'
          ];
        case "ERROR_OPERATION_NOT_ALLOWED":
          return [
            'failure',
            'Account not enabled - contact {class vibes email}'
          ];
      }
    }
    return ['success', email];
  }

  Future<List> loginAsTeacher({String email, String password}) async {
    try {
      AuthResult authResult = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser user = authResult.user;

      if(await checkAccountType(email) == 'Student') {
        return ['failure','Account registered as a student'];
      }

      if(await checkAccountStatus(email) != 'Activated') {
        return ['failure','Account is Deactivated. If you think this is a mistake contact {class vibes email}'];
      }

      return ['success', email];
    } catch (error) {
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          return ['failure', 'Email is badly formatted'];
        case "ERROR_WRONG_PASSWORD":
          return ['failure', 'Password is incorrect'];
        case "ERROR_USER_NOT_FOUND":
          return ['failure', 'No user exists for this email address'];
        case "ERROR_USER_DISABLED":
          return ['failure', 'Account has been disabled'];
        case "ERROR_TOO_MANY_REQUESTS":
          return [
            'failure',
            'Too many requests to sign in please wait to sign in'
          ];
        case "ERROR_OPERATION_NOT_ALLOWED":
          return [
            'failure',
            'Account not enabled - contact {class vibes email}'
          ];
      }
    }
    return ['success', email];
  }

//sign up as a teacher
//sign up as a student
// if teacher - get district id - check w/ district id and sort out all the errors before signing up

  Future<List> signUpStudent(
      {String email,
      String password,
      String username,}) async {
    try {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      return ['success', email];
    } catch (error) {
      switch (error.code) {
        case "ERROR_WEAk_PASSWORD":
          return ['failure', 'Password is not strong enough'];
        case "ERROR_INVALID_EMAIL":
          return ['failure', 'Email address formatted incorrectly'];
        case "ERROR_EMAIL_ALREADY_IN_USE ":
          return ['failure', 'Email already in use'];
      }
    }
    return ['success', email];
  }

    Future<List> signUpTeacher(
      {String email,
      String password,
      String username,}) async {
    try {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      return ['success', email];
    } catch (error) {
      switch (error.code) {
        case "ERROR_WEAk_PASSWORD":
          return ['failure', 'Password is not strong enough'];
        case "ERROR_INVALID_EMAIL":
          return ['failure', 'Email address formatted incorrectly'];
        case "ERROR_EMAIL_ALREADY_IN_USE ":
          return ['failure', 'Email already in use'];
      }
    }
    return ['success', email];
  }

  void setUpAccountStudent(
      {String email, String password, String username}) {
    _firestore.collection('UserData').document(email).setData({
      'email': email,
      'display name': username,
      'account type': 'Student',
      'account status': 'Activated',
    });
  }

    void setUpAccountTeacher(
      {String email, String password, String username,String districtId}) {
    _firestore.collection('UserData').document(email).setData({
      'email': email,
      'display name': username,
      'account type': 'Teacher',
      'account status': 'Activated',
    });
  }

  Future<String> checkAccountType(String email) async {
    return await _firestore
        .collection('UserData')
        .document(email)
        .get()
        .then((docSnap) => docSnap.data['account type']);
  }

    Future<String> checkAccountStatus(String email) async {
    return await _firestore
        .collection('UserData')
        .document(email)
        .get()
        .then((docSnap) => docSnap.data['account status']);
  }

  void signOut() async {
    await _firebaseAuth.signOut();
  }
}
