import 'package:club_model/backend/common/common_provider.dart';
import 'package:club_model/club_model.dart';

import '../../models/common/data_model/banner_model.dart';

class AdminProvider extends CommonProvider{
  AdminProvider(){
    propertyModel = CommonProviderPrimitiveParameter<PropertyModel?>(
      value: null,
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<PropertyModel?> propertyModel;

  void updateBanner({required Map<String, BannerModel> bannerMap, bool isClear = true}){

    PropertyModel? model = propertyModel.get();
    if(isClear){
      model?.banners.clear();
    }
    model?.banners.addAll(bannerMap);
    propertyModel.set(value: model,isNotify: true);
  }








}