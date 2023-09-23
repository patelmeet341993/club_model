import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../configs/constants.dart';
import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';
import 'media_meta_model.dart';

class FeedCommentModel {
  String id = "";
  String parentId = "";
  String comment = "";
  String createdById = "";
  String createdByName = "";
  String createdByImage = "";
  String tagUserId = "";
  String tagUserName = "";
  String commentType = CommentTypes.text;
  int commentsCount = 0;
  MediaMetaModel? mediaMetaModel;
  FeedCommentModel? firstComment;
  Timestamp? createdTime;
  Timestamp? editedTime;
  List<FeedCommentModel> comments = [];

  FeedCommentModel({
    this.id = "",
    this.parentId = "",
    this.comment = "",
    this.createdById = "",
    this.createdByName = "",
    this.createdByImage = "",
    this.tagUserId = "",
    this.tagUserName = "",
    this.commentType = CommentTypes.text,
    this.commentsCount = 0,
    this.mediaMetaModel,
    this.firstComment,
    this.createdTime,
    this.editedTime,
    List<FeedCommentModel>? comments,
  }) {
    this.comments = comments ?? <FeedCommentModel>[];
  }

  FeedCommentModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    parentId = ParsingHelper.parseStringMethod(map['parentId']);
    comment = ParsingHelper.parseStringMethod(map['comment']);
    createdById = ParsingHelper.parseStringMethod(map['createdById']);
    createdByName = ParsingHelper.parseStringMethod(map['createdByName']);
    createdByImage = ParsingHelper.parseStringMethod(map['createdByImage']);
    tagUserId = ParsingHelper.parseStringMethod(map['tagUserId']);
    tagUserName = ParsingHelper.parseStringMethod(map['tagUserName']);
    commentType = ParsingHelper.parseStringMethod(map['commentType'], defaultValue: CommentTypes.text);
    commentsCount = ParsingHelper.parseIntMethod(map['commentsCount']);

    mediaMetaModel = null;
    Map<String, dynamic> mediaMetaModelMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['mediaMetaModel']);
    if (mediaMetaModelMap.isNotEmpty) mediaMetaModel = MediaMetaModel.fromMap(mediaMetaModelMap);

    firstComment = null;
    Map<String, dynamic> firstCommentMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['firstComment']);
    if (firstCommentMap.isNotEmpty) firstComment = FeedCommentModel.fromMap(firstCommentMap);

    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    editedTime = ParsingHelper.parseTimestampMethod(map['editedTime']);

    comments.clear();
    List<Map<String, dynamic>> commentsMapsList = ParsingHelper.parseMapsListMethod<String, dynamic>(map['comments']);
    comments.addAll(commentsMapsList.map((e) => FeedCommentModel.fromMap(e)));
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "parentId": parentId,
      "comment": comment,
      "createdById": createdById,
      "createdByName": createdByName,
      "createdByImage": createdByImage,
      "tagUserId": tagUserId,
      "tagUserName": tagUserName,
      "commentType": commentType,
      "commentsCount": commentsCount,
      "mediaMetaModel": mediaMetaModel?.toMap(toJson: toJson),
      "firstComment": firstComment?.toMap(toJson: toJson),
      "createdTime": toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "editedTime": toJson ? editedTime?.toDate().millisecondsSinceEpoch : editedTime,
      "comments": comments.map((e) => e.toMap(toJson: toJson)).toList(),
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
