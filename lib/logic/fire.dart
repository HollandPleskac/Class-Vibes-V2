import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';

final Firestore _firestore = Firestore.instance;

class Fire {
  void updateClassName(String uid, String classId, String newClassName) {
    _firestore.collection("Classes").document(classId).updateData({
      "class name": newClassName,
    });

    _firestore
        .collection("UserData")
        .document(uid)
        .collection("Classes")
        .document(classId)
        .updateData({
      "class name": newClassName,
    });
  }

  void updateAllowJoin(String uid, String classId, bool newStatusOnJoin) {
    _firestore.collection("Classes").document(classId).updateData({
      "allow join": newStatusOnJoin,
    });
    _firestore
        .collection("UserData")
        .document(uid)
        .collection("Classes")
        .document(classId)
        .updateData({
      "allow join": newStatusOnJoin,
    });
  }

  void updateMaxDaysInactive(
      String uid, String classId, int newMaxDaysInactive) {
    _firestore.collection("Classes").document(classId).updateData({
      "max days inactive": newMaxDaysInactive,
    });
    _firestore
        .collection("UserData")
        .document(uid)
        .collection("Classes")
        .document(classId)
        .updateData({
      "max days inactive": newMaxDaysInactive,
    });
  }

  Future<String> generateNewClassCode(String uid, String classId) async {
    String newCode = randomAlphaNumeric(6);
    // String newCode = '8RDS1y';
    int isCodeUnique = await _firestore
        .collection("Classes")
        .where("class code", isEqualTo: newCode)
        .getDocuments()
        .then((querySnapshot) => querySnapshot.documents.length);

    if (isCodeUnique != 0) {
      // code not unique
      return 'retry';
    }
    _firestore.collection("Classes").document(classId).updateData({
      "class code": newCode,
    });
    _firestore
        .collection("UserData")
        .document(uid)
        .collection("Classes")
        .document(classId)
        .updateData({
      "class code": newCode,
    });
    return 'success';
  }
}