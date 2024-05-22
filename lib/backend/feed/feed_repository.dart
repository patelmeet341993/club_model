import 'package:club_model/models/common/data_model/app_error_model.dart';

import '../../club_model.dart';
import '../../models/common/data_model/data_response_model.dart';
import '../common/elastic_controller.dart';

class FeedRepository {
  Future<DataResponseModel<bool>> createFeedInFirestore({required CreateFeedRequestModel requestModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedRepository().createFeedInFirestore() called with requestModel:'$requestModel'", tag: tag);

    DataResponseModel<bool> responseModel = const DataResponseModel<bool>();

    MyPrint.printOnConsole("Creating Feed For Id:'${requestModel.feedId}'", tag: tag);
    if (requestModel.feedId.isEmpty) {
      String newFeedId = MyUtils.getNewId(isFromUUuid: false);
      requestModel.feedId = newFeedId;
    }
    requestModel.feedModel.id = requestModel.feedId;

    MyPrint.printOnConsole("Final FeedId:${requestModel.feedId}", tag: tag);

    try {
      await FirebaseNodes.feedDocumentReference(feedId: requestModel.feedId).set(requestModel.feedModel.toMap(toJson: false));

      MyPrint.printOnConsole("Feed Created in Firestore", tag: tag);

      responseModel = const DataResponseModel<bool>(
        data: true,
      );
    } on Exception catch (e, s) {
      MyPrint.printOnConsole("Error Exception in Creating Feed Document in FeedRepository().createFeedInFirestore():$e", tag: tag);
      MyPrint.logOnConsole(s, tag: tag);

      responseModel = DataResponseModel<bool>(
        data: false,
        appErrorModel: AppErrorModel(
          exception: e,
          stackTrace: s,
          message: "Couldn't Create Feed in Firestore",
        ),
      );
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Creating Feed Document in FeedRepository().createFeedInFirestore():$e", tag: tag);
      MyPrint.logOnConsole(s, tag: tag);

      responseModel = DataResponseModel<bool>(
        data: false,
        appErrorModel: AppErrorModel(
          stackTrace: s,
          message: "Couldn't Create Feed in Firestore",
        ),
      );
    }

    return responseModel;
  }

  Future<DataResponseModel<bool>> createFeedInElastic({required CreateFeedRequestModel requestModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedRepository().createFeedInElastic() called with requestModel:'$requestModel'", tag: tag);

    DataResponseModel<bool> responseModel = const DataResponseModel<bool>();

    MyPrint.printOnConsole("Creating Feed For Id:'${requestModel.feedId}'", tag: tag);
    if (requestModel.feedId.isEmpty) {
      String newFeedId = MyUtils.getNewId(isFromUUuid: false);
      requestModel.feedId = newFeedId;
    }
    requestModel.feedModel.id = requestModel.feedId;

    MyPrint.printOnConsole("Final FeedId:${requestModel.feedId}", tag: tag);

    try {
      bool isCreated = await ElasticController().createDocument(
        index: ElasticIndexes.clubFeedsIndex,
        docId: requestModel.feedId,
        data: requestModel.feedModel.toMap(toJson: true),
      );

      MyPrint.printOnConsole("Feed Created in Elastic:$isCreated", tag: tag);

      if (isCreated) {
        responseModel = const DataResponseModel<bool>(
          data: true,
        );
      } else {
        responseModel = DataResponseModel<bool>(
          data: false,
          appErrorModel: AppErrorModel(
            exception: Exception("Couldn't Create Feed in Elastic"),
            stackTrace: StackTrace.current,
            message: "Couldn't Create Feed in Elastic",
          ),
        );
      }
    } on Exception catch (e, s) {
      MyPrint.printOnConsole("Error Exception in Creating Feed Document in FeedRepository().createFeedInElastic():$e", tag: tag);
      MyPrint.logOnConsole(s, tag: tag);

      responseModel = DataResponseModel<bool>(
        data: false,
        appErrorModel: AppErrorModel(
          exception: e,
          stackTrace: s,
          message: "Couldn't Create Feed in Elastic",
        ),
      );
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Creating Feed Document in FeedRepository().createFeedInElastic():$e", tag: tag);
      MyPrint.logOnConsole(s, tag: tag);

      responseModel = DataResponseModel<bool>(
        data: false,
        appErrorModel: AppErrorModel(
          exception: Exception("Couldn't Create Feed in Elastic"),
          stackTrace: s,
          message: "Couldn't Create Feed in Elastic",
        ),
      );
    }

    return responseModel;
  }

  Future<DataResponseModel<bool>> deleteFeedInFirestore({required DeleteFeedRequestModel requestModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedRepository().deleteFeedInFirestore() called with requestModel:'$requestModel'", tag: tag);

    DataResponseModel<bool> responseModel = const DataResponseModel<bool>();

    MyPrint.printOnConsole("Deleting Feed For Id:${requestModel.feedId}", tag: tag);

    if (requestModel.feedId.isEmpty) {
      MyPrint.printOnConsole("Returning from FeedRepository().deleteFeedInFirestore() because feedId is empty", tag: tag);

      return DataResponseModel<bool>(
        data: false,
        appErrorModel: AppErrorModel(
          exception: Exception("Couldn't Delete Feed in Firestore because feedId is empty"),
          stackTrace: StackTrace.current,
          message: "Couldn't Delete Feed in Firestore because feedId is empty",
        ),
      );
    }

    MyPrint.printOnConsole("Final FeedId:${requestModel.feedId}", tag: tag);

    try {
      await FirebaseNodes.feedDocumentReference(feedId: requestModel.feedId).delete();

      MyPrint.printOnConsole("Feed Deleted in Firestore", tag: tag);

      responseModel = const DataResponseModel<bool>(
        data: true,
      );
    } on Exception catch (e, s) {
      MyPrint.printOnConsole("Error Exception in Deleting Feed Document in FeedRepository().deleteFeedInFirestore():$e", tag: tag);
      MyPrint.logOnConsole(s, tag: tag);

      responseModel = DataResponseModel<bool>(
        data: false,
        appErrorModel: AppErrorModel(
          exception: e,
          stackTrace: s,
          message: "Couldn't Delete Feed in Firestore",
        ),
      );
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Deleting Feed Document in FeedRepository().deleteFeedInFirestore():$e", tag: tag);
      MyPrint.logOnConsole(s, tag: tag);

      responseModel = DataResponseModel<bool>(
        data: false,
        appErrorModel: AppErrorModel(
          stackTrace: s,
          message: "Couldn't Delete Feed in Firestore",
        ),
      );
    }

    return responseModel;
  }

  Future<DataResponseModel<bool>> deleteFeedInElastic({required DeleteFeedRequestModel requestModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedRepository().deleteFeedInElastic() called with requestModel:'$requestModel'", tag: tag);

    DataResponseModel<bool> responseModel = const DataResponseModel<bool>();

    MyPrint.printOnConsole("Creating Feed For Id:'${requestModel.feedId}'", tag: tag);
    if (requestModel.feedId.isEmpty) {
      String newFeedId = MyUtils.getNewId(isFromUUuid: false);
      requestModel.feedId = newFeedId;
    }

    MyPrint.printOnConsole("Final FeedId:${requestModel.feedId}", tag: tag);

    try {
      bool isCreated = await ElasticController().deleteDocument(
        index: ElasticIndexes.clubFeedsIndex,
        docId: requestModel.feedId,
      );

      MyPrint.printOnConsole("Feed Deleted in Elastic:$isCreated", tag: tag);

      if (isCreated) {
        responseModel = const DataResponseModel<bool>(
          data: true,
        );
      } else {
        responseModel = DataResponseModel<bool>(
          data: false,
          appErrorModel: AppErrorModel(
            exception: Exception("Couldn't Delete Feed in Elastic"),
            stackTrace: StackTrace.current,
            message: "Couldn't Delete Feed in Elastic",
          ),
        );
      }
    } on Exception catch (e, s) {
      MyPrint.printOnConsole("Error Exception in Deleting Feed Document in FeedRepository().deleteFeedInElastic():$e", tag: tag);
      MyPrint.logOnConsole(s, tag: tag);

      responseModel = DataResponseModel<bool>(
        data: false,
        appErrorModel: AppErrorModel(
          exception: e,
          stackTrace: s,
          message: "Couldn't Delete Feed in Elastic",
        ),
      );
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Deleting Feed Document in FeedRepository().deleteFeedInElastic():$e", tag: tag);
      MyPrint.logOnConsole(s, tag: tag);

      responseModel = DataResponseModel<bool>(
        data: false,
        appErrorModel: AppErrorModel(
          exception: Exception("Couldn't Delete Feed in Elastic"),
          stackTrace: s,
          message: "Couldn't Delete Feed in Elastic",
        ),
      );
    }

    return responseModel;
  }
}
