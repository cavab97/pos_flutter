import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:mcncashier/models/PorductDetails.dart';

class AplhabetWidgetList extends StatefulWidget {
  AplhabetWidgetList(
      {Key key, this.inputList, this.callback, this.selectedStockIds})
      : super(key: key);
  final List<ProductDetails> inputList;
  final List<int> selectedStockIds;
  Function callback;
  @override
  _AplhabetWidgetListState createState() => _AplhabetWidgetListState();
}

class _AplhabetWidgetListState extends State<AplhabetWidgetList> {
  List<String> strList = [];
  List<Widget> normalList = [];
  List<ProductDetails> productDetailsList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    /* for (var i = 0; i < 100; i++) {
      var name = faker.person.name();
      userList.add(User(name, faker.company.name(), false));
    } */
    super.initState();
    productDetailsList.addAll(widget.inputList);
    productDetailsList = productDetailsList.map((e) {
      e.name = e.name[0].toUpperCase() + e.name.substring(1);
      return e;
    }).toList();
    productDetailsList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    filterList();
    searchController.addListener(() {
      filterList();
    });
  }

  filterList() {
    //normalList = [];
    productDetailsList.clear();
    strList = [];
    if (searchController.text.isNotEmpty) {
      productDetailsList = widget.inputList
          .where((user) => user.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    } else {
      productDetailsList.addAll(widget.inputList);
    }
    productDetailsList = productDetailsList.map((product) {
      product.name = product.name[0].toUpperCase() + product.name.substring(1);
      //normalList.add();
      strList.add(product.name);
      return product;
    }).toList();

    setState(() {
      strList;
      productDetailsList;
      //normalList;
    });
  }

  tapFuction(int productId) {
    widget.callback(productId);
    filterList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlphabetListScrollView(
      strList: strList,
      highlightTextStyle: TextStyle(
        color: Colors.yellow,
      ),
      showPreview: true,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(productDetailsList[index].name),
          onTap: () => tapFuction(productDetailsList[index].productId),
          selected: widget.selectedStockIds
              .contains(productDetailsList[index].productId),
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
