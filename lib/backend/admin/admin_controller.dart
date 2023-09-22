

import 'package:club_model/backend/admin/admin_provider.dart';
import 'package:club_model/backend/admin/admin_repository.dart';
import 'package:club_model/models/common/data_model/banner_model.dart';

import '../../models/common/data_model/property_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class AdminController{
  late AdminProvider _adminProvider;
  late AdminRepository _adminRepository;

  AdminController({required AdminProvider? adminProvider, AdminRepository? repository}) {
    _adminProvider = adminProvider ?? AdminProvider();
    _adminRepository = repository ?? AdminRepository();
  }

  AdminProvider get adminProvider => _adminProvider;

  AdminRepository get adminRepository => _adminRepository;

  Future<void> addBannerToFirebase({required BannerModel bannerModel}) async {
    try{
      await adminRepository.AddBannerRepo(bannerModel);
      adminProvider.updateBanner(isClear:false,bannerMap: {bannerModel.id:bannerModel});
    }catch(e,s){
      MyPrint.printOnConsole("Error in AdminController().addBannerToFirebase():$e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> deleteBannerFromFirebase({required BannerModel bannerModel}) async {
    try{
      await adminRepository.deleteBannerRepo(bannerModel);
      adminProvider.updateBanner(isClear:false,bannerMap: {bannerModel.id:bannerModel});
    }catch(e,s){
      MyPrint.printOnConsole("Error in AdminController().deleteBannerFromFirebase():$e");
      MyPrint.printOnConsole(s);
    }
  }



  Future<void> reorderBannerListToFirebase({required List<BannerModel> bannerList}) async {
    try{
      Map<String,BannerModel> bannerMap = {};
      bannerList.forEach((element) {
        bannerMap[element.id] = element;
      });
      await adminRepository.reorderList(bannerList);
      adminProvider.updateBanner(isClear:true,bannerMap:bannerMap);
    }catch(e,s){
      MyPrint.printOnConsole("Error in AdminController().reorderBannerListToFirebase():$e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<void> getPropertyDataAndSetInProvider() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminController().getPropertyDataAndSetInProvider() called", tag: tag);

    try {
      PropertyModel? propertyModel = await adminRepository.getPropertyModelFromFireStore();
      adminProvider.propertyModel.set(value: propertyModel);
    } catch (e) {
      MyPrint.printOnConsole(
        "Error in getting PropertyModel in AdminController().getPropertyDataAndSetInProvider():$e",
        tag: tag,
      );
      MyPrint.printOnConsole(e, tag: tag);
    }
  }
}