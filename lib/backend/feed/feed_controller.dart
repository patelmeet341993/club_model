import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:club_model/backend/common/elastic_controller.dart';
import 'package:club_model/models/common/data_model/data_response_model.dart';
import 'package:club_model/models/feed/request_model/create_feed_request_model.dart';
import 'package:club_model/utils/cloudinary_manager.dart';
import 'package:elastic_client/elastic_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../club_model.dart';
import 'feed_repository.dart';

class FeedController {
  late FeedRepository _feedRepository;

  FeedController({
    FeedRepository? repository,
  }) {
    _feedRepository = repository ?? FeedRepository();
  }

  FeedRepository get feedRepository => _feedRepository;

  Future<bool> createFeed({required CreateFeedRequestModel requestModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    bool isSuccess = false;

    FeedRepository repository = feedRepository;

    try {
      List<DataResponseModel<bool>> responses = await Future.wait([
        repository.createFeedInFirestore(requestModel: requestModel),
        repository.createFeedInElastic(requestModel: requestModel),
      ]);

      List<bool> isSuccessAll = responses.map((e) => e.data == true).toList();

      isSuccess = !isSuccessAll.contains(false);
      // NotificationController().sendNewFeedNotification(feedModel: feedModel, interests: interestIds);
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Creating Feed in FeedController().createFeed():$e', tag: tag);
      MyPrint.logOnConsole(s, tag: tag);
      AnalyticsController().recordError(e, s, reason: "Error in Create Feed in FeedController().createFeed()");
    }

    return isSuccess;
  }

  /*Future<bool> updateFeed(FeedModel feedModel) async {
    bool isSuccess = false;
    try {
      Map<String, dynamic> firestoreMap = {
        "feedVenueMetaModel" : feedModel.feedVenueMetaModel.toMap(),
        "community_id" : feedModel.community_id,
        "community_name" : feedModel.community_name,
        "feedDataModel" : feedModel.feedDataModel?.toMap(),
        "editedTime" : feedModel.editedTime,
      };

      Map<String, dynamic> elasticMap = {
        "feedVenueMetaModel" : feedModel.feedVenueMetaModel.toMap(),
        "community_id" : feedModel.community_id,
        "community_name" : feedModel.community_name,
        "feedDataModel" : feedModel.feedDataModel?.elasticToMap(),
        "editedTime" : feedModel.editedTime != null ? DatePresentation.yyyyMMddHHmmssFormatter(feedModel.editedTime!) : null,
      };

      int i = 0;
      Function whenComplete = () => i++;

      FirestoreController().firestore.collection(FEED_COLLECTION).doc(feedModel.id).update(firestoreMap).whenComplete(() {
        whenComplete();
      });
      ElasticController().updateDocument(getFeedsIndex(), feedModel.id, elasticMap).whenComplete(() {
        whenComplete();
      });

      while(i < 2) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      isSuccess = true;
    }
    catch(e) {
      MyPrint.printOnConsole('Error in Create Post:$e');
    }

    return isSuccess;
  }*/

  Future<bool> deletePost({required DeleteFeedRequestModel requestModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    bool isSuccess = false;

    FeedRepository repository = feedRepository;

    try {
      List<DataResponseModel<bool>> responses = await Future.wait([
        repository.deleteFeedInFirestore(requestModel: requestModel),
        repository.deleteFeedInElastic(requestModel: requestModel),
      ]);

      List<bool> isSuccessAll = responses.map((e) => e.data == true).toList();

      isSuccess = !isSuccessAll.contains(false);
      // NotificationController().sendNewFeedNotification(feedModel: feedModel, interests: interestIds);
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Creating Feed in FeedController().createFeed():$e', tag: tag);
      MyPrint.logOnConsole(s, tag: tag);
      AnalyticsController().recordError(e, s, reason: "Error in Create Feed in FeedController().createFeed()");
    }

    if (isSuccess) {
      ImageFeedDataModel? imageData;
      if (requestModel.feedModel?.feedDataModel is ImageFeedDataModel) {
        imageData = requestModel.feedModel!.feedDataModel as ImageFeedDataModel;
      }

      if (imageData != null) {
        List<String> imagesList = imageData.images.map((e) => e.imageUrl).toList()..removeWhere((element) => element.isEmpty);
        Future<bool> deleteImagesFuture = CloudinaryManager.deleteImagesFromCloudinary(images: imagesList).then((bool isSuccess) {
          return isSuccess;
        }).catchError((e) {
          return false;
        });

        futures.add(deleteImagesFuture);
      }
    }

    Future firestoreFuture = FirestoreController().firestore.collection(FEED_COLLECTION).doc(feedModel.id).delete().then((value) {
      return true;
    }).catchError((e) {
      return false;
    });

    Future elasticFuture = ElasticController().deleteDocument(getFeedsIndex(), feedModel.id).then((value) {
      return true;
    }).catchError((e) {
      return false;
    });

    List<Future> futures = [
      firestoreFuture,
      elasticFuture,
    ];

    await Future.wait(futures);

    return isSuccess;
  }

  Future<bool> hideUnHideFeed({required FeedModel feedModel, required bool hide}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    bool isUpdated1 = false;
    bool isUpdated2 = false;

    List<Future> futures = [
      FirestoreController().firestore.collection(FEED_COLLECTION).doc(feedModel.id).update({"enabledByUser": !hide}).then((value) {
        isUpdated1 = true;
      }).catchError((e) {
        MyPrint.printOnConsole("Error in Hide/Unhide Feed in Firestore:$e");
      }),
      ElasticController().updateDocument(getFeedsIndex(), feedModel.id, {"enabledByUser": !hide}).then((value) {
        isUpdated2 = true;
      }).catchError((e) {
        MyPrint.printOnConsole("Error in Hide/Unhide Feed in Elastic:$e");
      }),
    ];

    await Future.wait(futures);

    return isUpdated1 && isUpdated2;
  }

  Future<bool> updateFeedViewCount(FeedModel feedModel) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    if (feedModel.id.isEmpty) return false;

    bool isSuccess = false;

    try {
      Map<String, dynamic> data = {
        "viewsCount": firestore.FieldValue.increment(1),
        "totalInteractionCount": firestore.FieldValue.increment(1),
      };

      firestore.DocumentReference<Map<String, dynamic>> feedReference = FirestoreController().firestore.collection(FEED_COLLECTION).doc(feedModel.id);
      await feedReference.update(data);
      firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await feedReference.get();

      if (documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
        FeedModel newFeedModel = FeedModel.fromMap(documentSnapshot.data() ?? {});

        feedModel.updateFromMap(documentSnapshot.data() ?? {});

        data = {
          "viewsCount": newFeedModel.viewsCount,
          "totalInteractionCount": newFeedModel.totalInteractionCount,
        };
        await ElasticController().updateDocument(getFeedsIndex(), feedModel.id, data);
        isSuccess = true;
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in SportiFeedController().updateFeedViewCount():$e");
      MyPrint.printOnConsole(s);
    }

    return isSuccess;
  }

  Future<bool> likeDislikeFeed(FeedModel feedModel, {SportifeedLikeType? likeType, bool isLike = true, bool oldIsLike = false}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    bool isSuccess = false;

    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    if (userProvider.userid?.isEmpty ?? true) {
      MyPrint.printOnConsole("UserId is Null Or Empty");
      return false;
    }
    String likeTypeString = getSportifeedLikeTypeStringFromEnum(likeType ?? SportifeedLikeType.NONE);

    bool isFirestoreSuccess = false, isElacticSuccess = false;

    List<Future> futures = [];

    if (isLike) {
      firestore.Timestamp timestamp = await DataController().getNewTimeStamp();

      Map<String, dynamic> firestoreFeedData = {
        "type": likeTypeString,
        "time": timestamp,
      };

      Map<String, dynamic> elasticFeedData = {
        "type": likeTypeString,
        "time": DatePresentation.yyyyMMddHHmmssFormatter(timestamp),
        "userid": userProvider.userid!,
        "feedid": feedModel.id,
        "parentType": "feed",
      };

      futures.addAll([
        FirestoreController().firestore.collection(USER_FEED_LIKES_COLLECTION).doc(feedModel.id).collection("likes").doc(userProvider.userid!).set(firestoreFeedData).then((value) {
          isFirestoreSuccess = true;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Adding Like in Firestore in SportiFeedController().likeFeed():$e");
          isFirestoreSuccess = false;
        }),
        ElasticController().createDocument(getUserLikesIndex(), "${feedModel.id}_${userProvider.userid!}", elasticFeedData).then((value) {
          isElacticSuccess = true;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Adding Like in Elastic in SportiFeedController().likeFeed():$e");
          isElacticSuccess = false;
        }),
      ]);
    } else {
      futures.addAll([
        FirestoreController().firestore.collection(USER_FEED_LIKES_COLLECTION).doc(feedModel.id).collection("likes").doc(userProvider.userid!).delete().then((value) {
          isFirestoreSuccess = true;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Adding Like in Firestore in SportiFeedController().likeFeed():$e");
          isFirestoreSuccess = false;
        }),
        ElasticController().deleteDocument(getUserLikesIndex(), "${feedModel.id}_${userProvider.userid!}").then((value) {
          isElacticSuccess = true;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Adding Like in Elastic in SportiFeedController().likeFeed():$e");
          isElacticSuccess = false;
        }),
      ]);
    }

    await Future.wait(futures);

    MyPrint.printOnConsole("isFirestoreSuccess:$isFirestoreSuccess");
    MyPrint.printOnConsole("isElacticSuccess:$isElacticSuccess");

    isSuccess = isFirestoreSuccess && isElacticSuccess;

    if (isSuccess) {
      if (isLike) {
        feedModel.totalInteractionCount++;
      }

      if (oldIsLike != isLike) {
        if (isLike)
          feedModel.likesCount++;
        else
          feedModel.likesCount--;
      }

      //Add In MyLikes
      if ((userProvider.userid?.isNotEmpty ?? false) && feedModel.createdTime != null) {
        String myLikeId = "${userProvider.userid!}_${feedModel.createdTime!.toDate().year}_${feedModel.createdTime!.toDate().month}";

        await updateMyLike(myLikeId, feedModel.id, likeTypeString, isAdd: isLike).then((value) {
          MyPrint.printOnConsole("Update My Like Success:$value");
        });
      }

      //Update Feed Model In Firestore and Elastic
      firestore.DocumentReference<Map<String, dynamic>> reference = FirestoreController().firestore.collection(FEED_COLLECTION).doc(feedModel.id);
      reference.update({
        "likesCount": firestore.FieldValue.increment(oldIsLike != isLike ? (isLike ? 1 : -1) : 0),
        "totalInteractionCount": firestore.FieldValue.increment(isLike ? 1 : 0),
      }).then((value) async {
        //MyPrint.printOnConsole("Like Count Modified in Firestore Successfully");
        firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await reference.get();
        if (documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
          FeedModel newFeedModel = FeedModel.fromMap(documentSnapshot.data()!);

          //MyPrint.printOnConsole("New Like Count:${feedModel.likesCount}");

          feedModel.updateFromMap(newFeedModel.toMap());

          SportifeedProvider sportifeedProvider = Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
          sportifeedProvider.myFeedsList.where((element) => element.id == newFeedModel.id).forEach((FeedModel feedModel) {
            feedModel.updateFromMap(newFeedModel.toMap());
          });

          sportifeedProvider.feedsList.where((element) => element.id == newFeedModel.id).forEach((FeedModel feedModel) {
            feedModel.updateFromMap(newFeedModel.toMap());
          });
          //isInitializePollFromHive = true;
          sportifeedProvider.notifyListeners();

          String feedImageUrl = "";
          if ((newFeedModel.feedDataModel is ImageFeedDataModel) && (newFeedModel.feedDataModel as ImageFeedDataModel).images.isNotEmpty) {
            feedImageUrl = (newFeedModel.feedDataModel as ImageFeedDataModel).images[0].image_url;
          }
          ImageFeedDataModel imageFeedDataModel = ImageFeedDataModel();
          if ((newFeedModel.feedDataModel is ImageFeedDataModel)) {
            imageFeedDataModel = (newFeedModel.feedDataModel as ImageFeedDataModel);
          }

          if (userProvider.userid! != newFeedModel.createdById) {
            NotificationController().sendFeedUpdateNotification(
                feedId: newFeedModel.id,
                otheruserid: newFeedModel.createdById,
                actionType: isLike ? 0 : 1,
                feedImage: (imageFeedDataModel.images.isNotEmpty) ? imageFeedDataModel.images[0].image_url : "",
                likeCount: newFeedModel.likesCount,
                commentCount: newFeedModel.commentsCount,
                imageFeedDataModel: imageFeedDataModel);
          }

          bool isSuccess = await ElasticController().updateDocument(getFeedsIndex(), newFeedModel.id, {"likesCount": newFeedModel.likesCount}).then((value) {
            return true;
          }).catchError((e) {
            return false;
          });
          MyPrint.printOnConsole("Update Like Count Feed In Elastic IsSuccess:$isSuccess");
        }
      }).catchError((e) {
        MyPrint.printOnConsole("Error in Updating Feed Document in Firestore:$e");
      });
    }

    return isSuccess;
  }

  Future<bool> updateMyLike(String myLikeDocumentId, String feedId, String likeTypeString, {bool isAdd = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    bool isSuccess = false;

    Map<String, dynamic> likeData = {
      "type": likeTypeString,
      "time": firestore.Timestamp.now(),
    };

    Map<String, dynamic> hiveLikeData = {
      "type": likeTypeString,
      "time": DatePresentation.yyyyMMddHHmmssFormatter(firestore.Timestamp.now()),
    };

    firestore.DocumentReference<Map<String, dynamic>> documentReference = FirestoreController().firestore.collection(MY_LIKES_COLLECTION).doc(myLikeDocumentId);

    try {
      await documentReference.update({feedId: isAdd ? likeData : firestore.FieldValue.delete()});
      isSuccess = true;
    } catch (e) {
      MyPrint.printOnConsole("Error in SportiFeedController.updateMyLike():$e, Type:${e.runtimeType}");
      if (e.runtimeType == firestore.FirebaseException) {
        firestore.FirebaseException fe = e as firestore.FirebaseException;

        switch (fe.code) {
          case "not-found":
            {
              bool createDocumentIsSuccess = await documentReference.set({feedId: likeData}).then((value) {
                return true;
              }).catchError((e) {
                MyPrint.printOnConsole("Error in Creating MyLike Document in SportiFeedController.updateMyLike():$e, Type:${e.runtimeType}");
                return false;
              });
              isSuccess = createDocumentIsSuccess;
            }
        }
      }
    }

    if (isSuccess) {
      await Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false).updateMyLikesForDocument(feedId, hiveLikeData, isAdd: isAdd);
    }

    return isSuccess;
  }

  Future<bool> setVoteInPoll({
    required FeedModel feedModel,
    required PollModel pollModel,
    required PollAnswerModel pollAnswerModel,
    String oldAnswer = "",
    bool isSet = true,
  }) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    if (isSet && oldAnswer.isNotEmpty && pollAnswerModel.answerid == oldAnswer) {
      return true;
    }

    bool isSuccess = false;

    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    if (userProvider.userid?.isEmpty ?? true) {
      MyPrint.printOnConsole("UserId is Null Or Empty");
      return false;
    }

    bool isFirestoreSuccess = false, isElacticSuccess = false;

    firestore.Timestamp timestamp = await DataController().getNewTimeStamp();

    Map<String, dynamic> firestoreFeedData = {
      "vote": pollAnswerModel.answerid,
      "time": timestamp,
    };

    Map<String, dynamic> elasticFeedData = {
      "vote": pollAnswerModel.answerid,
      "time": DatePresentation.yyyyMMddHHmmssFormatter(timestamp),
      "userid": userProvider.userid!,
      "pollid": pollModel.id,
      "parentType": "feed",
    };

    List<Future> futures = [];

    if (isSet) {
      futures.addAll([
        FirestoreController().firestore.collection(USER_FEED_POLLS_COLLECTION).doc(pollModel.id).collection("polls").doc(userProvider.userid!).set(firestoreFeedData).then((value) {
          isFirestoreSuccess = true;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Adding Poll in Firestore in SportiFeedController().setVoteInPoll():$e");
          isFirestoreSuccess = false;
        }),
        ElasticController().createDocument(getUserPollsIndex(), "${pollModel.id}_${userProvider.userid!}", elasticFeedData).then((value) {
          isElacticSuccess = true;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Adding Poll in Elastic in SportiFeedController().setVoteInPoll():$e");
          isElacticSuccess = false;
        })
      ]);
    } else {
      futures.addAll([
        FirestoreController().firestore.collection(USER_FEED_POLLS_COLLECTION).doc(pollModel.id).collection("polls").doc(userProvider.userid!).delete().then((value) {
          isFirestoreSuccess = true;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Adding Poll in Firestore in SportiFeedController().setVoteInPoll():$e");
          isFirestoreSuccess = false;
        }),
        ElasticController().deleteDocument(getUserPollsIndex(), "${pollModel.id}_${userProvider.userid!}").then((value) {
          isElacticSuccess = true;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Adding Poll in Elastic in SportiFeedController().setVoteInPoll():$e");
          isElacticSuccess = false;
        })
      ]);
    }

    await Future.wait(futures);

    MyPrint.printOnConsole("isFirestoreSuccess:$isFirestoreSuccess");
    MyPrint.printOnConsole("isElacticSuccess:$isElacticSuccess");

    isSuccess = isFirestoreSuccess && isElacticSuccess;

    if (isSuccess) {
      //Add In MyLikes
      if ((userProvider.userid?.isNotEmpty ?? false) && pollModel.createdTime != null) {
        String myPollId = "${userProvider.userid!}_${pollModel.createdTime!.toDate().year}_${pollModel.createdTime!.toDate().month}";

        await updateMyPoll(
          myPollDocumentId: myPollId,
          pollId: pollModel.id,
          answerId: (!isSet && oldAnswer.isNotEmpty) ? oldAnswer : pollAnswerModel.answerid,
          isSet: isSet,
        ).then((value) {
          MyPrint.printOnConsole("Update My Poll Success:$value");
        });
      }

      //Update Feed Model In Firestore and Elastic
      firestore.DocumentReference<Map<String, dynamic>> reference = FirestoreController().firestore.collection(FEED_COLLECTION).doc(feedModel.id);
      Map<String, dynamic> data = {
        "pollModel.totalVotes": firestore.FieldValue.increment(isSet ? (oldAnswer.isEmpty ? 1 : 0) : (oldAnswer.isEmpty ? 0 : -1)),
        "pollModel.answers.${pollAnswerModel.answerid}.votes": firestore.FieldValue.increment(isSet ? 1 : (oldAnswer.isEmpty ? 0 : -1)),
      };

      if (oldAnswer.isNotEmpty) {
        data["pollModel.answers.$oldAnswer.votes"] = firestore.FieldValue.increment(-1);
      }

      MyPrint.printOnConsole('data to update in feed for poll:$data');

      await reference.update(data).then((value) async {
        //MyPrint.printOnConsole("Like Count Modified in Firestore Successfully");
        firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await reference.get();
        if (documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
          FeedModel feedModel = FeedModel.fromMap(documentSnapshot.data()!);
          if (feedModel.pollModel != null) {
            pollModel.updateFromMap(feedModel.pollModel!.toMap());
          }

          await ElasticController().updateDocument(getFeedsIndex(), feedModel.id, {"pollModel": null});
          if (feedModel.pollModel != null) {
            bool isSuccess = await ElasticController().updateDocument(getFeedsIndex(), feedModel.id, {"pollModel": feedModel.pollModel!.elasticToMap()}).then((value) {
              return true;
            }).catchError((e) {
              return false;
            });
          }
          MyPrint.printOnConsole("Update Poll Count Feed In Elastic IsSuccess:$isSuccess");
        }
      }).catchError((e) {
        MyPrint.printOnConsole("Error in Updating Poll Document in Firestore:$e");
      });
    }

    return isSuccess;
  }

  Future<bool> updateMyPoll({required String myPollDocumentId, required String pollId, required String answerId, bool isSet = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    bool isSuccess = false;

    Map<String, dynamic> likeData = {
      "answerid": isSet ? answerId : "",
      "time": firestore.Timestamp.now(),
    };

    Map<String, dynamic> hiveLikeData = {
      "answerid": isSet ? answerId : "",
      "time": DatePresentation.yyyyMMddHHmmssFormatter(firestore.Timestamp.now()),
    };

    firestore.DocumentReference<Map<String, dynamic>> documentReference = FirestoreController().firestore.collection(MY_POLLS_COLLECTION).doc(myPollDocumentId);

    try {
      await documentReference.update({pollId: isSet ? likeData : firestore.FieldValue.delete()});
      isSuccess = true;
    } catch (e) {
      MyPrint.printOnConsole("Error in SportiFeedController.updateMyLike():$e, Type:${e.runtimeType}");
      if (e.runtimeType == firestore.FirebaseException) {
        firestore.FirebaseException fe = e as firestore.FirebaseException;

        switch (fe.code) {
          case "not-found":
            {
              bool createDocumentIsSuccess = await documentReference.set({pollId: likeData}).then((value) {
                return true;
              }).catchError((e) {
                MyPrint.printOnConsole("Error in Creating MyLike Document in SportiFeedController.updateMyLike():$e, Type:${e.runtimeType}");
                return false;
              });
              isSuccess = createDocumentIsSuccess;
            }
        }
      }
    }

    if (isSuccess) {
      await Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false).updateMyPollsForDocument(pollId, hiveLikeData, isAdd: isSet);
    }

    return isSuccess;
  }

  Future<void> getMyLikesFromFirestoreAndStoreInHive() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    DataProvider dataProvider = Provider.of<DataProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    SportifeedProvider sportifeedProvider = Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);

    if (userProvider.userid?.isEmpty ?? true) return;

    if (dataProvider.currentTimestamp == null) {
      await DataController().getCurrentTimeStamp();
    }

    List<String> ids = [];

    for (int i = 0; i < 10; i++) {
      DateTime dateTime = dataProvider.currentTimestamp!.toDate().subtract(Duration(days: 30 * i));
      String docId = "${userProvider.userid!}_${dateTime.year}_${dateTime.month}";
      if (!ids.contains(docId)) {
        ids.add(docId);
      }
    }
    MyPrint.printOnConsole("Final Ids:$ids");

    List<Future> futures = [];
    ids.forEach((element) {
      futures.add(sportifeedProvider.fetchMyLikesMapFromFirestoreAndStoreInHive(element));
    });

    await Future.wait(futures);

    MyPrint.printOnConsole("Final My Likes:${sportifeedProvider.myLikesBox?.toMap()}");
  }

  Future<void> getMyPollsFromFirestoreAndStoreInHive() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    DataProvider dataProvider = Provider.of<DataProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    SportifeedProvider sportifeedProvider = Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);

    if (userProvider.userid?.isEmpty ?? true) {
      MyPrint.printOnConsole("User id is null or empty in SportifeedController().getMyPollsFromFirestoreAndStoreInHive()");
      return;
    }

    if (dataProvider.currentTimestamp == null) {
      await DataController().getCurrentTimeStamp();
    }

    if (dataProvider.currentTimestamp == null) return;

    List<String> ids = [];

    for (int i = 0; i < 10; i++) {
      DateTime dateTime = dataProvider.currentTimestamp!.toDate().subtract(Duration(days: 30 * i));
      String docId = "${userProvider.userid!}_${dateTime.year}_${dateTime.month}";
      if (!ids.contains(docId)) {
        ids.add(docId);
      }
    }
    MyPrint.printOnConsole("Final Ids:$ids");

    List<Future> futures = [];
    ids.forEach((element) {
      futures.add(sportifeedProvider.fetchMyPollsMapFromFirestoreAndStoreInHive(element));
    });

    await Future.wait(futures);

    MyPrint.printOnConsole("Final My Polls:${sportifeedProvider.myPollsBox?.toMap()}");
  }

  Future<CommunityModel?> getCommunityFromId(String id) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    Doc? doc = await ElasticController().getDocument(getCommunityIndex(), id);
    MyPrint.printOnConsole("Community Data For Id $id :${doc?.doc}");
    if (doc != null && doc.doc.isNotEmpty) {
      try {
        return CommunityModel.elasticFromMap(Map.castFrom(doc.doc));
      } catch (e) {
        MyPrint.printOnConsole("Error in Converting Community Data in CommunityModel:$e");
      }
    }
  }

  Future<FeedModel?> getFeedFromId(String id) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    Doc? doc = await ElasticController().getDocument(getFeedsIndex(), id);
    MyPrint.printOnConsole("Community Data For Id $id :${doc?.doc}");
    if (doc != null && doc.doc.isNotEmpty) {
      try {
        return FeedModel.elasticFromMap(Map.castFrom<dynamic, dynamic, String, dynamic>(doc.doc));
      } catch (e) {
        MyPrint.printOnConsole("Error in Converting Community Data in CommunityModel:$e");
      }
    }
  }

  //For Getting Feeds Start---------------------------------------------------------------------------------------------------
  Future<void> getFeedsListForMainPageFromOffline() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    try {
      SportifeedProvider sportifeedProvider = Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
      sportifeedProvider.feedsList.clear();

      Map<String, dynamic> map = {};

      firestore.Timestamp startTime = firestore.Timestamp.now();
      try {
        map = Map.from(Map.castFrom((await HiveManager().get(SEMBAST_FEEDS)) ?? {}));
      } catch (e) {}

      firestore.Timestamp endTime = firestore.Timestamp.now();
      MyPrint.printOnConsole('Offline Feeds Got From Offline in ${startTime.toDate().difference(endTime.toDate()).inMilliseconds} milliseconds');

      map.forEach((String key, dynamic value) {
        Map<String, dynamic> valueMap = {};

        try {
          valueMap = Map.castFrom(value ?? {});
        } catch (e) {}

        if (value?.isNotEmpty ?? false) {
          FeedModel feedModel = FeedModel.elasticFromMap(Map.castFrom(valueMap));
          sportifeedProvider.feedsList.add(feedModel);
        }
      });

      sportifeedProvider.feedsList.removeWhere((element) => sportifeedProvider.isFeedHiddenByUser(element.id));

      endTime = firestore.Timestamp.now();
      MyPrint.printOnConsole('Offline Feeds Processed From Offline in ${startTime.toDate().difference(endTime.toDate()).inMilliseconds} milliseconds');

      MyPrint.printOnConsole('Feeds List Length in Offline:${sportifeedProvider.feedsList.length}');
      sportifeedProvider.notifyListeners();
    } catch (e, s) {
      MyPrint.printOnConsole("Error in SportifeedController().getFeedsListForMainPageFromOffline():$e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> getFeedsListForMainPage(bool isRefresh, {bool withoutNotify = false, bool clearFeeds = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    BuildContext context = NavigationController.mainScreenNavigator.currentContext!;

    if (!ConnectionController().checkConnection()) {
      return;
    }

    SportifeedProvider sportifeedProvider = Provider.of<SportifeedProvider>(context, listen: false);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh");
      sportifeedProvider.hasMoreFeeds = true;
      sportifeedProvider.isFirstTimeLoadingFeeds = clearFeeds;
      sportifeedProvider.isLoadingFeeds = false;

      sportifeedProvider.isFirstTimeLoadingPinnedFeeds = true;
      sportifeedProvider.isLoadingPinnedFeeds = false;
      sportifeedProvider.hasMorePinnedFeeds = true;
      sportifeedProvider.elasticDocumentIndexPinnedFeeds = 0;
      sportifeedProvider.pinnedFeedsList.clear();

      sportifeedProvider.isFirstTimeLoadingInteractiveFeeds = true;
      sportifeedProvider.isLoadingInteractiveFeeds = false;
      sportifeedProvider.hasMoreInteractiveFeeds = true;
      sportifeedProvider.elasticDocumentIndexInteractiveFeeds = 0;
      sportifeedProvider.interactiveFeedsList.clear();

      sportifeedProvider.isFirstTimeLoadingLatestFeeds = true;
      sportifeedProvider.isLoadingLatestFeeds = false;
      sportifeedProvider.hasMoreLatestFeeds = true;
      sportifeedProvider.elasticDocumentIndexLatestFeeds = 0;
      sportifeedProvider.latestFeedsList.clear();

      sportifeedProvider.isLoadingRecentFeeds = false;
      sportifeedProvider.recentFeedsList.clear();

      if (clearFeeds) sportifeedProvider.feedsList.clear();
    }

    if (!sportifeedProvider.hasMoreFeeds || sportifeedProvider.isLoadingFeeds) return;

    sportifeedProvider.isLoadingFeeds = true;
    if (!withoutNotify) sportifeedProvider.notifyListeners();

    try {
      List<FeedModel> newPinnedFeeds = [], newNonPinnedFeeds = [];
      bool isGotPinnedFeeds = true, isGotInteractiveFeeds = true, isGotLatestFeeds = true, isGotRecentFeeds = true;

      DateTime startTime = DateTime.now();

      if (isRefresh) {
        //For Getting Pinned Feeds
        if (sportifeedProvider.hasMorePinnedFeeds && !sportifeedProvider.isLoadingPinnedFeeds) {
          isGotPinnedFeeds = false;
          sportifeedProvider.isLoadingPinnedFeeds = true;

          DateTime startTime = DateTime.now();
          getPinnedFeedsList(
            communityIds: sportifeedProvider.communities.map((e) => e.id).toList()..removeWhere((element) => element.isEmpty),
            locationRadius: sportifeedProvider.locationRadius,
            geoPoint: userProvider.userModel?.currentLocation?.geoPoint,
            documentIndex: sportifeedProvider.elasticDocumentIndexPinnedFeeds,
            documentLimit: sportifeedProvider.documentLimitPinnedFeeds,
          ).then((List<FeedModel> feeds) {
            DateTime endTime = DateTime.now();
            MyPrint.printOnConsole("Got Pinned Feeds:${feeds.length} got in ${startTime.difference(endTime).inMilliseconds} Milliseconds");

            sportifeedProvider.elasticDocumentIndexPinnedFeeds += feeds.length;

            if (feeds.length < sportifeedProvider.documentLimitPinnedFeeds) sportifeedProvider.hasMorePinnedFeeds = false;

            feeds.removeWhere((element) => sportifeedProvider.isFeedHiddenByUser(element.id));

            MyPrint.printOnConsole("Pinned Feeds List:${feeds.map((e) => "Id:${e.id}, Creater Name:${e.createdByName}, Community Id:${e.community_id}, IsPinned:${e.isPinned}, \n").toList()}");

            sportifeedProvider.pinnedFeedsList.addAll(feeds);
            MyPrint.printOnConsole("Final Pinned Feeds:${feeds.length}");

            newPinnedFeeds.addAll(feeds);
            MyPrint.printOnConsole("Added Pinned Feeds:${feeds.isNotEmpty ? feeds.first.id : ""}");

            sportifeedProvider.isLoadingPinnedFeeds = false;
            sportifeedProvider.isFirstTimeLoadingPinnedFeeds = false;

            isGotPinnedFeeds = true;
          }).catchError((e) {
            sportifeedProvider.isFirstTimeLoadingPinnedFeeds = false;
            sportifeedProvider.isLoadingPinnedFeeds = false;
            sportifeedProvider.pinnedFeedsList.clear();
            sportifeedProvider.hasMorePinnedFeeds = false;

            isGotPinnedFeeds = true;
          });
        }
      }

      //For Getting Latest Feeds
      if (sportifeedProvider.hasMoreLatestFeeds && !sportifeedProvider.isLoadingLatestFeeds) {
        isGotLatestFeeds = false;
        sportifeedProvider.isLoadingLatestFeeds = true;

        DateTime startTime = DateTime.now();
        getUserPreferedFeedsList(
          communityIds: sportifeedProvider.communities.map((e) => e.id).toList()..removeWhere((element) => element.isEmpty),
          matchedUserIds: userProvider.userModel?.my_matches ?? [],
          documentIndex: sportifeedProvider.elasticDocumentIndexLatestFeeds,
          documentLimit: sportifeedProvider.documentLimitLatestFeeds,
          geoPoint: userProvider.userModel?.currentLocation?.geoPoint,
          locationRadius: sportifeedProvider.locationRadius,
          isInteractive: false,
        ).then((List<FeedModel> feeds) async {
          DateTime endTime = DateTime.now();
          MyPrint.printOnConsole("Got Latest Feeds:${feeds.length} got in ${startTime.difference(endTime).inMilliseconds} Milliseconds");

          while (!isGotPinnedFeeds) {
            await Future.delayed(Duration(microseconds: 100));
          }

          sportifeedProvider.elasticDocumentIndexLatestFeeds += feeds.length;

          if (feeds.length < sportifeedProvider.documentLimitLatestFeeds) sportifeedProvider.hasMoreLatestFeeds = false;

          MyPrint.printOnConsole("Latest Feeds List:${feeds.map((e) => "Id:${e.id}, Creater Name:${e.createdByName}, Community Id:${e.community_id}, IsPinned:${e.isPinned}, \n").toList()}");

          sportifeedProvider.latestFeedsList.addAll(feeds);
          List<String> newFeedsIds = newPinnedFeeds.map((e) => e.id).toList();
          newFeedsIds.addAll(newNonPinnedFeeds.map((e) => e.id).toList());
          feeds.removeWhere((element) => newFeedsIds.contains(element.id));
          newNonPinnedFeeds.addAll(feeds);
          MyPrint.printOnConsole("Added Latest Feeds");

          MyPrint.printOnConsole("Final Latest Feeds:${feeds.length}");
          MyPrint.logOnConsole(
              "Final Latest Feeds List:${feeds.map((e) => "Id:${e.id}, Creater Name:${e.createdByName},Created Time:${e.createdTime != null ? DatePresentation.yyyyMMddFormatter(e.createdTime!) : null}, \n").toList()}");

          sportifeedProvider.isLoadingLatestFeeds = false;
          sportifeedProvider.isFirstTimeLoadingLatestFeeds = false;

          isGotLatestFeeds = true;
        }).catchError((e) {
          sportifeedProvider.isFirstTimeLoadingLatestFeeds = false;
          sportifeedProvider.isLoadingLatestFeeds = false;
          sportifeedProvider.latestFeedsList.clear();
          sportifeedProvider.hasMoreLatestFeeds = false;

          isGotLatestFeeds = true;
        });
      }

      //For Getting Interactive Feeds
      if (sportifeedProvider.hasMoreInteractiveFeeds && !sportifeedProvider.isLoadingInteractiveFeeds) {
        isGotInteractiveFeeds = false;
        sportifeedProvider.isLoadingInteractiveFeeds = true;

        DateTime startTime = DateTime.now();
        getUserPreferedFeedsList(
          communityIds: sportifeedProvider.communities.map((e) => e.id).toList()..removeWhere((element) => element.isEmpty),
          matchedUserIds: userProvider.userModel?.my_matches ?? [],
          documentIndex: sportifeedProvider.elasticDocumentIndexInteractiveFeeds,
          documentLimit: sportifeedProvider.documentLimitInteractiveFeeds,
          geoPoint: userProvider.userModel?.currentLocation?.geoPoint,
          locationRadius: sportifeedProvider.locationRadius,
          isInteractive: true,
        ).then((List<FeedModel> feeds) async {
          DateTime endTime = DateTime.now();
          MyPrint.printOnConsole("Got Interactive Feeds:${feeds.length} got in ${startTime.difference(endTime).inMilliseconds} Milliseconds");

          while (!isGotLatestFeeds) {
            await Future.delayed(Duration(microseconds: 100));
          }

          sportifeedProvider.elasticDocumentIndexInteractiveFeeds += feeds.length;

          if (feeds.length < sportifeedProvider.documentLimitInteractiveFeeds) sportifeedProvider.hasMoreInteractiveFeeds = false;

          feeds.removeWhere((element) => sportifeedProvider.isFeedHiddenByUser(element.id));

          MyPrint.printOnConsole("Interactive Feeds List:${feeds.map((e) => "Id:${e.id}, Creater Name:${e.createdByName}, Community Id:${e.community_id}, IsPinned:${e.isPinned}, \n").toList()}");

          sportifeedProvider.interactiveFeedsList.addAll(feeds);
          List<String> newFeedsIds = newPinnedFeeds.map((e) => e.id).toList();
          newFeedsIds.addAll(newNonPinnedFeeds.map((e) => e.id).toList());
          feeds.removeWhere((element) => newFeedsIds.contains(element.id));
          feeds.forEach((element) {
            element.isInteractiveFeed = true;
          });
          newNonPinnedFeeds.addAll(feeds);
          MyPrint.printOnConsole("Added Interactive Feeds");

          MyPrint.printOnConsole("Final Interactive Feeds:${feeds.length}");
          MyPrint.printOnConsole(
              "Final Interactive Feeds List:${feeds.map((e) => "Id:${e.id}, Creater Name:${e.createdByName}, Community Id:${e.community_id}, IsPinned:${e.isPinned}, \n").toList()}");

          sportifeedProvider.isLoadingInteractiveFeeds = false;
          sportifeedProvider.isFirstTimeLoadingInteractiveFeeds = false;

          isGotInteractiveFeeds = true;
        }).catchError((e) {
          sportifeedProvider.isFirstTimeLoadingInteractiveFeeds = false;
          sportifeedProvider.isLoadingInteractiveFeeds = false;
          sportifeedProvider.interactiveFeedsList.clear();
          sportifeedProvider.hasMoreInteractiveFeeds = false;

          isGotInteractiveFeeds = true;
        });
      }

      //For Getting Recent Feeds
      if (!sportifeedProvider.isLoadingRecentFeeds) {
        isGotRecentFeeds = false;
        sportifeedProvider.isLoadingRecentFeeds = true;

        DateTime startTime = DateTime.now();
        getUserPreferedFeedsList(
          communityIds: sportifeedProvider.communities.map((e) => e.id).toList()..removeWhere((element) => element.isEmpty),
          matchedUserIds: userProvider.userModel?.my_matches ?? [],
          documentIndex: 0,
          documentLimit: sportifeedProvider.documentLimitRecentFeeds,
          geoPoint: userProvider.userModel?.currentLocation?.geoPoint,
          locationRadius: sportifeedProvider.locationRadius,
          isRecentFeeds: true,
          isInteractive: false,
        ).then((List<FeedModel> feeds) async {
          DateTime endTime = DateTime.now();
          MyPrint.printOnConsole("Got Recent Feeds:${feeds.length} got in ${startTime.difference(endTime).inMilliseconds} Milliseconds");

          while (!isGotInteractiveFeeds) {
            await Future.delayed(Duration(microseconds: 100));
          }

          feeds.removeWhere((element) => sportifeedProvider.isFeedHiddenByUser(element.id));

          MyPrint.printOnConsole("Recent Feeds List:${feeds.map((e) => "Id:${e.id}, Creater Name:${e.createdByName}, Community Id:${e.community_id}, IsPinned:${e.isPinned}, \n").toList()}");

          sportifeedProvider.recentFeedsList.addAll(feeds);
          List<String> newFeedsIds = newPinnedFeeds.map((e) => e.id).toList();
          newFeedsIds.addAll(newNonPinnedFeeds.map((e) => e.id).toList());
          List<String> existingFeedsIds = sportifeedProvider.feedsList.map((e) => e.id).toList();
          newFeedsIds.addAll(existingFeedsIds);
          feeds.removeWhere((element) => newFeedsIds.contains(element.id));
          newNonPinnedFeeds.addAll(feeds);
          MyPrint.printOnConsole("Added Recent Feeds");

          MyPrint.printOnConsole("Final Recent Feeds:${feeds.length}");
          MyPrint.printOnConsole("Final Recent Feeds List:${feeds.map((e) => "Id:${e.id}, Creater Name:${e.createdByName}, Community Id:${e.community_id}, IsPinned:${e.isPinned}, \n").toList()}");

          sportifeedProvider.isLoadingRecentFeeds = false;

          isGotRecentFeeds = true;
        }).catchError((e) {
          sportifeedProvider.isLoadingRecentFeeds = false;
          sportifeedProvider.recentFeedsList.clear();

          isGotRecentFeeds = true;
        });
      }

      while (!isGotPinnedFeeds || !isGotInteractiveFeeds || !isGotLatestFeeds || !isGotRecentFeeds) {
        await Future.delayed(Duration(microseconds: 10));
      }

      DateTime endTime = DateTime.now();
      MyPrint.printOnConsole("Got All Feeds:${newPinnedFeeds.length} got in ${startTime.difference(endTime).inMilliseconds} Milliseconds");

      if (isRefresh) {
        sportifeedProvider.feedsList.clear();
      }

      List<FeedModel> newFeeds = [];
      newPinnedFeeds.shuffle();
      newFeeds.addAll(newPinnedFeeds);
      newNonPinnedFeeds.shuffle();
      newFeeds.addAll(newNonPinnedFeeds);

      newFeeds.removeWhere((element) => sportifeedProvider.isFeedHiddenByUser(element.id));

      //List<String> feedsIds = sportifeedProvider.feedsList.map((e) => e.id).toList();
      //if(feedsIds.isNotEmpty) newFeeds.removeWhere((element) => feedsIds.contains(element.id));
      sportifeedProvider.feedsList.addAll(newFeeds);
      MyPrint.printOnConsole("First Feed In All Feeds List::${sportifeedProvider.feedsList.isNotEmpty ? sportifeedProvider.feedsList.first.id : ""}");

      //To Store In Offline
      if (isRefresh /*&& sportifeedProvider.feedsList.isNotEmpty*/) {
        Map<String, dynamic> offlineFeeds = {};
        int length = (sportifeedProvider.feedsList.length >= sportifeedProvider.offlineFeedsCount ? sportifeedProvider.offlineFeedsCount : sportifeedProvider.feedsList.length);
        for (int i = 0; i < length; i++) {
          FeedModel feedModel = sportifeedProvider.feedsList[i];
          offlineFeeds[feedModel.id] = feedModel.elasticToMap();
        }
        firestore.Timestamp startTime = firestore.Timestamp.now();
        await HiveManager().set(SEMBAST_FEEDS, offlineFeeds);
        firestore.Timestamp endTime = firestore.Timestamp.now();
        MyPrint.printOnConsole('Offline Feeds Set in ${startTime.toDate().difference(endTime.toDate()).inMilliseconds} Milliseconds');

        /*startTime = firestore.Timestamp.now();
        dynamic value = await HiveManager().get(SEMBAST_FEEDS);
        endTime = firestore.Timestamp.now();
        MyPrint.printOnConsole('Offline Feeds Got in ${startTime.toDate().difference(endTime.toDate()).inMilliseconds} Milliseconds');
        MyPrint.printOnConsole("Offline Feeds:${value}");*/
      }

      MyPrint.printOnConsole("hasMorePinnedFeeds:${sportifeedProvider.hasMorePinnedFeeds}");
      MyPrint.printOnConsole("hasMoreInteractiveFeeds:${sportifeedProvider.hasMoreInteractiveFeeds}");
      MyPrint.printOnConsole("hasMoreLatestFeeds:${sportifeedProvider.hasMoreLatestFeeds}");

      sportifeedProvider.hasMoreFeeds = sportifeedProvider.hasMorePinnedFeeds || sportifeedProvider.hasMoreInteractiveFeeds || sportifeedProvider.hasMoreLatestFeeds;
      MyPrint.printOnConsole("hasMoreFeeds:${sportifeedProvider.hasMoreFeeds}");

      sportifeedProvider.isLoadingFeeds = false;
      sportifeedProvider.isFirstTimeLoadingFeeds = false;
      sportifeedProvider.notifyListeners();
      MyPrint.printOnConsole("Feeds Length : ${sportifeedProvider.feedsList.length}");
    } catch (e) {
      MyPrint.printOnConsole("Error:" + e.toString());
      sportifeedProvider.hasMoreFeeds = true;
      sportifeedProvider.isFirstTimeLoadingFeeds = true;
      sportifeedProvider.isLoadingFeeds = false;

      sportifeedProvider.isFirstTimeLoadingPinnedFeeds = true;
      sportifeedProvider.isLoadingPinnedFeeds = false;
      sportifeedProvider.hasMorePinnedFeeds = true;
      sportifeedProvider.elasticDocumentIndexPinnedFeeds = 0;
      sportifeedProvider.pinnedFeedsList.clear();

      sportifeedProvider.isFirstTimeLoadingInteractiveFeeds = true;
      sportifeedProvider.isLoadingInteractiveFeeds = false;
      sportifeedProvider.hasMoreInteractiveFeeds = true;
      sportifeedProvider.elasticDocumentIndexInteractiveFeeds = 0;
      sportifeedProvider.interactiveFeedsList.clear();

      sportifeedProvider.isFirstTimeLoadingLatestFeeds = true;
      sportifeedProvider.isLoadingLatestFeeds = false;
      sportifeedProvider.hasMoreLatestFeeds = true;
      sportifeedProvider.elasticDocumentIndexLatestFeeds = 0;
      sportifeedProvider.latestFeedsList.clear();

      if (clearFeeds) sportifeedProvider.feedsList.clear();
      sportifeedProvider.notifyListeners();
    }
  }

  Future<void> getFeedsListForSportiScoopCommunity({required BuildContext context, required bool isRefresh, bool withoutNotify = false}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    if (!ConnectionController().checkConnection()) {
      return;
    }

    SportifeedProvider sportifeedProvider = Provider.of<SportifeedProvider>(context, listen: false);

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh");

      sportifeedProvider.isFirstTimeLoadingSportiScoopFeeds = true;
      sportifeedProvider.isLoadingSportiScoopFeeds = false;
      sportifeedProvider.hasMoreSportiScoopFeeds = true;
      sportifeedProvider.elasticDocumentSportiScoopFeeds = 0;
      sportifeedProvider.sportiScoopFeedsList.clear();

      if (!withoutNotify) {
        sportifeedProvider.notifyListeners();
      }
    }

    try {
      if (!sportifeedProvider.hasMoreSportiScoopFeeds || sportifeedProvider.isLoadingSportiScoopFeeds) return;

      sportifeedProvider.isLoadingSportiScoopFeeds = true;
      if (!withoutNotify) {
        sportifeedProvider.notifyListeners();
      }

      DateTime startTime = DateTime.now();

      List<FeedModel> feeds = await FeedController().getUserPreferedFeedsList(
        communityIds: [Messages.sportiscoop],
        matchedUserIds: [],
        documentIndex: sportifeedProvider.elasticDocumentSportiScoopFeeds,
        documentLimit: sportifeedProvider.documentLimitSportiScoopFeeds,
        locationRadius: 0,
        isInteractive: false,
      );

      sportifeedProvider.elasticDocumentSportiScoopFeeds += feeds.length;

      if (feeds.length < sportifeedProvider.documentLimitSportiScoopFeeds) sportifeedProvider.hasMoreSportiScoopFeeds = false;

      DateTime endTime = DateTime.now();
      MyPrint.printOnConsole("Got SportiScoop Feeds:${feeds.length} got in ${startTime.difference(endTime).inMilliseconds} Milliseconds");

      feeds.removeWhere((element) => sportifeedProvider.isFeedHiddenByUser(element.id));

      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      String userid = userProvider.userid ?? "";
      if (userid.isNotEmpty) {
        feeds.removeWhere((element) {
          return element.id.isNotEmpty && sportifeedProvider.isFeedHiddenByUser(element.id) && element.createdById != userid;
        });
      }
      sportifeedProvider.sportiScoopFeedsList.addAll(feeds);

      sportifeedProvider.isLoadingSportiScoopFeeds = false;
      sportifeedProvider.isFirstTimeLoadingSportiScoopFeeds = false;
      sportifeedProvider.notifyListeners();
      MyPrint.printOnConsole("Feeds Length : ${sportifeedProvider.sportiScoopFeedsList.length}");
    } catch (e, s) {
      MyPrint.printOnConsole("Error:" + e.toString());

      AnalyticsController().recordError(e, s, reason: "Error in SportiFeedController().getFeedsListForSportiScoopCommunity()");

      sportifeedProvider.isFirstTimeLoadingSportiScoopFeeds = true;
      sportifeedProvider.isLoadingSportiScoopFeeds = false;
      sportifeedProvider.hasMoreSportiScoopFeeds = true;
      sportifeedProvider.elasticDocumentSportiScoopFeeds = 0;
      sportifeedProvider.sportiScoopFeedsList.clear();
      sportifeedProvider.notifyListeners();
    }
  }

  Future<void> getUserPreferedCommunitiesFromOffline() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    MyPrint.printOnConsole("getUserPreferedCommunitiesFromOffline called");

    try {
      SportifeedProvider sportifeedProvider = Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
      sportifeedProvider.communities.clear();
      sportifeedProvider.communities.add(CommunityModel(name: "My Feeds"));
      sportifeedProvider.communities.add(CommunityModel(name: Messages.sportiscoop, id: Messages.sportiscoop));

      Map<String, dynamic> map = {};

      firestore.Timestamp startTime = firestore.Timestamp.now();
      try {
        map = Map.from(Map.castFrom((await HiveManager().get(SEMBAST_COMMUNITIES)) ?? {}));
      } catch (e) {}

      firestore.Timestamp endTime = firestore.Timestamp.now();
      MyPrint.printOnConsole('Offline Communities Got From Offline in ${startTime.toDate().difference(endTime.toDate()).inMilliseconds} milliseconds');

      map.forEach((String key, dynamic value) {
        Map<String, dynamic> valueMap = {};

        try {
          valueMap = Map.castFrom(value ?? {});
        } catch (e) {}

        if (value?.isNotEmpty ?? false) {
          CommunityModel communityModel = CommunityModel.elasticFromMap(Map.castFrom(valueMap));
          sportifeedProvider.communities.add(communityModel);
        }
      });

      endTime = firestore.Timestamp.now();
      MyPrint.printOnConsole('Offline Communities Processed From Offline in ${startTime.toDate().difference(endTime.toDate()).inMilliseconds} milliseconds');

      MyPrint.printOnConsole('Communities List Length in Offline:${sportifeedProvider.communities.length}');
      sportifeedProvider.notifyListeners();
    } catch (e, s) {
      MyPrint.printOnConsole("Error in SportifeedController().getUserPreferedCommunitiesFromOffline():$e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> getUserPreferedCommunities() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    MyPrint.printOnConsole("getUserPreferedCommunities called}");

    if (!ConnectionController().checkConnection()) {
      return;
    }

    SportifeedProvider sportifeedProvider = Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);

    List<CommunityModel> communities = [
      CommunityModel(
        name: "My Feeds",
      ),
      CommunityModel(name: Messages.sportiscoop, id: Messages.sportiscoop),
    ];

    List<String> interests = [];
    interests.addAll((userProvider.userModel?.interests2 ?? {}).keys.toList());
    MyPrint.printOnConsole("Interests for community search:$interests");

    if (interests.isNotEmpty) {
      sportifeedProvider.isLoadingCommunity = true;
      sportifeedProvider.notifyListeners();

      List<Map<String, dynamic>> should = [];

      interests.forEach((element) {
        should.add({
          "exists": {"field": "interests2.$element"},
        });
      });

      Map<String, dynamic> query = {
        "bool": {
          "must": {
            "bool": {
              "should": should,
            }
          },
        }
      };
      MyPrint.printOnConsole("Final Community Query:$query");

      SearchResult searchResult = await ElasticController().client.search(
            index: getCommunityIndex(),
            size: 10000,
            query: query,
          );

      MyPrint.printOnConsole("Get Community Result:${searchResult.hits.length}");

      Map<String, dynamic> offlineCommunities = {};

      searchResult.hits.forEach((element) {
        MyPrint.printOnConsole("Data:${element.doc}");
        CommunityModel communityModel = CommunityModel.elasticFromMap(Map.castFrom(element.doc));
        communities.add(communityModel);

        offlineCommunities[communityModel.id] = communityModel.elasticToMap();
      });

      firestore.Timestamp startTime = firestore.Timestamp.now();
      await HiveManager().set(SEMBAST_COMMUNITIES, offlineCommunities);
      firestore.Timestamp endTime = firestore.Timestamp.now();
      MyPrint.printOnConsole('Offline Communities Set in ${startTime.toDate().difference(endTime.toDate()).inMilliseconds} Milliseconds');
    }

    sportifeedProvider.isLoadingCommunity = false;
    sportifeedProvider.communities = communities;
    sportifeedProvider.notifyListeners();
  }

  Future<List<FeedModel>> getUserPreferedFeedsList({
    required int documentIndex,
    required List<String> communityIds,
    required List<String> matchedUserIds,
    required int documentLimit,
    firestore.GeoPoint? geoPoint,
    required int locationRadius,
    bool isRecentFeeds = false,
    bool isInteractive = false,
  }) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("FeedController().createFeed() called with requestModel:'$requestModel'", tag: tag);

    MyPrint.printOnConsole("getUserPreferedFeedsList called with isInteractive:$isInteractive, isRecentFeeds:$isRecentFeeds");

    if (communityIds.isEmpty && matchedUserIds.isEmpty) return [];

    ReceivePort receivePort = ReceivePort();
    Isolate newIsolate = await Isolate.spawn(
      getUserPreferedFeedsIsolateMethod,
      receivePort.sendPort,
    );

    //Second Transaction(Receiving Sendport From Isolate Method)
    dynamic value = await receivePort.first;
    SendPort newIsolateSendPort = value as SendPort;
    MyPrint.printOnConsole("NewIsolateSendPort Received");

    ReceivePort responsePort = ReceivePort();
    //Third Transaction(Sending Data on Isolate's Sendport)
    newIsolateSendPort.send([
      documentIndex,
      documentLimit,
      matchedUserIds,
      communityIds,
      geoPoint,
      locationRadius,
      isRecentFeeds,
      isInteractive, //For Not Getting Interactive Users
      responsePort.sendPort,
      AppController().isDev,
    ]);

    dynamic value2 = await responsePort.first;

    List<FeedModel> feeds = List.from(value2);

    //To Get Data Of User and Venue In Provider If Not Exist
    FeedUserProvider feedUserProvider = Provider.of<FeedUserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    FeedVenueProvider feedVenueProvider = Provider.of<FeedVenueProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    feeds.forEach((FeedModel feedModel) {
      MyPrint.printOnConsole("Feed Id:${feedModel.id}");
      if (feedModel.createdById.isNotEmpty) {
        feedUserProvider.userdata[feedModel.createdById] = UserModel(
          id: feedModel.createdById,
          name: feedModel.createdByName,
          images: feedModel.createdByImage.isNotEmpty ? [feedModel.createdByImage] : [],
        );
      }
      if (feedModel.feedVenueMetaModel.venueId.isNotEmpty) {
        feedVenueProvider.venuedata[feedModel.feedVenueMetaModel.venueId] = VenueModel(
          id: feedModel.feedVenueMetaModel.venueId,
          title: feedModel.feedVenueMetaModel.venueName,
          owners: {},
          otherFacilites: [],
          documentList: [],
          imageList: [],
          offers: [],
          days: {},
        );
      }
    });

    return feeds;
  }

  Future<List<FeedModel>> getFeedsListFromHashtag({required List<String> hashtag, required int documentIndex, required int documentLimit}) async {
    MyPrint.printOnConsole("getFeedsListFromHashtag called with hashtag:$hashtag");

    if (hashtag.isEmpty) return [];

    ReceivePort receivePort = ReceivePort();
    Isolate newIsolate = await Isolate.spawn(
      getFeedsFromHashtagIsolateMethod,
      receivePort.sendPort,
    );

    //Second Transaction(Receiving Sendport From Isolate Method)
    dynamic value = await receivePort.first;
    SendPort newIsolateSendPort = value as SendPort;
    MyPrint.printOnConsole("NewIsolateSendPort Received");

    ReceivePort responsePort = ReceivePort();
    //Third Transaction(Sending Data on Isolate's Sendport)
    newIsolateSendPort.send([
      documentIndex,
      documentLimit,
      hashtag,
      responsePort.sendPort,
      AppController().isDev,
    ]);

    dynamic value2 = await responsePort.first;

    List<FeedModel> feeds = List.from(value2);

    //To Get Data Of User and Venue In Provider If Not Exist
    FeedUserProvider feedUserProvider = Provider.of<FeedUserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    FeedVenueProvider feedVenueProvider = Provider.of<FeedVenueProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    feeds.forEach((FeedModel feedModel) {
      MyPrint.printOnConsole("Feed Id:${feedModel.id}");
      if (feedModel.createdById.isNotEmpty) {
        feedUserProvider.userdata[feedModel.createdById] = UserModel(
          id: feedModel.createdById,
          name: feedModel.createdByName,
          images: feedModel.createdByImage.isNotEmpty ? [feedModel.createdByImage] : [],
        );
      }
      if (feedModel.feedVenueMetaModel.venueId.isNotEmpty) {
        feedVenueProvider.venuedata[feedModel.feedVenueMetaModel.venueId] = VenueModel(
          id: feedModel.feedVenueMetaModel.venueId,
          title: feedModel.feedVenueMetaModel.venueName,
          owners: {},
          otherFacilites: [],
          documentList: [],
          imageList: [],
          offers: [],
          days: {},
        );
      }
    });

    return feeds;
  }

  Future<void> getMyFeedsList(BuildContext context, bool isRefresh, {bool withoutNotify = false}) async {
    MyPrint.printOnConsole("getMyFeedsList called with refresh:$isRefresh");

    if (!ConnectionController().checkConnection()) {
      return;
    }

    SportifeedProvider sportifeedProvider = Provider.of<SportifeedProvider>(context, listen: false);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    MyPrint.printOnConsole("----------------${userProvider.userid}");

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh");
      sportifeedProvider.isMyFeedsFirstTimeLoading = true;
      sportifeedProvider.isMyFeedsLoading = false; // track if venues fetching
      sportifeedProvider.myFeedsHasMore = true; // flag for more products available or not
      sportifeedProvider.myFeedsElasticDocumentIndex = 0;
      sportifeedProvider.myFeedsList.clear();

      if (!withoutNotify) sportifeedProvider.notifyListeners();
    }
    MyPrint.printOnConsole("sportifeedProvider.myFeedsList:${sportifeedProvider.myFeedsList.length}");

    try {
      if (!sportifeedProvider.myFeedsHasMore || sportifeedProvider.isMyFeedsLoading) return;

      sportifeedProvider.isMyFeedsLoading = true;
      if (!withoutNotify) sportifeedProvider.notifyListeners();

      ReceivePort receivePort = ReceivePort();

      Isolate newIsolate = await Isolate.spawn(
        getUserFeedsIsolateMethod,
        receivePort.sendPort,
      );

      //Second Transaction(Receiving Sendport From Isolate Method)
      dynamic value = await receivePort.first;
      SendPort newIsolateSendPort = value as SendPort;
      MyPrint.printOnConsole("NewIsolateSendPort Received");

      ReceivePort responsePort = ReceivePort();
      //Third Transaction(Sending Data on Isolate's Sendport)
      MyPrint.printOnConsole("----------------${userProvider.userid}");
      newIsolateSendPort.send([
        sportifeedProvider.myFeedsElasticDocumentIndex,
        sportifeedProvider.myFeedsDocumentLimit,
        userProvider.userid ?? "",
        true,
        responsePort.sendPort,
        AppController().isDev,
      ]);

      dynamic value2 = await responsePort.first;

      List<FeedModel> feeds = List.from(value2);
      MyPrint.printOnConsole("New Feeds Length:${feeds.length}");

      FeedUserProvider feedUserProvider = Provider.of<FeedUserProvider>(context, listen: false);
      FeedVenueProvider feedVenueProvider = Provider.of<FeedVenueProvider>(context, listen: false);

      feeds.forEach((FeedModel feedModel) {
        if (feedModel.createdById.isNotEmpty) {
          feedUserProvider.userdata[feedModel.createdById] = UserModel(
            id: feedModel.createdById,
            name: feedModel.createdByName,
            images: feedModel.createdByImage.isNotEmpty ? [feedModel.createdByImage] : [],
          );
        }
        if (feedModel.feedVenueMetaModel.venueId.isNotEmpty) {
          feedVenueProvider.venuedata[feedModel.feedVenueMetaModel.venueId] = VenueModel(
            id: feedModel.feedVenueMetaModel.venueId,
            title: feedModel.feedVenueMetaModel.venueName,
            owners: {},
            otherFacilites: [],
            documentList: [],
            imageList: [],
            offers: [],
            days: {},
          );
        }
      });

      sportifeedProvider.myFeedsElasticDocumentIndex += feeds.length;

      if (feeds.length < sportifeedProvider.myFeedsDocumentLimit) sportifeedProvider.myFeedsHasMore = false;

      MyPrint.printOnConsole("Feeds Length : ${feeds.length}");
      MyPrint.printOnConsole("My Feeds Length Before Adding : ${sportifeedProvider.myFeedsList.length}");
      sportifeedProvider.myFeedsList.addAll(feeds);
      MyPrint.printOnConsole("My Feeds Length After Adding : ${sportifeedProvider.myFeedsList.length}");

      sportifeedProvider.isMyFeedsLoading = false;
      sportifeedProvider.isMyFeedsFirstTimeLoading = false;
      sportifeedProvider.notifyListeners();
      MyPrint.printOnConsole("My Feeds Length : ${sportifeedProvider.myFeedsList.length}");
    } catch (e, s) {
      MyPrint.printOnConsole("Error:" + e.toString());
      MyPrint.printOnConsole(s);
      sportifeedProvider.isMyFeedsFirstTimeLoading = false;
      sportifeedProvider.isMyFeedsLoading = false;
      sportifeedProvider.myFeedsList.clear();
      sportifeedProvider.myFeedsHasMore = false;
      sportifeedProvider.notifyListeners();
    }
  }

  Future<List<FeedModel>> getPinnedFeedsList(
      {required int documentIndex, required List<String> communityIds, firestore.GeoPoint? geoPoint, required int locationRadius, required int documentLimit}) async {
    MyPrint.printOnConsole("getUserPreferedPinnedFeedsList called");

    if (communityIds.isEmpty) return [];

    try {
      ReceivePort receivePort = ReceivePort();
      Isolate newIsolate = await Isolate.spawn(
        getUserPreferedPinnedFeedsIsolateMethod,
        receivePort.sendPort,
      );

      //Second Transaction(Receiving Sendport From Isolate Method)
      dynamic value = await receivePort.first;
      SendPort newIsolateSendPort = value as SendPort;
      MyPrint.printOnConsole("NewIsolateSendPort Received");

      ReceivePort responsePort = ReceivePort();
      //Third Transaction(Sending Data on Isolate's Sendport)
      newIsolateSendPort.send([
        documentIndex,
        documentLimit,
        communityIds,
        geoPoint,
        locationRadius,
        responsePort.sendPort,
        AppController().isDev,
      ]);

      dynamic value2 = await responsePort.first;

      List<FeedModel> feeds = List.from(value2);

      //To Get Data Of User and Venue In Provider If Not Exist
      FeedUserProvider feedUserProvider = Provider.of<FeedUserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
      FeedVenueProvider feedVenueProvider = Provider.of<FeedVenueProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
      feeds.forEach((FeedModel feedModel) {
        MyPrint.printOnConsole("Feed Id:${feedModel.id}");
        if (feedModel.createdById.isNotEmpty) {
          feedUserProvider.userdata[feedModel.createdById] = UserModel(
            id: feedModel.createdById,
            name: feedModel.createdByName,
            images: feedModel.createdByImage.isNotEmpty ? [feedModel.createdByImage] : [],
          );
        }
        if (feedModel.feedVenueMetaModel.venueId.isNotEmpty) {
          feedVenueProvider.venuedata[feedModel.feedVenueMetaModel.venueId] = VenueModel(
            id: feedModel.feedVenueMetaModel.venueId,
            title: feedModel.feedVenueMetaModel.venueName,
            owners: {},
            otherFacilites: [],
            documentList: [],
            imageList: [],
            offers: [],
            days: {},
          );
        }
      });

      return feeds;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in SportiFeedController().getUserPreferedPinnedFeedsList():$e");
      MyPrint.printOnConsole(s);
      return [];
    }
  }

  //For Getting Feeds End---------------------------------------------------------------------------------------------------

  //Comments Section Starts--------------------------------------------------------------------------------------------------------------------------------------------------

  Future<bool> createComment(FeedCommentModel commentModel, String feedId, {bool isUpdateFeedLastComment = false, bool isUpdateCommentFirstComment = false}) async {
    bool isSuccess = false;

    firestore.Timestamp timestamp = await DataController().getNewTimeStamp();
    commentModel.createdTime = timestamp;
    commentModel.editedTime = timestamp;

    try {
      int i = 0, maxCount = 2;
      Function whenComplete = () => i++;

      FirestoreController().firestore.collection(COMMENT_COLLECTION).doc(commentModel.id).set(commentModel.toMap()).whenComplete(() {
        whenComplete();
      });
      ElasticController().createDocument(getCommentsIndex(), commentModel.id, commentModel.elasticToMap()).whenComplete(() {
        whenComplete();
      });

      if (feedId.isNotEmpty) {
        firestore.DocumentReference<Map<String, dynamic>> documentReference = FirestoreController().firestore.collection(FEED_COLLECTION).doc(feedId);

        maxCount++;
        documentReference.get().then((firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
          if (documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
            try {
              Map<String, dynamic> firebaseData = {
                "commentsCount": firestore.FieldValue.increment(1),
                "totalInteractionCount": firestore.FieldValue.increment(1),
              };
              if (isUpdateFeedLastComment) {
                firebaseData['lastComment'] = commentModel.toMap();
              }

              await documentReference.update(firebaseData);
              whenComplete();
              documentSnapshot = await documentReference.get();
              FeedModel feedModel = FeedModel.fromMap(Map.castFrom(documentSnapshot.data() ?? {}));
              String feedImageUrl = "";
              if ((feedModel.feedDataModel is ImageFeedDataModel) && (feedModel.feedDataModel as ImageFeedDataModel).images.isNotEmpty) {
                feedImageUrl = (feedModel.feedDataModel as ImageFeedDataModel).images[0].image_url;
              }
              ImageFeedDataModel imageFeedDataModel = ImageFeedDataModel();
              if ((feedModel.feedDataModel is ImageFeedDataModel)) {
                imageFeedDataModel = (feedModel.feedDataModel as ImageFeedDataModel);
              }
              // MyPrint.printOnConsole();
              //To Stop Updating notification when i post comment on my feed
              if (commentModel.createdById != feedModel.createdById) {
                NotificationController().sendFeedUpdateNotification(
                  feedId: feedModel.id,
                  otheruserid: feedModel.createdById,
                  actionType: isUpdateFeedLastComment ? 2 : 3,
                  // feedImage: feedImageUrl,
                  feedImage: (imageFeedDataModel.images.isNotEmpty) ? imageFeedDataModel.images[0].image_url : "",

                  likeCount: feedModel.likesCount,
                  commentCount: feedModel.commentsCount,
                  comment: commentModel.comment,
                  imageFeedDataModel: imageFeedDataModel,
                );
              }

              try {
                ElasticController().updateDocument(getFeedsIndex(), feedId, {
                  "commentsCount": feedModel.commentsCount,
                  "totalInteractionCount": feedModel.totalInteractionCount,
                  "lastComment": feedModel.lastComment?.elasticToMap(),
                });
              } catch (e) {
                MyPrint.printOnConsole("Error in Updating LastComment in Feed in Elastic:$e");
              }
            } catch (e) {
              MyPrint.printOnConsole("Error in Updating LastComment in Feed in Firestore:$e");
            }
          }
        });
      }

      if (commentModel.parentId.isNotEmpty) {
        firestore.DocumentReference<Map<String, dynamic>> documentReference = FirestoreController().firestore.collection(COMMENT_COLLECTION).doc(commentModel.parentId);

        maxCount++;
        documentReference.get().then((firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
          if (documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
            FeedCommentModel feedCommentModel = FeedCommentModel.fromMap(documentSnapshot.data()!);

            Map<String, dynamic> data = {
              "commentsCount": firestore.FieldValue.increment(1),
            };

            if (isUpdateCommentFirstComment && feedCommentModel.firstComment == null) {
              data["firstComment"] = commentModel.toMap();
            }

            try {
              await documentReference.update(data);
              documentSnapshot = await documentReference.get();
              FeedCommentModel model = FeedCommentModel.fromMap(Map.castFrom(documentSnapshot.data() ?? {}));

              try {
                await ElasticController().updateDocument(getCommentsIndex(), commentModel.parentId, {
                  "firstComment": model.firstComment?.elasticToMap(),
                  "commentsCount": model.commentsCount,
                });
              } catch (e) {
                MyPrint.printOnConsole("Error in Updating FirstComment in Comment in Elastic:$e");
              }
            } catch (e) {
              MyPrint.printOnConsole("Error in Updating FirstComment in Comment in Firestore:$e");
            }
          }

          whenComplete();
        });
      }

      while (i < maxCount) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      isSuccess = true;
    } catch (e) {
      MyPrint.printOnConsole('Error in Create Comment:$e');
    }

    return isSuccess;
  }

  Future<bool> editComment(FeedCommentModel commentModel, {bool isUpdateFeedLastComment = false, bool isUpdateCommentFirstComment = false}) async {
    bool isSuccess = false;

    firestore.Timestamp timestamp = await DataController().getNewTimeStamp();
    commentModel.editedTime = timestamp;

    try {
      int i = 0, maxCount = 2;
      Function whenComplete = () => i++;

      FirestoreController().firestore.collection(COMMENT_COLLECTION).doc(commentModel.id).update(commentModel.toMap()).whenComplete(() {
        whenComplete();
      });
      ElasticController().updateDocument(getCommentsIndex(), commentModel.id, commentModel.elasticToMap()).whenComplete(() {
        whenComplete();
      });

      if (isUpdateFeedLastComment) {
        if (commentModel.parentId.isNotEmpty) {
          firestore.DocumentReference<Map<String, dynamic>> documentReference = FirestoreController().firestore.collection(FEED_COLLECTION).doc(commentModel.parentId);
          documentReference.get().then((firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
            if (documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
              FeedModel feedModel = FeedModel.fromMap(Map.castFrom(documentSnapshot.data() ?? {}));

              if (feedModel.lastComment?.id == commentModel.id) {
                try {
                  await documentReference.update({"lastComment": commentModel.toMap()});
                  documentSnapshot = await documentReference.get();
                  FeedModel feedModel = FeedModel.fromMap(Map.castFrom(documentSnapshot.data() ?? {}));

                  try {
                    await ElasticController().updateDocument(getFeedsIndex(), commentModel.parentId, {"lastComment": feedModel.lastComment?.elasticToMap()});
                  } catch (e) {
                    MyPrint.printOnConsole("Error in Updating LastComment in Feed in Elastic:$e");
                  }
                } catch (e) {
                  MyPrint.printOnConsole("Error in Updating LastComment in Feed in Firestore:$e");
                }
              }
            }
          });
        }
      }

      if (isUpdateCommentFirstComment) {
        if (commentModel.parentId.isNotEmpty) {
          firestore.DocumentReference<Map<String, dynamic>> documentReference = FirestoreController().firestore.collection(COMMENT_COLLECTION).doc(commentModel.parentId);
          documentReference.get().then((firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
            if (documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
              FeedCommentModel feedCommentModel = FeedCommentModel.fromMap(documentSnapshot.data()!);

              if (feedCommentModel.firstComment?.id == commentModel.id) {
                try {
                  await documentReference.update({"firstComment": commentModel.toMap()});
                  documentSnapshot = await documentReference.get();
                  FeedCommentModel model = FeedCommentModel.fromMap(Map.castFrom(documentSnapshot.data() ?? {}));

                  try {
                    await ElasticController().updateDocument(getCommentsIndex(), commentModel.parentId, {"firstComment": model.firstComment?.elasticToMap()});
                  } catch (e) {
                    MyPrint.printOnConsole("Error in Updating FirstComment in Comment in Elastic:$e");
                  }
                } catch (e) {
                  MyPrint.printOnConsole("Error in Updating FirstComment in Comment in Firestore:$e");
                }
              }
            }
          });
        }
      }

      while (i < maxCount) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      isSuccess = true;
    } catch (e) {
      MyPrint.printOnConsole('Error in Edit Comment:$e');
    }

    return isSuccess;
  }

  Future<List<FeedCommentModel>> getCommentsList({required int documentIndex, int size = 10, required String parentId, bool isDescending = true}) async {
    MyPrint.printOnConsole('getCommentsList called with parentId:$parentId');

    if (parentId.isEmpty || documentIndex < 0) return [];

    ReceivePort receivePort = ReceivePort();
    Isolate newIsolate = await Isolate.spawn(
      getCommentsIsolateMethod,
      receivePort.sendPort,
    );

    //Second Transaction(Receiving Sendport From Isolate Method)
    dynamic value = await receivePort.first;
    SendPort newIsolateSendPort = value as SendPort;
    MyPrint.printOnConsole("NewIsolateSendPort Received");

    ReceivePort responsePort = ReceivePort();
    //Third Transaction(Sending Data on Isolate's Sendport)
    newIsolateSendPort.send([
      documentIndex,
      size,
      parentId,
      isDescending,
      responsePort.sendPort,
      AppController().isDev,
    ]);

    dynamic value2 = await responsePort.first;

    List<FeedCommentModel> comments = List.from(value2);

    return comments;
  }

  Future<void> checkAndUpdateUserdataInFeedsAndComments({required String userid, required String name, required String imageUrl}) async {
    if (userid.isEmpty || (name.isEmpty && imageUrl.isEmpty)) return;

    bool? lastUserDataUpdated = await SharedPrefManager().getBool(LAST_USER_DATA_UPDATED);

    if (lastUserDataUpdated != null) {
      bool isSuccess = await updateUserdataInFeedsAndComments(userid, newName: name, newImageUrl: imageUrl);
    }
  }

  Future<bool> updateUserdataInFeedsAndComments(String userid, {String newName = "", String newImageUrl = ""}) async {
    MyPrint.printOnConsole("updateUserdataInComments called with userid:$userid, newName:$newName, newImageUrl:$newImageUrl");
    if (userid.isEmpty || (newName.isEmpty && newImageUrl.isEmpty)) return false;

    await SharedPrefManager().setBool(LAST_USER_DATA_UPDATED, true);

    String url1 = getElasticSearchUrl() + "${getFeedsIndex()}/_update_by_query?refresh=true&timeout=2m";
    String url2 = getElasticSearchUrl() + "${getCommentsIndex()}/_update_by_query?refresh=true&timeout=2m";
    MyPrint.printOnConsole("Url:$url1");

    Map<String, String> header = {
      "Authorization": getElasticSearchBasicAuth(),
      "Content-Type": "application/json",
    };

    String source = "";
    if (newName.isNotEmpty) {
      source += "ctx._source['createdByName']='$newName';";
    }
    if (newImageUrl.isNotEmpty) {
      source += "ctx._source['createdByImage']='$newImageUrl';";
    }

    Map<String, dynamic> body = {
      "script": {"source": source, "lang": "painless"},
      "query": {
        "match": {"createdById": "$userid"}
      }
    };

    try {
      bool isFeedsUpdateSuccessfull = false;
      bool isCommentsUpdateSuccessfull = false;

      await Future.wait([
        http.post(Uri.parse(url1), headers: header, body: jsonEncode(body)).then((http.Response response) {
          isFeedsUpdateSuccessfull = true;
          MyPrint.printOnConsole("Update Document Response For updateUserdataInFeeds, Status${response.statusCode}, Body:${response.body}");
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Updating UserdataInFeeds:$e");
        }),
        http.post(Uri.parse(url2), headers: header, body: jsonEncode(body)).then((http.Response response) {
          isCommentsUpdateSuccessfull = true;
          MyPrint.printOnConsole("Update Document Response For updateUserdataInComments, Status${response.statusCode}, Body:${response.body}");
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Updating UserdataInComments:$e");
        }),
      ]);

      MyPrint.printOnConsole("isFeedsUpdateSuccessfull:$isFeedsUpdateSuccessfull");
      MyPrint.printOnConsole("isCommentsUpdateSuccessfull:$isCommentsUpdateSuccessfull");

      await SharedPrefManager().clearKey(LAST_USER_DATA_UPDATED);

      bool isUpdated = isFeedsUpdateSuccessfull && isCommentsUpdateSuccessfull;

      if (isUpdated) {
        FeedUserProvider feedUserProvider = Provider.of(NavigationController.mainScreenNavigator.currentContext!, listen: false);
        if (feedUserProvider.userdata[userid] != null) {
          UserModel userModel = feedUserProvider.userdata[userid]!;
          userModel.name = newName;
          if ((userModel.images ?? []).isNotEmpty) {
            userModel.images!
              ..removeAt(0)
              ..insert(0, newImageUrl);
          } else {
            userModel.images = [newName];
          }
          feedUserProvider.notifyListeners();
        }
      }

      return isUpdated;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in SportiFeedController().updateUserdataInFeedsAndComments():$e");
      MyPrint.printOnConsole(s);
      return false;
    }
  }

  //Comments Section Ends---------------------------------------------------------------------------------------------------------------------------------------------------

  Future<List<MyMention>> onSearchMention(List<String> terms) async {
    MyPrint.printOnConsole("onSearchMention called with term:'$terms'");

    SportifeedProvider sportifeedProvider = Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);

    if ((terms.isNotEmpty && !terms.contains("")) || (sportifeedProvider.mentionsMap.isEmpty && (terms.isEmpty || terms.contains("")))) {
      UserProvider userProvider = Provider.of<UserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);

      List<UserModel> usermodels = await SportinityController().getUsersDocsListFromNameSearchAndMyFriend(
        searchUserNames: terms,
        myuserid: userProvider.userModel?.id ?? "",
        isSearchByMyFriend: true,
        shouldMyFriend: true,
        isGetFromElastic: true,
      );
      usermodels.forEach((element) {
        String username = element.userName ?? "";
        MyPrint.printOnConsole("Username:$username");
        if (username.isNotEmpty) {
          String userImage = noUserImageUrl;
          try {
            List<String> images = element.images ?? [];
            if (images.isNotEmpty && images[0].isNotEmpty) {
              userImage = CloudinaryImage(images[0]).transform().height(100).width(100).crop("fill").gravity("faces").generate() ?? images[0];
            }
          } catch (e) {
            userImage = noUserImageUrl;
          }

          String userid = element.id ?? "";
          sportifeedProvider.mentionsMap[username] = MyMention(
            userid: userid,
            name: element.name ?? '',
            imageurl: userImage,
            username: username,
          );
        }
      });
      MyPrint.printOnConsole('usernamesUseridMapFromApi:${sportifeedProvider.mentionsMap.map((key, value) => MapEntry(key, value.userid))}');
    }

    return sportifeedProvider.mentionsMap.values.toList();
  }

  Future<void> getFeedsAndSetField() async {
    firestore.QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirestoreController().firestore.collection(FEED_COLLECTION).get();

    firestore.WriteBatch batch = FirestoreController().firestore.batch();
    int count = 0;
    List<List<firestore.DocumentSnapshot<Map<String, dynamic>>>> list = [];

    querySnapshot.docs.forEach((firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (count == 0) {
        list.add([]);
        count++;
      } else if (count == 499)
        count = 0;
      else
        count++;
      list.last.add(documentSnapshot);
    });

    for (int i = 0; i < list.length; i++) {
      List<firestore.DocumentSnapshot<Map<String, dynamic>>> docs = list[i];

      for (int i = 0; i < docs.length; i++) {
        firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot = docs[i];
        Map<String, dynamic> data = {};
        FeedModel feedModel = FeedModel.fromMap(documentSnapshot.data() ?? {});

        //if(!documentSnapshot.data()!.containsKey("rating")) data.addAll({'rating' : 5.0,});
        //if(documentSnapshot.data()!.containsKey("quota")) data.addAll({'quota' : FieldValue.delete(),});
        //if(!documentSnapshot.data()!.containsKey("user_plan")) data.addAll({'user_plan' : UserPlanModel.fromMap({}).toMap(),});

        batch.update(FirestoreController().firestore.collection(FEED_COLLECTION).doc(documentSnapshot.id), data);
      }

      await batch.commit();
      if (i != list.length - 1) batch = FirestoreController().firestore.batch();
      MyPrint.printOnConsole("$i commit success");
    }
    MyPrint.printOnConsole("Set Successful");
  }

  Future<void> getFeedsAndSetFieldInElasticSearch() async {
    firestore.QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirestoreController().firestore.collection(FEED_COLLECTION).get();

    int count = 0;
    List<List<firestore.DocumentSnapshot<Map<String, dynamic>>>> list = [];

    querySnapshot.docs.forEach((firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (count == 0) {
        list.add([]);
        count++;
      } else if (count == 499)
        count = 0;
      else
        count++;
      list.last.add(documentSnapshot);
    });

    for (int i = 0; i < list.length; i++) {
      List<firestore.DocumentSnapshot<Map<String, dynamic>>> documentSnapshots = list[i];
      List<Doc> docs = [];
      documentSnapshots.forEach((firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
        FeedModel feedModel = FeedModel.fromMap(documentSnapshot.data() ?? {});

        Doc doc = Doc(documentSnapshot.id, feedModel.elasticToMap());
        docs.add(doc);
      });

      await ElasticController().client.bulk(updateDocs: docs, index: getFeedsIndex(), batchSize: 500);
      MyPrint.printOnConsole("$i commit success");
    }

    MyPrint.printOnConsole("Set Successful");
  }

  Future<void> getCommunitiesAndSetField() async {
    firestore.QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirestoreController().firestore.collection(COMMUNITY_COLLECTION).get();

    firestore.WriteBatch batch = FirestoreController().firestore.batch();
    int count = 0;
    List<List<firestore.DocumentSnapshot<Map<String, dynamic>>>> list = [];

    querySnapshot.docs.forEach((firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (count == 0) {
        list.add([]);
        count++;
      } else if (count == 499)
        count = 0;
      else
        count++;
      list.last.add(documentSnapshot);
    });

    /*Map<String, Map<String, Map<String, dynamic>>> interestmap = await DataController().getInterests2(NavigationController.mainScreenNavigator.currentContext!);
    Map<String, String> interestNameIdMap = {};
    Map<String, InterestModel> interestIdModelMap = {};
    interestmap.forEach((key, value) {
      value.forEach((key, value) {
        InterestModel interestModel = InterestModel.fromMap(value);
        interestNameIdMap[interestModel.name] = interestModel.id;
        interestIdModelMap[interestModel.id] = interestModel;
      });
    });*/

    for (int i = 0; i < list.length; i++) {
      List<firestore.DocumentSnapshot<Map<String, dynamic>>> docs = list[i];

      for (int i = 0; i < docs.length; i++) {
        firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot = docs[i];
        Map<String, dynamic> data = {};
        CommunityModel communityModel = CommunityModel.fromMap(documentSnapshot.data() ?? {});

        /*Map<String, dynamic> interest2Map = {};
        communityModel.interests.forEach((String interest) {
          if(interestNameIdMap[interest]?.isNotEmpty ?? false) {
            if(interestIdModelMap[interestNameIdMap[interest]!] != null) {
              InterestModel interestModel = interestIdModelMap[interestNameIdMap[interest]!]!;
              interestModel.rating = 3;
              interestModel.totalRating = 3;
              interestModel.totalUsers = 1;
              interest2Map[interestModel.id] = interestModel.toMap();
            }
          }
        });
        data['interests2'] = interest2Map;*/

        batch.update(FirestoreController().firestore.collection(COMMUNITY_COLLECTION).doc(documentSnapshot.id), data);
      }

      await batch.commit();
      if (i != list.length - 1) batch = FirestoreController().firestore.batch();
      MyPrint.printOnConsole("$i commit success");
    }
    MyPrint.printOnConsole("Set Successful");
  }

  Future<void> getCommunitiesAndSetFieldInElasticSearch() async {
    firestore.QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirestoreController().firestore.collection(COMMUNITY_COLLECTION).get();

    int count = 0;
    List<List<firestore.DocumentSnapshot<Map<String, dynamic>>>> list = [];

    querySnapshot.docs.forEach((firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (count == 0) {
        list.add([]);
        count++;
      } else if (count == 499)
        count = 0;
      else
        count++;
      list.last.add(documentSnapshot);
    });

    for (int i = 0; i < list.length; i++) {
      List<firestore.DocumentSnapshot<Map<String, dynamic>>> documentSnapshots = list[i];
      List<Doc> docs = [];
      documentSnapshots.forEach((firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
        CommunityModel communityModel = CommunityModel.fromMap(documentSnapshot.data() ?? {});

        Doc doc = Doc(documentSnapshot.id, communityModel.elasticToMap());
        docs.add(doc);
      });

      await ElasticController().client.bulk(updateDocs: docs, index: getCommunityIndex(), batchSize: 500);
      MyPrint.printOnConsole("$i commit success");
    }

    MyPrint.printOnConsole("Set Successful");
  }

  Future<void> createCommentsForFeed() async {
    MyPrint.printOnConsole("createCommentsForFeed called");

    List<FeedCommentModel> feedComments = [];

    int i = 0, maxCount = 0;
    void Function() whenComplete = () => i++;

    late FeedCommentModel lastCommentModel;

    DateTime startTime = DateTime.now();

    for (int i = 2000; i < 3000; i++) {
      FeedCommentModel feedCommentModel = FeedCommentModel();
      feedCommentModel.id = Uuid().v1().replaceAll("-", "");
      feedCommentModel.parentId = "DpcxvRpqillho7wE9XoJ";
      feedCommentModel.comment = (i + 1).toString();
      feedCommentModel.createdById = "wUCicnKywkcQwYxJNFmhjfGYXHM2";
      feedCommentModel.createdByName = "Dishant Agrawal";
      feedCommentModel.createdByImage = "http://res.cloudinary.com/dfjdlhxuy/image/upload/v1637160430/image_cropper_1637160422901.jpg";
      feedCommentModel.tagUserId = "";
      feedCommentModel.tagUserName = "";
      feedCommentModel.createdTime = firestore.Timestamp.now();
      feedCommentModel.commentType = "text";
      feedCommentModel.mediaMetaModel;
      feedCommentModel.editedTime;
      feedCommentModel.firstComment;
      feedCommentModel.commentsCount = 0;

      if (i == 2999) {
        lastCommentModel = feedCommentModel;
      }

      maxCount++;
      FirestoreController().firestore.collection(COMMENT_COLLECTION).doc(feedCommentModel.id).set(feedCommentModel.toMap()).whenComplete(whenComplete);

      maxCount++;
      ElasticController().createDocument(getCommentsIndex(), feedCommentModel.id, feedCommentModel.elasticToMap()).whenComplete(whenComplete);
    }

    maxCount++;
    FirestoreController().firestore.collection(FEED_COLLECTION).doc("DpcxvRpqillho7wE9XoJ").update({
      "lastComment": lastCommentModel.toMap(),
      "commentsCount": 5000,
      "updatedTime": firestore.Timestamp.now(),
    }).whenComplete(whenComplete);

    maxCount++;
    ElasticController().updateDocument(getFeedsIndex(), "DpcxvRpqillho7wE9XoJ", {
      "lastComment": lastCommentModel.elasticToMap(),
      "commentsCount": 5000,
      "updatedTime": DatePresentation.yyyyMMddHHmmssFormatter(firestore.Timestamp.now()),
    }).whenComplete(whenComplete);

    while (i < maxCount) {
      await Future.delayed(Duration(milliseconds: 10));
    }

    DateTime endTime = DateTime.now();

    MyPrint.printOnConsole("Comments Creation Successfull in ${startTime.difference(endTime).inMilliseconds} milliseconds");
  }

  Future<UserModel?> getUserModel(String id) async {
    Doc? doc = await ElasticController().getDocument(getUsersIndex(), id);
    MyPrint.printOnConsole("Community Data For Id $id :${doc?.doc}");
    if (doc != null && doc.doc.isNotEmpty) {
      try {
        return UserModel.elasticFromMap(Map.castFrom(doc.doc));
      } catch (e) {
        MyPrint.printOnConsole("Error in Converting Community Data in CommunityModel:$e");
      }
    }
  }

  Future<void> deleteAllCommunities() async {
    firestore.QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirestoreController().firestore.collection(COMMUNITY_COLLECTION).get();

    querySnapshot.docs.forEach((element) {
      FirestoreController().firestore.collection(COMMUNITY_COLLECTION).doc(element.id).delete();
      ElasticController().deleteDocument(getCommunityIndex(), element.id);
    });
  }

  Future<void> getInterestsAndCreateCommunity() async {
    Map<String, Map<String, Map<String, dynamic>>> interestsMap = await DataController().getInterests3(INTERESTS2_DOCUMENT);

    List<InterestModel> interests = [];

    interestsMap.forEach((String category, Map<String, Map<String, dynamic>> interestIdMap) {
      interestIdMap.forEach((String interestId, Map<String, dynamic> interestMap) {
        InterestModel interestModel = InterestModel.fromMap(interestMap);
        MyPrint.printOnConsole("Interest Name:${interestModel.name}");
        if (interestModel.name.isNotEmpty) {
          interests.add(interestModel);
        }
      });
    });
    MyPrint.printOnConsole("Interests Length:${interests.length}");

    int count = 0;
    for (InterestModel interest in interests) {
      String newDocId = await DataController().getNewDocId();

      CommunityModel communityModel = CommunityModel(
        id: newDocId,
        name: interest.name,
        cid: interest.name,
        createdTime: firestore.Timestamp.now(),
        interests2: {
          interest.id: interest,
        },
      );

      bool isSuccess = await createCommunity(communityModel);
      if (isSuccess) {
        count++;
        MyPrint.printOnConsole("Community Created Successfully for Id:${communityModel.id}, Name:${communityModel.name}");
      } else {
        MyPrint.printOnConsole("Community Creation Failed for Id:${communityModel.id}, Name:${communityModel.name}");
      }
      MyPrint.printOnConsole("$count done");
    }

    MyPrint.printOnConsole("$count communities created");
  }

  Future<bool> createCommunity(CommunityModel communityModel) async {
    MyPrint.printOnConsole("CreateCommunity Called for Id:${communityModel.id}, Name:${communityModel.name}");

    bool isSuccess = false;

    try {
      bool isCreatedCommunityInFirestore = false, isCreatedCommunityInElastic = false;

      List<Future> futures = [
        FirestoreController().firestore.collection(COMMUNITY_COLLECTION).doc(communityModel.id).set(communityModel.toMap()).then((value) {
          MyPrint.printOnConsole("Community Created in Firestore for Id:${communityModel.id}, Name:${communityModel.name}");
          isCreatedCommunityInFirestore = true;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Creating Community in Firestore for Id:${communityModel.id}, Name:${communityModel.name}, Error:$e");
        }),
        ElasticController().createDocument(getCommunityIndex(), communityModel.id, communityModel.elasticToMap()).then((value) {
          if (value) {
            MyPrint.printOnConsole("Community Created in Elastic for Id:${communityModel.id}, Name:${communityModel.name}");
            isCreatedCommunityInElastic = true;
          } else {
            MyPrint.printOnConsole("Error in Creating Community in Elastic for Id:${communityModel.id}, Name:${communityModel.name}");
          }
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Creating Community in Elastic for Id:${communityModel.id}, Name:${communityModel.name}, Error:$e");
        }),
      ];

      await Future.wait(futures);

      isSuccess = isCreatedCommunityInFirestore && isCreatedCommunityInElastic;

      if (!isSuccess) {
        if (isCreatedCommunityInFirestore) {
          await FirestoreController().firestore.collection(COMMUNITY_COLLECTION).doc(communityModel.id).delete();
        }

        if (isCreatedCommunityInElastic) {
          await ElasticController().deleteDocument(getCommunityIndex(), communityModel.id);
        }
      }
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Create Community:$e');
      MyPrint.printOnConsole(s);
    }

    return isSuccess;
  }

  Future<void> getFeedsAndUpdateDynamicLink() async {
    firestore.QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirestoreController().firestore.collection(FEED_COLLECTION).get();

    for (firestore.DocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
      FeedModel feedModel = FeedModel.fromMap(documentSnapshot.data() ?? {});

      ImageFeedDataModel? imageFeedDataModel;
      String imageUrl = "";
      if (feedModel.feedDataModel is ImageFeedDataModel) {
        imageFeedDataModel = feedModel.feedDataModel as ImageFeedDataModel;
        imageUrl = imageFeedDataModel.images.isNotEmpty ? imageFeedDataModel.images[0].image_url : "";
        if (imageUrl.isNotEmpty) {
          try {
            imageUrl = CloudinaryImage(imageUrl).transform().width(400).height(400).generate() ?? imageUrl;
          } catch (e, s) {
            MyPrint.printOnConsole(s);
          }
        }
      }

      String? dynamicLink = await DynamicLinkService.createDynamicLink(
        title: "Checkout ${feedModel.createdByName.trim().isNotEmpty ? "${feedModel.createdByName}'s " : "New "}post on Sportiwe",
        description: (imageFeedDataModel?.description ?? "").isNotEmpty ? imageFeedDataModel!.description.characters.take(100).toString() : "Download App and check this feed",
        imageurl: imageUrl,
        map: {"type": "feed", "nid": feedModel.id},
      );
      MyPrint.printOnConsole("New Dynamic Link For Feed ${feedModel.id}:$dynamicLink");

      Map<String, dynamic> data = {"dynamic_link": dynamicLink ?? ""};

      bool isFeedUpdatedInFirestore = false, isFeedUpdatedInElastic = false;
      List<Future> futures = [
        FirestoreController().firestore.collection(FEED_COLLECTION).doc(feedModel.id).update(data).then((value) {
          isFeedUpdatedInFirestore = true;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Updating Feed ${feedModel.id} in Firestore:$e");
        }),
        ElasticController().updateDocument(getFeedsIndex(), feedModel.id, data).then((value) {
          isFeedUpdatedInElastic = value;
        }).catchError((e) {
          MyPrint.printOnConsole("Error in Updating Feed ${feedModel.id} in Elastic:$e");
        }),
      ];
      await Future.wait(futures);
      if (isFeedUpdatedInFirestore && isFeedUpdatedInElastic) {
        MyPrint.printOnConsole("Dynamic Link Updated in Feed:${feedModel.id}");
      } else {
        MyPrint.printOnConsole("Dynamic Link Couldn't Updated in Feed:${feedModel.id}");
      }
    }
  }

  //region To Hide Any Feed For UserId
  Future<bool> hideUnhideFeedForUser({BuildContext? context, required String userId, required String feedId, bool isHide = true}) async {
    String newId = MyUtils.getNewId();

    MyPrint.printOnConsole("SportiFeedController.hideUnhideFeedForUser called for userId:$userId, feedId:$feedId, isHide:$isHide", tag: newId);

    if (feedId.isEmpty || userId.isEmpty) return false;

    String hideReasonMessage = "";

    //region If isHide is true, then Show RemoveThisPostDialog and get Reason For Hide, If Not Got, then return
    if (isHide) {
      dynamic value = await showCupertinoDialog(
        context: context ?? NavigationController.mainScreenNavigator.currentContext!,
        barrierDismissible: false,
        builder: (context) {
          return RemoveThisPostDialog(
            userId: userId,
            feedId: feedId,
          );
        },
      );
      MyPrint.printOnConsole("Response From RemoveThisPostDialog:'$value'", tag: newId);

      hideReasonMessage = ParsingHelper.parseStringMethod(value);

      if (hideReasonMessage.isEmpty) {
        MyPrint.printOnConsole("Got No Reason for Hide", tag: newId);
        MyPrint.printOnConsole("SportiFeedController.hideUnhideFeedForUser completed for userId:$userId, feedId:$feedId, isHide:$isHide", tag: newId);
        return false;
      }
    }
    //endregion

    Map<String, String> hiddenFeeds = await SportifeedHiveController().getHiddenFeedsOfUser(userId: userId);
    MyPrint.printOnConsole("hiddenFeeds for userId:$userId :$hiddenFeeds", tag: newId);

    if (isHide) {
      hiddenFeeds[feedId] = hideReasonMessage;
    } else {
      hiddenFeeds.remove(feedId);
    }

    MyPrint.printOnConsole("New hiddenFeeds for userId:$userId :$hiddenFeeds", tag: newId);

    //Store Updated Hidden Feeds in Provider
    SportifeedProvider sportiFeedProvider = Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    sportiFeedProvider.setHiddenFeedsByUser(hiddenFeed: hiddenFeeds, isNotify: false);

    //Remove Feed with feedId from All the Feeds List in SportiFeedProvider
    sportiFeedProvider.removeFeedFromAllFeedsList(feedId: feedId);

    //Store Updated Hidden Feeds in Hive
    SportifeedHiveController().storeFeedsOfUserInHive(userId: userId, data: hiddenFeeds);

    MyPrint.printOnConsole("SportiFeedController.hideUnhideFeedForUser completed for userId:$userId, feedId:$feedId, isHide:$isHide", tag: newId);
    return true;
  }

  Future<void> getHiddenFeedsForUserAndSetInProvider({required String userId}) async {
    String newId = MyUtils.getNewId();

    MyPrint.printOnConsole("SportiFeedController.getHiddenFeedsForUserAndSetInProvider called for userId:$userId", tag: newId);

    if (userId.isEmpty) return;

    Map<String, String> hiddenFeeds = await SportifeedHiveController().getHiddenFeedsOfUser(userId: userId);
    MyPrint.printOnConsole("hiddenFeeds for userId:$userId :$hiddenFeeds", tag: newId);

    SportifeedProvider sportiFeedProvider = Provider.of<SportifeedProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);
    sportiFeedProvider.setHiddenFeedsByUser(hiddenFeed: hiddenFeeds);

    MyPrint.printOnConsole("SportiFeedController.getHiddenFeedsForUserAndSetInProvider finished for userId:$userId", tag: newId);
  }
//endregion
}

void getUserPreferedFeedsIsolateMethod(SendPort mainSendPort) async {
  ReceivePort newIsolateReceivePort = ReceivePort();
  //Second Transaction of Page Method(Sending Sendport of Isolate Method)
  mainSendPort.send(newIsolateReceivePort.sendPort);

  //Third Transaction of Page Method(Receiving Data from Page Method)
  List list = await newIsolateReceivePort.first;
  print("Received List:$list");

  int elasticIndex = list[0];
  int documentLimit = list[1];
  List<String> matchedUserIds = list[2];
  List<String> communities = list[3];
  firestore.GeoPoint? geoPoint = list[4];
  int locationRadius = list[5];
  bool isRecentFeeds = list[6];
  bool isInteractiveFeeds = list[7];
  SendPort replyPort = list[8];
  bool isDev = list[9];

  AppController().isDev = isDev;

  try {
    List<Map<String, dynamic>> must = [], mustShould = [], filter = [];
    if (geoPoint != null) {
      filter.add({
        "geo_distance": {
          "distance": "${locationRadius}km",
          "geoPoint": {"lat": geoPoint.latitude, "lon": geoPoint.longitude}
        }
      });
    }

    //For Getting Feeds of matched users
    matchedUserIds.forEach((element) {
      mustShould.add({
        "match": {
          "createdById": element,
        }
      });
    });

    //For Getting Feeds of Selected Communities
    communities.forEach((element) {
      mustShould.add({
        "match": {
          "community_id": element,
        }
      });
    });

    if (mustShould.isNotEmpty) {
      must.add({
        "bool": {"should": mustShould}
      });
    }

    must.add({
      "match": {"enabledByAdmin": true}
    });

    must.add({
      "match": {"enabledByUser": true}
    });

    if (isRecentFeeds) {
      must.add({
        "range": {
          "createdTime": {
            "gte": DatePresentation.yyyyMMddHHmmssFormatter(firestore.Timestamp.fromDate(firestore.Timestamp.now().toDate().subtract(Duration(minutes: 3)))),
            "lte": DatePresentation.yyyyMMddHHmmssFormatter(firestore.Timestamp.now()),
            "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
          }
        }
      });
    }

    if (isInteractiveFeeds) {
      filter.add({
        "range": {
          "createdTime": {
            "gte": DatePresentation.yyyyMMddHHmmssFormatter(firestore.Timestamp.fromDate(firestore.Timestamp.now().toDate().subtract(Duration(days: 7)))),
            "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
          }
        }
      });
    }

    Map<String, dynamic> query = {
      "bool": {"must": must, "filter": filter}
    };

    List<Map<String, dynamic>> sort = [];
    //sort.add({"updatedTime" : {"order" : "desc"}});
    if (isRecentFeeds) {
      bool isInteractive = Random().nextBool();

      if (isInteractive)
        sort.add({
          "totalInteractionCount": {"order": "desc"}
        });
      else
        sort.add({
          "createdTime": {"order": "desc"}
        });
    } else {
      if (isInteractiveFeeds)
        sort.add({
          "totalInteractionCount": {"order": "desc"}
        });
      else
        sort.add({
          "createdTime": {"order": "desc"}
        });
    }

    MyPrint.logOnConsole("Final UserPreferedFeeds ${isRecentFeeds ? "Recent" : (isInteractiveFeeds ? "Interactive" : "Latest")} Query:${jsonEncode(query)}");
    MyPrint.printOnConsole("Final UserPreferedFeeds ${isRecentFeeds ? "Recent" : (isInteractiveFeeds ? "Interactive" : "Latest")} Sort:$sort");

    HttpOverrides.global = MyHttpOverrides();

    List<FeedModel> feeds = [];
    SearchResult searchResult = await ElasticController().client.index(name: getFeedsIndex()).search(
          query: query,
          sort: sort,
          size: documentLimit,
          offset: elasticIndex,
        );

    MyPrint.printOnConsole("Posts Docs Length:${searchResult.hits.length}");

    searchResult.hits.forEach((element) {
      MyPrint.printOnConsole("Feed Document:${element.id}");
      feeds.add(FeedModel.elasticFromMap(Map.castFrom(element.doc)));
    });

    MyPrint.logOnConsole("Posts in Isolates:${feeds.length}");

    //Fourth Transaction of Page Method(Sending Data to the Page Method)
    replyPort.send(feeds);
  } catch (e, s) {
    MyPrint.printOnConsole("Error in getFeedsIsolateMethod Isolate:$e");
    MyPrint.printOnConsole(s);
    replyPort.send([]);
  }
}

void getUserFeedsIsolateMethod(SendPort mainSendPort) async {
  ReceivePort newIsolateReceivePort = ReceivePort();
  //Second Transaction of Page Method(Sending Sendport of Isolate Method)
  mainSendPort.send(newIsolateReceivePort.sendPort);

  //Third Transaction of Page Method(Receiving Data from Page Method)
  List list = await newIsolateReceivePort.first;
  print("Received List:$list");

  int elasticIndex = list[0];
  int documentLimit = list[1];
  String userId = list[2];
  bool isIgnoreFeedEnableCheck = list[3];
  SendPort replyPort = list[4];
  bool isDev = list[5];

  if (userId.isEmpty) {
    replyPort.send([]);
    return;
  }

  AppController().isDev = isDev;

  try {
    List<Map<String, dynamic>> must = [
      {
        "match": {
          "createdById": userId,
        }
      }
    ];
    if (!isIgnoreFeedEnableCheck) {
      must.addAll([
        {
          "match": {
            "enabledByAdmin": true,
          }
        },
        {
          "match": {
            "enabledByUser": true,
          }
        }
      ]);
    }

    Map<String, dynamic> query = {
      "bool": {
        "must": must,
      }
    };

    MyPrint.printOnConsole("Final MyFeeds Query:${jsonEncode(query)}");

    List<Map<String, dynamic>> sort = [];
    sort.add({
      "createdTime": {"order": "desc"}
    });

    HttpOverrides.global = MyHttpOverrides();

    List<FeedModel> feeds = [];
    SearchResult searchResult = await ElasticController().client.index(name: getFeedsIndex()).search(
          query: query,
          sort: sort,
          size: documentLimit,
          offset: elasticIndex,
        );

    MyPrint.printOnConsole("Posts Docs Length:${searchResult.hits.length}");

    searchResult.hits.forEach((element) {
      MyPrint.printOnConsole("Feed Document:${element.id}");
      feeds.add(FeedModel.elasticFromMap(Map.castFrom(element.doc)));
    });

    MyPrint.logOnConsole("Feeds in Isolates:${feeds.length}");

    //Fourth Transaction of Page Method(Sending Data to the Page Method)
    replyPort.send(feeds);
  } catch (e, s) {
    MyPrint.printOnConsole("Error in getFeedsIsolateMethod Isolate:$e");
    MyPrint.printOnConsole(s);
    replyPort.send([]);
  }
}

void getUserPreferedPinnedFeedsIsolateMethod(SendPort mainSendPort) async {
  ReceivePort newIsolateReceivePort = ReceivePort();
  //Second Transaction of Page Method(Sending Sendport of Isolate Method)
  mainSendPort.send(newIsolateReceivePort.sendPort);

  //Third Transaction of Page Method(Receiving Data from Page Method)
  List list = await newIsolateReceivePort.first;
  print("Received List:$list");

  int elasticIndex = list[0];
  int documentLimit = list[1];
  List<String> communities = list[2];
  firestore.GeoPoint? geoPoint = list[3];
  int locationRadius = list[4];
  SendPort replyPort = list[5];
  bool isDev = list[6];

  AppController().isDev = isDev;

  try {
    List<Map<String, dynamic>> should = [], filter = [];

    if (geoPoint != null) {
      filter.add({
        "geo_distance": {
          "distance": "${locationRadius}km",
          "geoPoint": {"lat": geoPoint.latitude, "lon": geoPoint.longitude}
        }
      });
    }

    //For Getting Feeds of Selected Communities
    communities.forEach((element) {
      should.add({
        "match": {
          "community_id": element,
        }
      });
    });

    Map<String, dynamic> query = {
      "bool": {
        "must": [
          {
            "match": {"isPinned": true}
          },
          {
            "match": {"enabledByUser": true}
          },
          {
            "match": {"enabledByAdmin": true}
          },
          {
            "bool": {
              "should": should,
            }
          }
        ],
        "filter": filter
      }
    };

    MyPrint.printOnConsole("Pinned Feeds Final Query:${jsonEncode(query)}");

    HttpOverrides.global = MyHttpOverrides();

    List<FeedModel> feeds = [];
    SearchResult searchResult = await ElasticController().client.index(name: getFeedsIndex()).search(
          query: query,
          size: documentLimit,
          offset: elasticIndex,
        );

    MyPrint.printOnConsole("Posts Docs Length:${searchResult.hits.length}");

    searchResult.hits.forEach((element) {
      MyPrint.printOnConsole("Feed Document:${element.id}");
      feeds.add(FeedModel.elasticFromMap(Map.castFrom(element.doc)));
    });

    MyPrint.logOnConsole("Posts in Isolates:${feeds.length}");

    //Fourth Transaction of Page Method(Sending Data to the Page Method)
    replyPort.send(feeds);
  } catch (e, s) {
    MyPrint.printOnConsole("Error in getFeedsIsolateMethod Isolate:$e");
    MyPrint.printOnConsole(s);
    replyPort.send([]);
  }
}

void getCommentsIsolateMethod(SendPort mainSendPort) async {
  ReceivePort newIsolateReceivePort = ReceivePort();
  //Second Transaction of Page Method(Sending Sendport of Isolate Method)
  mainSendPort.send(newIsolateReceivePort.sendPort);

  //Third Transaction of Page Method(Receiving Data from Page Method)
  List list = await newIsolateReceivePort.first;
  print("Received List:$list");

  int elasticIndex = list[0];
  int documentLimit = list[1];
  String parentId = list[2];
  bool isDescending = list[3];
  SendPort replyPort = list[4];
  bool isDev = list[5];

  AppController().isDev = isDev;

  try {
    List<Map<String, dynamic>> must = [];

    must.add({
      "match": {
        "parentId": parentId,
      }
    });

    Map<String, dynamic> query = {
      "bool": {
        "must": must,
      }
    };

    MyPrint.printOnConsole("Final Comments Query:${jsonEncode(query)}");

    List<Map<String, dynamic>> sort = [];
    sort.add({
      "createdTime": {"order": isDescending ? "desc" : "asc"}
    });

    HttpOverrides.global = MyHttpOverrides();

    List<FeedCommentModel> comments = [];
    SearchResult searchResult = await ElasticController().client.index(name: getCommentsIndex()).search(
          query: query,
          sort: sort,
          size: documentLimit,
          offset: elasticIndex,
        );

    MyPrint.printOnConsole("Comments Docs Length:${searchResult.hits.length}");

    searchResult.hits.forEach((element) {
      FeedCommentModel feedCommentModel = FeedCommentModel.elasticFromMap(Map.castFrom(element.doc));
      MyPrint.printOnConsole("Comment Document:${feedCommentModel.id}, Parent:${feedCommentModel.parentId}");
      comments.add(feedCommentModel);
    });

    MyPrint.logOnConsole("Comments in Isolates:${comments.length}");

    //Fourth Transaction of Page Method(Sending Data to the Page Method)
    replyPort.send(comments);
  } catch (e, s) {
    MyPrint.printOnConsole("Error in getCommentsIsolateMethod Isolate:$e");
    MyPrint.printOnConsole(s);
    replyPort.send([]);
  }
}

void getFeedsFromHashtagIsolateMethod(SendPort mainSendPort) async {
  ReceivePort newIsolateReceivePort = ReceivePort();
  //Second Transaction of Page Method(Sending Sendport of Isolate Method)
  mainSendPort.send(newIsolateReceivePort.sendPort);

  //Third Transaction of Page Method(Receiving Data from Page Method)
  List list = await newIsolateReceivePort.first;
  print("Received List:$list");

  int elasticIndex = list[0];
  int documentLimit = list[1];
  List<String> hashtags = list[2];
  SendPort replyPort = list[3];
  bool isDev = list[4];

  AppController().isDev = isDev;

  try {
    List<Map<String, dynamic>> must = [], mustShould = [];

    //For Getting Feeds that contains hashtag
    hashtags.forEach((element) {
      mustShould.add({
        "match": {
          "hashtags": element,
        }
      });
    });

    if (mustShould.isNotEmpty) {
      must.add({
        "bool": {"should": mustShould}
      });
    }

    must.add({
      "match": {"enabledByAdmin": true}
    });

    must.add({
      "match": {"enabledByUser": true}
    });

    Map<String, dynamic> query = {
      "bool": {
        "must": must,
      }
    };

    List<Map<String, dynamic>> sort = [
      {
        "createdTime": {"order": "desc"}
      }
    ];

    MyPrint.logOnConsole("Final FeedsFromHashtag Query:${jsonEncode(query)}");
    MyPrint.printOnConsole("Final FeedsFromHashtag Sort:$sort");

    HttpOverrides.global = MyHttpOverrides();

    List<FeedModel> feeds = [];
    SearchResult searchResult = await ElasticController().client.index(name: getFeedsIndex()).search(
          query: query,
          sort: sort,
          size: documentLimit,
          offset: elasticIndex,
        );

    MyPrint.printOnConsole("Feeds Docs Length:${searchResult.hits.length}");

    searchResult.hits.forEach((element) {
      MyPrint.printOnConsole("Feed Document:${element.id}");
      feeds.add(FeedModel.elasticFromMap(Map.castFrom(element.doc)));
    });

    MyPrint.logOnConsole("Posts in Isolates:${feeds.length}");

    //Fourth Transaction of Page Method(Sending Data to the Page Method)
    replyPort.send(feeds);
  } catch (e, s) {
    MyPrint.printOnConsole("Error in getFeedsFromHashtagIsolateMethod Isolate:$e");
    MyPrint.printOnConsole(s);
    replyPort.send([]);
  }
}
