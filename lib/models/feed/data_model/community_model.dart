import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class CommunityModel {
  String id = "", cid = "", name = "", description = "", imageUrl = "", coverImageUrl = "";
  int postCount = 0;
  Timestamp? createdTime, updatedTime, editedTime;

  CommunityModel({
    this.id = "",
    this.cid = "",
    this.name = "",
    this.description = "",
    this.imageUrl = "",
    this.coverImageUrl = "",
    this.postCount = 0,
    this.createdTime,
    this.updatedTime,
    this.editedTime,
  });

  CommunityModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    cid = ParsingHelper.parseStringMethod(map['cid']);
    name = ParsingHelper.parseStringMethod(map['name']);
    description = ParsingHelper.parseStringMethod(map['description']);
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);
    coverImageUrl = ParsingHelper.parseStringMethod(map['coverImageUrl']);
    postCount = ParsingHelper.parseIntMethod(map['postCount']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
    editedTime = ParsingHelper.parseTimestampMethod(map['editedTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "cid": cid,
      "name": name,
      "description": description,
      "imageUrl": imageUrl,
      "coverImageUrl": coverImageUrl,
      "postCount": postCount,
      "createdTime": toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime": toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
      "editedTime": toJson ? editedTime?.toDate().millisecondsSinceEpoch : editedTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
