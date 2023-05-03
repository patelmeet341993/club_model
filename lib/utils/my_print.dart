import 'dart:developer';

class MyPrint {
  static void printOnConsole(Object s, {String? tag}) {
    print("${(tag?.isNotEmpty ?? false) ? "$tag " : ""}${s.toString()}");
  }

  static void logOnConsole(Object s, {String? tag}) {
    log("${(tag?.isNotEmpty ?? false) ? "$tag " : ""}${s.toString()}");
  }
}