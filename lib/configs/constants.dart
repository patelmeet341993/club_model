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

  //region Patient
  static const String patientCollection = "patient";

  static MyFirestoreCollectionReference get patientCollectionReference => FirestoreController.collectionReference(
    collectionName: patientCollection,
  );

  static MyFirestoreDocumentReference patientDocumentReference({String? patientId}) => FirestoreController.documentReference(
    collectionName: patientCollection,
    documentId: patientId,
  );
  //endregion

  //region Visits
  static const String visitsCollection = "visits";

  static MyFirestoreCollectionReference get visitsCollectionReference => FirestoreController.collectionReference(
    collectionName: visitsCollection,
  );

  static MyFirestoreDocumentReference visitDocumentReference({String? visitId}) => FirestoreController.documentReference(
    collectionName: visitsCollection,
    documentId: visitId,
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
