import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QRCodescanPop extends StatefulWidget {
  QRCodescanPop({Key key}) : super(key: key);

  @override
  QRCodescanPopState createState() => QRCodescanPopState();
}

class QRCodescanPopState extends State<QRCodescanPop> {
  var scanResult;
  @override
  void initState() {
    super.initState();
    scan();
  }

  Future scan() async {
    try {
      var options = ScanOptions(
        // strings: {
        //   "cancel": _cancelController.text,
        //   "flash_on": _flashOnController.text,
        //   "flash_off": _flashOffController.text,
        // },
        // restrictFormat: selectedFormats,
        useCamera: 1,
        // autoEnableFlash: _autoEnableFlash,
        // android: AndroidOptions(
        //   aspectTolerance: _aspectTolerance,
        //   useAutoFocus: _useAutoFocus,
        // ),
      );
      var result = await BarcodeScanner.scan(options: options);
      setState(() => scanResult = result);
      print(scanResult);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      content: mainContent(),
    );
  }

  Widget mainContent() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width / 1.8,
        height: MediaQuery.of(context).size.height / 1.8,
        child: Center());
  }
}
