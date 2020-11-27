import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/preferences.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/helpers/LocalAPI/CustomerList.dart';
import 'package:mcncashier/helpers/LocalAPI/OrdersList.dart';
import 'package:mcncashier/helpers/LocalAPI/ProductList.dart';
import 'package:mcncashier/models/Box.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory.dart';
import 'package:mcncashier/models/Customer_Liquor_Inventory_Log.dart';
import 'package:mcncashier/models/Rac.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/screens/ChangeQtyDailog.dart';
import 'package:mcncashier/screens/SearchCustomer.dart';
import 'package:mcncashier/services/LocalAPIs.dart';
import 'package:mcncashier/theme/Sized_Config.dart';

class WineStorage extends StatefulWidget {
  // PIN Enter PAGE
  WineStorage({Key key}) : super(key: key);

  @override
  _WineStorageState createState() => _WineStorageState();
}

class _WineStorageState extends State<WineStorage>
    with TickerProviderStateMixin {
  Customer customer;
  ProductsList prodictAPI = new ProductsList();
  CustomersList  custAPI = CustomersList();
  LocalAPI localAPI = LocalAPI();
  List<Rac> racList = new List<Rac>();
  List<Box> boxsList = new List<Box>();
  List<Customer_Liquor_Inventory> inventoryData =
      List<Customer_Liquor_Inventory>();
  OrdersList orderAPI = new OrdersList();
  TabController _tabController;
  bool isLoading = false;
  bool isEditing = false;
  @override
  void initState() {
    super.initState();
    getRacList();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      var racID = racList[_tabController.index].racId;
      getBoxList(racID);
    }
  }

  getRacList() async {
    setState(() {
      isLoading = true;
    });
    var branchId = await CommunFun.getbranchId();
    List<Rac> list = await prodictAPI.getRacList(branchId);
    if (list.length > 0) {
      setState(() {
        racList = list;
        isLoading = false;
      });
      getBoxList(racList[0].racId);
    } else {
      setState(() {
        racList = [];
        isLoading = false;
      });
    }
    _tabController = TabController(vsync: this, length: racList.length);
    _tabController.addListener(_handleTabSelection);
  }

  getBoxList(racID) async {
    setState(() {
      isLoading = true;
    });
    var branchId = await CommunFun.getbranchId();
    List<Box> list = await prodictAPI.getBoxList(branchId, racID);
    if (list.length > 0) {
      setState(() {
        boxsList = list;
        isLoading = false;
      });
    } else {
      setState(() {
        boxsList = [];
        isLoading = false;
      });
    }
  }

  opneShowAddCustomerDailog() {
    // Send receipt Popup
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SearchCustomerPage(
              onClose: () {
                checkCustomerSelected();
              },
              isFor: Constant.dashboard);
        });
  }

  checkCustomerSelected() async {
    Customer customerData = await CommunFun.getCustomer();
    setState(() {
      customer = customerData;
    });
    getcustomerRedeemList(customer);
  }

  getcustomerRedeemList(Customer customer) async {
    var result = await custAPI.getCustomerRedeem(customer.customerId);
    setState(() {
      inventoryData = result;
      isEditing = result.length > 0 ? true : false;
    });
  }

  removeCustomer() {
    CommonUtils.showAlertDialog(context, () {
      Navigator.of(context).pop();
    }, () {
      Navigator.of(context).pop();
      removeCust();
    }, "Alert", "Are you sure you want to remove customer?", "Yes", "No", true);
  }

  removeCust() async {
    await Preferences.removeSinglePref(Constant.CUSTOMER_DATA);
    setState(() {
      customer = null;
      isEditing = false;
      inventoryData = [];
    });
  }

  openInvtQtyPop(Box box) async {
    if (customer != null) {
      var bqty = box.wineQty != null ? box.wineQty : 0.0;
      if (inventoryData.length > 0) {
        var isSelected = inventoryData.firstWhere(
            (item) => item.clBoxId == box.boxId && item.clLeftQuantity > 0,
            orElse: () => null);
        if (isSelected != null) {
          bqty = isSelected.clLeftQuantity;
        }
        if (isSelected != null) {
          await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return ChangeQtyDailog(
                    type: "cm",
                    qty: bqty,
                    onClose: (qty, remark) {
                      Navigator.of(context).pop();
                      addtoInventory(box, qty);
                    });
              });
        }
      } else {
        CommunFun.showToast(context, "Item is not available in you redeem.");
      }
    } else {
      CommunFun.showToast(context, Strings.please_select_customer);
    }
  }

  addtoInventory(Box box, qty) async {
    if (customer != null) {
      setState(() {
        isLoading = true;
      });
      bool isUpdate = false;
      var isSelected;
      if (inventoryData.length > 0) {
        isSelected = inventoryData.firstWhere(
            (item) => item.clBoxId == box.boxId && item.clLeftQuantity > 0,
            orElse: () => null);
      }
      if (isSelected != null) {
        DateTime expireDate = DateTime.parse(isSelected.clExpiredOn);
        if (expireDate.isAfter(DateTime.now()) &&
            isSelected.clTotalQuantity > 0) {
          setState(() {
            isUpdate = true;
          });
        } else {
          CommunFun.showToast(context, "Your redeem is expired.");
          return false;
        }
      }
      User user = await CommunFun.getuserDetails();
      Customer_Liquor_Inventory inventory = new Customer_Liquor_Inventory();
      if (!isUpdate) {
        await CommunFun.showToast(
            context, "This is not available in your redeem.");
      } else if (isSelected.clLeftQuantity > 0) {
        inventory = isSelected;
        inventory.clLeftQuantity = isSelected.clLeftQuantity - qty;
        inventory.updatedAt =
            await CommunFun.getCurrentDateTime(DateTime.now());
        inventory.updatedBy = user.id;
        var clid = await orderAPI.insertWineInventory(inventory, isUpdate);
        Customer_Liquor_Inventory_Log log = new Customer_Liquor_Inventory_Log();
        var lastappid = await orderAPI.getLastCustomerInventoryLogid();
        if (lastappid != 0) {
          log.appId = lastappid + 1;
        } else {
          log.appId = 1;
        }
        log.uuid = await CommunFun.getLocalID();
        log.clAppId = isUpdate ? isSelected.appId : inventory.appId;
        log.branchId = box.branchId;
        log.productId = box.productId;
        log.customerId = customer.customerId;
        log.liType = box.boxFor;
        log.qty = qty;
        log.qtyBeforeChange = box.wineQty;
        log.qtyAfterChange = box.wineQty != null ? (box.wineQty - qty) : 0;
        log.updatedAt = await CommunFun.getCurrentDateTime(DateTime.now());
        log.updatedBy = user.id;
        var lid = await orderAPI.insertWineInventoryLog(log);
        getcustomerRedeemList(customer);
        setState(() {
          isLoading = false;
        });
      } else {
        await CommunFun.showToast(
            context, "You have finished you purchased item.");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      CommunFun.showToast(context, Strings.please_select_customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Widget tableHeader1() {
      // products Header part 1
      return Container(
        height: SizeConfig.safeBlockVertical * 11,
        padding: EdgeInsets.only(left: 10, right: 10),
        width: MediaQuery.of(context).size.width / 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: SizeConfig.safeBlockVertical * 5,
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  Strings.wineStorage,
                  style: Styles.whiteCommun(),
                ),
              ],
            ),
            customer == null
                ? Container(
                    child: RaisedButton(
                      onPressed: () {
                        opneShowAddCustomerDailog();
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: SizeConfig.safeBlockVertical * 4,
                          ),
                          SizedBox(width: 5),
                          Text(Strings.select_customer,
                              style: Styles.whiteBoldsmall()),
                        ],
                      ),
                      color: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      removeCustomer();
                    },
                    child: Chip(
                      backgroundColor: Colors.deepOrange,
                      avatar: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        customer.name,
                        style: Styles.whiteBoldsmall(),
                      ),
                    ),
                  ),
          ],
        ),
      );
    }

    final _tabs = TabBar(
      controller: _tabController,
      indicatorSize: TabBarIndicatorSize.label,
      unselectedLabelColor: Colors.white,
      labelColor: Colors.white,
      isScrollable: true,
      labelPadding: EdgeInsets.all(2),
      indicatorPadding: EdgeInsets.all(2),
      indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Colors.deepOrange),
      tabs: List<Widget>.generate(racList.length, (int index) {
        return new Tab(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: SizeConfig.safeBlockHorizontal * 2,
            ),
            child: Text(
              racList[index].name.toUpperCase(),
              style: Styles.whiteBoldsmall(),
            ),
          ),
        );
      }),
    );

    Widget boxList() {
      var size = MediaQuery.of(context).size;
      final double itemHeight = size.height / 3.2;
      final double itemWidth = size.width / 3.2;
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 10, bottom: 20, left: 0, right: 0),
        child: GridView.count(
          crossAxisSpacing: 9.0,
          mainAxisSpacing: 9.0,
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: isEditing ? 4 : 6,
          children: boxsList.map((product) {
            return InkWell(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              onTap: () {
                //addtoInventory(product);
                openInvtQtyPop(product);
              },
              child: Container(
                width: itemWidth,
                height: itemHeight,
                margin: EdgeInsets.all(2),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
                child: Hero(
                  tag: product.boxId,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          product.name.toUpperCase(),
                          style: Styles.blackMediumBold(),
                        ),
                        Text(
                          product.wineQty != null
                              ? "QTY : " + product.wineQty.toString()
                              : "QTY : 0",
                          style: Styles.blackMediumBold(),
                        ),
                      ]),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Scaffold(
      body: LoadingOverlay(
          child: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Table(
                border: TableBorder.all(color: Colors.white, width: 0.6),
                columnWidths: {
                  0: FractionColumnWidth(.6),
                  1: FractionColumnWidth(.3),
                },
                children: [
                  TableRow(children: [
                    TableCell(child: tableHeader1()),
                  ]),
                  TableRow(children: [
                    TableCell(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: SizeConfig.safeBlockVertical * 8,
                              color: Colors.black26,
                              padding: EdgeInsets.only(
                                  top: SizeConfig.safeBlockVertical * 1.3,
                                  bottom: SizeConfig.safeBlockVertical * 1.3,
                                  left: SizeConfig.safeBlockVertical * 2,
                                  right: SizeConfig.safeBlockVertical * 2),
                              child: DefaultTabController(
                                  initialIndex: 0,
                                  length: racList.length,
                                  child: _tabs),
                            ),
                            SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Container(
                                // padding: EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width: isEditing
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.5
                                            : MediaQuery.of(context).size.width,
                                        child: boxsList.length > 0
                                            ? boxList()
                                            : SizedBox(),
                                      ),
                                      customerInvList()
                                    ]),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          isLoading: isLoading,
          color: Colors.black87,
          progressIndicator: CommunFun.overLayLoader()),
    );
  }

  Widget customerInvList() {
    return isEditing
        ? Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width / 3.5,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: ListView(
              shrinkWrap: true,
              children: inventoryData.map((invItem) {
                return ListTile(
                  title: Text(invItem.name, style: Styles.whiteSmall()),
                  subtitle: Text(
                      "Expire on : " +
                          DateFormat('EEE, MMM d yyyy, hh:mm aaa')
                              .format(DateTime.parse(invItem.clExpiredOn)),
                      style: Styles.greylight()),
                  isThreeLine: true,
                  trailing: Text("Qty: " + invItem.clLeftQuantity.toString(),
                      style: Styles.whiteSmall()),
                );
              }).toList(),
            ),
          )
        : SizedBox();
  }
}
