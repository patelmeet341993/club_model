import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_model/club_model.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class ProductModel {
  String id = "";
  String name = "";
  String thumbnailImageUrl = "";
  String createdBy = "";
  String productType = "";
  BrandModel? brand;
  double sizeInML = 0;
  double price = 0;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  ProductModel({
    this.id = "",
    this.name = "",
    this.thumbnailImageUrl = "",
    this.createdBy = "",
    this.productType = "",
    this.brand,
    this.sizeInML = 0,
    this.price = 0,
    this.createdTime,
    this.updatedTime,
  });

  ProductModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    thumbnailImageUrl = ParsingHelper.parseStringMethod(map['thumbnailImageUrl']);
    createdBy = ParsingHelper.parseStringMethod(map['createdBy']);
    productType = ParsingHelper.parseStringMethod(map['productType']);
    sizeInML = ParsingHelper.parseDoubleMethod(map['sizeInML']);
    price = ParsingHelper.parseDoubleMethod(map['price']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);

    brand = null;
    Map<String, dynamic> brandMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['brand']);
    if(brandMap.isNotEmpty) {
      brand = BrandModel.fromMap(brandMap);
    }
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "name" : name,
      "thumbnailImageUrl" : thumbnailImageUrl,
      "createdBy" : createdBy,
      "productType" : productType,
      "sizeInML" : sizeInML,
      "price" : price,
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime" : toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
      "brand" : brand?.toMap(toJson: toJson),
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}