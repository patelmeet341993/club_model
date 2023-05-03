import 'package:cloud_firestore/cloud_firestore.dart';

import '../../configs/typedefs.dart';

class FirestoreController {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static MyFirestoreCollectionReference collectionReference({required String collectionName}) {
    return firestore.collection(collectionName);
  }

  static MyFirestoreDocumentReference documentReference({required String collectionName, String? documentId}) {
    return firestore.collection(collectionName).doc(documentId);
  }

  static Future<List<MyFirestoreQueryDocumentSnapshot>> getDocsFromCollection({required MyFirestoreCollectionReference collectionReference, required List<String> docIds}) async {
    //Create A New List Of DocumentSnapshots
    List<MyFirestoreQueryDocumentSnapshot> newDocs = [];

    //Total Input Documents Count
    int docIdsCount = docIds.length;

    //Limit Accepted By FireStore in WhereIn Query
    int maxLimit = 10;

    //No Of Count we are gonna fire whereIn query on FireStore
    int iterationCount = (docIdsCount / maxLimit).ceil();
    //MyPrint.printOnConsole("IterationCount:"+iterationCount.toString());

    //Min and Max Index to create subList from main input List
    int low = 0, hi = maxLimit;

    //While Loop Count
    int count = 0;

    while(count < iterationCount) {
      //If hi index > Total Input Documents Count ,
      // then make hi index equal to Total Input Documents Count
      if(hi > docIdsCount) {
        hi = docIdsCount;
      }

      //Create SubList From Main Input List
      List<String> docs = docIds.sublist(low, hi);

      //Fire WhereIn query on firestore collection with sublist of documentId
      MyFirestoreQuerySnapshot querySnapshot = await collectionReference.where(FieldPath.documentId, whereIn: docs).get();

      //Get DocumentSnapshots from QuerySnapshot
      List<MyFirestoreQueryDocumentSnapshot> documentSnapshots = querySnapshot.docs;

      //For Each Document check whether data is empty or not
      //If not then add that DocumentSnapshot to list of newDocumentSnapshot
      newDocs.addAll(documentSnapshots.where((element) => element.data().isNotEmpty));
      //--------------Fire Query Ends---------------------------------------------------

      //Increment low And Hi index by MaxLimit to move to next sublist from main list
      low += maxLimit;
      hi += maxLimit;

      //Increment While loop counter to move further
      count++;
    }

    return newDocs;
  }
}