import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/helpers/LocalAPI/OrdersList.dart';
import 'package:mcncashier/helpers/LocalAPI/PrinterList.dart';
import 'package:mcncashier/helpers/LocalAPI/ShiftList.dart';
import 'package:mcncashier/models/Order.dart';
import 'package:mcncashier/models/Printer.dart';
import 'package:mcncashier/models/Drawer.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/printer/printerconfig.dart';
import 'package:mcncashier/screens/PayINOutDailog.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mcncashier/models/Branch.dart';
import 'package:mcncashier/helpers/LocalAPI/Branch.dart';
import 'package:mcncashier/models/Terminal.dart';
import '../models/Shift.dart';

class ShiftReports extends StatefulWidget {
  // PIN Enter PAGE
  ShiftReports({Key key}) : super(key: key);

  @override
  _ShiftReportsState createState() => _ShiftReportsState();
}

class _ShiftReportsState extends State<ShiftReports> {
  LocalAPI localAPI = LocalAPI();
  ShiftList shiftList = new ShiftList();
  PrinterList printerAPI = new PrinterList();
  PrintReceipt printKOT = PrintReceipt();
  ShiftList shiftAPI = ShiftList();
  List<Printer> printerreceiptList = new List<Printer>();
  Shift shifittem = new Shift();
  var screenArea = 1.6;
  int _current = 0;
  List<Orders> orders = [];
  List<Drawerdata> drawerData = [];
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
  double payInOutAmount = 0.00;
  bool isInAmmount = false;
  Terminal terminal;
  Branch branchData;
  BranchList branchAPI = new BranchList();
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
    getAllPrinter();
    getbranch();
  }

  getbranch() async {
    var branchid = await CommunFun.getbranchId();
    var branch = await branchAPI.getbranchData(branchid);
    setState(() {
      branchData = branch;
    });
    return branch;
  }

  setPermissons() async {
    var permission = await CommunFun.getPemission();
    setState(() {
      permissions = permission;
    });
  }

  getAllPrinter() async {
    List<Printer> printerDraft =
        await printerAPI.getAllPrinterList(context, "0");
    var terminalid = await CommunFun.getTeminalKey();
    Terminal terminalData = await localAPI.getTerminalDetails(terminalid);
    setState(() {
      printerreceiptList = printerDraft;
      terminal = terminalData;
    });
  }

  getOrders() async {
    OrdersList orderApi = new OrdersList();
    var terminalid = await CommunFun.getTeminalKey();
    var branchid = await CommunFun.getbranchId();
    List<Orders> orderList = await orderApi.getOrdersList(branchid, terminalid);
    if (orderList.length > 0) {
      setState(() {
        orders = orderList;
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
        discountval += order.voucher_amount != null ? order.voucher_amount : 0;
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
      List<Shift> shift = await shiftList.getShiftData(context, shiftid);
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
      getpayInOutAmmount();
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
              if (reson == "Other") {
                Navigator.of(context).pop();
                otherReasonPop(amount, title);
              } else {
                Navigator.of(context).pop();
                insertPayinOUT(amount, reson);
              }
            },
          );
        });
  }

  otherReasonPop(amount, title) {
    print(amount);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AddOtherReason(
            amount: amount,
            title: title,
            type: "other",
            onClose: (otherText) {
              Navigator.of(context).pop();
              insertPayinOUT(amount, otherText);
            },
          );
        });
  }

  insertPayinOUT(amount, reson) async {
    User user = await CommunFun.getuserDetails();
    var terminalid = await CommunFun.getTeminalKey();
    Drawerdata drawer = new Drawerdata();
    drawer.shiftId = shifittem.appId;
    drawer.amount = amount;
    drawer.isAmountIn = isInAmmount == true ? 1 : 2;
    drawer.reason = reson;
    drawer.status = 1;
    drawer.createdBy = user.id;
    drawer.createdAt = await CommunFun.getCurrentDateTime(DateTime.now());
    drawer.localID = await CommunFun.getLocalID();
    drawer.terminalid = int.parse(terminalid);
    var result = await shiftAPI.saveInOutDrawerData(drawer);
    print(result);
    print(reson);

    getpayInOutAmmount();
  }

  getpayInOutAmmount() async {
    if (shifittem.shiftId != null) {
      List<Drawerdata> result =
          await shiftList.getPayinOutammount(shifittem.shiftId);

      if (result.length > 0) {
        setState(() {
          drawerData = result;
        });
        var drawerAmm = 0.00;
        for (var i = 0; i < drawerData.length; i++) {
          Drawerdata drawer = drawerData[i];
          if (drawer.amount != null) {
            drawerAmm += drawer.amount;
          }
        }
        setState(() {
          payInOutAmount = drawerAmm;
          expectedVal = drawerAmm;
        });
        countTotalDrawer();
      }
    }
  }

  countTotalDrawer() {
    var newval = shifittem.startAmount +
        cashSale +
        cashDeposit +
        cashRefund +
        cashRounding +
        payInOutAmount;
    setState(() {
      overShort = newval;
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
        physics: BouncingScrollPhysics(),
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
            .map(
              (item) => SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                  width: MediaQuery.of(context).size.width / screenArea,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        item,
                        style: Styles.whiteBold(),
                      ),
                      SizedBox(height: 10),
                      getReportList(item),
                    ],
                  ),
                ),
              ),
            )
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
    return Container(
        height: MediaQuery.of(context).size.height / 1.8,
        child: ListView(
          physics: BouncingScrollPhysics(),
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
        ));
  }

  Widget drawersummeryView() {
    return Container(
        height: MediaQuery.of(context).size.height / 1.8,
        child: new ListView(
          physics: BouncingScrollPhysics(),
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
                  shifittem.startAmount != null
                      ? shifittem.startAmount.toStringAsFixed(2)
                      : "",
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
                  "Cash Deposit",
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
                  "Cash In/Out",
                  style: Styles.blackMediumBold(),
                ),
                trailing: Text(
                  payInOutAmount.toStringAsFixed(2),
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
        ));
  }

  Widget paymentsummeryView() {
    return Container(
        height: MediaQuery.of(context).size.height / 1.8,
        child: ListView(
          physics: BouncingScrollPhysics(),
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
        ));
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
                      setState(() {
                        isInAmmount = true;
                      });
                      openpayInOUTPop("Cash In Amount", "5.00");
                    },
                    child: Text(
                      "Cash In",
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
                      setState(() {
                        isInAmmount = false;
                      });
                      openpayInOUTPop("Cash Out Amount", "5.00");
                    },
                    child: Text(
                      "Cash Out",
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
                      if (printerreceiptList.length > 0) {
                        printKOT.testReceiptPrint(
                            printerreceiptList[0].printerIp.toString(),
                            context,
                            "",
                            "OpenDrawer");
                      } else {
                        CommunFun.showToast(
                            context, Strings.printer_not_available);
                      }
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
            SizedBox(height: 5),
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
            SizedBox(height: 5),
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
            SizedBox(height: 5),
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

class AddOtherReason extends StatefulWidget {
  AddOtherReason({Key key, this.onClose, this.amount, this.title, this.type})
      : super(key: key);
  Function onClose;
  final double amount;
  final String title;
  final String type;

  @override
  AddOtherReasonState createState() => AddOtherReasonState();
}

class AddOtherReasonState extends State<AddOtherReason> {
  ShiftList shiftAPI = new ShiftList();
  List<Printer> printerreceiptList = new List<Printer>();
  PrintReceipt printKOT = PrintReceipt();
  PrinterList printerAPI = new PrinterList();
  TextEditingController reasonController = new TextEditingController();
  BranchList branchAPI = new BranchList();
  ShiftReports shiftReports = ShiftReports();

  Branch branchData;
  Terminal terminal;

  @override
  void initState() {
    super.initState();
    getAllPrinter();
    getbranch();
  }

  getAllPrinter() async {
    List<Printer> printerDraft =
        await printerAPI.getAllPrinterList(context, "0");
    var terminalid = await CommunFun.getTeminalKey();
    Terminal terminalData = await localAPI.getTerminalDetails(terminalid);

    setState(() {
      printerreceiptList = printerDraft;
      terminal = terminalData;
    });
  }

  getbranch() async {
    var branchid = await CommunFun.getbranchId();
    var branch = await branchAPI.getbranchData(branchid);
    setState(() {
      branchData = branch;
    });
    return branch;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      content: Container(
        height: MediaQuery.of(context).size.height / 3.6,
        width: MediaQuery.of(context).size.width / 3.4,
        child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Reason",
                  style: Styles.communBlack(),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            )),
      ),
      actions: <Widget>[canclebutton(context), confirmBtn(context)],
    );
  }

  Widget confirmBtn(context) {
    // Add button header rounded
    return FlatButton(
      onPressed: () {
        if (printerreceiptList.length > 0) {
          printKOT.cashInPrint(
              printerreceiptList[0].printerIp,
              context,
              widget.title,
              reasonController.text,
              branchData,
              terminal,
              widget.type,
              widget.amount);
        } else {
          CommunFun.showToast(context, Strings.printer_not_available);
        }

        widget.onClose(reasonController.text);
        print(reasonController.text);
        print(widget.type);
      },
      child: Text("Confirm", style: Styles.orangeSmall()),
      textColor: Colors.white,
    );
  }

  Widget canclebutton(context) {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("Cancel", style: Styles.orangeSmall()),
      textColor: Colors.white,
    );
  }
}
