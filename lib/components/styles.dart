import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class Styles {
  static whiteBold() {
    return TextStyle(
        // White text
        color: Color(0xFFffffff),
        fontSize: 25,
        fontWeight: FontWeight.w800,
        fontFamily: Strings.fontFamily);
  }

  static whiteMediumBold() {
    return TextStyle(
        // White text
        color: Color(0xFFffffff),
        fontSize: SizeConfig.safeBlockVertical * 2.8,
        fontWeight: FontWeight.w800,
        fontFamily: Strings.fontFamily);
  }

  static blackMediumBold() {
    return TextStyle(
        // White text
        color: Color(0xFF000000),
        fontSize: 20,
        fontWeight: FontWeight.w800,
        fontFamily: Strings.fontFamily);
  }

  static whiteBoldsmall() {
    return TextStyle(
        // White text
        color: Color(0xFFffffff),
        fontSize: SizeConfig.safeBlockVertical * 2.5,
        fontWeight: FontWeight.w800,
        fontFamily: Strings.fontFamily);
  }

  static blackBoldsmall() {
    return TextStyle(
        // White text
        color: Color(0xFF000000),
        fontSize: SizeConfig.safeBlockVertical * 3,
        fontWeight: FontWeight.w800,
        fontFamily: Strings.fontFamily);
  }

  static whiteSimpleSmall() {
    return TextStyle(
        // White text
        color: Color(0xFFffffff),
        fontSize: SizeConfig.safeBlockVertical * 2.5,
        fontWeight: FontWeight.w600,
        fontFamily: Strings.fontFamily);
  }

  static whiteSmall() {
    return TextStyle(
        // White text
        color: Color(0xFFffffff),
        fontSize: SizeConfig.safeBlockVertical * 2.3,
        fontWeight: FontWeight.w500,
        fontFamily: Strings.fontFamily);
  }

  static whiteSimpleLarge() {
    return TextStyle(
        // White text
        color: Color(0xFFffffff),
        fontSize: 30,
        fontWeight: FontWeight.normal,
        fontFamily: Strings.fontFamily);
  }

  static blackSimpleLarge() {
    return TextStyle(
        // White text
        color: Color(0xFF0000000),
        fontSize: 30,
        fontWeight: FontWeight.normal,
        fontFamily: Strings.fontFamily);
  }

  static communBlack() {
    // Back Text
    return TextStyle(
        color: Color(0xFF000000),
        fontSize: SizeConfig.safeBlockVertical * 4,
        fontWeight: FontWeight.w600,
        fontFamily: Strings.fontFamily);
  }

  static communBlacksmall() {
    // Back Text
    return TextStyle(
        color: Color(0xFF000000),
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontFamily: Strings.fontFamily);
  }

  static blackBoldLarge() {
    // Back Text
    return TextStyle(
        color: Color(0xFF000000),
        fontSize: SizeConfig.safeBlockVertical * 5,
        fontWeight: FontWeight.w800,
        fontFamily: Strings.fontFamily);
  }

  static blackLarge() {
    // Back Text
    return TextStyle(
        color: Color(0xFF000000), fontSize: 25, fontFamily: Strings.fontFamily);
  }

  static bluesmall() {
    return TextStyle(
        color: Color(0xFF0388fc),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: Strings.fontFamily);
  }

  static darkBlue() {
    return TextStyle(
        fontSize: SizeConfig.safeBlockVertical * 2.5,
        fontWeight: FontWeight.w700,
        color: Color(0xff100c56),
        fontFamily: Strings.fontFamily);
  }

  static darkGray() {
    return TextStyle(
        fontSize: SizeConfig.safeBlockVertical * 2.8,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        fontFamily: Strings.fontFamily);
  }

  static orangeLarge() {
    return TextStyle(
        fontSize: SizeConfig.safeBlockVertical * 5,
        fontWeight: FontWeight.w600,
        color: Color(0xffff531a),
        fontFamily: Strings.fontFamily);
  }

  static orangeMedium() {
    return TextStyle(
        fontSize: SizeConfig.safeBlockVertical * 4,
        fontWeight: FontWeight.w600,
        color: Color(0xffff531a),
        fontFamily: Strings.fontFamily);
  }

  static orangeSmall() {
    return TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xffff531a),
        fontFamily: Strings.fontFamily);
  }

  static normalBlack() {
    return TextStyle(color: Colors.black, fontSize: 25.0);
  }

  static communGrey() {
    return TextStyle(color: Colors.grey, fontSize: 20.0);
  }

  static greysmall() {
    return TextStyle(
      fontSize: SizeConfig.safeBlockVertical * 2.5,
      fontWeight: FontWeight.w600,
      color: Colors.grey[700],
    );
  }
}
