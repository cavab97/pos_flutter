import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'CustomTextFormField.dart';

class ShowEnterCardDetailPop extends StatefulWidget {
  ShowEnterCardDetailPop({
    Key key,
    @required this.currentPayment,
  }) : super(key: key);
  OrderPayment currentPayment;
  @override
  _ShowEnterCardDetailPopState createState() => _ShowEnterCardDetailPopState();
}

class _ShowEnterCardDetailPopState extends State<ShowEnterCardDetailPop> {
  final _formKey = GlobalKey<FormState>();
  FocusScopeNode node;
  @override
  void dispose() {
    if (node != null) {
      node.unfocus();
    }
    super.dispose();
  }

  TextEditingController digitController = new TextEditingController();
  TextEditingController codeInput = new TextEditingController();
  TextEditingController remarkInputController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    node = FocusScope.of(context);
    var errorMSG = "";
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      titlePadding: EdgeInsets.all(20),
      title: Center(child: Text("Card Payment")),
      content: Container(
        width: MediaQuery.of(context).size.width / 2.4,
        height: MediaQuery.of(context).size.height / 2.4,
        child: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(Strings.enterLast, style: Styles.blackMediumBold()),
              SizedBox(height: 20),
              CustomTextFormField(
                inputController: digitController,
                textInputType: TextInputType.number,
                hintText: Strings.enterDigit,
                errorMSG: errorMSG,
                maxLength: 4,
                controllerNode: node,
                /* validatorFunction: (value) {
                  if (value.isEmpty) {
                    return Strings.referenceNumMsg;
                  } else
                    return null;
                }, */
              ),
              SizedBox(height: 10),
              Text(Strings.approvalCode, style: Styles.blackMediumBold()),
              SizedBox(height: 20),
              CustomTextFormField(
                inputController: codeInput,
                textInputType: TextInputType.text,
                hintText: Strings.enterCode,
                errorMSG: errorMSG,
                validatorFunction: (value) {
                  if (value.isEmpty) {
                    return Strings.approvalCodeMsg;
                  } else
                    return null;
                },
                controllerNode: node,
              ),
              SizedBox(height: 10),
              Text(Strings.remark, style: Styles.blackMediumBold()),
              SizedBox(height: 20),
              CustomTextFormField(
                inputController: remarkInputController,
                textInputType: TextInputType.text,
                hintText: Strings.enterRemark,
                errorMSG: errorMSG,
                controllerNode: node,
                submittedFunction: (_) {
                  node.requestFocus(new FocusNode());
                  checkPIN();
                },
              ),
            ],
          ),
        )),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            node.requestFocus(new FocusNode());
            Navigator.of(context).pop();
          },
          child: Text(Strings.cancel, style: Styles.orangeSmall()),
        ),
        FlatButton(
          onPressed: () {
            checkPIN();
          },
          child: Text(Strings.done, style: Styles.orangeSmall()),
        ),
      ],
    );
  }

  checkPIN() {
    if (_formKey.currentState.validate()) {
      widget.currentPayment.remark = remarkInputController.text;
      widget.currentPayment.approval_code = codeInput.text;
      widget.currentPayment.last_digits = digitController.text;
      digitController.text = "";
      codeInput.text = "";
      remarkInputController.text = "";
      Navigator.of(context).pop();
      //cashPayment(seletedPayment);
    }
  }
}
