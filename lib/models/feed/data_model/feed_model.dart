import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../configs/constants.dart';
import '../../../utils/extensions.dart';
import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';
import 'feed_club_meta_model.dart';
import 'feed_comment_model.dart';
import 'feed_data_model.dart';
import 'poll/poll_model.dart';

class FeedModel {
  String id = "";
  String createdById = "";
  String createdByName = "";
  String createdByImage = "";
  String communityId = "";
  String communityName = "";
  String dynamicLink = "";
  String userActivity = "";
  String type = FeedType.none;
  int likesCount = 0;
  int commentsCount = 0;
  int sharesCount = 0;
  int viewsCount = 0;
  int totalInteractionCount = 0;
  bool enabledByAdmin = true;
  bool enabledByUser = true;
  bool isPinned = false;
  bool isInteractiveFeed = false;
  List<String> interests = [];
  List<String> hashtags = [];
  Map<String, String> usernames = {};
  PollModel? pollModel;
  FeedDataModel? feedDataModel;
  FeedCommentModel? lastComment;
  FeedClubMetaModel? feedClubMetaModel;
  Timestamp? createdTime;
  Timestamp? updatedTime;
  Timestamp? editedTime;
  GeoPoint? geoPoint;

  FeedModel({
    this.id = "",
    this.createdById = "",
    this.createdByName = "",
    this.createdByImage = "",
    this.communityId = "",
    this.communityName = "",
    this.dynamicLink = "",
    this.userActivity = "",
    this.type = FeedType.none,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.totalInteractionCount = 0,
    this.enabledByAdmin = true,
    this.enabledByUser = true,
    this.isPinned = false,
    this.isInteractiveFeed = false,
    List<String>? interests,
    List<String>? hashtags,
    Map<String, String>? usernames,
    this.pollModel,
    this.feedDataModel,
    this.lastComment,
    this.feedClubMetaModel,
    this.createdTime,
    this.updatedTime,
    this.editedTime,
    this.geoPoint,
  }) {
    this.interests = interests ?? <String>[];
    this.hashtags = hashtags ?? <String>[];
    this.usernames = usernames ?? <String, String>{};
  }

  FeedModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    createdById = ParsingHelper.parseStringMethod(map['createdById']);
    createdByName = ParsingHelper.parseStringMethod(map['createdByName']);
    createdByImage = ParsingHelper.parseStringMethod(map['createdByImage']);
    communityId = ParsingHelper.parseStringMethod(map['communityId']);
    communityName = ParsingHelper.parseStringMethod(map['communityName']);
    dynamicLink = ParsingHelper.parseStringMethod(map['dynamicLink']);
    userActivity = ParsingHelper.parseStringMethod(map['userActivity']);
    type = ParsingHelper.parseStringMethod(map['type'], defaultValue: FeedType.none);
    likesCount = ParsingHelper.parseIntMethod(map['likesCount']);
    commentsCount = ParsingHelper.parseIntMethod(map['commentsCount']);
    sharesCount = ParsingHelper.parseIntMethod(map['sharesCount']);
    viewsCount = ParsingHelper.parseIntMethod(map['viewsCount']);
    totalInteractionCount = ParsingHelper.parseIntMethod(map['totalInteractionCount']);
    enabledByAdmin = ParsingHelper.parseBoolMethod(map['enabledByAdmin']);
    enabledByUser = ParsingHelper.parseBoolMethod(map['enabledByUser']);
    isPinned = ParsingHelper.parseBoolMethod(map['isPinned']);
    isInteractiveFeed = ParsingHelper.parseBoolMethod(map['isInteractiveFeed']);
    interests = ParsingHelper.parseListMethod<dynamic, String>(map['interests']);
    hashtags = ParsingHelper.parseListMethod<dynamic, String>(map['hashtags']);
    usernames = ParsingHelper.parseMapMethod<dynamic, dynamic, String, String>(map['usernames']);

    pollModel = null;
    Map<String, dynamic> pollModelMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['pollModel']);
    if (pollModelMap.isNotEmpty) pollModel = PollModel.fromMap(pollModelMap);

    feedDataModel = null;
    Map<String, dynamic> feedDataModelMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['feedDataModel']);
    if (feedDataModelMap.isNotEmpty) feedDataModel = FeedDataModel.fromMap(type, feedDataModelMap);

    lastComment = null;
    Map<String, dynamic> lastCommentMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['lastComment']);
    if (lastCommentMap.isNotEmpty) lastComment = FeedCommentModel.fromMap(lastCommentMap);

    feedClubMetaModel = null;
    Map<String, dynamic> feedClubMetaModelMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['feedClubMetaModel']);
    if (feedClubMetaModelMap.isNotEmpty) feedClubMetaModel = FeedClubMetaModel.fromMap(feedClubMetaModelMap);

    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
    editedTime = ParsingHelper.parseTimestampMethod(map['editedTime']);

    geoPoint = ParsingHelper.parseGeoPointMethod(map['geoPoint']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "createdById": createdById,
      "createdByName": createdByName,
      "createdByImage": createdByImage,
      "communityId": communityId,
      "communityName": communityName,
      "dynamicLink": dynamicLink,
      "userActivity": userActivity,
      "type": type,
      "likesCount": likesCount,
      "commentsCount": commentsCount,
      "sharesCount": sharesCount,
      "viewsCount": viewsCount,
      "totalInteractionCount": totalInteractionCount,
      "enabledByAdmin": enabledByAdmin,
      "enabledByUser": enabledByUser,
      "isPinned": isPinned,
      "isInteractiveFeed": isInteractiveFeed,
      "interests": interests,
      "hashtags": hashtags,
      "usernames": usernames,
      "pollModel": pollModel?.toMap(toJson: toJson),
      "feedDataModel": feedDataModel?.toMap(toJson: toJson),
      "lastComment": lastComment?.toMap(toJson: toJson),
      "feedClubMetaModel": feedClubMetaModel?.toMap(toJson: toJson),
      "createdTime": toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime": toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
      "editedTime": toJson ? editedTime?.toDate().millisecondsSinceEpoch : editedTime,
      "geoPoint": geoPoint.toMap(toJson: toJson),
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
