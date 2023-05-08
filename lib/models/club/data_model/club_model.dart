import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';
import '../../location/data_model/location_model.dart';

class ClubModel {
  String id = "";
  String name = "";
  String thumbnailImageUrl = "";
  String mobileNumber = "";
  String address = "";
  bool adminEnabled = false;
  bool clubEnabled = false;
  List<String> images = <String>[];
  Timestamp? createdTime;
  Timestamp? updatedTime;
  LocationModel? location;

  ClubModel({
    this.id = "",
    this.name = "",
    this.thumbnailImageUrl = "",
    this.mobileNumber = "",
    this.address = "",
    this.adminEnabled = false,
    this.clubEnabled = false,
    List<String>? images,
    this.createdTime,
    this.updatedTime,
    this.location,
  }) {
    this.images = images ?? <String>[];
  }

  ClubModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    thumbnailImageUrl = ParsingHelper.parseStringMethod(map['thumbnailImageUrl']);
    mobileNumber = ParsingHelper.parseStringMethod(map['mobileNumber']);
    address = ParsingHelper.parseStringMethod(map['address']);
    adminEnabled = ParsingHelper.parseBoolMethod(map['adminEnabled']);
    clubEnabled = ParsingHelper.parseBoolMethod(map['clubEnabled']);
    images = ParsingHelper.parseListMethod<dynamic, String>(map['images']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);

    location = null;
    Map<String, dynamic> locationMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['location']);
    if(locationMap.isNotEmpty) {
      location = LocationModel.fromMap(locationMap);
    }
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "name" : name,
      "thumbnailImageUrl" : thumbnailImageUrl,
      "mobileNumber" : mobileNumber,
      "address" : address,
      "adminEnabled" : adminEnabled,
      "clubEnabled" : clubEnabled,
      "images" : images,
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime" : toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
      "location" : location?.toMap(toJson: toJson),
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}