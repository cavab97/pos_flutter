import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class FinalEndScreen extends StatefulWidget {
  FinalEndScreen(
      {Key key, this.total, this.totalPaid, this.change, this.onClose})
      : super(key: key);
  Function onClose;
  final total;
  final totalPaid;
  final change;
  @override
  FinalEndScreentate createState() => FinalEndScreentate();
}

class FinalEndScreentate extends State<FinalEndScreen> {
  var total;
  var ammountPaid;
  var change;

  @override
  void initState() {
    super.initState();
    setState(() {
      total = widget.total;
      ammountPaid = widget.totalPaid;
      change = widget.change;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: new GestureDetector(
            onTap: () {
              widget.onClose();
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          color: Colors.grey,
                          child: SizedBox(
                            height: SizeConfig.safeBlockVertical * 15,
                            child: Image.asset(Strings.asset_headerLogo,
                                fit: BoxFit.contain, gaplessPlayback: true),
                          ),
                        ),
                        closeButton(context)
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height -
                          SizeConfig.safeBlockVertical * 15,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        //  crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new Expanded(
                                flex: 7,
                                child: Text(
                                  "Total :",
                                  textAlign: TextAlign.end,
                                  style: Styles.blackExtraLarge(),
                                ),
                              ),
                              new Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      total != null
                                          ? total.toStringAsFixed(2)
                                          : "0",
                                      textAlign: TextAlign.end,
                                      style: Styles.blackExtraLarge(),
                                    ),
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new Expanded(
                                flex: 7,
                                child: Text(
                                  "Amount Paid :",
                                  textAlign: TextAlign.end,
                                  style: Styles.blackExtraLarge(),
                                ),
                              ),
                              new Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      ammountPaid != null
                                          ? ammountPaid.toStringAsFixed(2)
                                          : "0",
                                      textAlign: TextAlign.end,
                                      style: Styles.blackExtraLarge(),
                                    ),
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new Expanded(
                                flex: 7,
                                child: Text(
                                  "Change :",
                                  textAlign: TextAlign.end,
                                  style: Styles.blackExtraLarge(),
                                ),
                              ),
                              new Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      change != null
                                          ? change.toStringAsFixed(2)
                                          : "0",
                                      textAlign: TextAlign.end,
                                      style: Styles.blackExtraLarge(),
                                    ),
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                "Press screen to Continue",
                                textAlign: TextAlign.end,
                                style: Styles.communBlack(),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget closeButton(context) {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(0.0)),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
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
}
