import 'package:club_model/configs/constants.dart';
import 'package:club_model/models/common/data_model/new_document_data_model.dart';
import 'package:club_model/models/user/data_model/user_model.dart';
import 'package:club_model/utils/my_print.dart';
import 'package:club_model/utils/my_utils.dart';

class UserRepository {
  Future<bool> createNewUser({required UserModel userModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserRepository().createNewUser() called with userModel:'$userModel'", tag: tag);

    bool isCreated = false;

    try {
      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
      MyPrint.printOnConsole("newDocumentDataModel:'$newDocumentDataModel'", tag: tag);

      userModel.id = newDocumentDataModel.docId;
      userModel.createdTime = newDocumentDataModel.timestamp;

      MyPrint.printOnConsole("Final userModel:'$userModel'", tag: tag);

      await FirebaseNodes.userDocumentReference(userId: userModel.id).set(userModel.toMap());
      isCreated = true;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in Firestore in UserRepository().createNewUser():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isCreated:'$isCreated'", tag: tag);

    return isCreated;
  }
}