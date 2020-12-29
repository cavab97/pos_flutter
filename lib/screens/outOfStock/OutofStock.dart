import 'package:flutter/material.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mcncashier/components/colors.dart';
import 'package:mcncashier/components/styles.dart';
import 'package:mcncashier/components/communText.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/models/PorductDetails.dart';
import 'AplhabetWidgetList.dart';

class OutofStock extends StatefulWidget {
  @override
  _OutofStockState createState() => _OutofStockState();
}

class _OutofStockState extends State<OutofStock> {
  List<ProductDetails> itemWithStock = [];
  List<ProductDetails> itemNoStock = [];
  List<ProductDetails> filterItemWithStock = [];
  List<ProductDetails> filterItemNoStock = [];
  List<int> selectedStockIds = [];
  String currentSelectedPart = "";
  TextEditingController withStockSearchController = TextEditingController();
  TextEditingController noStockSearchController = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getItem();
    noStockSearchController.addListener(() {
      filterNoStockList(itemNoStock);
    });
    withStockSearchController.addListener(() {
      filterWithStockList(itemWithStock);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getItem() async {
    String branchid = await CommunFun.getbranchId();
    List<ProductDetails> product = await localAPI.getAllProduct(branchid);
    for (ProductDetails productDetails in product) {
      productDetails.name = productDetails.name[0].toUpperCase() +
          productDetails.name.substring(1);
      if (productDetails.outOfStock == 0) {
        itemWithStock.add(productDetails);
      } else {
        itemNoStock.add(productDetails);
      }
    }
    /* if (this.mounted) {
      setState(() {
        itemWithStock;
        itemNoStock;
      });
    } */
    filterNoStockList(itemNoStock);
    filterWithStockList(itemWithStock);
  }

  filterWithStockList(List<ProductDetails> productDetailsList) {
    filterItemWithStock.clear();
    if (withStockSearchController.text.isNotEmpty) {
      filterItemWithStock = productDetailsList
          .where((user) => user.name
              .toLowerCase()
              .contains(withStockSearchController.text.toLowerCase()))
          .toList();
      /* if (filterItemWithStock.length == 0 && productDetailsList.length != 0)
        filterItemWithStock.addAll(productDetailsList); */
    } else {
      filterItemWithStock.addAll(productDetailsList);
    }
    setState(() {
      filterItemWithStock;
    });
  }

  filterNoStockList(List<ProductDetails> productDetailsList) {
    filterItemNoStock.clear();
    if (noStockSearchController.text.isNotEmpty) {
      filterItemNoStock = productDetailsList
          .where((user) => user.name
              .toLowerCase()
              .contains(noStockSearchController.text.toLowerCase()))
          .toList();
      /* if (filterItemNoStock.length == 0 && productDetailsList.length != 0)
        filterItemNoStock.addAll(productDetailsList); */
    } else {
      filterItemNoStock.addAll(productDetailsList);
    }
    setState(() {
      filterItemNoStock;
    });
  }

  addToSelectedIds(int productId, String selectedPart) {
    if (selectedPart != currentSelectedPart) selectedStockIds.clear();
    if (!selectedStockIds.contains(productId))
      selectedStockIds.add(productId);
    else
      selectedStockIds.remove(productId);
    setState(() {
      selectedStockIds;
      currentSelectedPart = selectedPart;
    });
  }

  addToNoStock() {
    if (itemWithStock.length == 0) return;
    for (int selectStockId in selectedStockIds) {
      if (itemWithStock
          .where((element) => element.productId == selectStockId)
          .isEmpty) continue;
      ProductDetails item = itemWithStock
          .firstWhere((element) => element.productId == selectStockId);
      itemWithStock.remove(item);
      itemNoStock.add(item);
    }
    if (this.mounted) {
      setState(() {
        filterNoStockList(itemNoStock);
        filterWithStockList(itemWithStock);
        selectedStockIds = [];
      });
    }
  }

  makeProductWithStock() {
    if (itemNoStock.length == 0) return;
    for (int selectStockId in selectedStockIds) {
      if (itemNoStock
          .where((element) => element.productId == selectStockId)
          .isEmpty) continue;
      ProductDetails product = itemNoStock
          .firstWhere((element) => element.productId == selectStockId);
      itemWithStock.add(product);
      itemNoStock.remove(product);
    }
    if (this.mounted) {
      setState(() {
        filterNoStockList(itemNoStock);
        filterWithStockList(itemWithStock);
        selectedStockIds = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: isLoading,
          color: Colors.black87,
          progressIndicator: CommunFun.overLayLoader(),
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        //SizedBox(width: 10),
                        backButton(),
                        SizedBox(width: 10),
                        Text(
                          'Out of Stock',
                          style: TextStyle(
                              fontSize: 50, color: StaticColor.colorWhite),
                        ),
                        Spacer(),
                        confirmButton(),
                        //SizedBox(width: 10),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    flex: 9,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                color: StaticColor.colorWhite,
                              ),
                              child: aplhabetList(filterItemWithStock,
                                  withStockSearchController, "WithStock")
                              /* AplhabetWidgetList(
                                    inputList: itemWithStock,
                                    callback: addToSelectedIds,
                                    selectedStockIds: selectedStockIds,
                                  ) */
                              //: Column(children: []),
                              ),
                          flex: 3,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MaterialButton(
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 70,
                                  color: StaticColor.colorWhite,
                                ),
                                onPressed: makeProductWithStock,
                              ),
                              SizedBox(height: 20),
                              MaterialButton(
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 70,
                                  color: StaticColor.colorWhite,
                                ),
                                onPressed: addToNoStock,
                              ),
                            ],
                          ),
                          flex: 1,
                        ),
                        Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                color: StaticColor.colorWhite,
                              ),
                              child: aplhabetList(filterItemNoStock,
                                  noStockSearchController, "NoStock")
                              /*  AplhabetWidgetList(
                                    inputList: itemNoStock,
                                    callback: addToSelectedIds,
                                    selectedStockIds: selectedStockIds,
                                  ) */
                              //: Column(children: []),
                              ),
                          flex: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget confirmButton() {
    return ButtonTheme(
      height: 45,
      child: RaisedButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          String branchid = await CommunFun.getbranchId();
          await localAPI.updateProductWithStock(
            itemWithStock.map((e) => e.productId).toList(),
            itemNoStock.map((e) => e.productId).toList(),
            branchid,
          );
          Navigator.of(context).pop();
        },
        child: Row(
          children: <Widget>[
            Icon(
              Icons.save,
              color: StaticColor.colorWhite,
              size: 30,
            ),
            SizedBox(width: 5),
            Text(Strings.update, style: Styles.whiteBoldsmall()),
          ],
        ),
        color: StaticColor.deepOrange,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      ),
    );
  }

  Widget backButton() {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.arrow_back,
        color: StaticColor.colorWhite,
        size: 40,
      ),
    );
  }

  Widget printTestPrint(_onPress) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.4,
      child: RaisedButton(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
        onPressed: _onPress,
        child: Text(
          Strings.printTestRec,
          style: Styles.whiteSimpleSmall(),
        ),
        color: StaticColor.backgroundColor,
        textColor: StaticColor.colorWhite,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1,
              style: BorderStyle.solid,
              color: StaticColor.colorWhite),
        ),
      ),
    );
  }

  Widget aplhabetList(
    List<ProductDetails> productDetailsList,
    TextEditingController searchController,
    String selectedPart,
  ) {
    List<String> strList = [];
    strList.addAll(productDetailsList.map((e) => e.name).toList());
    return AlphabetListScrollView(
      strList: strList,
      highlightTextStyle: TextStyle(
        color: StaticColor.deepOrange,
      ),
      showPreview: true,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(productDetailsList[index].name),
          onTap: () => addToSelectedIds(
              productDetailsList[index].productId, selectedPart),
          selected:
              selectedStockIds.contains(productDetailsList[index].productId),
          selectedTileColor: Colors.black,
        );
        //return normalList[index];
      },
      indexedHeight: (i) {
        return 50;
      },
      keyboardUsage: true,
      headerWidgetList: <AlphabetScrollListHeader>[
        AlphabetScrollListHeader(widgetList: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                suffix: Icon(Icons.search, color: Colors.grey),
                labelText: "Search",
              ),
            ),
          )
        ], icon: Icon(Icons.search), indexedHeaderHeight: (index) => 80),
      ],
    );
  }
}
