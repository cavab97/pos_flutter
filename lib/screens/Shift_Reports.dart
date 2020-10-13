import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/Shift.dart';
import 'package:mcncashier/screens/PayINOutDailog.dart';
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
  var screenArea = 1.6;
  int _current = 0;
  List<Orders> orders = [];
  double grossSale = 0.00;
  double netSale = 0.00;
  double totalTender = 0.00;
  double discount = 0.00;
  double refund = 0.00;
  double tax = 0.00;
  double cashSale = 0.00;
  double cashDeposit = 0.00;
  double cashRefund = 0.00;
  double cashRounding = 0.00;
  double payinOut = 0.00;
  double expectedVal = 0.00;
  double overShort = 0.00;
  final List<String> imgList = [
    'Summary',
    'Cash Drawer Summary',
    'Payment Summary'
  ];
  var permissions = "";
  @override
  void initState() {
    super.initState();
    getShiftData();
    getOrders();
    setPermissons();
  }

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
  }

  getOrders() async {
    var branchid = await CommunFun.getbranchId();
    List<Orders> ordersList = await localAPI.getShiftInvoiceData(branchid);
    if (ordersList.length > 0) {
      setState(() {
        orders = ordersList;
      });
      var grosssale = 0.00;
      var netsale = 0.00;
      var discountval = 0.00;
      var refundval = 0.00;
      var taxval = 0.00;
      var totaltend = 0.00;
      for (var i = 0; i < orders.length; i++) {
        Orders order = orders[i];
        grosssale += order.sub_total;
        refundval += 0;
        netsale = grosssale - refundval;
        taxval += order.tax_amount;
        discountval += order.voucher_amount;
        totaltend += (netsale + tax) - discountval;
      }
      setState(() {
        grossSale = grosssale;
        netSale = netsale;
        discount = discountval;
        refund = refundval;
        tax = taxval;
        totalTender = totaltend;
      });
    }
  }

  getShiftData() async {
    var shiftid = await Preferences.getStringValuesSF(Constant.DASH_SHIFT);
    if (shiftid != null) {
      List<Shift> shift = await localAPI.getShiftData(shiftid);
      setState(() {
        shifittem = shift[0];
        cashSale = 0.00;
        cashDeposit = 0.00;
        cashRefund = 0.00;
        cashRounding = 0.00;
        payinOut = 0.00;
        expectedVal = 0.00;
        overShort = 0.00;
      });
    }
  }

  openpayInOUTPop(title, amount) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PayInOutDailog(
            title: title,
            ammount: amount,
            onClose: (amount, reson) {
              Navigator.of(context).pop();
            },
          );
        });
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
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              shiftTitles(),
              crousalWidget(),
              scrollIndicator(),
              permissions.contains(Constant.EDIT_REPORT)
                  ? squareActionButton()
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget crousalWidget() {
    return Container(
      height: MediaQuery.of(context).size.height / screenArea,
      width: MediaQuery.of(context).size.width,
      child: CarouselSlider(
        options: CarouselOptions(
            viewportFraction: 0.8,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            height: double.maxFinite,
            autoPlay: false,
            initialPage: 0,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            }),
        items: imgList
            .map((item) => Container(
                  // color: Colors.blueGrey,
                  width: MediaQuery.of(context).size.width / screenArea,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Text(
                        item,
                        style: Styles.whiteBold(),
                      ),
                      SizedBox(height: 10),
                      Container(child: getReportList(item)),
                    ],
                  ),
                ))
            .toList(),
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

  Widget getReportList(name) {
    Widget reportView = Container();
    switch (name) {
      case "Summary":
        reportView = summeryView();
        break;
      case "Payment Summary":
        reportView = paymentsummeryView();
        break;
      case "Cash Drawer Summary":
        reportView = drawersummeryView();
        break;
      default:
        break;
    }
    return reportView;
  }

  Widget summeryView() {
    return ListView(
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
              grossSale.toStringAsFixed(2),
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
              refund.toStringAsFixed(2),
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
              discount.toStringAsFixed(2),
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
              netSale.toStringAsFixed(2),
              style: Styles.blackMediumBold(),
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
              tax.toStringAsFixed(2),
              style: Styles.blackMediumBold(),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(
              "Total Tenders :",
              style: Styles.blackMediumBold(),
            ),
            trailing: Text(
              totalTender.toStringAsFixed(2),
              style: Styles.blackMediumBold(),
            ),
          ),
        ),
      ],
    );
  }

  Widget drawersummeryView() {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Container(
          color: Colors.grey,
          child: ListTile(
            title: Text(
              "Opnening Amount",
              style: Styles.whiteMediumBold(),
            ),
            trailing: Text(
              shifittem != null ? shifittem.startAmount.toStringAsFixed(2) : "",
              style: Styles.whiteMediumBold(),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(
              "Cash Sales",
              style: Styles.blackMediumBold(),
            ),
            trailing: Text(
              cashSale.toStringAsFixed(2),
              style: Styles.blackMediumBold(),
            ),
          ),
        ),
        Container(
          color: Colors.grey,
          child: ListTile(
            title: Text(
              "Case Deposit",
              style: Styles.whiteMediumBold(),
            ),
            trailing: Text(
              cashDeposit.toStringAsFixed(2),
              style: Styles.whiteMediumBold(),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(
              "Cash Refunds",
              style: Styles.blackMediumBold(),
            ),
            trailing: Text(
              cashRefund.toStringAsFixed(2),
              style: Styles.blackMediumBold(),
            ),
          ),
        ),
        Container(
          color: Colors.grey,
          child: ListTile(
            title: Text(
              "Cash Rounding",
              style: Styles.whiteMediumBold(),
            ),
            trailing: Text(
              cashRounding.toStringAsFixed(2),
              style: Styles.whiteMediumBold(),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(
              "Pay In/Out",
              style: Styles.blackMediumBold(),
            ),
            trailing: Text(
              payinOut.toStringAsFixed(2),
              style: Styles.blackMediumBold(),
            ),
          ),
        ),
        Container(
          color: Colors.grey,
          child: ListTile(
            title: Text(
              "Drawer Expected/Actual",
              style: Styles.whiteMediumBold(),
            ),
            trailing: Text(
              expectedVal.toStringAsFixed(2),
              style: Styles.whiteMediumBold(),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(
              "Over/Short",
              style: Styles.blackMediumBold(),
            ),
            trailing: Text(
              overShort.toStringAsFixed(2),
              style: Styles.blackMediumBold(),
            ),
          ),
        ),
      ],
    );
  }

  Widget paymentsummeryView() {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Container(
          color: Colors.grey,
          child: ListTile(
            title: Text(
              "Total",
              style: Styles.whiteMediumBold(),
            ),
            trailing: Text(
              grossSale.toStringAsFixed(2),
              style: Styles.whiteMediumBold(),
            ),
          ),
        ),
      ],
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
                      openpayInOUTPop("Pay In Amount", "5.00");
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
                      openpayInOUTPop("Pay Out Amount", "5.00");
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
                      overflow: TextOverflow.ellipsis,
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
