import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class FeedClubMetaModel {
  String clubName = "", clubId = "";

  FeedClubMetaModel({
    this.clubId = "",
    this.clubName = "",
  });

  FeedClubMetaModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    clubId = ParsingHelper.parseStringMethod(map['clubId']);
    clubName = ParsingHelper.parseStringMethod(map['clubName']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "clubId": clubId,
      "clubName": clubName,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
