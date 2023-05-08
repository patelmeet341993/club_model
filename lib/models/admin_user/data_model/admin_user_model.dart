


import 'package:club_model/club_model.dart';

class AdminUserModel {
  String adminType = "",password = "",adminId = "";
  Timestamp? createdTime;
  bool isEnabled = true;

  AdminUserModel({
    this.adminType = "",
    this.password = "",
    this.adminId = "",
    this.createdTime,
    this.isEnabled =  true,
  });

  AdminUserModel.fromMap(Map<String, dynamic> map) {
    adminType = ParsingHelper.parseStringMethod(map['adminType']);
    password = ParsingHelper.parseStringMethod(map['password']);
    adminId = ParsingHelper.parseStringMethod(map['adminId']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    isEnabled = ParsingHelper.parseBoolMethod(map['isEnabled']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    Map<String, dynamic> map = {
      "adminType" : adminType,
      "password" : password,
      "adminId" : adminId,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
      "isEnabled" : isEnabled,
    };

    return map;
  }

  @override
  String toString({bool toJson = true}) {
    return toJson ? MyUtils.encodeJson(toMap(toJson: true)) : "AdminUserModel(${toMap(toJson: false)})";
  }
}