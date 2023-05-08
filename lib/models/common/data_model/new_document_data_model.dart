import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_model/utils/my_utils.dart';

class NewDocumentDataModel {
  String docId = "";
  Timestamp timestamp = Timestamp.now();

  NewDocumentDataModel({
    this.docId = "",
    required this.timestamp,
  });

  @override
  String toString() {
    return MyUtils.encodeJson({
      "docId" : docId,
      "timestamp" : timestamp.toDate().toString(),
    });
  }
}