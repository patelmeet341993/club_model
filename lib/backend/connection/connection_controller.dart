import 'package:flutter/cupertino.dart';

import '../../configs/app_strings.dart';
import '../../utils/my_toast.dart';
import 'connection_provider.dart';

class ConnectionController {
  late ConnectionProvider _connectionProvider;

  ConnectionController({ConnectionProvider? provider}) {
    _connectionProvider = provider ?? ConnectionProvider();
  }

  ConnectionProvider get connectionProvider => _connectionProvider;

  bool checkConnection({bool isShowErrorSnakbar = true, BuildContext? context}) {
    if(!connectionProvider.isInternet && isShowErrorSnakbar && context != null) {
      MyToast.showError(context: context, msg: AppStrings.noInternet,);
    }

    return connectionProvider.isInternet;
  }
}