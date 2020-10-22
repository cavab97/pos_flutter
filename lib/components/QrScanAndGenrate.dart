import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodesImagePop extends StatefulWidget {
  QRCodesImagePop({Key key, this.ip, this.onClose}) : super(key: key);
  final ip;
  Function onClose;

  @override
  QRCodesImagePopState createState() => QRCodesImagePopState();
}

class QRCodesImagePopState extends State<QRCodesImagePop> {
  var scanResult;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onBackPressed,
        child: AlertDialog(
          titlePadding: EdgeInsets.all(0),
          title: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Container(
                padding:
                    EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                height: SizeConfig.safeBlockVertical * 9,
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("QR Code",
                        style: TextStyle(
                            fontSize: SizeConfig.safeBlockVertical * 3,
                            color: Colors.white)),
                  ],
                ),
              ),
              closeButton(context), // close button
            ],
          ),
          content: mainContent(),
        ));
  }

  Widget closeButton(context) {
    return Positioned(
      top: -30,
      right: -20,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(30.0)),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onClose();
            },
            icon: Icon(
              Icons.clear,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop();
    widget.onClose();
  }

  Widget mainContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width / 2.8,
      height: MediaQuery.of(context).size.height / 1.8,
      child: QrImage(
        data: widget.ip,
        version: QrVersions.auto,
        size: 320,
        gapless: false,
       // embeddedImage: AssetImage('assets/headerlogo_receipt.png'),
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(80, 80),
        ),
      ),
    );
  }
}
