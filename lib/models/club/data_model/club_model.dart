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
  List<String> coverImages = <String>[];
  List<GallerySection> galleryImages = <GallerySection>[];
  List<String> clubUserList = <String>[];
  List<Map<String,String>> clubOwners = <Map<String,String>>[];
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
    List<String>? coverImages,
    List<GallerySection>? galleryImages,
    List<Map<String,String>>? clubOwners,
    this.createdTime,
    this.updatedTime,
    this.location,
  }) {
    this.coverImages = coverImages ?? <String>[];
    this.clubOwners = clubOwners ?? <Map<String,String>>[];
    this.galleryImages = galleryImages ?? <GallerySection>[];
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
    // clubOwners = ParsingHelper.parseListMethod<dynamic, Map<String,String>>(map['clubOwners']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);

    List<Map<String,dynamic >> galleryImagesList = ParsingHelper.parseMapsListMethod(map['galleryImages']);
    galleryImages = galleryImagesList.map((e){
      return GallerySection.fromMap(e);
    }).toList();

    List<Map<String,String>> clubOwnersList = ParsingHelper.parseMapsListMethod(map['clubOwners']);
    clubOwners = clubOwnersList.map((e){
      return e;
    }).toList();

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
      "coverImages" : coverImages,
      "galleryImages" : galleryImages.map((e) => e.toMap(toJson: toJson)).toList(),
      "clubOwners" : clubOwners,
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

class GallerySection {
  String imageUrl = '';
  String sectionName = '';
  Timestamp? createdTime;

  GallerySection({
    this.imageUrl = "",
    this.sectionName = "",
    this.createdTime,
  });

  GallerySection.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);
    sectionName = ParsingHelper.parseStringMethod(map['sectionName']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "imageUrl" : imageUrl,
      "sectionName" : sectionName,
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}