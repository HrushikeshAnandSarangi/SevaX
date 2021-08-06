import 'package:flutter/material.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/new_baseline/models/lending_item_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';
import 'package:sevaexchange/utils/utils.dart';

class LendingItemCardWidget extends StatelessWidget {
  final LendingItemModel lendingItemModel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  LendingItemCardWidget({this.lendingItemModel, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 92,
            height: 62,
            child: Image.network(lendingItemModel.itemImages[0]),
          ),
          SizedBox(
            width: 15,
          ),
          Text(
            lendingItemModel.itemName,
            style: TextStyle(
              fontSize: 16,
              //fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: onEdit,
            child: Icon(
              Icons.edit,
              color: HexColor('#606670'),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          InkWell(
            onTap: onDelete,
            child: Icon(
              Icons.cancel_rounded,
              color: HexColor('#BEBEBE'),
            ),
          )
        ],
      ),
    );
  }

  Widget title(String title) {
    return Text(title,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Europa',
          color: HexColor('#9B9B9B'),
        ));
  }
}
