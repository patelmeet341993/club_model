import 'package:club_model/club_model.dart';

class FeedMediaMetaModel {
  double aspectRatio = 0;
  double width = 0;

  FeedMediaMetaModel({
    this.aspectRatio = 0,
    this.width = 0,
  });

  FeedMediaMetaModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    aspectRatio = ParsingHelper.parseDoubleMethod(map['aspectRatio']);
    width = ParsingHelper.parseDoubleMethod(map['width']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "aspectRatio": aspectRatio,
      "width": width,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
