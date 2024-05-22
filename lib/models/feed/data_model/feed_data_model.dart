import '../../../configs/constants.dart';
import 'image_feed_data_model.dart';
import 'video_feed_data_model.dart';

class FeedDataModel {
  static FeedDataModel? fromMap(String feedType, Map<String, dynamic> postDataMap) {
    FeedDataModel? feedDataModel;

    if (feedType == FeedType.image) {
      feedDataModel = ImageFeedDataModel.fromMap(postDataMap);
    } else if (feedType == FeedType.poll) {
      feedDataModel = ImageFeedDataModel.fromMap(postDataMap);
    } else if (feedType == FeedType.video) {
      feedDataModel = VideoFeedDataModel.fromMap(postDataMap);
    }

    return feedDataModel;
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return {};
  }
}
