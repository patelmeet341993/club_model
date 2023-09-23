import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';
import 'feed_media_meta_model.dart';

class FeedImageModel {
  String imageUrl = "";
  FeedMediaMetaModel? feedMediaMetaModel;

  FeedImageModel({
    this.imageUrl = "",
    this.feedMediaMetaModel,
  });

  FeedImageModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);

    feedMediaMetaModel = null;
    Map<String, dynamic> feedMediaMetaModelMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['feedMediaMetaModel']);
    if (feedMediaMetaModelMap.isNotEmpty) feedMediaMetaModel = FeedMediaMetaModel.fromMap(feedMediaMetaModelMap);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "imageUrl": imageUrl,
      "feedMediaMetaModel": feedMediaMetaModel?.toMap(toJson: toJson),
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
