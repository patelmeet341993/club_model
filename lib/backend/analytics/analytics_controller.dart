import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../utils/my_print.dart';

class AnalyticsController {
  static AnalyticsController? _instance;

  factory AnalyticsController() {
    _instance ??= AnalyticsController._();
    return _instance!;
  }

  AnalyticsController._();

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;


  Future<void> setUserid() async {
    /*String uid = await UserController().getUserId();
    await analytics.setUserId(id: uid);*/
  }
  
  Future<void> fireEvent({required String analyticEvent, Map<String, dynamic>? parameters}) async {
    await analytics.logEvent(name:  analyticEvent, parameters: parameters != null && parameters.isNotEmpty ? parameters : null).then((value) {
      MyPrint.printOnConsole('$analyticEvent fired with parameters:$parameters');
    })
    .catchError((e, s) {
      MyPrint.printOnConsole('Error in Firing $analyticEvent:$e');
      MyPrint.printOnConsole(s);
    });
  }
  
  Future<void> recordError(Object exception, StackTrace stackTrace, {String? reason}) async {
    await FirebaseCrashlytics.instance.recordError(exception, stackTrace, reason: reason, printDetails: true,);
  }
}