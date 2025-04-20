import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_item_card_widget.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_place_card_widget.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_place_details_widget.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';

class BorrowRequestParticipantsCard extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Function? onImageTap;
  final Widget? buttonsContainer;
  final RequestModel? requestModel;
  final BorrowAcceptorModel? borrowAcceptorModel;
  final BuildContext? context;
  final List<LendingModel>? lendingModelList;
  final LendingModel? lendingPlaceModel;

  const BorrowRequestParticipantsCard(
      {Key? key,
      this.padding,
      this.onImageTap,
      this.buttonsContainer = const SizedBox(),
      this.requestModel,
      this.context,
      this.borrowAcceptorModel,
      this.lendingModelList,
      this.lendingPlaceModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    logger.e('requestModel.roomOrTool: ' + requestModel!.roomOrTool.toString());
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 35,
                  child: ClipOval(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomNetworkImage(
                        (borrowAcceptorModel!.acceptorphotoURL != null &&
                                borrowAcceptorModel!.acceptorphotoURL != '')
                            ? borrowAcceptorModel!.acceptorphotoURL!
                            : defaultUserImageURL!,
                        fit: BoxFit.cover,
                        onTap: onImageTap as VoidCallback?,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 115,
                      child: Text(
                        borrowAcceptorModel!.acceptorName!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      requestModel!.roomOrTool == LendingType.PLACE.readable
                          ? lendingPlaceModel!
                                  .lendingPlaceModel!.contactInformation ??
                              ''
                          : borrowAcceptorModel!.acceptorEmail ??
                              '', //add date on which potential borrower requested
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                SizedBox(width: 8),
                buttonsContainer!
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                requestModel!.roomOrTool == LendingType.ITEM.readable
                    //borrowAcceptorModel.borrowedItemsIds need to fetch data using the ids
                    ? Container(
                        // height: 400,
                        width: 300,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: lendingModelList!.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  LendingItemCardWidget(
                                    lendingItemModel: lendingModelList![index]
                                        .lendingItemModel!,
                                    hidden: true,
                                  ),
                                  SizedBox(height: 10),
                                ],
                              );
                            }),
                      )
                    : Container(
                        // width: 370,
                        child: Expanded(
                          child: Column(
                            children: [
                              LendingPlaceDetailsWidget(
                                lendingModel: lendingPlaceModel!,
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Chip(
                  label: Text(
                    requestModel!.approvedUsers!
                            .contains(borrowAcceptorModel!.acceptorEmail)
                        ? (borrowAcceptorModel!.borrowAgreementLink == '' ||
                                borrowAcceptorModel!.borrowAgreementLink ==
                                    null)
                            ? S.of(context).agreement_accepted
                            : S.of(context).agreement_signed
                        : S.of(context).agreement_to_be_signed,
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            addressComponent,
            SizedBox(height: 5),
            Divider(
              color: Colors.grey[100],
              thickness: 1.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget get addressComponent {
    return requestModel!.address != null
        ? CustomListTile(
            leading: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.location_on,
                color: Colors.black,
              ),
            ),
            title: Text(
              S.of(context!).location,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              maxLines: 1,
            ),
            subtitle: borrowAcceptorModel!.selectedAddress != null
                ? Text(borrowAcceptorModel!.selectedAddress!)
                : Text(''),
          )
        : Container();
  }
}
