import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class BannerModel {
  String id = "";
  String imageUrl = "";
  int viewNumber = -1;
  bool isInternal = false;
  Timestamp? createdTime;

  BannerModel({
    this.id = "",
    this.imageUrl = "",
    this.viewNumber =-1,
    this.isInternal = false,
    this.createdTime,

  });

  BannerModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);
    viewNumber = ParsingHelper.parseIntMethod(map['viewNumber']);
    isInternal = ParsingHelper.parseBoolMethod(map['isInternal']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "imageUrl" : imageUrl,
      "viewNumber" : viewNumber,
      "isInternal" : isInternal,
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}