import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';

class ProfileUpdateRequestModel {
  String id = "";
  String name = "";
  Timestamp? updatedTime;

  ProfileUpdateRequestModel({
    this.id = "",
    this.name = "",
    this.updatedTime,
  });

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "name" : name,
      "updatedTime" : toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}