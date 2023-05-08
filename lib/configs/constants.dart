import '../backend/common/firestore_controller.dart';
import 'typedefs.dart';

class AppConstants {

}

class FirestoreExceptionCodes {
  static const String notFound = "not-found";
}

class FirebaseNodes {
  //region Admin
  static const String adminCollection = "admin";

  static MyFirestoreCollectionReference get adminCollectionReference => FirestoreController.collectionReference(
    collectionName: adminCollection,
  );

  static MyFirestoreDocumentReference adminDocumentReference({String? documentId}) => FirestoreController.documentReference(
    collectionName: adminCollection,
    documentId: documentId,
  );

  //region Property Document
  static const String propertyDocument = "property";

  static MyFirestoreDocumentReference get adminPropertyDocumentReference => adminDocumentReference(
    documentId: propertyDocument,
  );
  //endregion
  //endregion

  //region Admin Users
  static const String adminUsersCollection = "admin_users";

  static MyFirestoreCollectionReference get adminUsersCollectionReference => FirestoreController.collectionReference(
    collectionName: adminUsersCollection,
  );

  static MyFirestoreDocumentReference adminUserDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: adminUsersCollection,
    documentId: userId,
  );
  //endregion

  //region Club
  static const String clubsCollection = "clubs";

  static MyFirestoreCollectionReference get clubsCollectionReference => FirestoreController.collectionReference(
    collectionName: clubsCollection,
  );

  static MyFirestoreDocumentReference clubDocumentReference({String? clubId}) => FirestoreController.documentReference(
    collectionName: clubsCollection,
    documentId: clubId,
  );
  //endregion

  //region Product
  static const String productsCollection = "products";

  static MyFirestoreCollectionReference get productsCollectionReference => FirestoreController.collectionReference(
    collectionName: productsCollection,
  );

  static MyFirestoreDocumentReference productDocumentReference({String? productId}) => FirestoreController.documentReference(
    collectionName: productsCollection,
    documentId: productId,
  );
  //endregion

  //region User
  static const String usersCollection = "users";

  static MyFirestoreCollectionReference get usersCollectionReference => FirestoreController.collectionReference(
    collectionName: usersCollection,
  );

  static MyFirestoreDocumentReference userDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: usersCollection,
    documentId: userId,
  );
  //endregion

  //region Timestamp Collection
  static const String timestampCollection = "timestamp_collection";

  static MyFirestoreCollectionReference get timestampCollectionReference => FirestoreController.collectionReference(
    collectionName: timestampCollection,
  );
  //endregion
}

//Shared Preference Keys
class SharePreferenceKeys {
  static const String appThemeMode = "themeMode";
}

class UIConstants {
  static const String noUserImageUrl = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
}
