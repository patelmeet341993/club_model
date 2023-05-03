import 'package:flutter/material.dart';

class Styles {
  static final Styles _instance = Styles._();
  Styles._();
  factory Styles() => _instance;

  Color lightPrimaryColor = const Color(0xff6d65df);
  Color darkPrimaryColor = const Color(0xff6d65df);

  Color lightPrimaryVariant = const Color(0xff6d65df).withOpacity(0.6);
  Color darkPrimaryVariant = const Color(0xff6d65df).withOpacity(0.6);

  Color lightSecondaryColor = Colors.blueAccent;
  Color darkSecondaryColor = Colors.blueAccent;

  Color lightSecondaryVariant = Colors.blueAccent.shade400;
  Color darkSecondaryVariant = Colors.blueAccent.shade400;

  Color lightAppBarTextColor = const Color(0xff495057);
  Color darkAppBarTextColor = const Color(0xffffffff);

  Color lightTextColor = const Color(0xff495057);
  Color darkTextColor = const Color(0xffffffff);

  Color lightBackgroundColor = Colors.grey.shade100;
  Color darkBackgroundColor = const Color(0xffffffff);

  Color lightAppBarColor = const Color(0xffffffff);
  Color darkAppBarColor = const Color(0xff2e343b);

  Color lightTextFiledFillColor = Colors.white;
  Color darkTextFiledFillColor = Colors.black;

  Color lightHoverColor = Colors.grey.withOpacity(0.05);
  Color darkHoverColor = Colors.grey.withOpacity(0.5);

  Color lightFocusedTextFormFieldColor = const Color(0xff6d65df).withOpacity(0.05);
  Color darkFocusedTextFormFieldColor = const Color(0xff6d65df).withOpacity(0.5);

  double buttonBorderRadius = 5;

  //region CustomColors
  Color cardColor = const Color(0xfff0f0f0);
  Color secondaryColor = const Color(0xff084EAD);
  Color myPrimaryColor = const Color(0xff4C508F);
  Color textGrey = const Color(0xff676767);
  //endregion//

  //region ShimmerColors
  Color shimmerHighlightColor = const Color(0xfff2f2f2);
  Color shimmerBaseColor = const Color(0xffb6b6b6);
  Color shimmerContainerColor = const Color(0xffc2c2c2);
  //endregion
}