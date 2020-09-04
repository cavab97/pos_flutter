import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/components/colors.dart';

class OpeningAmmountPage extends StatefulWidget {
  OpeningAmmountPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OpeningAmmountPageState createState() => _OpeningAmmountPageState();
}

List<StaggeredTile> _staggeredTiles = const <StaggeredTile>[
  const StaggeredTile.count(1, 4),
  const StaggeredTile.count(1, 4),
  const StaggeredTile.count(1, 4),
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(4, 2),
  const StaggeredTile.count(4, 2),
  const StaggeredTile.count(4, 1),
  const StaggeredTile.count(3, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(4, 1),
];

List<Widget> _tiles = const <Widget>[
  const _Example01Tile(Colors.green, Icons.widgets),
  const _Example01Tile(Colors.lightBlue, Icons.wifi),
  const _Example01Tile(Colors.amber, Icons.panorama_wide_angle),
  const _Example01Tile(Colors.brown, Icons.map),
  const _Example01Tile(Colors.deepOrange, Icons.send),
  const _Example01Tile(Colors.indigo, Icons.airline_seat_flat),
  const _Example01Tile(Colors.red, Icons.bluetooth),
  const _Example01Tile(Colors.pink, Icons.battery_alert),
  const _Example01Tile(Colors.purple, Icons.desktop_windows),
  const _Example01Tile(Colors.blue, Icons.radio),
];

class _Example01Tile extends StatelessWidget {
  const _Example01Tile(this.backgroundColor, this.iconData);

  final Color backgroundColor;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    /* return new Card(
      color: backgroundColor,
      child: new InkWell(
        onTap: () {},
        child: new Center(
          child: new Padding(
            padding: const EdgeInsets.all(4.0),
            child: new Icon(
              iconData,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );*/
  }
}

class _OpeningAmmountPageState extends State<OpeningAmmountPage> {
  @override
  Widget build(BuildContext context) {
/*
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Example 01'),
        ),
        body: new Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: new StaggeredGridView.count(
              crossAxisCount: 4,
              staggeredTiles: _staggeredTiles,
              children: _tiles,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              padding: const EdgeInsets.all(4.0),
            )));
*/

    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            height: 70,
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(Strings.title_opening_amount.toUpperCase(),
                    style: TextStyle(fontSize: 25, color: Colors.white)),
              ],
            ),
          ),
          closeButton(context),
        ],
      ),
      content: mainContent(),
    );
  }

  Widget closeButton(context) {
    return Positioned(
        top: -30,
        right: -20,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(30.0)),
            child: Icon(
              Icons.clear,
              color: Colors.white,
              size: 30,
            ),
          ),
        ));
  }

  Widget mainContent() {
    return Column(
      children: [getAmount(), getNumbers(context)],
    );
  }

  Widget _button(String number, Function() f) {
    // Creating a method of return type Widget with number and function f as a parameter
    return Padding(
      padding: EdgeInsets.all(5),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.grey)),
        height: 90.0,
        child: Text(number,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
        textColor: Colors.black,
        color: Colors.grey[100],
        onPressed: f,
      ),
    );
  }

  Widget getAmount() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("00.00",
              style: TextStyle(
                  fontSize: 50,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget getNumbers(context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _button("1", () {}), // using custom widget button
                _button("2", () {}),
                _button("3", () {}),
                _button("<-", () {}),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _button("4", () {}), // using custom widget button
                _button("5", () {}),
                _button("6", () {}),
                _button(".", () {}),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: _button("7", () {})),
                      // using custom widget button
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: _button("8", () {})),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: _button("9", () {})),
                    ],
                  ),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: _button("0", () {})),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: _button("00", () {})),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: _button(".", () {})),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.grey)),
                      height: 200.0,
                      child: Text("enter".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0)),
                      textColor: Colors.black,
                      color: Colors.grey[100],
                      onPressed: () {},
                    ),
                  )
                ],
              )
            ]),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5.0)));
  }

  TextStyle buildInputTextStyle(
      {String fontFamily = 'Raleway',
      Color color = colorInput,
      double fontSize = 32.0,
      FontWeight fontWeight = FontWeight.w500}) {
    return TextStyle(
        fontFamily: fontFamily,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: FontStyle.normal);
  }

  Container buildVerticalLine() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      width: 1.0,
      height: MediaQuery.of(context).size.width / 4,
      color: isDark ? colorDarkLine : colorLine,
    );
  }

  Container buildHorizontalLine() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 1.0,
      color: isDark ? colorDarkLine : colorLine,
    );
  }
}
