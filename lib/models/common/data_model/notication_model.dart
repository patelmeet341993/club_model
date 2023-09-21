import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class NotificationModel {
  String id = "", title = "", description = "", notificationType = "",sendingTargetGroup = "";
  bool isOpened = false;
  Timestamp? createdTime;

  NotificationModel({
    this.id = "",
    this.title = "",
    this.description = "",
    this.notificationType = "",
    this.sendingTargetGroup = "",
    this.isOpened = false,
    this.createdTime,
  });

  NotificationModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    title = ParsingHelper.parseStringMethod(map['title']);
    description = ParsingHelper.parseStringMethod(map['description']);
    notificationType = ParsingHelper.parseStringMethod(map['notificationType']);
    sendingTargetGroup = ParsingHelper.parseStringMethod(map['sendingTargetGroup']);
    isOpened = ParsingHelper.parseBoolMethod(map['isOpened']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "title" : title,
      "sendingTargetGroup" : sendingTargetGroup,
      "notificationType" : notificationType,
      "description" : description,
      "isOpened" : isOpened,
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}