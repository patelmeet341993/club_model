import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club_model/club_model.dart';

import '../../models/common/data_model/notication_model.dart';
import '../../utils/my_print.dart';
import 'notification_provider.dart';

class NotificationController{
  late NotificationProvider _notificationProvider;

  NotificationController({required NotificationProvider? notificationProvider}) {
    _notificationProvider = notificationProvider ?? NotificationProvider();
  }

  Future<void> createNotification(NotificationModel notificationModel, {required String userId}) async {
    try {
      bool isSuccess = await FirebaseNodes.notificationDocumentReference(notificationId: notificationModel.id).set(notificationModel.toMap()).then((value) {
        return true;
      }).catchError((onError) {
        MyPrint.printOnConsole("Firebase set error in the create notification");
        return false;
      });

      if (isSuccess) {
        _notificationProvider.addNotificationInList(notificationModel);
      }

    } catch (e, s) {
      MyPrint.printOnConsole("Error in TransactionController.createNotification $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> getNotificationListFromFirebase({bool isRefresh = true, bool isNotify = true}) async {
    try {

      if (!isRefresh && _notificationProvider.notificationList.length > 0) {
        MyPrint.printOnConsole("Returning Cached Data");
        _notificationProvider.notificationList;
      }

      if (isRefresh) {
        MyPrint.printOnConsole("Refresh");
        _notificationProvider.hasMoreNotifications.set(value: true); // flag for more products available or not
        _notificationProvider.lastDocument.set(value: null); // flag for last document from where next 10 records to be fetched
        _notificationProvider.notificationLoading.set(value: false, isNotify: isNotify);
        _notificationProvider.notificationList.setList(list: [], isNotify: isNotify);
      }

      if (!_notificationProvider.hasMoreNotifications.get()) {
        MyPrint.printOnConsole('No More Users');
        return;
      }
      if (_notificationProvider.notificationLoading.get()) return;

      _notificationProvider.notificationLoading.set(value: true, isNotify: isNotify);

      Query<Map<String, dynamic>> query = FirebaseNodes.notificationCollectionReference
          .limit(AppConstants.notificationDocumentLimitForPagination)
          .orderBy("createdTime", descending: true);

      //For Last Document
      DocumentSnapshot<Map<String, dynamic>>? snapshot = _notificationProvider.lastDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null");
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null");
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Admin Users:${querySnapshot.docs.length}");

      if (querySnapshot.docs.length < AppConstants.notificationDocumentLimitForPagination) _notificationProvider.hasMoreNotifications.set(value: false);

      if (querySnapshot.docs.isNotEmpty) _notificationProvider.lastDocument.set(value:querySnapshot.docs[querySnapshot.docs.length - 1]);

      List<NotificationModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
        if ((documentSnapshot.data() ?? {}).isNotEmpty) {
          NotificationModel notificationModel = NotificationModel.fromMap(documentSnapshot.data()!);
          list.add(notificationModel);
        }
      }
      _notificationProvider.addAllNotificationList(list, isNotify: false);
      _notificationProvider.notificationLoading.set(value: false);
      MyPrint.printOnConsole("Final Notification Length From Firestore:${list.length}");
      MyPrint.printOnConsole("Final Notification Length in Provider:${_notificationProvider.notificationList.length}");
    } catch (e, s) {
      MyPrint.printOnConsole("Error in get Notification List form Firebase in Notification Controller $e");
      MyPrint.printOnConsole(s);
    }
  }


}