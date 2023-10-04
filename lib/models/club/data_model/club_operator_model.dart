import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class ClubOperatorModel {
  String id = "";
  String name = "";
  String profileImageUrl = "";
  String mobileNumber = "";
  List<String> clubIds = [];
  Map<String,String> clubRoles = <String,String>{};
  String emailId = "";
  String password = "";
  bool adminEnabled = true;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  ClubOperatorModel({
    this.id = "",
    this.name = "",
    this.profileImageUrl = "",
    this.mobileNumber = "",
    List<String>? clubIds,
    Map<String,String>? clubRoles,
    this.emailId = "",
    this.password = "",
    this.adminEnabled = true,
    this.createdTime,
    this.updatedTime,
  }){
    this.clubIds = clubIds ?? <String>[];
    this.clubRoles = clubRoles ?? <String,String>{};
  }

  ClubOperatorModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    profileImageUrl = ParsingHelper.parseStringMethod(map['profileImage']);
    mobileNumber = ParsingHelper.parseStringMethod(map['mobileNumber']);
    clubIds = ParsingHelper.parseListMethod<dynamic, String>(map['clubIds']);
    clubRoles = ParsingHelper.parseMapMethod<dynamic,dynamic,String,String>(map['clubRoles']);
    adminEnabled = ParsingHelper.parseBoolMethod(map['adminEnabled']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
    emailId = ParsingHelper.parseStringMethod(map["emailId"]);
    password = ParsingHelper.parseStringMethod(map["password"]);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "name" : name,
      "profileImage" : profileImageUrl,
      "mobileNumber" : mobileNumber,
      "clubIds" : clubIds,
      "clubRoles" : clubRoles,
      "adminEnabled" : adminEnabled,
      "emailId":emailId,
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