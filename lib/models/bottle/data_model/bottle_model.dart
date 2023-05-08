import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class BottleModel {
  String id = "";
  String name = "";
  String brandName = "";
  String thumbnailImageUrl = "";
  String brandThumbnailImageUrl = "";
  double sizeInML = 0;
  double price = 0;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  BottleModel({
    this.id = "",
    this.name = "",
    this.brandName = "",
    this.thumbnailImageUrl = "",
    this.brandThumbnailImageUrl = "",
    this.sizeInML = 0,
    this.price = 0,
    this.createdTime,
    this.updatedTime,
  });

  BottleModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    brandName = ParsingHelper.parseStringMethod(map['brandName']);
    thumbnailImageUrl = ParsingHelper.parseStringMethod(map['thumbnailImageUrl']);
    brandThumbnailImageUrl = ParsingHelper.parseStringMethod(map['brandThumbnailImageUrl']);
    sizeInML = ParsingHelper.parseDoubleMethod(map['sizeInML']);
    price = ParsingHelper.parseDoubleMethod(map['price']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "name" : name,
      "brandName" : brandName,
      "thumbnailImageUrl" : thumbnailImageUrl,
      "brandThumbnailImageUrl" : brandThumbnailImageUrl,
      "sizeInML" : sizeInML,
      "price" : price,
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime" : toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}