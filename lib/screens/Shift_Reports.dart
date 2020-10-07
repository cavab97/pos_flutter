import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class ShiftReports extends StatefulWidget {
  // PIN Enter PAGE
  ShiftReports({Key key}) : super(key: key);

  @override
  _ShiftReportsState createState() => _ShiftReportsState();
}

class _ShiftReportsState extends State<ShiftReports> {
  LocalAPI localAPI = LocalAPI();
  Shift shifittem = new Shift();
  var screenArea = 1.5;
  int _current = 0;

  final List<String> imgList = [
    'Summary',
    'Cash Drawer Summary',
    'Payment Summary'
  ];

  @override
  void initState() {
    super.initState();
    getShiftData();
  }

  getShiftData() async {
    var shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    if (shiftid != null) {
      List<Shift> shift = await localAPI.getShiftData(shiftid);
      setState(() {
        shifittem = shift[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0), // here the desired height
        child: AppBar(
          leading: new IconButton(
            icon: new Icon(
              Icons.arrow_back,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Shift Report",
                      style: Styles.whiteBold(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    shiftbtn()
                  ],
                ),
                Text(
                  shifittem.updatedAt != null
                      ? Strings.opened_at +
                          " " +
                          DateFormat('EEE, MMM d yyyy, hh:mm aaa')
                              .format(DateTime.parse(shifittem.updatedAt)) +
                          " by Admin "
                      : "",
                  textAlign: TextAlign.center,
                  style: Styles.whiteSimpleSmall(),
                ),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          // height: SizeConfig.blockSizeHorizontal * 2,
          // width: SizeConfig.blockSizeVertical* 2,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              shiftTitles(),
              Container(
                height: MediaQuery.of(context).size.height / 1.8,
                width: MediaQuery.of(context).size.width / 1.5,
                // width: 800,
                // color: Colors.green,
                child: CarouselSlider(
                  options: CarouselOptions(
                      height: double.maxFinite,
                      disableCenter: false,
                      autoPlay: false,
                      initialPage: 0,
                      aspectRatio: 2.0,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                  items: imgList
                      .map(
                        (item) => Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 20),
                            Text(
                              item,
                              style: Styles.whiteBold(),
                            ),
                            SizedBox(height: 10),
                            Container(
                                width: MediaQuery.of(context).size.width /
                                    screenArea,
                                //  color: Colors.green,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    Container(
                                      color: Colors.grey,
                                      child: ListTile(
                                        title: Text(
                                          "Gross Sales",
                                          style: Styles.whiteMediumBold(),
                                        ),
                                        trailing: Text(
                                          "0.00",
                                          style: Styles.whiteMediumBold(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.white,
                                      child: ListTile(
                                        title: Text(
                                          "Refunds",
                                          style: Styles.blackMediumBold(),
                                        ),
                                        trailing: Text(
                                          "0.00",
                                          style: Styles.blackMediumBold(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.grey,
                                      child: ListTile(
                                        title: Text(
                                          "Discount",
                                          style: Styles.whiteMediumBold(),
                                        ),
                                        trailing: Text(
                                          "0.00",
                                          style: Styles.whiteMediumBold(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.white,
                                      child: ListTile(
                                        title: Text(
                                          "Net Sales",
                                          style: Styles.blackMediumBold(),
                                        ),
                                        trailing: Text(
                                          "0.00",
                                          style: Styles.blackMediumBold(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.grey,
                                      child: ListTile(
                                        title: Text(
                                          "Rounding",
                                          style: Styles.whiteMediumBold(),
                                        ),
                                        trailing: Text(
                                          "0.00",
                                          style: Styles.whiteMediumBold(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.white,
                                      child: ListTile(
                                        title: Text(
                                          "Tax/Service Charge",
                                          style: Styles.blackMediumBold(),
                                        ),
                                        trailing: Text(
                                          "0.00/0.00",
                                          style: Styles.blackMediumBold(),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
              scrollIndicator(),
              squareActionButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        /*squareBtn("Pay In"),
        squareBtn("Pay Out"),
        squareBtn("Open Cash Drawer"),*/
      ],
    );
  }

  Widget squareBtn(name) {
    return RaisedButton(
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      onPressed: () {},
      child: Text(
        name,
        style: TextStyle(color: Colors.deepOrange, fontSize: 20),
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side:
            BorderSide(width: 1, style: BorderStyle.solid, color: Colors.white),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  Widget scrollIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: imgList.map((url) {
        int index = imgList.indexOf(url);
        return Container(
          width: 15.0,
          height: 15.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _current == index ? Colors.deepOrange : Colors.white,
          ),
        );
      }).toList(),
    );
  }

  Widget squareActionButton() {
    return Container(
        width: MediaQuery.of(context).size.width / screenArea,
        child: Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.all(20),
                    onPressed: () {
                      CommunFun.showToast(context, "Comming Soon");
                    },
                    child: Text(
                      "Pay In",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.all(20),
                    onPressed: () {
                      CommunFun.showToast(context, "Comming Soon");
                    },
                    child: Text(
                      "Pay Out",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.all(20),
                    onPressed: () {
                      CommunFun.showToast(context, "Comming Soon");
                    },
                    child: Text(
                      "Open Cash Drawer",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ]),
        ));
  }

  Widget shiftbtn() {
    return RaisedButton(
      padding: EdgeInsets.all(0),
      onPressed: () {},
      child: Text(
        Strings.open,
        style: TextStyle(color: Colors.deepOrange, fontSize: 15),
      ),
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 1, style: BorderStyle.solid, color: Colors.deepOrange),
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }

  shiftTitles() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Total Net Sales",
              style: Styles.whiteSimpleSmall(),
            ),
            SizedBox(height: 10),
            Text(
              "0.00",
              style: Styles.orangeLarge(),
            )
          ],
        ),
        SizedBox(width: 50),
        Column(
          children: <Widget>[
            Text(
              "Transactions",
              style: Styles.whiteSimpleSmall(),
            ),
            SizedBox(height: 10),
            Text(
              "0.00",
              style: Styles.orangeLarge(),
            )
          ],
        ),
        SizedBox(width: 50),
        Column(
          children: <Widget>[
            Text(
              "Average Order Value",
              style: Styles.whiteSimpleSmall(),
            ),
            SizedBox(height: 10),
            Text(
              "0.00",
              style: Styles.orangeLarge(),
            )
          ],
        )
      ],
    );
  }
}
