import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';
import 'feed_data_model.dart';
import 'feed_image_model.dart';

class ImageFeedDataModel extends FeedDataModel {
  String description = "";
  List<FeedImageModel> images = [];

  ImageFeedDataModel({
    this.description = "",
    List<FeedImageModel>? images,
  }) {
    this.images = images ?? <FeedImageModel>[];
  }

  ImageFeedDataModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    description = ParsingHelper.parseStringMethod(map['description']);

    images.clear();
    List<Map<String, dynamic>> imagesMapsList = ParsingHelper.parseMapsListMethod<String, dynamic>(map['images']);
    images.addAll(imagesMapsList.map((e) => FeedImageModel.fromMap(e)).toList());
  }

  @override
  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "description": description,
      "images": images.map((e) => e.toMap(toJson: toJson)).toList(),
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
