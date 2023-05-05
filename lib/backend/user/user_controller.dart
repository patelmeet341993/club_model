import 'package:club_model/backend/user/user_repository.dart';

import '../../models/user/data_model/user_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class UserController {
  late UserRepository _userRepository;

  UserController({
    UserRepository? repository,
  }) {
    _userRepository = repository ?? UserRepository();
  }

  UserRepository  get userRepository => _userRepository;

  Future<bool> checkUserWithIdExistOrNotAndIfNotExistThenCreate({
    required String userId,
    String mobileNumber = "",
  }) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserController().checkUserWithIdExistOrNotAndIfNotExistThenCreate() called with userId:'$userId', mobileNumber:'$mobileNumber'", tag: tag);

    bool isUserExist = false;

    if(userId.isEmpty) return isUserExist;

    try {
      UserModel? userModel = await userRepository.getUserModelFromId(userId: userId);
      MyPrint.printOnConsole("userModel:'$userModel'", tag: tag);

      if(userModel != null) {
        isUserExist = true;
      }
      else {
        UserModel createdUserModel = UserModel(
          id: userId,
          mobileNumber: mobileNumber,
        );
        bool isCreated = await userRepository.createNewUser(userModel: createdUserModel);
        MyPrint.printOnConsole("isUserCreated:'$isCreated'", tag: tag);
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in UserController().checkUserWithIdExistOrNotAndIfNotExistThenCreate():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return isUserExist;
  }

  Future<bool> createNewUser({required UserModel userModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserController().createNewUser() called with userModel:'$userModel'", tag: tag);

    bool isCreated = false;

    try {
      isCreated = await userRepository.createNewUser(userModel: userModel);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in UserController().createNewUser():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isCreated:'$isCreated'", tag: tag);

    return isCreated;
  }
}
