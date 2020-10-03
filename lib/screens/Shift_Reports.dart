import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ShiftReports extends StatefulWidget {
  // PIN Enter PAGE
  ShiftReports({Key key}) : super(key: key);

  @override
  _ShiftReportsState createState() => _ShiftReportsState();
}

class _ShiftReportsState extends State<ShiftReports> {
  LocalAPI localAPI = LocalAPI();
  Shift shifittem = new Shift();
  final List<String> imgList = [
    'Summary',
    'Cash Drawer Summary',
    'Payment Summary'
  ];
  @override
  void initState() {
    super.initState();
    getshiftData();
  }

  getshiftData() async {
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
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            //width: MediaQuery.of(context).size.width / 1.2,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                shifttitles(),
                Container(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      disableCenter: false,
                      autoPlay: false,
                      initialPage: 0,
                      scrollDirection: Axis.horizontal,
                    ),
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
                                  width:
                                      MediaQuery.of(context).size.width / 1.8,
                                  //  color: Colors.green,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      Container(
                                        color: Colors.grey,
                                        child: ListTile(
                                          title: Text(
                                            "Gross Sales",
                                            style: Styles.whiteSimpleLarge(),
                                          ),
                                          trailing: Text(
                                            "0.00",
                                            style: Styles.whiteSimpleLarge(),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        child: ListTile(
                                          title: Text(
                                            "Refunds",
                                            style: Styles.blackSimpleLarge(),
                                          ),
                                          trailing: Text(
                                            "0.00",
                                            style: Styles.blackSimpleLarge(),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.grey,
                                        child: ListTile(
                                          title: Text(
                                            "Discount",
                                            style: Styles.whiteSimpleLarge(),
                                          ),
                                          trailing: Text(
                                            "0.00",
                                            style: Styles.whiteSimpleLarge(),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        child: ListTile(
                                          title: Text(
                                            "Net Sales",
                                            style: Styles.blackSimpleLarge(),
                                          ),
                                          trailing: Text(
                                            "0.00",
                                            style: Styles.blackSimpleLarge(),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.grey,
                                        child: ListTile(
                                          title: Text(
                                            "Rounding",
                                            style: Styles.whiteSimpleLarge(),
                                          ),
                                          trailing: Text(
                                            "0.00",
                                            style: Styles.whiteSimpleLarge(),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        child: ListTile(
                                          title: Text(
                                            "Tax/Service Charge",
                                            style: Styles.blackSimpleLarge(),
                                          ),
                                          trailing: Text(
                                            "0.00/0.00",
                                            style: Styles.blackSimpleLarge(),
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
                bottomButtons()
              ],
            ),
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
        squareBtn("Pay In"),
        squareBtn("Pay Out"),
        squareBtn("Open Cash Drawer"),
      ],
    );
  }

  Widget squareBtn(name) {
    return RaisedButton(
      padding: EdgeInsets.all(0),
      onPressed: () {},
      child: Text(
        name,
        style: TextStyle(color: Colors.deepOrange, fontSize: 15),
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side:
            BorderSide(width: 1, style: BorderStyle.solid, color: Colors.white),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
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

  shifttitles() {
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
            SizedBox(height: 20),
            Text(
              "0.00",
              style: Styles.whiteSimpleSmall(),
            )
          ],
        ),
        SizedBox(width: 20),
        Column(
          children: <Widget>[
            Text(
              "Transations",
              style: Styles.whiteSimpleSmall(),
            ),
            SizedBox(height: 20),
            Text(
              "0.00",
              style: Styles.whiteSimpleSmall(),
            )
          ],
        ),
        SizedBox(width: 20),
        Column(
          children: <Widget>[
            Text(
              "Average Order Value",
              style: Styles.whiteSimpleSmall(),
            ),
            SizedBox(height: 20),
            Text(
              "0.00",
              style: Styles.whiteSimpleSmall(),
            )
          ],
        )
      ],
    );
  }
}
