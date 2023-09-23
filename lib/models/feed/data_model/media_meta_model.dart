import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class MediaMetaModel {
  double width = 0;
  double height = 0;
  String type = "";
  String url = "";

  MediaMetaModel({
    this.width = 0,
    this.height = 0,
    this.type = "",
    this.url = "",
  });

  MediaMetaModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    width = ParsingHelper.parseDoubleMethod(map['width']);
    height = ParsingHelper.parseDoubleMethod(map['height']);
    type = ParsingHelper.parseStringMethod(map['type']);
    url = ParsingHelper.parseStringMethod(map['url']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "width": width,
      "height": height,
      "type": type,
      "url": url,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }

  double getHeight(double width) {
    return ((width * height) / this.width);
  }
}
