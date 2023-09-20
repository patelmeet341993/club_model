import 'notification_provider.dart';

class NotificationController{
  late NotificationProvider _notificationProvider;

  NotificationController({required NotificationProvider? notificationProvider}) {
    _notificationProvider = notificationProvider ?? NotificationProvider();
  }
}