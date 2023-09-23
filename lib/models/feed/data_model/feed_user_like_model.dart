import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../configs/constants.dart';
import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class FeedUserLikeModel {
  String userid = "";
  String feedId = "";
  String parentType = "";
  String type = FeedLikeType.none;
  Timestamp? time;

  FeedUserLikeModel({
    this.userid = "",
    this.feedId = "",
    this.parentType = "",
    this.type = FeedLikeType.none,
    this.time,
  });

  FeedUserLikeModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    userid = ParsingHelper.parseStringMethod(map['userid']);
    feedId = ParsingHelper.parseStringMethod(map['feedId']);
    parentType = ParsingHelper.parseStringMethod(map['parentType']);
    type = ParsingHelper.parseStringMethod(map['type']);
    time = ParsingHelper.parseTimestampMethod(map['time']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "userid": userid,
      "feedId": feedId,
      "parentType": parentType,
      "type": type,
      "time": toJson ? time?.toDate().millisecondsSinceEpoch : time,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
