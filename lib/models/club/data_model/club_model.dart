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
  bool adminEnabled = true;
  List<String> coverImages = <String>[];
  Map<String, GallerySection> galleryImages = <String, GallerySection>{};
  List<String> clubOperatorList = <String>[];
  Map<String, String> operatorRoles = <String, String>{};
  List<String> clubProductIdList = <String>[];
  Map<String, String> clubProducts = <String, String>{};
  Timestamp? createdTime;
  Timestamp? updatedTime;
  LocationModel? location;

  ClubModel({
    this.id = "",
    this.name = "",
    this.thumbnailImageUrl = "",
    this.mobileNumber = "",
    this.address = "",
    this.adminEnabled = true,
    List<String>? coverImages,
    List<String>? clubOperatorList,
    List<String>? clubProductIdList,
    Map<String, GallerySection>? galleryImages,
    Map<String, String>? operatorRoles,
    Map<String, String>? clubProducts,
    this.createdTime,
    this.updatedTime,
    this.location,
  }) {
    this.coverImages = coverImages ?? <String>[];
    this.clubOperatorList = clubOperatorList ?? <String>[];
    this.clubProductIdList = clubProductIdList ?? <String>[];
    this.galleryImages = galleryImages ?? <String, GallerySection>{};
    this.operatorRoles = operatorRoles ?? <String, String>{};
    this.clubProducts = clubProducts ?? <String, String>{};
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
    coverImages = ParsingHelper.parseListMethod<dynamic, String>(map['coverImages']);
    clubOperatorList = ParsingHelper.parseListMethod<dynamic, String>(map['clubOperatorList']);
    clubProductIdList = ParsingHelper.parseListMethod<dynamic, String>(map['clubProductIdList']);
    operatorRoles = ParsingHelper.parseMapMethod<dynamic, dynamic, String, String>(map['operatorRoles']);
    clubProducts = ParsingHelper.parseMapMethod<dynamic, dynamic, String, String>(map['clubProducts']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);

    galleryImages.clear();
    Map<String, dynamic> galleryImagesMap1 = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['galleryImages']);
    Map<String, GallerySection> galleryImagesMap2 = <String, GallerySection>{};
    galleryImagesMap1.forEach((String key, dynamic value) {
      Map<String, dynamic> map = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(value);
      if (map.isNotEmpty) {
        galleryImagesMap2[key] = GallerySection.fromMap(map);
      }
    });
    galleryImages.addAll(galleryImagesMap2);

    location = null;
    Map<String, dynamic> locationMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['location']);
    if (locationMap.isNotEmpty) {
      location = LocationModel.fromMap(locationMap);
    }
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "thumbnailImageUrl": thumbnailImageUrl,
      "mobileNumber": mobileNumber,
      "address": address,
      "adminEnabled": adminEnabled,
      "coverImages": coverImages,
      "clubOperatorList": clubOperatorList,
      "clubProductIdList": clubProductIdList,
      "galleryImages": galleryImages.map((String gallerySectionId, GallerySection gallerySection) {
        return MapEntry(gallerySectionId, gallerySection.toMap(toJson: toJson));
      }),
      "operatorRoles": operatorRoles,
      "clubProducts": clubProducts,
      "createdTime": toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime": toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
      "location": location?.toMap(toJson: toJson),
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}

class GallerySection {
  List<String> imageUrls = [];
  String sectionName = '';
  String id = '';
  Timestamp? createdTime;

  GallerySection({
    List<String>? imageUrls,
    this.sectionName = "",
    this.id = "",
    this.createdTime,
  }) {
    this.imageUrls = imageUrls ?? <String>[];
  }

  GallerySection.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    imageUrls = ParsingHelper.parseListMethod<dynamic, String>(map['imageUrls']);
    sectionName = ParsingHelper.parseStringMethod(map['sectionName']);
    id = ParsingHelper.parseStringMethod(map['id']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "imageUrls": imageUrls,
      "id": id,
      "sectionName": sectionName,
      "createdTime": toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}