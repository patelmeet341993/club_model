import '../backend/common/firestore_controller.dart';
import 'typedefs.dart';

class AppConstants {
  static const int notificationDocumentLimitForPagination = 15; //25 //5
  static const int notificationRefreshIndexForPagination = 5;
}

class BannerRoutingType{
  static const String offerType = "Offer";
  static const String newLaunchType = "New Launch";
  static const String newDiscountType = "New Discounts";

  static List<String> get values => [
    offerType,
    newLaunchType,
    newDiscountType
  ];

}

class NotificationType{
  static const String offerType = "Offer";
  static const String newLaunchType = "New Launch";
  static const String newDiscountType = "New Discounts";

  static List<String> get values => [
    offerType,
    newLaunchType,
    newDiscountType
  ];
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

  // region Brand
  static const String brandCollection = "brand";

  static MyFirestoreCollectionReference get brandCollectionReference => FirestoreController.collectionReference(
    collectionName: brandCollection,
  );

  static MyFirestoreDocumentReference brandDocumentReference({String? brandId}) => FirestoreController.documentReference(
    collectionName: brandCollection,
    documentId: brandId,
  );
  //endregion

   // region Notifications
  static const String notificationCollection = "notifications";

  static MyFirestoreCollectionReference get notificationCollectionReference => FirestoreController.collectionReference(
    collectionName: notificationCollection,
  );

  static MyFirestoreDocumentReference notificationDocumentReference({String? notificationId}) => FirestoreController.documentReference(
    collectionName: notificationCollection,
    documentId: notificationId,
  );
  //endregion

  //region Club
  static const String clubsCollection = "clubs";
  static const String clubsUserCollection = "club Users";

  static MyFirestoreCollectionReference get clubsCollectionReference => FirestoreController.collectionReference(
    collectionName: clubsCollection,
  );
  static MyFirestoreCollectionReference get clubUserCollectionReference => FirestoreController.collectionReference(
    collectionName: clubsUserCollection,
  );

  static MyFirestoreDocumentReference clubDocumentReference({String? clubId}) => FirestoreController.documentReference(
    collectionName: clubsCollection,
    documentId: clubId,
  );

  static MyFirestoreDocumentReference clubUserDocumentReference({String? clubId}) => FirestoreController.documentReference(
    collectionName: clubsUserCollection,
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

class FirebaseStorageFoldersNames{

  static const String productFolder = 'products';

  static const String brandFolder = 'brands';

  static const String clubFolder = 'clubs';
}

//Shared Preference Keys
class SharePreferenceKeys {
  static const String appThemeMode = "themeMode";
}

class UIConstants {
  static const String noUserImageUrl = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
}

String getSecureUrl(String url) {
  if(url.startsWith("http:")) {
    url = url.replaceFirst("http:", "https:");
  }
  return url;
}

class CommentTypes {
  static const String text = "Text";
  static const String gif = "Gif";
}

class FeedType {
  static const String image = "IMAGE";
  static const String video = "VIDEO";
  static const String poll = "POLL";
  static const String none = "NONE";
}

class FeedLikeType {
 static const String heart = "HEART";
 static const String fire = "FIRE";
 static const String like = "LIKE";
 static const String thumbsUp = "THUMBSUP";
 static const String clap = "CLAP";
 static const String cry = "CRY";
 static const String angry = "ANGRY";
 static const String laughing = "LAUGHING";
 static const String none = "NONE";
}
