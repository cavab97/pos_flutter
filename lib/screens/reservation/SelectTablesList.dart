import 'package:flutter/material.dart';
import 'package:mcncashier/components/StringFile.dart';
import 'package:mcncashier/models/TableDetails.dart';

class SelectTablesList extends StatefulWidget {
  SelectTablesList({Key key, this.tableList, this.onClose}) : super(key: key);
  final List<TablesDetails> tableList;
  final Function onClose;
  @override
  _SelectTablesState createState() => _SelectTablesState();
}

class _SelectTablesState extends State<SelectTablesList> {
  TablesDetails selectedTable;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Table'),
      content: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GridView.count(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.8,
          crossAxisCount: 5,
          children: widget.tableList.map(
            (table) {
              String time = "00:00";
              if (table.occupiedMinute != null) {
                var d = Duration(
                    minutes:
                        int.parse(table.occupiedMinute.round().toString()));
                List<String> parts = d.toString().split(':');
                time =
                    '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
              }
              return GestureDetector(
                onTap: () {
                  if (this.mounted) {
                    setState(() {
                      selectedTable = table;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: selectedTable != null &&
                                selectedTable.tableId == table.tableId
                            ? Colors.yellowAccent
                            : Colors.white,
                        border: Border.all(width: 1)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(time),
                          ],
                        ),
                        Text(
                          table.tableName,
                          style: TextStyle(fontSize: 25),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text((table.numberofpax ?? 0).toString()),
                            Text('/' + table.tableCapacity.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 20),
      actions: [
        FlatButton.icon(
          color: Colors.green,
          icon: Icon(Icons.check),
          label: Text(Strings.confirm),
          onPressed: () {
            widget.onClose(selectedTable);
            Navigator.of(context).pop();
          },
        ),
        FlatButton.icon(
          color: Colors.red,
          icon: Icon(Icons.close),
          label: Text(Strings.cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
