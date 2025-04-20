import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/ui/utils/location_helper.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/notification_manager.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/filters.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class FindCommunitiesView extends StatefulWidget {
  final bool keepOnBackPress;
  final UserModel loggedInUser;
  final bool showBackBtn;
  final bool isFromHome;

  FindCommunitiesView(
      {required this.keepOnBackPress,
      required this.loggedInUser,
      required this.showBackBtn,
      required this.isFromHome});

  @override
  State<StatefulWidget> createState() {
    return FindCommunitiesViewState();
  }
}

enum CompareUserStatus { JOINED, REQUESTED, REJECTED, JOIN }

class FindCommunitiesViewState extends State<FindCommunitiesView> {
  final TextEditingController searchTextController = TextEditingController();
  static String? JOIN;
  static String? JOINED;
  bool showAppbar = false;
  String? nearTimebankText;
  var radius;
  final profanityDetector = ProfanityDetector();
  BuildContext? parentContext;
  String errorText = '';
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    LocationHelper.getLocation().then((value) {
      if (mounted) setState(() {});
    });
    super.initState();

    final _textUpdates = StreamController<String>();
    searchTextController.addListener(() {
      _debouncer.run(() {
        String s = searchTextController.text;

        if (s.isEmpty) {
          setState(() {});
        } else {
          communityBloc.fetchCommunities(s);
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    communityBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    JOIN = 'Info';
    JOINED = S.of(context).joined;
    nearTimebankText = S.of(context).timebanks_near_you;
    bool showBachBtn = widget.showBackBtn;
    showAppbar = widget.isFromHome;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: !showAppbar
          ? AppBar(
              automaticallyImplyLeading: false,
              elevation: 0.5,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () async {
//                     await Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => SevaCore(
//                               loggedInUser: SevaCore.of(context).loggedInUser,
//                               child: NearByFiltersView(
//                                 SevaCore.of(context).loggedInUser,
//                               ),
//                             ),
//                           ),
//                         )
//                         .then((value) => setState(() {}));

                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context1) => NearByFiltersView(
                              userModel: SevaCore.of(context).loggedInUser,
                              // widget.loggedInUser,
                            ),
                          ),
                        )
                        .then((value) => setState(() {}));
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.power_settings_new,
                  ),
                  onPressed: () {
                    logOut();
//                      Navigator.of(context).push(MaterialPageRoute(
//                          builder: (context) => ()));
                  },
                ),
              ],
              leading: showBachBtn
                  ? BackButton(
                      onPressed: () => Navigator.pop(context),
                    )
                  : Offstage(),
              title: Text(
                S.of(context).find_your_timebank,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              titleSpacing: 0,
            )
          : null,
      body: searchTeams(),
    ); // );
  }

  void logOut() {
    String loggedInEmail = SevaCore.of(context).loggedInUser.email!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).log_out),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(S.of(context).log_out_confirmation),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Spacer(),
                  CustomTextButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    shape: StadiumBorder(),
                    color: HexColor("#d2d2d2"),
                    textColor: Colors.white,
                    child: Text(
                      S.of(context).cancel,
                      style: TextStyle(fontFamily: 'Europa'),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CustomTextButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      S.of(context).log_out,
                      style: TextStyle(
                        fontFamily: 'Europa',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () async {
                      // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                      //   statusBarBrightness: Brightness.light,
                      //   statusBarColor: Colors.white,
                      // ));

                      try {
                        await FCMNotificationManager
                            .removeDeviceRegisterationForMember(
                                email: loggedInEmail);
                      } catch (e) {
                        throw e;
                      }
                      Navigator.of(context).pop();
                      _signOut(context);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    // Navigator.pop(context);

    var auth = AuthProvider.of(context).auth;
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AuthRouter(),
      ),
    );
  }

  Widget searchTeams() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        Text(
          S.of(context).looking_existing_timebank,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(color: Colors.black),
          controller: searchTextController,
          validator: (value) {
            if (profanityDetector.isProfaneString(value!)) {
              // errorText =
              return S.of(context).profanity_text_alert;
            }
            return null;
          },
          decoration: InputDecoration(
            //errorText: errorText,
            errorMaxLines: 2,
            suffixIcon: Offstage(
              offstage: searchTextController.text.length == 0,
              child: IconButton(
                splashColor: Colors.transparent,
                icon: Icon(
                  Icons.clear,
                  color: Colors.black54,
                ),
                onPressed: () {
                  //searchTextController.clear();
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) => searchTextController.clear());
                },
              ),
            ),
            alignLabelWithHint: true,
            isDense: true,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
            ),
            contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
            filled: true,
            fillColor: Colors.grey[300],
            focusedErrorBorder: OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.white),
              borderRadius: new BorderRadius.circular(25.7),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25.7),
            ),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7)),
            hintText: S.of(context).find_timebank_help_text,
            hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: buildList(),
        ),
        // This container holds the align
        widget.isFromHome ? Container() : createCommunity(),
        CustomTextButton(
          shape: StadiumBorder(),
          color: Theme.of(context).colorScheme.secondary,
          onPressed: () async {
            await CollectionRef.users.doc(widget.loggedInUser.email).update(
              {
                'skipCreateCommunityPage': true,
              },
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => SevaCore(
                  loggedInUser: widget.loggedInUser,
                  child: HomePageRouter(),
                ),
              ),
              ModalRoute.withName('/'),
            );
          },
          child:
              Text(S.of(context).skip, style: TextStyle(color: Colors.white)),
        ),
      ]),
    );
  }

  Widget buildList() {
    if (searchTextController.text.trim().length < 1) {
      return Column(
        children: <Widget>[
          getEmptyWidget('Users', nearTimebankText!),
          Expanded(child: nearByTimebanks()),
        ],
      );
    }
    // ListView contains a group of widgets that scroll inside the drawer
    return StreamBuilder<List<CommunityModel>>(
      stream: SearchManager.searchCommunity(
        queryString: searchTextController.text,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(S.of(context).try_later);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }

        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 100, horizontal: 60),
            child: Center(
              child: Text(S.of(context).no_timebanks_found,
                  style: TextStyle(fontFamily: "Europa", fontSize: 14)),
            ),
          );
        }

        List<CommunityModel> communityList = snapshot.data!;

        return Padding(
          padding: EdgeInsets.only(left: 0, right: 0, top: 5.0),
          child: ListView.builder(
            padding: EdgeInsets.only(
              bottom: 180,
            ),
            itemCount: communityList.length,
            itemBuilder: (BuildContext context, int index) {
              CompareUserStatus status;

              status = _compareUserStatus(
                  communityList[index], widget.loggedInUser.sevaUserID!);

              return timeBankWidget(
                  communityModel: communityList[index],
                  context: context,
                  status: status);
            },
          ),
        );
      },
    );
  }

  Widget timeBankWidget(
      {CommunityModel? communityModel,
      BuildContext? context,
      CompareUserStatus? status}) {
    return ListTile(
      // onTap: goToNext(snapshot.data),
      title: Text(communityModel!.name,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
      subtitle: FutureBuilder(
        future: getUserForId(sevaUserId: communityModel.created_by),
        builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
          if (snapshot.hasError) {
            return Text(
              S.of(context).timebank,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("...");
          } else if (snapshot.hasData) {
            return Text(
              S.of(context).created_by + "${snapshot.data!.fullname}",
            );
          } else {
            return Container();
          }
        },
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        CustomElevatedButton(
          onPressed: (communityModel.id !=
                  SevaCore.of(context!).loggedInUser.currentCommunity)
              ? () {
                  var communityModell = communityModel;
                  createEditCommunityBloc.selectCommunity(communityModell);
                  createEditCommunityBloc
                      .updateUserDetails(SevaCore.of(context!).loggedInUser);
                  Navigator.of(context!).push(
                    MaterialPageRoute(
                      builder: (_context) => SevaCore(
                        loggedInUser: SevaCore.of(context!).loggedInUser,
                        child: ExploreCommunityDetails(
                          communityId: communityModell.id,
                          isSignedUser: true,
                        ),
                      ),
                    ),
                  );
                }
              : null!,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Text(getUserTimeBankStatusTitle(status!) ?? ""),
              ),
            ],
          ),
          color: Theme.of(context!).colorScheme.secondary,
          textColor: Colors.white,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          elevation: 2.0,
        )
      ]),
    );
  }

  Widget nearByTimebanks() {
    return StreamBuilder<List<CommunityModel>>(
        stream: FirestoreManager.getNearCommunitiesListStream(
          nearbySettings: SevaCore.of(context).loggedInUser.nearBySettings!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.hasData) {
            if (snapshot.data!.length != 0) {
              List<CommunityModel> communityList = snapshot.data!;

              return ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: 180,
                    top: 5.0,
                  ), //to avoid keyboard overlap //temp fix neeeds to be changed
                  shrinkWrap: true,
                  itemCount: communityList.length,
                  itemBuilder: (BuildContext context, int index) {
                    CompareUserStatus status;
                    status = _compareUserStatus(
                      communityList[index],
                      widget.loggedInUser.sevaUserID!,
                    );

                    return timeBankWidget(
                      communityModel: communityList[index],
                      context: context,
                      status: status,
                    );
                  });
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 100, horizontal: 60),
                child: Center(
                  child: Text(S.of(context).no_timebanks_found,
                      style: TextStyle(fontFamily: "Europa", fontSize: 14)),
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
              child: Text(S.of(context).timebank_gps_hint),
            );
            // return Text("Couldn't load results");
          }
          /*else if(snapshot.data==null){
            return Expanded(
              child: Center(
                child: Text('No Timebank found'),
              ),
            );
          }*/
          return Text("");
        });
  }

  String getUserTimeBankStatusTitle(CompareUserStatus status) {
    switch (status) {
      case CompareUserStatus.JOIN:
        return JOIN!;

      case CompareUserStatus.JOINED:
        return JOINED!;

      default:
        return JOIN!;
    }
  }

  CompareUserStatus _compareUserStatus(
    CommunityModel communityModel,
    String seveaUserId,
  ) {
    if (communityModel.members.contains(widget.loggedInUser.sevaUserID)) {
      return CompareUserStatus.JOINED;
    } else if (communityModel.admins.contains(widget.loggedInUser.sevaUserID)) {
      //

      return CompareUserStatus.JOINED;
    } else {
      //

      return CompareUserStatus.JOIN;
    }
  }

  Widget getEmptyWidget(String title, String notFoundValue) {
    return Center(
      child: Text(
        notFoundValue,
        overflow: TextOverflow.ellipsis,
        // style: sectionHeadingStyle,
      ),
    );
  }

  TextStyle get sectionHeadingStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12.5,
      color: Colors.black,
    );
  }

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }

  Widget createCommunity() {
    return Container(
      // This align moves the children to the bottom
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        // This container holds all the children that will be aligned
        // on the bottom and should not scroll with the above ListView
        child: Container(
          child: Column(
            children: <Widget>[
              CustomElevatedButton(
                color: Theme.of(context).colorScheme.secondary,
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 2.0,
                textColor: Colors.white,
                child: Text(
                  S.of(context).create_timebank,
                  style: Theme.of(context).primaryTextTheme.labelLarge,
                ),
                onPressed: () async {
                  globals.isFromOnBoarding = true;
                  var timebankAdvisory =
                      S.of(context).create_timebank_confirmation;
                  Map<String, bool> onActivityResult =
                      (await showTimebankAdvisory(
                                  dialogTitle: timebankAdvisory))
                              ?.cast<String, bool>() ??
                          {};
                  if (onActivityResult['PROCEED'] == true) {
                    createEditCommunityBloc
                        .updateUserDetails(SevaCore.of(context).loggedInUser);
                    Navigator.push(
                      parentContext!,
                      MaterialPageRoute(
                        builder: (context1) => SevaCore(
                          loggedInUser:
                              SevaCore.of(parentContext!).loggedInUser,
                          child: CreateEditCommunityView(
                            isCreateTimebank: true,
                            timebankId: FlavorConfig.values.timebankId,
                            isFromFind: true,
                          ),
                        ),
                      ),
                    );
                  } else {}
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<dynamic, dynamic>> showTimebankAdvisory(
      {String? dialogTitle}) async {
    final result = await showDialog<Map<dynamic, dynamic>>(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            actionsPadding: EdgeInsets.only(right: 20),
            content: Form(
              child: Container(
                height: 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    dialogTitle ?? '',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              CustomTextButton(
                shape: StadiumBorder(),
                color: HexColor("#d2d2d2"),
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop({'PROCEED': false});
                },
              ),
              CustomTextButton(
                shape: StadiumBorder(),
                color: Theme.of(context).colorScheme.secondary,
                child: Text(
                  S.of(context).proceed,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop({'PROCEED': true});
                },
              ),
            ],
          );
        });
    return result ?? {};
  }
}
