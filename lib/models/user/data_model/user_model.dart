
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_model/utils/my_utils.dart';
import 'package:club_model/utils/parsing_helper.dart';

class UserModel {
  String id = "";
  String name = "";
  String imageUrl = "";
  String mobileNumber = "";
  Timestamp? createdTime;
  Timestamp? updatedTime;

  UserModel({
    this.id = "",
    this.name = "",
    this.imageUrl = "",
    this.mobileNumber = "",
    this.createdTime,
    this.updatedTime,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);
    mobileNumber = ParsingHelper.parseStringMethod(map['mobileNumber']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "name" : name,
      "imageUrl" : imageUrl,
      "mobileNumber" : mobileNumber,
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime" : toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}