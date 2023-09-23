import 'package:club_model/club_model.dart';

class PollAnswerModel {
  String answerId = "", answer = "";
  int votes = 0;

  PollAnswerModel({
    this.answerId = "",
    this.answer = "",
    this.votes = 0,
  });

  PollAnswerModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    answerId = ParsingHelper.parseStringMethod(map['answerId']);
    answer = ParsingHelper.parseStringMethod(map['answer']);
    votes = ParsingHelper.parseIntMethod(map['votes']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "answerId": answerId,
      "answer": answer,
      "votes": votes,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
