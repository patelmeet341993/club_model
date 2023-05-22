import 'package:club_model/configs/constants.dart';
import 'package:club_model/models/common/data_model/new_document_data_model.dart';
import 'package:club_model/models/user/data_model/user_model.dart';
import 'package:club_model/utils/my_print.dart';
import 'package:club_model/utils/my_utils.dart';

import '../../configs/typedefs.dart';
import '../../models/user/request_model/profile_update_request_model.dart';

class UserRepository {
  Future<UserModel?> getUserModelFromId({required String userId}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserRepository().getUserModelFromId() called with userId:'$userId'", tag: tag);

    if(userId.isEmpty) {
      MyPrint.printOnConsole("Returning from UserRepository().getUserModelFromId() because userId is empty", tag: tag);
      return null;
    }

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.userDocumentReference(userId: userId).get();
      MyPrint.printOnConsole("snapshot.exists:'${snapshot.exists}'", tag: tag);
      MyPrint.printOnConsole("snapshot.data():'${snapshot.data()}'", tag: tag);

      if(snapshot.exists && (snapshot.data()?.isNotEmpty ?? false)) {
        return UserModel.fromMap(snapshot.data()!);
      }
      else {
        return null;
      }
    }
    catch(e,s) {
      MyPrint.printOnConsole("Error in UserRepository().getUserModelFromId():'$e'", tag: tag);
      MyPrint.printOnConsole(s ,tag: tag);
      return null;
    }
  }

  Future<bool> createNewUser({required UserModel userModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserRepository().createNewUser() called with userModel:'$userModel'", tag: tag);

    if(userModel.id.isEmpty) {
      MyPrint.printOnConsole("Returning from UserRepository().createNewUser() because userId is empty", tag: tag);
      return false;
    }

    bool isCreated = false;

    try {
      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
      MyPrint.printOnConsole("newDocumentDataModel:'$newDocumentDataModel'", tag: tag);

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

  Future<bool> updateUserProfileData({required ProfileUpdateRequestModel requestModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserRepository().updateUserProfileData() called with requestModel:'$requestModel'", tag: tag);

    if(requestModel.id.isEmpty) {
      MyPrint.printOnConsole("Returning from UserRepository().updateUserProfileData() because userId is empty", tag: tag);
      return false;
    }

    bool isUpdated = false;

    try {
      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
      MyPrint.printOnConsole("newDocumentDataModel:'$newDocumentDataModel'", tag: tag);

      requestModel.updatedTime = newDocumentDataModel.timestamp;

      MyPrint.printOnConsole("Final requestModel:'$requestModel'", tag: tag);

      await FirebaseNodes.userDocumentReference(userId: requestModel.id).update(requestModel.toMap());
      isUpdated = true;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in Firestore in UserRepository().updateUserProfileData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isUpdated:'$isUpdated'", tag: tag);

    return isUpdated;
  }
}