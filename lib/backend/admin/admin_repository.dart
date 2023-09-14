import 'package:club_model/club_model.dart';
import 'package:club_model/models/common/data_model/banner_model.dart';

import '../../configs/constants.dart';

class AdminRepository{

  Future<PropertyModel?> getPropertyModelFromFireStore() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminRepository().getPropertyModelFromFireStore() called", tag: tag);

    PropertyModel? propertyModel;

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.adminPropertyDocumentReference.get();
      MyPrint.printOnConsole("snapshot exist:${snapshot.exists}", tag: tag);
      MyPrint.printOnConsole("snapshot data:${snapshot.data()}", tag: tag);

      if(snapshot.data().checkNotEmpty) {
        propertyModel = PropertyModel.fromMap(snapshot.data()!);
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().getPropertyData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Final propertyModel:$propertyModel", tag: tag);

    return propertyModel;
  }

  Future<void> AddBannerRepo(BannerModel bannerModel) async {
    try {
      await FirebaseNodes.adminPropertyDocumentReference.update({'banners.${bannerModel.id}':bannerModel.toMap()});
    }catch(e, s) {
      MyPrint.printOnConsole("Error in AdminRepository().AddBannerRepo():$e");
      MyPrint.printOnConsole(s);
    }
  }


  Future<void> reorderList(List<BannerModel> bannerList) async {
    try {
      Map<String,Map<String,dynamic>> bannerMap = {};
      bannerList.forEach((element) {
        bannerMap[element.id] = element.toMap();
      });

      await FirebaseNodes.adminPropertyDocumentReference.update({'banner':bannerMap});
    }catch(e, s) {
      MyPrint.printOnConsole("Error in AdminRepository().reorderList():$e");
      MyPrint.printOnConsole(s);
    }
  }




}