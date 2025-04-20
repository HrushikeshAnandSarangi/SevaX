import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class LendingPlaceCardWidget extends StatelessWidget {
  final LendingPlaceModel? lendingPlaceModel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  bool hidden = false;

  LendingPlaceCardWidget(
      {this.lendingPlaceModel,
      this.onEdit,
      this.onDelete,
      this.hidden = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 186,
            child: Image.network(lendingPlaceModel!.houseImages![0]),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                lendingPlaceModel!.placeName!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Europa',
                  color: Colors.black,
                ),
              ),
              Spacer(),
              HideWidget(
                hide: hidden,
                child: InkWell(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit,
                    color: HexColor('#606670'),
                  ),
                ),
                secondChild: SizedBox.shrink(),
              ),
              SizedBox(
                width: 8,
              ),
              HideWidget(
                hide: hidden,
                child: InkWell(
                  onTap: onDelete,
                  child: Icon(
                    Icons.cancel_rounded,
                    color: HexColor('#BEBEBE'),
                  ),
                ),
                secondChild: SizedBox.shrink(),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              title('${lendingPlaceModel!.noOfGuests}'
                  ' ${S.of(context).guests_text} '),
              title('${lendingPlaceModel!.noOfRooms}'
                  ' ${S.of(context).bed_rooms} .'),
              title('${lendingPlaceModel!.noOfBathRooms}'
                  ' ${S.of(context).bath_rooms} '),
            ],
          )
        ],
      ),
    );
  }
}

Widget title(String title) {
  return Text(title,
      style: TextStyle(
        fontSize: 14,
        fontFamily: 'Europa',
        color: HexColor('#9B9B9B'),
      ));
}
