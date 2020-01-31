// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/requests/request_users_content_holder.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';
// import 'package:timezone/browser.dart';

class RequestDetailsAboutPage extends StatefulWidget {
  final RequestModel requestItem;
  TimebankModel timebankModel;

  final bool applied;
  RequestDetailsAboutPage({Key key, this.applied = false, this.requestItem, this.timebankModel})
      : super(key: key);

  @override
  _RequestDetailsAboutPageState createState() => _RequestDetailsAboutPageState();
}

class _RequestDetailsAboutPageState extends State<RequestDetailsAboutPage> {
  // String timeRange = '10:00 AM - 12:00 PM';
  String location = 'Location';
  // String subLocation = '881, 6th Cross Rd, Bengaluru, India';

  // String description =
  //     'India Startup in association with BullerProof. Your Startup is hostion this FREE workshop "Idea to opportunity" at Excel Partner ';

  TextStyle titleStyle = TextStyle(
    fontSize: 18,
    color: Colors.black,
  );

  TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var futures = <Future>[];
    futures.clear();

    if(widget.requestItem.acceptors != null){
      widget.requestItem.acceptors.forEach((memberEmail) {
        futures.add(getUserDetails(memberEmail: memberEmail));
      });
      isApplied = widget.requestItem.acceptors
          .contains(SevaCore.of(context).loggedInUser.email);
    }
    else{
      isApplied = false;
    }



    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    SizedBox(height: 10,),
                    Text(
                      widget.requestItem.title,
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
                        DateFormat('EEEEEEE, MMMM dd').format(
                          getDateTimeAccToUserTimezone(
                              dateTime: DateTime.fromMillisecondsSinceEpoch(
                                  widget.requestItem.requestStart),
                              timezoneAbb:
                                  SevaCore.of(context).loggedInUser.timezone),
                        ),
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        DateFormat('h:mm a').format(
                          getDateTimeAccToUserTimezone(
                              dateTime: DateTime.fromMillisecondsSinceEpoch(
                                  widget.requestItem.requestStart),
                              timezoneAbb:
                                  SevaCore.of(context).loggedInUser.timezone),
                        ) +' - ' + DateFormat('h:mm a').format(
                        getDateTimeAccToUserTimezone(
                            dateTime: DateTime.fromMillisecondsSinceEpoch(
                                widget.requestItem.requestEnd),
                            timezoneAbb:
                            SevaCore.of(context).loggedInUser.timezone),
                      ),
                        style: subTitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
                        height: 25,
                        width: 72,
                        child: widget.requestItem.sevaUserId ==
                            SevaCore.of(context).loggedInUser.sevaUserID
                            ?
                        FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Color.fromRGBO(44, 64, 140, 1),
                                child: Text(

                                  'Edit',
                                  style: TextStyle(color: Colors.white,fontSize: 13),
                                ),
                                onPressed: () {
                                  MaterialPageRoute(
                                    builder: (context) => EditRequest(
                                      timebankId: SevaCore.of(context)
                                          .loggedInUser
                                          .currentTimebank,
                                      requestModel: widget.requestItem,
                                    ),
                                  );
                                },
                              )
                           : Container(),
                      )
                    ),
                    CustomListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.grey,
                      ),
                      title: Text(
                        location,
                        style: titleStyle,
                        maxLines: 1,
                      ),
                      subtitle: FutureBuilder<String>(
                        future: _getLocation(
                          widget.requestItem.location.latitude,
                          widget.requestItem.location.latitude,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text("Unnamed Location");
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Resolving location...");
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
                        "Hosted by ${widget.requestItem.fullName}",
                        style: titleStyle,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '${widget.requestItem.approvedUsers.length} / ${widget.requestItem.acceptors.length} people Approved',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                  future: Future.wait(futures),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data.length == 0) {
                      return Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Text(
                          'No approved members',
                        ),
                      );
                    }

                    var snap = snapshot.data.map((f) {
                      return UserModel.fromDynamic(f);
                    }).toList();

                    print(" $snap ---------------------------- ");

                    return Container(
                      height: 40,
                      child: InkWell(
                        onTap: () {
                          print('tapped');
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: snap.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      snap[index].photoURL,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
              SizedBox(height: 10),


              // NetworkImage(
              //   imageUrl:
              //       'https://technext.github.io/Evento/images/demo/bg-slide-01.jpg',
              //   fit: BoxFit.fitWidth,
              //   placeholder: (context, url) => Center(
              //     child: CircularProgressIndicator(),
              //   ),
              //   errorWidget: (context, url, error) => Icon(Icons.error),
              // ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text(
                  widget.requestItem.description,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              /*CachedNetworkImage(
                  imageUrl: widget.requestItem.photoUrl,
                  errorWidget: (context,url,error) =>
                      Container(),
                  placeholder: (context,url){
                    return Center(child: CircularProgressIndicator());
                  }

              ),*/
              SizedBox(height: 10,),
              getBottombar(),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> getUserDetails({String memberEmail}) async {
    var user = await Firestore.instance
        .collection("users")
        .document(memberEmail)
        .get();

    return user.data;
  }

  Future<String> _getLocation(double lat, double lng) async {
    String address = await LocationUtility().getFormattedAddress(lat, lng);
    // log('_getLocation: $address');
    // setState(() {
    //   this.selectedAddress = address;
    // });

    return address;
  }

  bool isApplied = false;
  Widget getBottombar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: widget.requestItem.sevaUserId !=
                              SevaCore.of(context).loggedInUser.sevaUserID
                          ? 'You have${isApplied ? '' : " not"} applied for the request'
                          : "You created this request",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
              ),
            ),
            Offstage(
              offstage: widget.requestItem.sevaUserId ==
                  SevaCore.of(context).loggedInUser.sevaUserID,
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
                        isApplied ? 'Withdraw' : 'Apply',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                    ],
                  ),
                  onPressed: () {
                    if (widget.timebankModel.protected) {
                      if (widget.timebankModel.admins.contains(
                          SevaCore.of(context).loggedInUser.sevaUserID)) {
                        applyAction();
                      } else {
                        //show dialog
                        _showProtectedTimebankMessage();
                        print("not authorized");
                      }
                    } else {
                      applyAction();
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showProtectedTimebankMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Protected Timebank"),
          content: new Text("You cannot accept requests in a protected timebank"),
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

  void applyAction() {
    if (isApplied) {
      print("Withraw request");
      _withdrawRequest();
    } else {
      print("Accept request");
      _acceptRequest();
    }
    Navigator.pop(context);
  }

  void _acceptRequest() {
    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.add(SevaCore.of(context).loggedInUser.email);
    widget.requestItem.acceptors = acceptorList.toList();
    acceptRequest(
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }

  void _withdrawRequest() {
    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.remove(SevaCore.of(context).loggedInUser.email);
    widget.requestItem.acceptors = acceptorList.toList();
    acceptRequest(
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      isWithdrawal: true,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }
}
