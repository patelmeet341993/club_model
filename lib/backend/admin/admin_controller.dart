

import 'package:club_model/backend/admin/admin_provider.dart';
import 'package:club_model/backend/admin/admin_repository.dart';
import 'package:club_model/models/common/data_model/banner_model.dart';

import '../../utils/my_print.dart';

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

    }catch(e,s){
      MyPrint.printOnConsole("Error in AdminController().addBannerToFirebase():$e");
      MyPrint.printOnConsole(s);
    }


  }


}