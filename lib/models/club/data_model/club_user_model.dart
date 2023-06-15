import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class ClubUserModel {
  String id = "";
  String name = "";
  String profileImage = "";
  String mobileNumber = "";
  String clubId = "";
  String userId = "";
  String adminType = "";
  String password = "";
  bool adminEnabled = false;
  bool clubEnabled = false;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  ClubUserModel({
    this.id = "",
    this.name = "",
    this.profileImage = "",
    this.mobileNumber = "",
    this.clubId = "",
    this.userId = "",
    this.password = "",
    this.adminEnabled = false,
    this.clubEnabled = false,
    this.createdTime,
    this.updatedTime,
  });

  ClubUserModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    profileImage = ParsingHelper.parseStringMethod(map['profileImage']);
    mobileNumber = ParsingHelper.parseStringMethod(map['mobileNumber']);
    clubId = ParsingHelper.parseStringMethod(map['address']);
    adminEnabled = ParsingHelper.parseBoolMethod(map['adminEnabled']);
    clubEnabled = ParsingHelper.parseBoolMethod(map['clubEnabled']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
    userId = ParsingHelper.parseStringMethod(map["userId"]);
    password = ParsingHelper.parseStringMethod(map["password"]);
    adminType = ParsingHelper.parseStringMethod(map["adminType"]);



  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "name" : name,
      "profileImage" : profileImage,
      "mobileNumber" : mobileNumber,
      "address" : clubId,
      "adminType" : adminType,
      "adminEnabled" : adminEnabled,
      "clubEnabled" : clubEnabled,
      "userId":userId,
      "password":password,
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime" : toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}