

import 'package:club_model/backend/admin/admin_provider.dart';
import 'package:club_model/backend/admin/admin_repository.dart';

class AdminController{
  late AdminProvider _adminProvider;
  late AdminRepository _adminRepository;

  EventController({required AdminProvider? eventProvider, AdminRepository? repository}) {
    _adminProvider = eventProvider ?? AdminProvider();
    _adminRepository = repository ?? AdminRepository();
  }

  AdminProvider get adminProvider => _adminProvider;

  AdminRepository get adminRepository => _adminRepository;



}