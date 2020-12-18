import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
    Key key,
    @required this.inputController,
    @required this.textInputType,
    @required this.hintText,
    @required this.errorMSG,
    this.textInputFormatterList,
    this.validatorFunction,
  }) : super(key: key);

  final TextEditingController inputController;
  final TextInputType textInputType;
  final String hintText;
  Function validatorFunction = () {};
  String errorMSG;
  List<TextInputFormatter> textInputFormatterList = [];

  @override
  Widget build(BuildContext context) {
    TextEditingController codeInput = new TextEditingController();
    return TextFormField(
      validator: validatorFunction,
      controller: codeInput,
      keyboardType: textInputType,
      inputFormatters: textInputFormatterList,
      decoration: InputDecoration(
        errorStyle: TextStyle(
            color: Colors.red, fontSize: SizeConfig.safeBlockVertical * 2),
        hintText: hintText, //Strings.enter_remark,
        hintStyle: TextStyle(
            fontSize: SizeConfig.safeBlockVertical * 2, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: Colors.grey),
        ),
        filled: true,
        contentPadding: EdgeInsets.all(15),
        fillColor: Colors.white,
      ),
      style: Styles.greysmall(),
      onChanged: (e) {
        errorMSG = "";
      },
    );
  }
}
