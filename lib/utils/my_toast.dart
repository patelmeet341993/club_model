import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'my_print.dart';

class MyToast{

  static _showToast(BuildContext context, String msg, int duration, Color toastColor, Color textColor) {
    try {
      Widget toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: toastColor,
        ),
        child: Text(msg, style: TextStyle(color: textColor),),
      );

      FToast fToast = FToast();
      fToast.init(context);

      /*fToast.showToast(
        child: toast,
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: duration ?? 2),
      );*/

      // Custom Toast Position
      fToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: duration),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            bottom: 100.0,
            left: 0,
            right: 0,
          );
        },
      );
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Showing Toast:$e");
      MyPrint.printOnConsole(s);
    }
  }

  static void showError({required BuildContext context, required String msg, int durationInSeconds = 2}) {
    _showToast(context, msg, durationInSeconds, Colors.red, Colors.white);
  }

  static void showSuccess({required BuildContext context, required String msg, int durationInSeconds = 2}) {
    _showToast(context, msg, durationInSeconds, Colors.green, Colors.white);
  }

  static void normalMsg({required BuildContext context, required String msg, int durationInSeconds = 2}) {
    ThemeData themeData = Theme.of(context);
    _showToast(context, msg, durationInSeconds, themeData.colorScheme.primary, Colors.white);
  }
  static void greyMsg({required BuildContext context, required String msg, int durationInSeconds = 2}) {
    ThemeData themeData = Theme.of(context);
    _showToast(context, msg, durationInSeconds, themeData.colorScheme.onBackground, Colors.white);
  }
}