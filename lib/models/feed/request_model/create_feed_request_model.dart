import 'package:club_model/club_model.dart';

class CreateFeedRequestModel {
  String feedId;
  FeedModel feedModel;

  CreateFeedRequestModel({
    this.feedId = "",
    required this.feedModel,
  });

  @override
  String toString() {
    return MyUtils.encodeJson({
      "feedId": feedId,
      "feedModel": feedModel.toMap(toJson: true),
    });
  }
}
