import 'package:firebase_storage/firebase_storage.dart';

import '../../utils/my_print.dart';

class DataController {
  static Future<bool> deleteImages({required List<String> images}) async {
    try {
      List<String> firebaseStorageImages = [], cloudinaryImages = [];

      for (String imageUrl in images) {
        if (imageUrl.contains("storage.googleapis")) {
          firebaseStorageImages.add(imageUrl);
        } else if (imageUrl.contains("res.cloudinary.com")) {
          cloudinaryImages.add(imageUrl);
        } else {
          firebaseStorageImages.add(imageUrl);
        }
      }

      List<Future> futures = [];
      if (firebaseStorageImages.isNotEmpty) {
        futures.add(deleteFilesFromFirebaseStorage(images: firebaseStorageImages));
      }
      /*if(cloudinaryImages.isNotEmpty) {
        futures.add(CloudinaryManager().deleteImagesFromCloudinary(images: cloudinaryImages));
      }*/
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
      return true;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in DataController().deleteImages():$e");
      MyPrint.printOnConsole(s);
      return false;
    }
  }

  static Future deleteFilesFromFirebaseStorage({required List<String> images}) async {
    await Future.wait(
      images.map((String url) async {
        Reference reference = FirebaseStorage.instance.refFromURL(url);
        return reference.delete().then((value) {
          MyPrint.printOnConsole("Image '$url' Deleted Successfully");
        }).catchError((e, s) {
          MyPrint.printOnConsole("Error in Deleting Image From Firebase Storage:$e");
          MyPrint.printOnConsole(s);
        });
      }),
      eagerError: true,
      cleanUp: (_) {
        MyPrint.printOnConsole('eager cleaned up');
      },
    );
  }
}