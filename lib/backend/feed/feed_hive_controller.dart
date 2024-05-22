import '../../club_model.dart';

class FeedHiveController {
  Future<Map<String, String>> getHiddenFeedsOfUser({required String userId}) async {
    String newId = MyUtils.getNewId();

    MyPrint.printOnConsole("FeedHiveController.getHiddenFeedsOfUser called for userId:$userId", tag: newId);

    if (userId.isEmpty) {
      MyPrint.printOnConsole("userId cannot be empty:$userId", tag: newId);
      MyPrint.printOnConsole("FeedHiveController.getHiddenFeedsOfUser succeed for userId:$userId", tag: newId);
      return <String, String>{};
    }

    try {
      String key = HiveKeys.getKeyForHiddenFeedsForUserId(userId: userId);
      dynamic myVal = await HiveManager().get(key: key);
      Map<String, String> myMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, String>(myVal);

      MyPrint.printOnConsole("FeedHiveController.getHiddenFeedsOfUser finished for userId:$userId", tag: newId);

      return myMap;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in FeedHiveController.getHiddenFeedsOfUser():$e", tag: newId);
      MyPrint.printOnConsole(s);
      return <String, String>{};
    }
  }

  Future<void> storeFeedsOfUserInHive({required String userId, required Map<String, String> data}) async {
    String newId = MyUtils.getNewId();

    MyPrint.printOnConsole("FeedHiveController.storeFeedsOfUserInHive called for userId:$userId", tag: newId);

    if (userId.isEmpty) {
      MyPrint.printOnConsole("userId cannot be empty:$userId", tag: newId);
      MyPrint.printOnConsole("FeedHiveController.storeFeedsOfUserInHive succeed for userId:$userId", tag: newId);
      return;
    }

    try {
      String key = HiveKeys.getKeyForHiddenFeedsForUserId(userId: userId);
      await HiveManager().set(key: key, value: data);

      MyPrint.printOnConsole("FeedHiveController.storeFeedsOfUserInHive succeed for userId:$userId", tag: newId);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in FeedHiveController.storeFeedsOfUserInHive():$e", tag: newId);
      MyPrint.printOnConsole(s);
    }
  }
}
