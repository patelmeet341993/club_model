import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../utils/my_print.dart';

class ConnectionProvider extends ChangeNotifier {
  bool isInternet = true;
  StreamSubscription<ConnectivityResult>? subscription;

  ConnectionProvider() {
    MyPrint.printOnConsole("ConnectionProvider constructor called");
    if(kIsWeb) {
      isInternet = true;
    }
    else {
      isInternet = Platform.isIOS;
    }
    try {
      Connectivity().checkConnectivity().then((ConnectivityResult result) {
        MyPrint.printOnConsole("Connectivity Result:$result");
        isInternet = result == ConnectivityResult.none ? false : true;

        MyPrint.printOnConsole("Connection Subscription Started");
        subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
          MyPrint.printOnConsole("Connectivity Result:$result");
          isInternet = result == ConnectivityResult.none ? false : true;
          notifyListeners();
        });
      });
    }
    catch (e, s) {
      MyPrint.printOnConsole("Error in Connectivity Subscription:$e");
      MyPrint.printOnConsole(s);
    }
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
    subscription = null;
  }
}