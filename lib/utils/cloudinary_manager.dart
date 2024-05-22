import 'package:cloudinary_sdk/cloudinary_sdk.dart';

import '../configs/credentials.dart';
import 'my_print.dart';
import 'my_utils.dart';

class CloudinaryManager {
  static Future<bool> deleteImagesFromCloudinary({required List<String> images}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CloudinaryManager.deleteImagesFromCloudinary() called with images:'$images'", tag: tag);

    if (images.isEmpty) {
      MyPrint.printOnConsole("CloudinaryManager.deleteImagesFromCloudinary() called with images:'$images'", tag: tag);

      return false;
    }

    bool isSuccess = false;

    Cloudinary cloudinary = Cloudinary.full(
      apiKey: CloudinaryCredentials.getCloudinaryApiKey(),
      apiSecret: CloudinaryCredentials.getCloudinaryApiSecret(),
      cloudName: CloudinaryCredentials.getCloudinaryCloudName(),
    );

    try {
      CloudinaryResponse cloudinaryResponse = await cloudinary.deleteResources(urls: images);
      MyPrint.printOnConsole("cloudinaryResponse:${MyUtils.encodeJson(cloudinaryResponse.toJson())}", tag: tag);
      MyPrint.printOnConsole("cloudinaryResponse.isSuccessful:${cloudinaryResponse.isSuccessful}", tag: tag);

      isSuccess = cloudinaryResponse.isSuccessful;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CloudinaryManager.deleteImagesFromCloudinary():$e");
      MyPrint.printOnConsole(s);
    }

    MyPrint.printOnConsole("isSuccess:$isSuccess", tag: tag);

    return isSuccess;
  }
}
