import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/offer_card.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';

import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/create_offer_request.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/admin_personal_requests_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/workshop/admin_offer_requests_tab.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/empty_widget.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

import '../../../../flavor_config.dart';

class BookmarkedOffers extends StatelessWidget {
  final String? sevaUserId;
  final TimebankModel? timebankModel;

  const BookmarkedOffers({Key? key, this.sevaUserId, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OfferModel>>(
      stream: getBookMarkedOffers(
          timebankid: timebankModel!.id, sevaUserId: sevaUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        }
        if (snapshot.data == null) {
          return Center(
            child: Text(
              S.of(context).no_bookmarked_offers,
            ),
          );
        }

        List<OfferModel> bookmarkedOffers = [];
        bookmarkedOffers = snapshot.data!;

        // OfferModel model;
        // snapshot.data.docs.forEach((offer) {
        //   model = OfferModel.fromMap(offer.data());
        //   if (model.timebanksPosted != null &&
        //       model.timebanksPosted.contains(timebankModel.id))
        //     bookmarkedOffers.add(model);
        // });

        if (bookmarkedOffers.length == 0) {
          return Center(
            child: EmptyWidget(
              title: S.of(context).no_bookmarked_offers,
              sub_title: "",
              titleFontSize: 16,
            ),
          );
        }
        return ListView.builder(
          itemCount: bookmarkedOffers.length,
          itemBuilder: (context, index) {
            OfferModel _offer = bookmarkedOffers[index];
            return OfferCard(
              requestType: _offer.type!,
              isCardVisible: false,
              isCreator: true, //hides the buttons
              title: getOfferTitle(offerDataModel: _offer),
              subtitle: getOfferDescription(offerDataModel: _offer),
              offerType: _offer.offerType!,
              public: _offer.public!,
              virtual: _offer.virtual!,
              isRecurring: _offer.isRecurring,
              isAutoGenerated: _offer.autoGenerated,
              selectedAddress: _offer.selectedAdrress,
              onCardPressed: () => showDialogForMakingAnOffer(
                  model: _offer,
                  parentContext: context,
                  timebankModel: timebankModel!,
                  sevaUserId: sevaUserId!,
                  hideCancelBookMark: false),
            );
          },
        );
      },
    );
  }
}

Widget getBio(BuildContext context, UserModel userModel) {
  if (userModel.bio != null) {
    if (userModel.bio!.length < 100) {
      return Container(
        margin: EdgeInsets.all(8),
        child: Center(
          child: Text(
            userModel!.bio!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.all(8),
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(
          userModel.bio!,
          maxLines: null,
          overflow: null,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Text(S.of(context).bio_not_updated),
  );
}

Widget _getCloseButton(BuildContext context) {
  return Container(
    alignment: FractionalOffset.topRight,
    child: Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'lib/assets/images/close.png',
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
      ),
    ),
  );
}

void showDialogForMakingAnOffer({
  OfferModel? model,
  BuildContext? parentContext,
  TimebankModel? timebankModel,
  String? sevaUserId,
  bool? hideCancelBookMark,
}) {
  showDialog(
    context: parentContext!,
    builder: (BuildContext viewContext) {
      return FutureBuilder(
        future: CollectionRef.users
            .where("sevauserid", isEqualTo: model!.sevaUserId)
            .get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(25.0),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 30,
                    width: 30,
                    child:
                        AspectRatio(aspectRatio: 1, child: LoadingIndicator()),
                  ),
                ],
              ),
            );
          }
          if (snapshot.data == null) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(25.0),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 30,
                    child: Text(
                      S.of(context).general_stream_error,
                    ),
                  ),
                ],
              ),
            );
          }
          UserModel userModel = UserModel.fromMap(
            snapshot.data!.docs[0].data()! as Map<String, dynamic>,
            'bookmarked_offers',
          );
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(25.0),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _getCloseButton(viewContext),
                  Container(
                    height: 70,
                    width: 70,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          userModel.photoURL ?? defaultUserImageURL),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      userModel.fullname!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        S.of(context).about + " " + userModel.fullname!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  getBio(context, userModel),
                  // Center(
                  //   child: Text(
                  //       userModel.fullname +
                  //           " " +
                  //           S.of(context).will_be_added_to_request,
                  //       style: TextStyle(
                  //         fontStyle: FontStyle.italic,
                  //       ),
                  //       textAlign: TextAlign.center),
                  // ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomElevatedButton(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        elevation: 2,
                        textColor: Colors.white,
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            S.of(context).accept_offer,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          // Once approved

                          if ((timebankModel!.id ==
                              FlavorConfig.values.timebankId)) {
                            if (!isAccessAvailable(
                              timebankModel!,
                              SevaCore.of(parentContext)
                                  .loggedInUser
                                  .sevaUserID!,
                            )) {
                              // ExtendedNavigator.of(context).pop();
                              showAdminAccessMessage(context: context);
                              return;
                            }
                          }

                          Navigator.pop(viewContext);

                          Navigator.push(
                            parentContext,
                            MaterialPageRoute(
                              builder: (parentContext) => CreateOfferRequest(
                                offer: model,
                                timebankId: model.timebankId,
                                // userModel: userModel,
                              ),
                            ),
                          );
                        },
                      ),
                      CustomElevatedButton(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        elevation: 2,
                        textColor: Colors.white,
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            S.of(context).add_to_existing_reqest,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          // Once approved

                          Navigator.pop(viewContext);

                          if (isAccessAvailable(
                              timebankModel!,
                              SevaCore.of(parentContext)
                                  .loggedInUser
                                  .sevaUserID!)) {
                            Navigator.push(
                              parentContext,
                              MaterialPageRoute(
                                builder: (parentContext) =>
                                    AdminOfferRequestsTab(
                                  timebankid: model.timebankId!,
                                  parentContext: parentContext,
                                  userModel: userModel,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              parentContext,
                              MaterialPageRoute(
                                builder: (context) => AdminPersonalRequests(
                                  timebankId: model.timebankId,
                                  isTimebankRequest: true,
                                  userModel: userModel,
                                  showAppBar: true,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      HideWidget(
                        hide: hideCancelBookMark!,
                        secondChild: Container(),
                        child: CustomElevatedButton(
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          elevation: 2,
                          textColor: Colors.white,
                          child: Container(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  S.of(context).remove_from_bookmark,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                          onPressed: () async {
                            removeBookmark(model.id!, sevaUserId!);
                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                      CustomElevatedButton(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        elevation: 2,
                        textColor: Colors.white,
                        child: Container(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                S.of(context).cancel,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                        onPressed: () async {
                          // request declined
                          Navigator.pop(viewContext);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
