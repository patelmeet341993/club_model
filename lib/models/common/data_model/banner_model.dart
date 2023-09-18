import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class BannerModel {
  String id = "";
  String imageUrl = "";
  String externalUrl = "";
  int viewNumber = -1;
  String internalFeatureType = "";
  String internalScreenName = "";
  bool isInternal = false;
  Timestamp? createdTime;

  BannerModel({
    this.id = "",
    this.imageUrl = "",
    this.externalUrl = "",
    this.internalFeatureType = "",
    this.internalScreenName = "",
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
    externalUrl = ParsingHelper.parseStringMethod(map['externalUrl']);
    internalFeatureType = ParsingHelper.parseStringMethod(map['internalFeatureType']);
    internalFeatureType = ParsingHelper.parseStringMethod(map['internalScreenName']);
    viewNumber = ParsingHelper.parseIntMethod(map['viewNumber']);
    isInternal = ParsingHelper.parseBoolMethod(map['isInternal']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "imageUrl" : imageUrl,
      "externalUrl" : externalUrl,
      "internalFeatureType" : internalFeatureType,
      "internalScreenName" : internalScreenName,
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