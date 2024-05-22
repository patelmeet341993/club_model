class AppErrorModel {
  String message;
  Exception? exception;
  StackTrace? stackTrace;
  int code;

  AppErrorModel({
    this.message = "",
    this.exception,
    this.stackTrace,
    this.code = -1,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "message": message,
      "exception": exception,
      "stackTrace": stackTrace,
      "code": code,
    };
  }

  @override
  String toString() {
    return "AppErrorModel(${toMap()})";
  }
}
