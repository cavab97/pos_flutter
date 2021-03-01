import 'package:flutter/material.dart';

class CloseButtonWidget extends StatelessWidget {
  CloseButtonWidget({
    Key key,
    @required this.inputContext,
    this.callback,
  }) : super(key: key);

  final BuildContext inputContext;
  Function callback;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.redAccent[700],
      onPressed: () {
        Navigator.of(inputContext).pop();
        if (this.callback != null) {
          this.callback();
        }
      },
      tooltip: 'Close',
      child: Icon(
        Icons.clear,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

/* return Positioned(
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
            color: StaticColor.colorRed,
            borderRadius: BorderRadius.circular(30.0)),
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.clear,
            color: StaticColor.colorWhite,
            size: 30,
          ),
        ),
      ),
    ),
  ); */