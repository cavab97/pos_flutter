import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcncashier/components/constant.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/commanutils.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/models/Customer.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'package:mcncashier/models/MST_Cart_Details.dart';
import 'package:mcncashier/models/Reservation.dart';
import 'package:mcncashier/models/SetMeal.dart';
import 'package:mcncashier/models/User.dart';
import 'package:mcncashier/models/mst_sub_cart_details.dart';
import 'package:mcncashier/screens/ProductQuantityDailog.dart';
import 'package:mcncashier/screens/reservation/SelectTablesList.dart';
import 'package:mcncashier/theme/Sized_Config.dart';
import 'package:mcncashier/models/TableDetails.dart';
import 'package:mcncashier/screens/SearchCustomer.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:date_time_picker/date_time_picker.dart';

class ReservationDetail extends StatefulWidget {
  ReservationDetail({
    Key key,
    this.selTable,
    this.reservationID,
    this.reservation,
    @required this.isUpdate,
    this.onClose,
  }) : super(key: key);
  final TablesDetails selTable;
  final String reservationID;
  final bool isUpdate;
  final Reservation reservation;
  final Function onClose;
  @override
  _ReservationDetailState createState() => _ReservationDetailState();
}

class _ReservationDetailState extends State<ReservationDetail> {
  FocusNode searchItemFocusNode = new FocusNode();
  List<FocusNode> enterFocusNode = List<FocusNode>.generate(
      10, (index) => new FocusNode()); //List.filled(4,  new FocusNode());

  final key = new GlobalKey<ScaffoldState>();
  int currentFocus = 0;
  String branchID;
  int tableID;
  List<ProductDetails> productList = [];
  List<ProductDetails> searchProductList = [];
  List<MSTCartdetails> cartItems = [];
  List<TablesDetails> tableList = [];
  List<MSTSubCartdetails> cartModifierList = [];
  List<MSTSubCartdetails> cartAttributesList = [];
  TablesDetails currentResTable;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _resNoController = TextEditingController();
  TextEditingController _tableNameController = TextEditingController();
  TextEditingController _memeberNoController = TextEditingController();
  TextEditingController _memberNameController = TextEditingController();
  TextEditingController _memberPhoneController = TextEditingController();
  TextEditingController _paxController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  TextEditingController _dateFromController = TextEditingController();
  TextEditingController _dateToController = TextEditingController();
  List<bool> cartItemSelected = [];
  int tempCartID = 0;

  @override
  void initState() {
    super.initState();
    afterInit();
  }

  afterInit() async {
    await getBranchID();
    getItem();
    await getTables();
    if (widget.isUpdate) {
      getReservationDetail();
      getReservationItemList();

      if (widget.reservation != null) {
        Reservation currentReservation = widget.reservation;
        TablesDetails tb = tableList
            .firstWhere((ele) => ele.tableId == currentReservation.tableID);
        setState(() {
          _dateFromController.text =
              DateTime.tryParse(currentReservation.resFrom).toString();
          _dateToController.text =
              DateTime.tryParse(currentReservation.resTo).toString();
          _memberPhoneController.text = currentReservation.customerPhone;
          _memberNameController.text = currentReservation.customerName;
          _memeberNoController.text = currentReservation.customerID;
          _paxController.text = currentReservation.pax.toString();
          _tableNameController.text = tb.tableName;
          _remarkController.text = currentReservation.remark;
          tableID = tb.tableId;
        });
      }
    } else {
      setResNoController();
      setState(() {
        _dateFromController.text =
            DateTime.now().add(Duration(minutes: 15)).toString();
        _dateToController.text =
            DateTime.now().add(Duration(hours: 1, minutes: 15)).toString();
      });
    }
    if (widget.selTable != null) {
      setTableName();
    }
    _searchController.addListener(() {
      getSearchList(_searchController.text.toString());
    });

    FocusScope.of(context).requestFocus(enterFocusNode[0]);
  }

  setTableName() async {
    setState(() {
      currentResTable = widget.selTable;
      _tableNameController.text = widget.selTable.tableName;
      tableID = widget.selTable.tableId;
    });
  }

  setResNoController() async {
    _resNoController.text = "{New}";
  }

  getItem() async {
    List<ProductDetails> products = await localAPI.getAllProduct(branchID);
    setState(() {
      productList = products;
      searchProductList = products;
    });
  }

  getBranchID() async {
    String branchid = await CommunFun.getbranchId();
    setState(() {
      branchID = branchid;
    });
  }

  getTables() async {
    List<TablesDetails> tables = await localAPI.getTables(branchID);
    setState(() {
      tableList = tables;
    });
  }

  getReservationDetail() async {
    setState(() {
      _resNoController.text = widget.reservationID;
    });
  }

  getReservationItemList() async {
    List<MSTCartdetails> reservationItems =
        await localAPI.getReservationItems(widget.reservationID);
    setState(() {
      cartItems = reservationItems;
      cartItemSelected =
          List<bool>.generate(cartItems.length, (index) => false);
    });
  }

  editProduct(MSTCartdetails cartDetails) async {
    var product;
    bool isSetMeal = false;
    if (cartDetails.issetMeal > 0) {
      List<SetMeal> productdt =
          await localAPI.setmealData(cartDetails.productId);
      product = productdt[0];
      isSetMeal = true;
    } else {
      product = productList
          .firstWhere((ele) => ele.productId == cartDetails.productId);
    }
    int selecteCartID = cartItemSelected.indexOf(true);
    List<MSTSubCartdetails> extraSubDetail = [];
    extraSubDetail.addAll(cartModifierList
        .where((ele) => ele.cartdetailsId == selecteCartID)
        .toList());
    extraSubDetail.addAll(cartAttributesList
        .where((ele) => ele.cartdetailsId == selecteCartID)
        .toList());
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return ProductQuantityDailog(
            selproduct: product,
            issetMeal: isSetMeal,
            cartItem: cartDetails,
            extraSubDetail: extraSubDetail,
            addReservation: (MSTCartdetails itemWithDetail,
                List<MSTSubCartdetails> modifierSelected,
                List<MSTSubCartdetails> attrSelected) {
              itemWithDetail.cartId = tempCartID;
              for (int i = 0; i < modifierSelected.length; i++) {
                modifierSelected[i].cartdetailsId = tempCartID;
              }
              for (int i = 0; i < attrSelected.length; i++) {
                attrSelected[i].cartdetailsId = tempCartID;
              }
              for (int i = 0; i < cartModifierList.length; i++) {
                if (cartModifierList[i].cartdetailsId == selecteCartID) {
                  cartModifierList.removeAt(i);
                }
              }
              for (int i = 0; i < cartAttributesList.length; i++) {
                if (cartAttributesList[i].cartdetailsId == selecteCartID) {
                  cartAttributesList.removeAt(i);
                }
              }
              cartItems[selecteCartID] = itemWithDetail;
              cartAttributesList.addAll(attrSelected);
              cartModifierList.addAll(modifierSelected);
            });
      },
    );
  }

  selectProduct(ProductDetails product) async {
    MSTCartdetails item = new MSTCartdetails();
    bool isSetMeal = product.isSetMeal ?? false;
    if (isSetMeal || product.attrCat != null) {
      showDialog(
          context: context,
          // barrierDismissible: false,
          builder: (BuildContext context) {
            return ProductQuantityDailog(
                selproduct: product,
                issetMeal: isSetMeal,
                addReservation: (MSTCartdetails itemWithDetail,
                    List<MSTSubCartdetails> modifierSelected,
                    List<MSTSubCartdetails> attrSelected) {
                  itemWithDetail.cartId = tempCartID;
                  for (int i = 0; i < modifierSelected.length; i++) {
                    modifierSelected[i].cartdetailsId = tempCartID;
                  }
                  for (int i = 0; i < attrSelected.length; i++) {
                    attrSelected[i].cartdetailsId = tempCartID;
                  }
                  item = itemWithDetail;
                  addItemToCart(item, modifierSelected, attrSelected);
                });
          });
    } else {
      item = await CommunFun.addReservationItem(product);
      addItemToCart(item);
    }
  }

  addItemToCart(MSTCartdetails item,
      [List<MSTSubCartdetails> itemModifierList,
      List<MSTSubCartdetails> itemAttributesList]) {
    if (this.mounted) {
      setState(() {
        cartItems.add(item);
        if (itemModifierList != null && itemModifierList.length > 0) {
          cartModifierList.addAll(itemModifierList);
        }
        if (itemAttributesList != null && itemAttributesList.length > 0) {
          cartAttributesList.addAll(itemAttributesList);
        }
        tempCartID++;
        cartItemSelected.add(false);
      });
    }
  }

  getSearchList(String seachText) async {
    seachText = seachText.trim();
    if (seachText != "") {
      var branchid = await CommunFun.getbranchId();
      List<ProductDetails> product =
          productList.where((ele) => ele.hasSetmeal != 0).toList();
      if (double.tryParse(seachText) != null) {
        product =
            product.where((ele) => ele.price == double.tryParse(seachText));
      } else if (seachText.isNotEmpty && product.length > 0) {
        String sText = seachText.toLowerCase();
        product = product.where((ele) {
          bool isSKU =
              ele.sku != null ? ele.sku.toLowerCase().contains(sText) : false;
          bool isName =
              ele.name != null ? ele.name.toLowerCase().contains(sText) : false;
          bool isName2 = ele.name_2 != null
              ? ele.name_2.toLowerCase().contains(sText)
              : false;
          return (isSKU || isName || isName2);
        }).toList();
      }
      List<SetMeal> setMeal =
          await localAPI.getSearchSetMealsData(seachText.toString(), branchid);

      setMeal.forEach((element) {
        ProductDetails cartItemproduct = new ProductDetails();
        cartItemproduct.price = double.parse(element.price.toStringAsFixed(2));
        cartItemproduct.status = element.status;
        cartItemproduct.productId = element.setmealId;
        cartItemproduct.base64 = element.base64;
        cartItemproduct.name = element.name;
        cartItemproduct.uuid = element.uuid;
        cartItemproduct.isSetMeal = true;
        product.add(cartItemproduct);
      });
      setState(() {
        searchProductList = product.length > 0 ? product : [];
      });
    } else {
      setState(() {
        searchProductList =
            productList.length > 10 ? productList.sublist(0, 10) : productList;
      });
    }
  }

  openShowAddCustomerDailog() {
    /* SyncAPICalls.logActivity(
            "menu", "clicked add customer menu item", "menu", 1); */
    // Send receipt Popup
    showDialog(
        context: context,
        //barrierDismissible: false,
        builder: (BuildContext context) {
          return SearchCustomerPage(
              onClose: () {
                //refreshAfterAction();
                checkCustomerSelected();
              },
              isFor: Constant.dashboard);
        });
  }

  openSelectTable() {
    /* SyncAPICalls.logActivity(
            "menu", "clicked add customer menu item", "menu", 1); */
    // Send receipt Popup
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SelectTablesList(
              tableList: tableList.where((ele) => ele.tableType == 1).toList(),
              onClose: (TablesDetails selectedTable) {
                if (this.mounted) {
                  setState(() {
                    currentResTable = selectedTable;
                    tableID = selectedTable.tableId;
                    _tableNameController.text = selectedTable.tableName;
                  });
                }
              });
        });
  }

  checkCustomerSelected() async {
    Customer customerData = await CommunFun.getCustomer();
    setState(() {
      _memeberNoController.text = customerData.phonecode.toString();
      _memeberNoController.value =
          TextEditingValue(text: customerData.customerId.toString());
      _memberPhoneController.text = customerData.phonecode.toString();
      _memberNameController.text = customerData.name;
    });
  }

  createReservation() async {
    Reservation reservation = new Reservation();
    User userdata = await CommunFun.getuserDetails();
    String dateString = await CommunFun.getCurrentDateTime(DateTime.now());
    reservation.updatedBy = reservation.createdBy = userdata.id;
    String resNo = "";
    String tableName = _tableNameController.text.trim();
    String lastResNo = await localAPI.getLastReservationID();
    if (_resNoController.text == "{New}") {
      String prefix = tableName.toUpperCase() + '-RS';
      lastResNo =
          lastResNo.split('-').length > 1 ? lastResNo.split('-')[1] : lastResNo;
      lastResNo = lastResNo.replaceAll(new RegExp(r'[^0-9]'), "");
      lastResNo = ((int.tryParse(lastResNo) ?? 0) + 1).toString();
      resNo = prefix + lastResNo.padLeft(6, "0");
    } else
      resNo = _resNoController.text.trim();
    resNo = resNo.trim();
    reservation.resNo = resNo;
    reservation.pax = _paxController.text.trim().isNotEmpty
        ? int.tryParse(_paxController.text)
        : 0;
    reservation.customerID = _memeberNoController.text.trim();
    reservation.customerName = _memberNameController.text.trim();
    reservation.customerPhone = _memberPhoneController.text.trim();
    reservation.terminalID = int.tryParse(await CommunFun.getTeminalKey());
    reservation.tableID = tableID;
    reservation.updatedAt = reservation.createdAt = dateString;
    dateString = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.tryParse(_dateFromController.text));
    reservation.resFrom = dateString;
    dateString = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.tryParse(_dateToController.text));
    reservation.resTo = dateString;
    reservation.remark = _remarkController.text.trim();
    int lastResID = await localAPI.addReservation(reservation);
    if (lastResID != 0) {
      //success;
      localAPI.insertReservationProduct(
        cartItems,
        resNo,
        cartModifierList,
        cartAttributesList,
      );
      if (widget.onClose != null) {
        widget.onClose(reservation);
      }
      Navigator.of(context).pop();
    }
  }

  updateReservation() async {
    Reservation reservation = widget.reservation;
    User userdata = await CommunFun.getuserDetails();
    String dateString = await CommunFun.getCurrentDateTime(DateTime.now());
    String oldResNo = reservation.resNo;
    reservation.pax = _paxController.text.trim().isNotEmpty
        ? int.tryParse(_paxController.text)
        : 0;
    reservation.resNo = _resNoController.text.trim();
    reservation.customerID = _memeberNoController.text.trim();
    reservation.customerName = _memberNameController.text.trim();
    reservation.customerPhone = _memberPhoneController.text.trim();
    reservation.tableID = tableID;
    reservation.updatedBy = userdata.id;
    reservation.updatedAt = dateString;
    dateString = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.tryParse(_dateFromController.text));
    reservation.resFrom = dateString;
    dateString = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.tryParse(_dateToController.text));
    reservation.resTo = dateString;

    await localAPI.addReservation(reservation, reservation.id);

    await localAPI.insertReservationProduct(
      cartItems,
      oldResNo,
      cartModifierList,
      cartAttributesList,
      reservation.resNo,
    );
    widget.onClose(reservation);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    bool keyboardShow = MediaQuery.of(context).viewInsets.bottom > 0;
    return AlertDialog(
      insetPadding:
          keyboardShow ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30.0),
        ),
      ),
      titlePadding: EdgeInsets.zero,
      title: keyboardShow
          ? SizedBox(
              width: MediaQuery.of(context).size.width * .9,
            )
          : Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
              width: MediaQuery.of(context).size.width * 0.95,
              child: Text(Strings.reservation),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black),
                ),
              ),
            ),
      content: Column(
        children: [
          keyboardShow &&
                  (MediaQuery.of(context).size.height -
                          MediaQuery.of(context).viewInsets.bottom) <
                      380 &&
                  searchItemFocusNode.hasFocus
              ? SizedBox()
              : Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (searchItemFocusNode.hasFocus) {
                        searchItemFocusNode.unfocus();
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Table(
                              defaultColumnWidth: MaxColumnWidth(
                                FractionColumnWidth(0.1),
                                FlexColumnWidth(1),
                              ),
                              columnWidths: {
                                //0: FractionColumnWidth(.2),
                                //0: FixedColumnWidth(10),
                                //0: FractionColumnWidth(0.1),
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(2),
                              },
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        Strings.reservationNo + ' :',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    TextField(
                                      controller: _resNoController,
                                      //initialValue: (widget.isUpdate ? '1' : '{New}'),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        Strings.tableNo + ' :',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: TextField(
                                        controller: _tableNameController,
                                        readOnly: true,
                                        enableInteractiveSelection: true,
                                        onTap: () => openSelectTable(),
                                        /* focusNode: new FocusNode(),
                                enabled: false, */
                                        decoration: InputDecoration(
                                          hintText: Strings.selectTable,
                                          focusedBorder: OutlineInputBorder(),
                                          border: OutlineInputBorder(),
                                          suffixIcon: InkWell(
                                            child: Icon(Icons.add, size: 18),
                                            //onTap: () => openShowAddCustomerDailog(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        Strings.pax + ' :',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: TextFormField(
                                        controller: _paxController,
                                        maxLength: 2,
                                        focusNode: enterFocusNode[0],
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                        ],
                                        decoration: InputDecoration(
                                          hintText:
                                              Strings.enterWith + Strings.pax,
                                          fillColor: Colors.white,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.blue),
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        onFieldSubmitted: (_) {
                                          FocusScope.of(context)
                                              .requestFocus(enterFocusNode[1]);
                                          if (this.mounted) {
                                            setState(() {
                                              currentFocus = 2;
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        Strings.memberNo + ' :',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: TextField(
                                        readOnly: true,
                                        enableInteractiveSelection: true,
                                        onTap: () =>
                                            openShowAddCustomerDailog(),
                                        controller: _memeberNoController,
                                        decoration: InputDecoration(
                                          hintText: Strings.enterMemberNum,
                                          focusedBorder: OutlineInputBorder(),
                                          border: OutlineInputBorder(),
                                          suffixIcon: InkWell(
                                            child: Icon(Icons.add, size: 18),
                                            onTap: () =>
                                                openShowAddCustomerDailog(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        Strings.customerName + ' :',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: TextFormField(
                                        focusNode: enterFocusNode[1],
                                        controller: _memberNameController,
                                        decoration: InputDecoration(
                                          hintText: Strings.enterWith +
                                              Strings.customerName,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.blue,
                                            ),
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        onFieldSubmitted: (_) {
                                          FocusScope.of(context).requestFocus(
                                              enterFocusNode[currentFocus]);
                                          if (this.mounted) {
                                            setState(() {
                                              currentFocus++;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        Strings.customerPhone + ' :',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    TextFormField(
                                      maxLength: 15,
                                      focusNode: enterFocusNode[2],
                                      controller: _memberPhoneController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]')),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: Strings.enterWith +
                                            Strings.customerPhone,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context).requestFocus(
                                            enterFocusNode[currentFocus]);
                                        if (this.mounted) {
                                          setState(() {
                                            currentFocus++;
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value.trim().isEmpty) {
                                          return 'Please enter ' +
                                              Strings.customerPhone +
                                              '.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        Strings.reserveFrom + ' :',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    DateTimePicker(
                                      //textAlignVertical: TextAlignVertical.center,
                                      type: DateTimePickerType.dateTime,
                                      controller: _dateFromController,
                                      dateMask: 'dd/MM hh:mm a',
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 14)),
                                      //dateLabelText: 'Select a time',
                                      validator: (val) {
                                        print(val);
                                        return null;
                                      },
                                      onSaved: (val) => print(val),
                                    ),
                                    //TextFormField(),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        Strings.reserveUntil + ' :',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    DateTimePicker(
                                      //textAlignVertical: TextAlignVertical.center,
                                      type: DateTimePickerType.dateTime,
                                      controller: _dateToController,
                                      dateMask: 'dd/MM hh:mm a',
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 14)),
                                      //dateLabelText: 'Select a time',
                                      validator: (val) {
                                        print(val);
                                        return null;
                                      },
                                      onSaved: (val) => print(val),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              if (searchItemFocusNode.hasFocus) {
                                searchItemFocusNode.unfocus();
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Remark' + ' :'),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      maxLength: 255,
                                      controller: _remarkController,
                                      focusNode: enterFocusNode[3],
                                      keyboardType: TextInputType.multiline,
                                      minLines: 5,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        hintText: "A sample remark",
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      textInputAction: TextInputAction.done,
                                      onEditingComplete: () {
                                        FocusScope.of(context)
                                            .requestFocus(searchItemFocusNode);
                                        if (this.mounted) {
                                          setState(() {
                                            currentFocus = 0;
                                          });
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 280,
                            child: TypeAheadField(
                              textFieldConfiguration: TextFieldConfiguration(
                                onSubmitted: (result) {
                                  if (searchProductList.length > 0) {
                                    selectProduct(searchProductList[0]);
                                    if (this.mounted) {
                                      setState(() {
                                        _searchController.text = "";
                                        FocusScope.of(context)
                                            .requestFocus(searchItemFocusNode);
                                      });
                                    }
                                  }
                                },
                                focusNode: searchItemFocusNode,
                                controller: _searchController,
                                style: Styles.communBlacksmall(),
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        left: 20, top: 15, bottom: 15),
                                    suffixIcon: Padding(
                                      padding: EdgeInsets.only(
                                          right:
                                              SizeConfig.safeBlockVertical * 3),
                                      child: Icon(
                                        Icons.add,
                                        color: StaticColor.deepOrange,
                                        size: SizeConfig.safeBlockVertical * 5,
                                      ),
                                    ),
                                    hintText: Strings.searchBarText,
                                    hintStyle: Styles.communGrey(),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: StaticColor.colorWhite),
                              ),
                              suggestionsCallback: (pattern) async {
                                return searchProductList;
                              },
                              itemBuilder:
                                  (context, ProductDetails searchProductList) {
                                return ListTile(
                                    leading: Container(
                                      color: StaticColor.colorGrey,
                                      width: 40,
                                      height: 40,
                                      child: searchProductList.base64 != ""
                                          ? CommonUtils.imageFromBase64String(
                                              searchProductList.base64)
                                          : new Image.asset(
                                              Strings.noImageAsset,
                                              gaplessPlayback: true,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    title: Text(
                                      searchProductList.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(searchProductList.price
                                            .toStringAsFixed(2) ??
                                        "0.00"),
                                    trailing: searchProductList.outOfStock ==
                                                1 ||
                                            (searchProductList.qty != null &&
                                                searchProductList
                                                        .hasInventory ==
                                                    1 &&
                                                searchProductList.qty <= 0)
                                        ? Text(Strings.outOfStoke,
                                            style: Styles.orangesimpleSmall())
                                        : SizedBox());
                              },
                              onSuggestionSelected:
                                  (ProductDetails selectedProduct) async {
                                _searchController.text = "";
                                if (selectedProduct.outOfStock != 1 ||
                                    (selectedProduct.hasInventory == 1 &&
                                        selectedProduct.qty > 0.0)) {
                                  await selectProduct(selectedProduct);
                                } else {
                                  CommunFun.showToast(
                                      context, Strings.outOfStokeMsg);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: RaisedButton.icon(
                              icon: Icon(Icons.remove),
                              label: Text('Delete'),
                              onPressed: cartItemSelected
                                          .where((ele) => ele)
                                          .length >
                                      0
                                  ? () {
                                      int selectedLength = cartItemSelected
                                          .where((ele) => ele)
                                          .length;
                                      CommonUtils.showAlertDialog(
                                        context,
                                        () {
                                          Navigator.of(context).pop();
                                        },
                                        () {
                                          for (int index = 0;
                                              index < cartItems.length;
                                              index++) {
                                            if (cartItemSelected[index] &&
                                                this.mounted) {
                                              setState(() {
                                                cartItems.removeAt(index);
                                                cartItemSelected
                                                    .removeAt(index);
                                              });
                                            }
                                          }
                                          Navigator.of(context).pop();
                                        },
                                        "Remove Item",
                                        "Are you sure you want to remove " +
                                            (selectedLength == 1
                                                ? (cartItems[cartItemSelected
                                                            .indexOf(true)]
                                                        .productName) +
                                                    "?"
                                                : "this " +
                                                    selectedLength.toString() +
                                                    " items?"),
                                        "Yes",
                                        "No",
                                        true,
                                      );
                                    }
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: RaisedButton.icon(
                              icon: Icon(Icons.edit),
                              label: Text('Edit Qty'),
                              onPressed:
                                  cartItemSelected.where((ele) => ele).length ==
                                          1
                                      ? () {
                                          editProduct(cartItems[
                                              cartItemSelected.indexOf(true)]);
                                        }
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        showCheckboxColumn: true,
                        columnSpacing:
                            (MediaQuery.of(context).size.width * .85 / 4),
                        columns: const <DataColumn>[
                          DataColumn(
                              label: Text(
                            'Item Code',
                            overflow: TextOverflow.ellipsis,
                          )),
                          DataColumn(
                              label: Text(
                            'Item Name',
                            overflow: TextOverflow.ellipsis,
                          )),
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Remark')),
                        ],
                        rows: cartItems.map((item) {
                          int index = cartItems.indexOf(item);
                          ProductDetails product = productList.firstWhere(
                              (ele) => ele.productId == item.productId);
                          return DataRow(
                              cells: [
                                DataCell(
                                    Text(product.sku.toUpperCase().toString())),
                                DataCell(Text(item.productName)),
                                DataCell(
                                  Text(
                                    (item.productQty % 1 == 0
                                            ? item.productQty.toInt()
                                            : item.productQty)
                                        .toString(),
                                  ),
                                ),
                                DataCell(Text(item.remark)),
                              ],
                              selected: cartItemSelected[index],
                              onSelectChanged: (bool selected) {
                                searchItemFocusNode.unfocus();
                                setState(() {
                                  cartItemSelected[index] = selected;
                                });
                              });
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 20),
      actions: keyboardShow
          ? []
          : [
              FlatButton.icon(
                color: Colors.green,
                icon: Icon(Icons.check),
                label: Text(widget.isUpdate ? Strings.update : Strings.add),
                onPressed:
                    widget.isUpdate ? updateReservation : createReservation,
              ),
              FlatButton.icon(
                  color: Colors.red,
                  icon: Icon(Icons.close),
                  label: Text(Strings.cancel),
                  onPressed: () => Navigator.of(context).pop()),
            ],
    );
  }
}
