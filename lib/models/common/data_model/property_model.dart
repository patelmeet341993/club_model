

import 'package:club_model/utils/my_utils.dart';
import 'package:club_model/utils/parsing_helper.dart';

class PropertyModel {
  String aboutDescription = "", contactNumber = "", whatsApp = "", termsAndConditionsUrl = "", privacyAndPolicyUrl = "";
  bool notificationsEnabled = false, subscriptionDeleteEnabled = false;
  List<String> bannerImages = [];


  PropertyModel({
    this.aboutDescription = "",
    this.contactNumber = "",
    this.whatsApp = "",
    this.bannerImages = const  [],
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
    bannerImages = ParsingHelper.parseListMethod<dynamic, String>(map['bannerImages']);
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
      "bannerImages": bannerImages,
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