import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

typedef MyFirestoreQuery = Query<Map<String, dynamic>>;

typedef MyFirestoreCollectionReference = CollectionReference<Map<String, dynamic>>;
typedef MyFirestoreQuerySnapshot = QuerySnapshot<Map<String, dynamic>>;
typedef MyFirestoreQueryDocumentSnapshot = QueryDocumentSnapshot<Map<String, dynamic>>;

typedef MyFirestoreDocumentReference = DocumentReference<Map<String, dynamic>>;
typedef MyFirestoreDocumentSnapshot = DocumentSnapshot<Map<String, dynamic>>;

typedef MyFirestoreDocumentSnapshotStreamSubscription = StreamSubscription<MyFirestoreDocumentSnapshot>;
