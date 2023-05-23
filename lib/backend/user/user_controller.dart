import 'package:club_model/backend/user/user_repository.dart';

import '../../models/user/data_model/user_model.dart';
import '../../models/user/request_model/profile_update_request_model.dart';
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

  Future<bool> updateProfileDetails({required ProfileUpdateRequestModel requestModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserController().updateProfileDetails() called with requestModel:'$requestModel'", tag: tag);

    bool isUpdated = false;

    try {
      isUpdated = await userRepository.updateUserProfileData(requestModel: requestModel);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in UserController().updateProfileDetails():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isUpdated:'$isUpdated'", tag: tag);

    return isUpdated;
  }
}
