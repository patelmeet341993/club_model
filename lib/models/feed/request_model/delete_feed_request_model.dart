import 'package:club_model/club_model.dart';

class DeleteFeedRequestModel {
  String feedId;
  FeedModel? feedModel;

  DeleteFeedRequestModel({
    this.feedId = "",
    this.feedModel,
  });

  @override
  String toString() {
    return MyUtils.encodeJson({
      "feedId": feedId,
      "feedModel": feedModel?.toMap(toJson: true),
    });
  }
}
