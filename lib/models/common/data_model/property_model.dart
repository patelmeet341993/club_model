

import 'package:club_model/models/common/data_model/banner_model.dart';
import 'package:club_model/utils/my_utils.dart';
import 'package:club_model/utils/parsing_helper.dart';

class PropertyModel {
  String aboutDescription = "", contactNumber = "", whatsApp = "", termsAndConditionsUrl = "", privacyAndPolicyUrl = "";
  bool notificationsEnabled = false, subscriptionDeleteEnabled = false;
  Map<String, BannerModel> banners = {};

  PropertyModel({
    this.aboutDescription = "",
    this.contactNumber = "",
    this.whatsApp = "",
    this.banners = const {},
    this.termsAndConditionsUrl = "",
    this.privacyAndPolicyUrl = "",
    this.notificationsEnabled = false,
    this.subscriptionDeleteEnabled = false,
  });

  PropertyModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    Map<String, Map<String, dynamic>> bannerMaps = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['banners']).map((key, value) {
      return MapEntry(key, ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(value));
    });
    banners.clear();
    bannerMaps.forEach((String key, Map<String, dynamic> value) {
      if (value.isNotEmpty) {
        banners[key] = BannerModel.fromMap(value);
      }
    });
    aboutDescription = ParsingHelper.parseStringMethod(map['aboutDescription']);
    contactNumber = ParsingHelper.parseStringMethod(map['contactNumber']);
    whatsApp = ParsingHelper.parseStringMethod(map['whatsApp']);
    termsAndConditionsUrl = ParsingHelper.parseStringMethod(map['termsAndConditionsUrl']);
    privacyAndPolicyUrl = ParsingHelper.parseStringMethod(map['privacyAndPolicyUrl']);
    notificationsEnabled = ParsingHelper.parseBoolMethod(map['notificationsEnabled']);
    subscriptionDeleteEnabled = ParsingHelper.parseBoolMethod(map['subscriptionDeleteEnabled']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "banners": banners,
      "aboutDescription": aboutDescription,
      "contactNumber": contactNumber,
      "whatsApp": whatsApp,
      "termsAndConditionsUrl": termsAndConditionsUrl,
      "privacyAndPolicyUrl": privacyAndPolicyUrl,
      "notificationsEnabled": notificationsEnabled,
      "subscriptionDeleteEnabled": subscriptionDeleteEnabled,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap());
  }
}