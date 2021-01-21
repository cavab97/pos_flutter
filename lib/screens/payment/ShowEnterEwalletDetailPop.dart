import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/OrderPayment.dart';
import 'CustomTextFormField.dart';

class ShowEnterEwalletDetailPop extends StatefulWidget {
  ShowEnterEwalletDetailPop({
    Key key,
    @required this.currentPayment,
  }) : super(key: key);

  OrderPayment currentPayment;
  @override
  _ShowEnterEwalletDetailPopState createState() =>
      _ShowEnterEwalletDetailPopState();
}

final _formKey = GlobalKey<FormState>();

TextEditingController refInputController = new TextEditingController();
TextEditingController remarkInputController = new TextEditingController();

class _ShowEnterEwalletDetailPopState extends State<ShowEnterEwalletDetailPop> {
  FocusScopeNode node;
  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
/* 
    refInputController.dispose();
    remarkInputController.dispose(); */
    if (node != null) {
      //FocusScope.of(context).requestFocus(new FocusNode());
      node.unfocus();
      //node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    node = FocusScope.of(context);

    var errorMSG = "";
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      titlePadding: EdgeInsets.all(20),
      title: Center(child: Text(Strings.walletPayment)),
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
              Text(Strings.enterRefNum, style: Styles.blackMediumBold()),
              SizedBox(
                height: 20,
              ),
              CustomTextFormField(
                inputController: refInputController,
                textInputType: TextInputType.text,
                hintText: Strings.enterRefNum,
                errorMSG: errorMSG,
                validatorFunction: (value) {
                  if (value.isEmpty) {
                    return Strings.referenceNumMsg;
                  }
                  return null;
                },
                controllerNode: node,
              ),
              SizedBox(
                height: 20,
              ),
              Text(Strings.remark, style: Styles.blackMediumBold()),
              SizedBox(
                height: 20,
              ),
              CustomTextFormField(
                inputController: remarkInputController,
                textInputType: TextInputType.text,
                hintText: Strings.enterRemark,
                errorMSG: errorMSG,
                /* validatorFunction: (value) {
                  if (value.isEmpty) {
                    return Strings.referenceNumMsg;
                  }
                  return null;
                }, */
                controllerNode: node,
                submittedFunction: (_) {
                  node.requestFocus(new FocusNode());
                  checkRefNum();
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
            checkRefNum();
          },
          child: Text(Strings.done, style: Styles.orangeSmall()),
        ),
      ],
    );
  }

  checkRefNum() {
    if (_formKey.currentState != null && _formKey.currentState.validate()) {
      widget.currentPayment.remark = remarkInputController.text;
      widget.currentPayment.reference_number = refInputController.text;
      Navigator.of(context).pop();
      //cashPayment(seletedPayment);
      // finalPayment(seletedPayment);
    }
  }
}
