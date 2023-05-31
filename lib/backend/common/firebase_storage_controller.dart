import 'dart:typed_data';

import 'package:club_model/club_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../utils/my_print.dart';

class FireBaseStorageController {

  static FirebaseStorage firebaseStorageInstance = FirebaseStorage.instance;

  //region FirebaseStorageOperations

  Future<String?> uploadFilesToFireBaseStorage({
    required Uint8List data,
    required String id,
    required String fileName,
    required storageFolderName,
  }) async {
    String? imageUrl;
    try {
      String? mimeType = lookupMimeType(fileName); // 'image/jpeg'

      final storageRef = firebaseStorageInstance.ref("$storageFolderName/").child("$id/$fileName");
      await storageRef.putData(data, SettableMetadata(contentType: mimeType));
      imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Firebase Storage Controller in Upload $storageFolderName File Method $e");
      MyPrint.printOnConsole(s);
      return imageUrl;
    }
  }

  static Future deleteFilesFromFirebaseStorage({required List<String> images}) async {
    await Future.wait(
      images.map((String url) async {
        Reference reference = firebaseStorageInstance.refFromURL(url);
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

  //endregion

  //region ProductOperations

  Future<String?> uploadProductImagesToFireBaseStorage({
    required Uint8List data,
    required String productId,
    required String fileName,
  }) async {
    String? imageUrl;
    try {
      imageUrl = await uploadFilesToFireBaseStorage(
          data: data,
          id: productId,
          fileName: fileName,
          storageFolderName: FirebaseStorageFoldersNames.productFolder
      );
      return imageUrl;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Firebase Storage Controller in Upload File Method $e");
      MyPrint.printOnConsole(s);
      return imageUrl;
    }
  }

  //endregion

}
