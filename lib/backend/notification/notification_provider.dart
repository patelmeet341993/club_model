import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/common/data_model/notication_model.dart';
import '../common/common_provider.dart';

class NotificationProvider extends CommonProvider{
  NotificationProvider(){
    notificationList = CommonProviderListParameter<NotificationModel>(
      list: [],
      notify: notify,
    );
    lastDocument = CommonProviderPrimitiveParameter<DocumentSnapshot<Map<String, dynamic>>?>(
      value:null,
      notify: notify,
    );
    notificationCount = CommonProviderPrimitiveParameter<int>(
      value:0,
      notify: notify,
    );
    hasMoreNotifications = CommonProviderPrimitiveParameter<bool>(
      value:false,
      notify: notify,
    );
    notificationLoading = CommonProviderPrimitiveParameter<bool>(
      value:false,
      notify: notify,
    );
  }

  late CommonProviderListParameter<NotificationModel> notificationList;
  late CommonProviderPrimitiveParameter<DocumentSnapshot<Map<String, dynamic>>?> lastDocument;
  late CommonProviderPrimitiveParameter<int> notificationCount;
  late CommonProviderPrimitiveParameter<bool> hasMoreNotifications;
  late CommonProviderPrimitiveParameter<bool> notificationLoading;

  void addAllNotificationList(List<NotificationModel> value,{bool isNotify = true}) {
    notificationList.setList(list: value);
    if(isNotify) {
      notifyListeners();
    }
  }




}