import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';
import 'feed_data_model.dart';

class VideoFeedDataModel extends FeedDataModel {
  String videoUrl = "", description = "";

  VideoFeedDataModel({
    this.videoUrl = "",
    this.description = "",
  });

  VideoFeedDataModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    videoUrl = ParsingHelper.parseStringMethod(map['videoUrl']);
    description = ParsingHelper.parseStringMethod(map['description']);
  }

  @override
  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "videoUrl": videoUrl,
      "description": description,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
