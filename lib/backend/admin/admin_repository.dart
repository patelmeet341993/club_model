import 'package:club_model/club_model.dart';
import 'package:club_model/models/common/data_model/banner_model.dart';

import '../../configs/constants.dart';

class AdminRepository{

  Future<PropertyModel?> getPropertyModelFromFireStore() async {

    PropertyModel? propertyModel;

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.adminPropertyDocumentReference.get();
      MyPrint.printOnConsole("snapshot exist:${snapshot.exists}");
      MyPrint.printOnConsole("snapshot data:${snapshot.data()}");

      if(snapshot.data().checkNotEmpty) {
        propertyModel = PropertyModel.fromMap(snapshot.data()!);
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().getPropertyData():$e");
      MyPrint.printOnConsole(s);
    }

    MyPrint.printOnConsole("Final propertyModel:$propertyModel");

    return propertyModel;
  }

  Future<void> AddBannerRepo(BannerModel bannerModel) async {
    await FirebaseNodes.adminPropertyDocumentReference.set(bannerModel.toMap());
  }


}