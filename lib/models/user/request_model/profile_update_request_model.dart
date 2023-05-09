import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';

class ProfileUpdateRequestModel {
  String id = "";
  String? name;
  String? imageUrl;
  Timestamp? updatedTime;

  ProfileUpdateRequestModel({
    required this.id,
    this.name = "",
    this.imageUrl = "",
    this.updatedTime,
  });

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      if(name != null) "name" : name,
      if(imageUrl != null) "imageUrl" : imageUrl,
      if(updatedTime != null) "updatedTime" : toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}