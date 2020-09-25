import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mcncashier/components/StringFile.dart';

class Styles {
  static whiteBold() {
    return TextStyle(
        // White text
        color: Color(0xFFffffff),
        fontSize: 25,
        fontWeight: FontWeight.w800,
        fontFamily: Strings.fontFamily);
  }

  static whiteBoldsmall() {
    return TextStyle(
        // White text
        color: Color(0xFFffffff),
        fontSize: 18,
        fontWeight: FontWeight.w800,
        fontFamily: Strings.fontFamily);
  }

  static whiteSimpleSmall() {
    return TextStyle(
        // White text
        color: Color(0xFFffffff),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: Strings.fontFamily);
  }

  static communBlack() {
    // Back Text
    return TextStyle(
        color: Color(0xFF000000),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: Strings.fontFamily);
  }

  static communBlacksmall() {
    // Back Text
    return TextStyle(
        color: Color(0xFF000000),
        fontSize: 18,
        fontWeight: FontWeight.normal,
        fontFamily: Strings.fontFamily);
  }

  static blackBoldLarge() {
    // Back Text
    return TextStyle(
        color: Color(0xFF000000),
        fontSize: 25,
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
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xff100c56),
        fontFamily: Strings.fontFamily);
  }

  static orangeLarge() {
    return TextStyle(
        fontSize: 30,
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
}
