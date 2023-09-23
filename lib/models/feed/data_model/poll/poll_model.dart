import 'package:club_model/club_model.dart';

class PollModel {
  String id = "";
  String question = "";
  int totalVotes = 0;
  Map<String, PollAnswerModel> answers = {};
  Timestamp? createdTime;
  Timestamp? expiryTime;

  PollModel({
    this.id = "",
    this.question = "",
    this.totalVotes = 0,
    Map<String, PollAnswerModel>? answers,
    this.createdTime,
    this.expiryTime,
  }) {
    this.answers = answers ?? <String, PollAnswerModel>{};
  }

  PollModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    question = ParsingHelper.parseStringMethod(map['question']);
    totalVotes = ParsingHelper.parseIntMethod(map['totalVotes']);

    answers.clear();
    Map<String, dynamic> answersMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['answers']);
    answersMap.forEach((String answerId, dynamic answerValue) {
      Map<String, dynamic> answerMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(answerValue);
      if (answerMap.isNotEmpty) answersMap[answerId] = PollAnswerModel.fromMap(answersMap);
    });

    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    expiryTime = ParsingHelper.parseTimestampMethod(map['expiryTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "question": question,
      "totalVotes": totalVotes,
      "createdTime": toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "expiryTime": toJson ? expiryTime?.toDate().millisecondsSinceEpoch : expiryTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
