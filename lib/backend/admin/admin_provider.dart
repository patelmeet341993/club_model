import 'package:club_model/backend/common/common_provider.dart';
import 'package:club_model/club_model.dart';

class AdminProvider extends CommonProvider{
  AdminProvider(){
    propertyModel = CommonProviderPrimitiveParameter<PropertyModel?>(
      value: null,
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<PropertyModel?> propertyModel;






}