import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/createoffer.dart';
import 'package:sevaexchange/views/exchange/edit_offer.dart';
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';

import '../core.dart';

class OffersModule extends StatefulWidget {
  final String timebankId;
  TimebankModel timebankModel;

  OffersModule.of({this.timebankId, this.timebankModel});

  @override
  OffersState createState() => OffersState();
}

class OffersState extends State<OffersModule> {
  String timebankId;

  _setORValue() {
    globals.orCreateSelector = 1;
  }

  OffersState() {}
  List<TimebankModel> timebankList = [];
  bool isNearme = false;
  int sharedValue = 0;

  @override
  Widget build(BuildContext context) {
    _setORValue();
    timebankId = widget.timebankModel.id;

    return Column(
      children: <Widget>[
        Offstage(
          offstage: false,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 12),
                child: Row(
                  children: <Widget>[
                    Text(
                      'My Offers',
                      style: (TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateOffer(
                              timebankId: timebankId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 10,
                          child: Image.asset("lib/assets/images/add.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Expanded(
                child: Container(),
              ),
              // StreamBuilder<List<TimebankModel>>(
              //     stream: FirestoreManager.getTimebanksForUserStream(
              //       userId: SevaCore.of(context).loggedInUser.sevaUserID,
              //     ),
              //     builder: (context, snapshot) {
              //       if (snapshot.hasError)
              //         return new Text('Error: ${snapshot.error}');
              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return Center(child: CircularProgressIndicator());
              //       }
              //       timebankList = snapshot.data;
              //       List<String> dropdownList = [];

              //       int adminOfCount = 0;
              //       if (FlavorConfig.values.timebankName == "Yang 2020") {
              //         dropdownList.add("Create Yang Gang");
              //       }

              //       timebankList.forEach((t) {
              //         dropdownList.add(t.id);
              //         if (t.admins.contains(
              //             SevaCore.of(context).loggedInUser.sevaUserID)) {
              //           adminOfCount++;

              //           SevaCore.of(context)
              //               .loggedInUser
              //               .timebankIdForYangGangAdmin = t.id;
              //         }
              //       });

              //       SevaCore.of(context).loggedInUser.associatedWithTimebanks =
              //           dropdownList.length;

              //       SevaCore.of(context).loggedInUser.adminOfYanagGangs =
              //           adminOfCount;

              //       return Expanded(
              //         child: DropdownButton<String>(
              //           value: timebankId,
              //           onChanged: (String newValue) {
              //             if (newValue == "Create Yang Gang") {
              //               createSubTimebank(context);
              //             } else {
              //               setState(() {
              //                 timebankId = newValue;
              //                 SevaCore.of(context)
              //                     .loggedInUser
              //                     .currentTimebank = newValue;
              //               });
              //             }
              //           },
              //           items: dropdownList
              //               .map<DropdownMenuItem<String>>((String value) {
              //             if (value == "Create Yang Gang") {
              //               return DropdownMenuItem<String>(
              //                 value: value,
              //                 child: Text(
              //                   value,
              //                   style: TextStyle(color: Colors.red),
              //                 ),
              //               );
              //             } else {
              //               if (value == 'All') {
              //                 return DropdownMenuItem<String>(
              //                   value: value,
              //                   child: Text(value),
              //                 );
              //               } else {
              //                 return DropdownMenuItem<String>(
              //                   value: value,
              //                   child: FutureBuilder<Object>(
              //                       future: FirestoreManager.getTimeBankForId(
              //                           timebankId: value),
              //                       builder: (context, snapshot) {
              //                         if (snapshot.hasError)
              //                           return new Text(
              //                               'Error: ${snapshot.error}');
              //                         if (snapshot.connectionState ==
              //                             ConnectionState.waiting) {
              //                           return Offstage();
              //                         }
              //                         TimebankModel timebankModel =
              //                             snapshot.data;
              //                         return Text(
              //                           timebankModel.name,
              //                           style: TextStyle(fontSize: 15.0),
              //                         );
              //                       }),
              //                 );
              //               }
              //             }
              //           }).toList(),
              //         ),
              //       );
              //     }),
              Container(
                width: 120,
                child: CupertinoSegmentedControl<int>(
                  selectedColor: Theme.of(context).primaryColor,
                  children: logoWidgets,
                  borderColor: Colors.grey,
                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  //selectedColor: Colors.deepOrange,
                  groupValue: sharedValue,
                  onValueChanged: (int val) {
                    print(val);
                    if (val != sharedValue) {
                      setState(() {
                        if (isNearme == true)
                          isNearme = false;
                        else
                          isNearme = true;
                      });
                      setState(() {
                        sharedValue = val;
                      });
                    }
                  },
                  //groupValue: sharedValue,
                ),
              ),
//              RaisedButton(
//                onPressed: () {
//                  setState(() {
//                    if (isNearme == true)
//                      isNearme = false;
//                    else
//                      isNearme = true;
//                  });
//                },
//                child: isNearme == false ? Text('Near Me') : Text('All'),
//                color: Theme.of(context).accentColor,
//                textColor: Colors.white,
//              ),
              Padding(
                padding: EdgeInsets.only(right: 5),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.white,
          height: 0,
        ),
        isNearme == true
            ? NearOfferListItems(
                parentContext: context,
                timebankId: timebankId,
              )
            : OfferListItems(
                parentContext: context,
                timebankId: timebankId,
              )
      ],
    );
  }

  void createSubTimebank(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimebankCreate(
          timebankId: FlavorConfig.values.timebankId,
        ),
      ),
    );
  }

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'All',
      style: TextStyle(fontSize: 10.0),
    ),
    1: Text(
      'Near Me',
      style: TextStyle(fontSize: 10.0),
    ),
  };
}

class OfferCardView extends StatefulWidget {
  final OfferModel offerModel;
  TimebankModel timebankModel;
  String sevaUserIdOffer;

  bool isAdmin = false;

  OfferCardView({this.offerModel, this.timebankModel});

  @override
  State<StatefulWidget> createState() {
    return OfferCardViewState();
  }
}

class OfferListItems extends StatelessWidget {
  final String timebankId;
  final BuildContext parentContext;
  String sevaUserId;

  OfferListItems({
    Key key,
    this.parentContext,
    this.timebankId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    sevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
    if (timebankId != 'All') {
      return StreamBuilder<List<OfferModel>>(
        stream: getOffersStream(timebankId: timebankId),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;
              offersList = filterBlockedOffersContent(
                  context: context, requestModelList: offersList);

              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }
              //Here we apply grouping startegy
              var consolidatedList =
                  GroupOfferCommons.groupAndConsolidateOffers(
                      offersList, SevaCore.of(context).loggedInUser.sevaUserID);

              print("============== $consolidatedList");

              return formatListOffer(consolidatedList: consolidatedList);
          }
        },
      );
    } else {
      print("set stream for offers");

      return StreamBuilder<List<OfferModel>>(
        stream: getAllOffersStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;

              offersList = filterBlockedOffersContent(
                  context: context, requestModelList: offersList);

              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }

              var consolidatedList =
                  GroupOfferCommons.groupAndConsolidateOffers(
                      offersList, SevaCore.of(context).loggedInUser.sevaUserID);

              return formatListOffer(consolidatedList: consolidatedList);
          }
        },
      );
    }
  }

  List<OfferModel> filterBlockedOffersContent(
      {List<OfferModel> requestModelList, BuildContext context}) {
    List<OfferModel> filteredList = [];

    requestModelList.forEach((request) => SevaCore.of(context)
                .loggedInUser
                .blockedMembers
                .contains(request.sevaUserId) ||
            SevaCore.of(context)
                .loggedInUser
                .blockedBy
                .contains(request.sevaUserId)
        ? "Filtering blocked content"
        : filteredList.add(request));

    return filteredList;
  }

  Widget formatListOffer({List<OfferModelList> consolidatedList}) {
    return Expanded(
      child: Container(
        child: ListView.builder(
            itemCount: consolidatedList.length + 1,
            itemBuilder: (context, index) {
              if (index >= consolidatedList.length) {
                return Container(
                  width: double.infinity,
                  height: 65,
                );
              }
              return getOfferWidget(consolidatedList[index]);
            }
            // children: consolidatedList.map((OfferModelList offerModel) {
            //   return getOfferWidget(offerModel);
            // }).toList(),
            ),
      ),
    );
  }

  Widget getOfferWidget(OfferModelList model) {
    return Container(
      decoration: containerDecoration,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: getOfferView(model),
    );
  }

  Widget getOfferView(OfferModelList offerModelList) {
    switch (offerModelList.getType()) {
      case OfferModelList.TITLE:
        var isMyContent =
            (offerModelList as OfferTitle).groupTitle.contains("My");
        return Container(
          height: isMyContent ? 18 : 18,
          margin: isMyContent ? EdgeInsets.all(12) : EdgeInsets.all(12),
          child: Text(
            GroupOfferCommons.getGroupTitleForOffer(
                groupKey: (offerModelList as OfferTitle).groupTitle),
          ),
        );

      case OfferModelList.OFFER:
        return getOfferViewHolder((offerModelList as OfferItem).offerModel);
    }
  }

  Widget getOfferViewHolder(OfferModel model) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (context) => OfferCardView(offerModel: model),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipOval(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'lib/assets/images/profile.png',
                    // image: user.photoURL,
                    image: model.photoUrlImage == null
                        ? defaultUserImageURL
                        : model.photoUrlImage,
                  ),
                ),
              )

              // StreamBuilder<UserModel>(
              //   stream: FirestoreManager.getUserForIdStream(
              //     sevaUserId: model.sevaUserId,
              //   ),
              //   builder: (context, snapshot) {
              //     if (snapshot.hasError) {
              //       return CircleAvatar(foregroundColor: Colors.red);
              //     }
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return CircleAvatar();
              //     }
              //     UserModel user = snapshot.data;
              //     return ClipOval(
              //       child: SizedBox(
              //         height: 40,
              //         width: 40,
              //         child: FadeInImage.assetNetwork(
              //             placeholder: 'lib/assets/images/profile.png',
              //             // image: user.photoURL,
              //             image:
              //                 "https://media.wired.com/photos/5c1ae77ae91b067f6d57dec0/master/pass/Comparison-City-MAIN-ART.jpg"),
              //       ),
              //     );
              //   },
              // ),
              ,
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model.title,
                      style: Theme.of(parentContext).textTheme.subhead,
                    ),
                    Text(
                      model.description.trim(),
                      style: Theme.of(parentContext).textTheme.subtitle,
                    ),
                    Offstage(
                      offstage: !model.offerAcceptors.contains(sevaUserId),
                      child: Container(
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.all(12),
                          // width: double.infinity,
                          child: Container(
                            width: 100,
                            height: 32,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.all(0),
                              color: Color.fromRGBO(44, 64, 140, 0.7),
                              child: Row(
                                children: <Widget>[
                                  SizedBox(width: 1),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(44, 64, 140, 1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    'Accepted',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(
                                    flex: 2,
                                  ),
                                ],
                              ),
                              onPressed: () {},
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTimeFormattedString(int timeInMilliseconds) {
    DateFormat dateFormat = DateFormat('d MMM h:m a ');
    String from = dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
    );
    return from;
  }

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(0),
            spreadRadius: 4,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: Colors.white,
    );
  }
}

class NearOfferListItems extends StatelessWidget {
  final String timebankId;
  final BuildContext parentContext;
  const NearOfferListItems({Key key, this.parentContext, this.timebankId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (timebankId != 'All') {
      return StreamBuilder<List<OfferModel>>(
        stream: getNearOffersStream(timebankId: timebankId),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;
              offersList = filterBlockedOffersContent(
                  context: context, requestModelList: offersList);

              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }
              return Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      OfferModel offer = offersList[index];
                      return getOfferWidget(offer);
                    },
                    itemCount: offersList.length,
                  ),
                ),
              );
          }
        },
      );
    } else {
      return StreamBuilder<List<OfferModel>>(
        stream: getNearOffersStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;
              offersList = filterBlockedOffersContent(
                  context: context, requestModelList: offersList);

              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }
              return Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      OfferModel offer = offersList[index];
                      return getOfferWidget(offer);
                    },
                    itemCount: offersList.length,
                  ),
                ),
              );
          }
        },
      );
    }
  }

  List<OfferModel> filterBlockedOffersContent(
      {List<OfferModel> requestModelList, BuildContext context}) {
    List<OfferModel> filteredList = [];

    requestModelList.forEach((request) => SevaCore.of(context)
                .loggedInUser
                .blockedMembers
                .contains(request.sevaUserId) ||
            SevaCore.of(context)
                .loggedInUser
                .blockedBy
                .contains(request.sevaUserId)
        ? "Filtering blocked content"
        : filteredList.add(request));

    return filteredList;
  }

  Widget getOfferWidget(OfferModel model) {
    return Container(
      // decoration: containerDecoration,
      // margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              parentContext,
              MaterialPageRoute(
                builder: (context) => OfferCardView(offerModel: model),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StreamBuilder<UserModel>(
                  stream: FirestoreManager.getUserForIdStream(
                    sevaUserId: model.sevaUserId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return CircleAvatar(foregroundColor: Colors.red);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar();
                    }
                    UserModel user = snapshot.data;
                    return ClipOval(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: FadeInImage.assetNetwork(
                            placeholder: 'lib/assets/images/profile.png',
                            image: user.photoURL),
                      ),
                    );
                  },
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        model.title.trim(),
                        style: Theme.of(parentContext).textTheme.subhead,
                      ),
                      Text(
                        model.description.trim(),
                        style: Theme.of(parentContext).textTheme.subtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getTimeFormattedString(int timeInMilliseconds) {
    DateFormat dateFormat = DateFormat('d MMM h:m a ');
    String from = dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
    );
    return from;
  }

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(10),
            spreadRadius: 4,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: Colors.white,
    );
  }
}

class OfferCardViewState extends State<OfferCardView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirestoreManager.getTimeBankForId(timebankId: widget.offerModel.timebankId)
        .then((timebank) {
      widget.timebankModel = timebank;
      if (timebank.admins
              .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
          timebank.coordinators
              .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
        if (widget.isAdmin == false) {
          setState(() {
            widget.timebankModel = timebank;
            widget.isAdmin = true;
          });
        }
      }
    });
  }

  TextStyle titleStyle = TextStyle(
    fontSize: 18,
    color: Colors.black,
  );

  TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );
  @override
  Widget build(BuildContext context) {
    FirestoreManager.getTimeBankForId(timebankId: widget.offerModel.timebankId)
        .then((timebank) {
      if (timebank.admins
              .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
          timebank.coordinators
              .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {}
    });
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          widget.offerModel.sevaUserId ==
                      SevaCore.of(context).loggedInUser.sevaUserID &&
                  widget.offerModel.requestList.length == 0
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext viewcontext) {
                          return AlertDialog(
                            title: Text(
                              'Are you sure you want to delete this offer?',
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(
                                  'No',
                                  style: TextStyle(
                                    fontSize: dialogButtonSize,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(viewcontext);
                                },
                              ),
                              FlatButton(
                                child: Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontSize: dialogButtonSize,
                                  ),
                                ),
                                onPressed: () {
                                  deleteOffer(offerModel: widget.offerModel);
                                  Navigator.pop(viewcontext);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  },
                )
              : Offstage()
        ],
        title: Text(
          "Offer Details",
          style: TextStyle(fontSize: 18),
        ),
        elevation: 0.5,
      ),
      body: FutureBuilder<Object>(
          future: FirestoreManager.getUserForId(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            UserModel userModel = snapshot.data;
            String usertimezone = userModel.timezone;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(),
                child: Container(
                  padding: EdgeInsets.all(14.0),
                  child: Container(
                    padding: EdgeInsets.all(0),
                    color: widget.offerModel.color,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //adding sample calss tarts here
                        SafeArea(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      widget.offerModel.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    CustomListTile(
                                      leading: Icon(
                                        Icons.access_time,
                                        color: Colors.grey,
                                      ),
                                      title: Text(
                                        'Posted on',
                                        style: titleStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        DateFormat('EEEEEEE, MMMM dd h:mm a')
                                            .format(
                                          getDateTimeAccToUserTimezone(
                                              dateTime: DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      widget.offerModel
                                                          .timestamp),
                                              timezoneAbb: SevaCore.of(context)
                                                  .loggedInUser
                                                  .timezone),
                                        ),
                                        style: subTitleStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Container(
                                        height: 30,
                                        width: 80,
                                        child: false
                                            ? FlatButton(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                color: Color.fromRGBO(
                                                    44, 64, 140, 1),
                                                child: Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onPressed: () {},
                                              )
                                            : Container(),
                                      ),
                                    ),
                                    CustomListTile(
                                      leading: Icon(
                                        Icons.location_on,
                                        color: Colors.grey,
                                      ),
                                      title: Text(
                                        "Location",
                                        style: titleStyle,
                                        maxLines: 1,
                                      ),
                                      subtitle: FutureBuilder<String>(
                                        future: _getLocation(
                                          widget.offerModel.location.latitude,
                                          widget.offerModel.location.longitude,
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Text("Unnamed Location");
                                          }

                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text(
                                                "Resolving location...");
                                          }
                                          return Text(
                                            snapshot.data,
                                            style: subTitleStyle,
                                            maxLines: 1,
                                          );
                                        },
                                      ),
                                    ),
                                    CustomListTile(
                                      // contentPadding: EdgeInsets.all(0),
                                      leading: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                      title: Text(
                                        "Offered by ${widget.offerModel.fullName}",
                                        style: titleStyle,
                                        maxLines: 1,
                                      ),
                                    ),
                                    // SizedBox(height: 20),
                                    // Text(
                                    //   '${widget.requestItem.approvedUsers.length} / ${widget.requestItem.acceptors.length} people Approved',
                                    //   style: TextStyle(
                                    //     fontSize: 16,
                                    //     fontWeight: FontWeight.w500,
                                    //   ),
                                    // ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      child: RichTextView(
                                          text: widget.offerModel.description),
                                    ),
                                  ],
                                ),
                                getBottombar()
                              ],
                            ),
                          ),
                        ),

                        //addding sample class here ends

                        // Container(
                        //   padding: EdgeInsets.all(8.0),
                        //   alignment: Alignment(-1.0, 0.0),
                        //   child:
                        //       Text('Posted By: ' + widget.offerModel.fullName),
                        // ),
                        // Container(
                        //   padding: EdgeInsets.all(8.0),
                        //   alignment: Alignment(-1.0, 0.0),
                        //   child: Text(
                        //     'PostDate:  ' +
                        //         DateFormat('MMMM dd, yyyy @ h:mm a').format(
                        //           getDateTimeAccToUserTimezone(
                        //               dateTime:
                        //                   DateTime.fromMillisecondsSinceEpoch(
                        //                       widget.offerModel.timestamp),
                        //               timezoneAbb: usertimezone),
                        //         ),
                        //   ),
                        // ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(' '),
                        ),
                        // Container(
                        //   padding: EdgeInsets.all(8.0),
                        //   child: RaisedButton(
                        //     color: Theme.of(context).accentColor,
                        //     onPressed: widget.offerModel.sevaUserId ==
                        //                 SevaCore.of(context)
                        //                     .loggedInUser
                        //                     .sevaUserID ||
                        //             (widget.isAdmin &&
                        //                 widget.offerModel.acceptedOffer)
                        //         ? null
                        //         : () {
                        //             widget.sevaUserIdOffer =
                        //                 widget.offerModel.sevaUserId;

                        //             FirestoreManager.getTimeBankForId(
                        //                     timebankId:
                        //                         widget.offerModel.timebankId)
                        //                 .then((timebank) {
                        //               if (timebank.admins.contains(
                        //                       SevaCore.of(context)
                        //                           .loggedInUser
                        //                           .sevaUserID) ||
                        //                   timebank.coordinators.contains(
                        //                       SevaCore.of(context)
                        //                           .loggedInUser
                        //                           .sevaUserID)) {
                        //                 setState(() {
                        //                   widget.isAdmin = true;
                        //                 });

                        //                 _makePostRequest(widget.offerModel);
                        //               } else {
                        //                 showDialog(
                        //                   context: context,
                        //                   builder: (BuildContext context) {
                        //                     return AlertDialog(
                        //                       title:
                        //                           new Text("Permission Denied"),
                        //                       content: new Text(
                        //                           "You need to be an Admin or Coordinator to have permission to send request to offers"),
                        //                       actions: <Widget>[
                        //                         new FlatButton(
                        //                           child: new Text("Close"),
                        //                           onPressed: () {
                        //                             Navigator.of(context).pop();
                        //                           },
                        //                         ),
                        //                       ],
                        //                     );
                        //                   },
                        //                 );
                        //               }
                        //             });
                        //           },
                        //     child: Text(
                        //       !widget.offerModel.acceptedOffer ||
                        //               !widget.isAdmin
                        //           ? 'Accepts'
                        //           : 'Accepted',
                        //       style: TextStyle(color: Colors.white),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  String offerStatusLabel;

  Future _makePostRequest(OfferModel offerModel) async {
    // set up POST request arguments
    String url =
        'https://us-central1-sevaxproject4sevax.cloudfunctions.net/acceptOffer';
    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, String> body = {
      'id': offerModel.id,
      'email': offerModel.email,
      'notificationId': utils.Utils.getUuid(),
      'acceptorSevaId': SevaCore.of(context).loggedInUser.sevaUserID,
      'timebankId': FlavorConfig.values.timebankId,
      'sevaUserId': offerModel.sevaUserId,
      'communityId': SevaCore.of(context).loggedInUser.currentCommunity,
    };

    setState(() {
      widget.offerModel.acceptedOffer = true;
    });

    // make POST request
    Response response =
        await post(url, headers: headers, body: json.encode(body));
    // check the status code for the result
    int statusCode = response.statusCode;

    if (statusCode == 200) {
      print("Request completed successfully");
    } else {
      print("Request failed");
    }
    // this API passes back the id of the new item added to the body
    // String body = response.body;
    // {
    //   "title": "Hello",
    //   "body": "body text",
    //   "userId": 1,
    //   "id": 101
    // }
  }

  bool isAccepted = false;
  BuildContext dialogContext;
  Widget getBottombar() {
    isAccepted = widget.offerModel.offerAcceptors.contains(
      SevaCore.of(context).loggedInUser.sevaUserID,
    );
    var textSpan = TextSpan(
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      text: '\nEdit Offer',
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateOffer(
                timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
                offerModel: widget.offerModel,
              ),
            ),
          );
        },
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: widget.offerModel.sevaUserId !=
                                SevaCore.of(context).loggedInUser.sevaUserID
                            ? 'You have${isAccepted ? '' : " not yet"} accepted this offer.'
                            : "You created this offer",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      widget.offerModel.sevaUserId ==
                              SevaCore.of(context).loggedInUser.sevaUserID
                          ? textSpan
                          : TextSpan(),
                    ],
                  ),
                ),
              ),
            ),
            Offstage(
              offstage: widget.offerModel.sevaUserId ==
                      SevaCore.of(context).loggedInUser.sevaUserID ||
                  widget.offerModel.offerAcceptors
                      .contains(SevaCore.of(context).loggedInUser.sevaUserID),
              child: Container(
                width: 100,
                height: 32,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(0),
                  color: Color.fromRGBO(44, 64, 140, 0.7),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 1),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(44, 64, 140, 1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Text(
                        widget.offerModel.offerAcceptors.contains(
                                SevaCore.of(context).loggedInUser.sevaUserID)
                            ? 'Withdraw'
                            : 'Accept',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                    ],
                  ),
                  onPressed: () async {
                    if (widget.timebankModel != null &&
                        widget.timebankModel.protected &&
                        !(widget.timebankModel.admins.contains(
                            SevaCore.of(context).loggedInUser.sevaUserID))) {
                      _showProtectedTimebankMessage();
                      return;
                    }

                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (createDialogContext) {
                          dialogContext = createDialogContext;
                          return AlertDialog(
                            title: Text('Please wait..'),
                            content: LinearProgressIndicator(),
                          );
                        });
                    var isAccepted = widget.offerModel.offerAcceptors
                        .contains(SevaCore.of(context).loggedInUser.sevaUserID);

                    Firestore.instance
                        .collection("offers")
                        .document(widget.offerModel.id)
                        .updateData({
                      'offerAcceptors': isAccepted
                          ? FieldValue.arrayRemove(
                              [SevaCore.of(context).loggedInUser.sevaUserID])
                          : FieldValue.arrayUnion(
                              [SevaCore.of(context).loggedInUser.sevaUserID])
                    });

                    widget.sevaUserIdOffer = widget.offerModel.sevaUserId;
                    var tempOutput =
                        new List<String>.from(widget.offerModel.offerAcceptors);
                    tempOutput
                        .add(SevaCore.of(context).loggedInUser.sevaUserID);
                    widget.offerModel.offerAcceptors = tempOutput;
                    await _makePostRequest(widget.offerModel);
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();

                    // FirestoreManager.getTimeBankForId(
                    //         timebankId: widget.offerModel.timebankId)
                    //     .then((timebank) async {
                    //   // print("recieved details");
                    //   if (timebank.admins.contains(
                    //           SevaCore.of(context).loggedInUser.sevaUserID) ||
                    //       timebank.coordinators.contains(
                    //           SevaCore.of(context).loggedInUser.sevaUserID)) {

                    //   } else {
                    //     showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) {
                    //         return AlertDialog(
                    //           title: new Text("Permission Denied"),
                    //           content: new Text(
                    //               "You need to be an Admin or Coordinator to have permission to send request to offers"),
                    //           actions: <Widget>[
                    //             new FlatButton(
                    //               child: new Text("Close"),
                    //               onPressed: () {
                    //                 Navigator.of(context).pop();
                    //               },
                    //             ),
                    //           ],
                    //         );
                    //       },
                    //     );
                    //   }
                    // });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String> _getLocation(double lat, double lng) async {
    String address = await LocationUtility().getFormattedAddress(lat, lng);
    return address;
  }

  void _showProtectedTimebankMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Protected Timebank"),
          content: new Text(
              "Admins or Co-Ordinators can only accept offers in a protected timebank"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteOffer({
    @required OfferModel offerModel,
  }) async {
    return await Firestore.instance
        .collection('offers')
        .document(offerModel.id)
        .delete();
  }
}
