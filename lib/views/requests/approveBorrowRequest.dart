import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/views/requests/requestOfferAgreementForm.dart';
import 'package:sevaexchange/ui/screens/offers/pages/add_update_lending_item.dart';
import 'package:sevaexchange/ui/screens/offers/pages/add_update_lending_place.dart';
import 'package:sevaexchange/ui/screens/offers/pages/agreementForm.dart';
import 'package:sevaexchange/ui/screens/offers/pages/select_lending_place.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dialog.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_item_card_widget.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_place_card_widget.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

class AcceptBorrowRequest extends StatefulWidget {
  final String timeBankId;
  final String userId;
  final RequestModel requestModel;
  final BuildContext parentContext;
  final VoidCallback onTap;

  AcceptBorrowRequest({
    required this.timeBankId,
    required this.userId,
    required this.requestModel,
    required this.parentContext,
    required this.onTap,
  });

  @override
  _AcceptBorrowRequestState createState() => _AcceptBorrowRequestState();
}

class _AcceptBorrowRequestState extends State<AcceptBorrowRequest> {
  GeoPoint? location;
  String selectedAddress = '';

  Future<void> openPdfViewer(
      String pdfUrl, String name, BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgreementForm(
          onPdfCreated: (String pdfLink, String documentNameFinal,
              dynamic agreementConfig, String agreementId) {},
          lendingModel: selectedLendingPlaceModel ??
              LendingModel(
                id: '', // Provide appropriate default or fetch from context
                creatorId:
                    '', // Provide appropriate default or fetch from context
                email: '', // Provide appropriate default or fetch from context
                timestamp: DateTime.now().millisecondsSinceEpoch,
                lendingType: LendingType.PLACE, // or LendingType.ITEM as needed
              ),
          requestModel: widget.requestModel,
          isOffer: false,
          placeOrItem: widget.requestModel.roomOrTool!,
          timebankId: widget.requestModel.timebankId!,
          communityId: widget.requestModel.communityId!,
          lendingModelListBorrowRequest: [],
          startTime: widget.requestModel.requestStart!,
          endTime: widget.requestModel.requestEnd!,
        ),
      ),
    );
  }

  String borrowAgreementLinkFinal = '';
  String agreementIdFinal = '';
  String documentName = '';
  LendingModel? selectedLendingPlaceModel;
  List<LendingModel> selectedItemModels = [];
  List<String> selectedModelsId = [];
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    logger.e('TYPE Alpha Check: ' + widget.requestModel.roomOrTool.toString());
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          S.of(context).accept_borrow_request,
          style: TextStyle(
              fontFamily: "Europa", fontSize: 19, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: widget.requestModel.roomOrTool == LendingType.PLACE.readable
            ? roomForm
            : itemForm,
      ),
    );
  }

  Widget get roomForm {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              S.of(context).details_of_the_request,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              S.of(context).accept_borrow_agreement_place_hint,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).select_a_place_lending,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // InkWell(
                //   onTap: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (context) {
                //           return AddUpdateLendingPlace(
                //             lendingModel: null,
                //             enteredTitle: '',
                //             onPlaceCreateUpdate: (LendingModel model) {
                //               selectedLendingPlaceModel = model;
                //               setState(() {});
                //             },
                //           );
                //         },
                //       ),
                //     );
                //   },
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         S.of(context).add_new,
                //         style: TextStyle(
                //           fontSize: 14,
                //           //fontWeight: FontWeight.bold,
                //           fontFamily: 'Europa',
                //           color: Colors.black,
                //         ),
                //       ),
                //       SizedBox(width: 3),
                //       Icon(Icons.add_circle_rounded,
                //           size: 25, color: Colors.grey[600]),
                //     ],
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 10),
            SelectLendingPlaceItem(
              onSelected: (LendingModel model) {
                selectedLendingPlaceModel = model;
                setState(() {});
              },
              lendingType: LendingType.PLACE,
            ),
            selectedLendingPlaceModel != null
                ? LendingPlaceCardWidget(
                    lendingPlaceModel:
                        selectedLendingPlaceModel!.lendingPlaceModel!,
                    onDelete: () {
                      selectedLendingPlaceModel = null;
                      setState(() {});
                    },
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return AddUpdateLendingPlace(
                              lendingModel: selectedLendingPlaceModel!,
                              onPlaceCreateUpdate: (LendingModel model) {
                                selectedLendingPlaceModel = model;
                                setState(() {});
                              },
                            );
                          },
                        ),
                      );
                    },
                  )
                : Container(),
            SizedBox(height: 20),
            requestAgreementFormComponent(widget.requestModel.roomOrTool!),
            SizedBox(height: 20),
            termsAcknowledegmentText,
            bottomActionButtons,
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget get itemForm {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              S.of(context).accept_borrow_agreement_item_title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            borrowItemsWidget,
            SizedBox(height: 10),
            Text(
              S.of(context).accept_borrow_agreement_page_hint,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).select_item_for_lending,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // InkWell(
                //   onTap: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (context) {
                //           return AddUpdateLendingItem(
                //             lendingModel: null,
                //             enteredTitle: '',
                //             onItemCreateUpdate: (LendingModel model) {
                //               // if (!selectedItemModels.contains(model)) {
                //               selectedItemModels.add(model);
                //               // }
                //               setState(() {});
                //             },
                //           );
                //         },
                //       ),
                //     );
                //   },
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         S.of(context).add_new,
                //         style: TextStyle(
                //           fontSize: 14,
                //           //fontWeight: FontWeight.bold,
                //           fontFamily: 'Europa',
                //           color: Colors.black,
                //         ),
                //       ),
                //       SizedBox(width: 3),
                //       Icon(Icons.add_circle_rounded,
                //           size: 25, color: Colors.grey[600]),
                //     ],
                //   ),
                // ),
              ],
            ),
            SelectLendingPlaceItem(
              onSelected: (LendingModel model) {
                if (!selectedItemModels.contains(model)) {
                  selectedItemModels.add(model);
                }
                setState(() {});
              },
              lendingType: LendingType.ITEM,
            ),
            SizedBox(
              height: 10,
            ),
            ListView.builder(
                itemCount: selectedItemModels.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  LendingModel model = selectedItemModels[index];
                  return LendingItemCardWidget(
                    lendingItemModel: model.lendingItemModel!,
                    onDelete: () {
                      selectedItemModels.remove(model);
                      setState(() {});
                    },
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return AddUpdateLendingItem(
                              lendingModel: model,
                              onItemCreateUpdate: (LendingModel model) {
                                // selectedItemModels.add(model);
                                setState(() {});
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                }),
            SizedBox(height: 20),
            requestAgreementFormComponent(widget.requestModel.roomOrTool!),
            SizedBox(height: 20),
            termsAcknowledegmentText,
            bottomActionButtons,
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget get borrowItemsWidget {
    return Wrap(
      runSpacing: 5.0,
      spacing: 5.0,
      children: widget.requestModel.borrowModel!.requiredItems!.values
          .toList()
          .map(
            (value) => value == null
                ? Container()
                : CustomChipWithTick(
                    label: value,
                    isSelected: true,
                    onTap: () {},
                  ),
          )
          .toList(),
    );
  }

  Widget get locationWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).address_text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6),
        Text(
          S.of(context).address_of_location,
          style: TextStyle(fontSize: 15),
          softWrap: true,
        ),
        SizedBox(height: 20),
        Center(
          child: LocationPickerWidget(
            selectedAddress: selectedAddress,
            location: location != null
                ? GeoFirePoint(
                    GeoPoint(location!.latitude, location!.longitude))
                : null,
            onChanged: (LocationDataModel dataModel) {
              setState(() {
                location = GeoPoint(dataModel.geoPoint.geopoint.latitude,
                    dataModel.geoPoint.geopoint.longitude);
                selectedAddress = dataModel.location;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget get termsAcknowledegmentText {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
            widget.requestModel.roomOrTool == LendingType.PLACE.readable
                ? S.of(context).approve_borrow_terms_acknowledgement_text1
                : S.of(context).approve_borrow_terms_acknowledgement_text2,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.start),
        SizedBox(height: 15),
        Text(
            widget.requestModel.roomOrTool == LendingType.PLACE.readable
                ? S.of(context).approve_borrow_terms_acknowledgement_text3
                : S.of(context).approve_borrow_terms_acknowledgement_text4,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.start),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.all(5.0),
        ),
      ],
    );
  }

  Widget get bottomActionButtons {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 32,
          width: 110,
          child: CustomElevatedButton(
            padding: EdgeInsets.only(left: 5, right: 5),
            color: Colors.grey[300]!,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2.0,
            textColor: Colors.black,
            child: Text(
              S.of(context).send_text,
              style: TextStyle(color: Colors.black, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              //donation approved
              if (_formKey.currentState!.validate()) {
                if (selectedLendingPlaceModel == null &&
                    widget.requestModel.roomOrTool ==
                        LendingType.PLACE.readable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).place_not_added),
                    ),
                  );

                  return;
                }

                if (selectedItemModels.length == 0 &&
                    widget.requestModel.roomOrTool ==
                        LendingType.ITEM.readable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).items_not_added),
                    ),
                  );

                  return;
                }
                if (location == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).location_not_added),
                    ),
                  );
                  // } else if (documentName == '') {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(
                  //       content:
                  //           Text(S.of(context).snackbar_select_agreement_type),
                  //     ),
                  //   );
                  //
                } else {
                  if (widget.requestModel.roomOrTool ==
                      LendingType.PLACE.readable) {
                    logger.e('COMES HERE 25');
                    await storeAcceptorDataBorrowRequest(
                      model: widget.requestModel,
                      borrowAcceptorModel: BorrowAcceptorModel(
                          acceptorEmail:
                              SevaCore.of(context).loggedInUser.email,
                          selectedAddress: selectedAddress,
                          acceptorName:
                              SevaCore.of(context).loggedInUser.fullname,
                          acceptorId:
                              SevaCore.of(context).loggedInUser.sevaUserID,
                          timestamp: DateTime.now().millisecondsSinceEpoch,
                          borrowAgreementLink: borrowAgreementLinkFinal,
                          agreementId: agreementIdFinal,
                          // borrowedItemsIds: selectedModelsId.toList(),
                          borrowedPlaceId: selectedLendingPlaceModel!.id,
                          isApproved: false,
                          acceptorphotoURL:
                              SevaCore.of(context).loggedInUser.photoURL),
                    );
                  } else {
                    logger.e('COMES HERE 26');

                    await storeAcceptorDataBorrowRequest(
                      model: widget.requestModel,
                      borrowAcceptorModel: BorrowAcceptorModel(
                        acceptorEmail: SevaCore.of(context).loggedInUser.email,
                        acceptorphotoURL:
                            SevaCore.of(context).loggedInUser.photoURL,
                        selectedAddress: selectedAddress,
                        acceptorName:
                            SevaCore.of(context).loggedInUser.fullname,
                        acceptorId:
                            SevaCore.of(context).loggedInUser.sevaUserID,
                        timestamp: DateTime.now().millisecondsSinceEpoch,
                        borrowAgreementLink: borrowAgreementLinkFinal,
                        agreementId: agreementIdFinal,
                        isApproved: false,
                        borrowedItemsIds: List<String>.from(
                            selectedItemModels.map((e) => e.id)).toList(),
                      ),
                    );
                  }
                  widget.onTap?.call();
                }
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
        ),
        SizedBox(width: 5),
        Container(
          height: 32,
          width: 110,
          child: CustomElevatedButton(
            padding: EdgeInsets.only(left: 5, right: 5),
            color: Colors.grey[300]!,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2.0,
            textColor: Colors.black,
            child: Text(
              S.of(context).message,
              style: TextStyle(color: Colors.black, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              UserModel loggedInUser = SevaCore.of(context).loggedInUser;

              ParticipantInfo sender = ParticipantInfo(
                id: loggedInUser.sevaUserID,
                name: loggedInUser.fullname,
                photoUrl: loggedInUser.photoURL,
                type: ChatType.TYPE_PERSONAL,
              );

              ParticipantInfo reciever = ParticipantInfo(
                id: widget.requestModel.sevaUserId,
                name: widget.requestModel.creatorName,
                photoUrl: widget.requestModel.photoUrl,
                type: ChatType.TYPE_PERSONAL,
              );

              createAndOpenChat(
                context: context,
                communityId: loggedInUser.currentCommunity!,
                sender: sender,
                timebankId: widget.requestModel.timebankId!,
                feedId: '',
                showToCommunities: [],
                entityId: '',
                reciever: reciever,
                onChatCreate: () {
                  //Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget requestAgreementFormComponent(String roomOrTool) {
    // logger.e('PLACE OR ITEM:  ' + roomOrTool);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        locationWidget,
        SizedBox(height: 15),
        Text(
          S.of(context).agreement,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.68,
              child: Text(
                S.of(context).request_agreement_form_component_text,
                style: TextStyle(fontSize: 14),
                softWrap: true,
              ),
            ),
            Image(
              width: 50,
              image: AssetImage(
                  'lib/assets/images/request_offer_agreement_icon.png'),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(documentName != '' ? S.of(context).view : ''),
                GestureDetector(
                    child: Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: Text(
                        documentName != ''
                            ? documentName
                            : S
                                .of(context)
                                .approve_borrow_no_agreement_selected,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: documentName != ''
                                ? Theme.of(context).primaryColor
                                : Colors.grey),
                        softWrap: true,
                      ),
                    ),
                    onTap: () async {
                      if (documentName != '') {
                        await openPdfViewer(
                            borrowAgreementLinkFinal, documentName, context);
                      } else {
                        return null;
                      }
                    }),
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(right: 12),
              width: 90,
              height: 32,
              child: CustomTextButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(0),
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 1),
                    Spacer(),
                    Text(
                      S.of(context).change,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                  ],
                ),
                onPressed: () {
                  if (selectedLendingPlaceModel == null &&
                      widget.requestModel.roomOrTool ==
                          LendingType.PLACE.readable) {
                    errorDialog(
                      context: context,
                      error: S.of(context).select_a_place_lending,
                    );
                    return;
                  }
                  if (selectedItemModels.isEmpty &&
                      widget.requestModel.roomOrTool ==
                          LendingType.ITEM.readable) {
                    errorDialog(
                      context: context,
                      error: S.of(context).select_item_for_lending,
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => AgreementForm(
                        lendingModel: selectedLendingPlaceModel!,
                        lendingModelListBorrowRequest:
                            selectedItemModels.length > 0
                                ? selectedItemModels
                                : [],
                        requestModel: widget.requestModel,
                        isOffer: false,
                        placeOrItem: widget.requestModel.roomOrTool!,
                        communityId: widget.requestModel.communityId!,
                        timebankId: widget.requestModel.timebankId!,
                        startTime: widget.requestModel.requestStart!,
                        endTime: widget.requestModel.requestEnd!,
                        onPdfCreated: (pdfLink, documentNameFinal,
                            agreementConfig, agreementId) {
                          logger.e('COMES BACK FROM ON PDF CREATED:  ' +
                              pdfLink.toString());
                          borrowAgreementLinkFinal = pdfLink;
                          documentName = documentNameFinal;
                          agreementIdFinal = agreementId;
                          // when request is created check if above value is stored in document
                          setState(() => {});
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
