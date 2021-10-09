import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:doseform/doseform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/components/sevaavatar/timebankcoverphoto.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';

// import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/models/enums/plan_ids.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/payment_repository.dart';
import 'package:sevaexchange/ui/screens/communities/widgets/community_category_selector.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/ui/screens/sponsors/sponsors_widget.dart';
import 'package:sevaexchange/ui/screens/sponsors/widgets/get_user_verified.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/parent_timebank_picker.dart';
import 'package:sevaexchange/utils/extensions.dart';
import '../switch_timebank.dart';

class CreateEditCommunityView extends StatelessWidget {
  final String timebankId;
  final bool isFromFind;
  final bool isCreateTimebank;

  CreateEditCommunityView({
    @required this.timebankId,
    this.isFromFind,
    this.isCreateTimebank,
  });

  @override
  Widget build(BuildContext context) {
    return isCreateTimebank
        ? ExitWithConfirmation(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor:Theme.of(context).primaryColor,
                elevation: 0.5,
                automaticallyImplyLeading: true,
                title: Text(
                  S.of(context).create_timebank,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              body: CreateEditCommunityViewForm(
                timebankId: timebankId,
                isFromFind: isFromFind,
                isCreateTimebank: isCreateTimebank,
              ),
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            body: CreateEditCommunityViewForm(
              timebankId: timebankId,
              isFromFind: isFromFind,
              isCreateTimebank: isCreateTimebank,
            ),
          );
  }
}

// Create a Form Widget
class CreateEditCommunityViewForm extends StatefulWidget {
  final String timebankId;
  final bool isFromFind;
  final bool isCreateTimebank;

  CreateEditCommunityViewForm({@required this.timebankId, this.isFromFind, this.isCreateTimebank});

  @override
  CreateEditCommunityViewFormState createState() {
    return CreateEditCommunityViewFormState();
  }
}

GlobalKey<DoseFormState> _billingInformationKey = GlobalKey();

class CreateEditCommunityViewFormState extends State<CreateEditCommunityViewForm> {
  double taxPercentage = 0.0;
  double negativeCreditsThreshold = 0;
  CommunityModel communityModel = CommunityModel({});
  CommunityModel editCommunityModel = CommunityModel({});
  final _formKey = GlobalKey<DoseFormState>();
  final infoWindowKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  TextEditingController searchTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  TimebankModel timebankModel = TimebankModel({});
  TimebankModel parentTimebank = TimebankModel({});

  TimebankModel editTimebankModel = TimebankModel({});
  String memberAssignment = "+ Add Members";
  List members = [];
  String communitynName = '';

  bool isBillingDetailsProvided = false;

  bool protectedVal = false;
  GeoFirePoint location;
  String selectedAddress = '';
  String selectedTimebank = '';
  String _billingDetailsError = '';
  String communityImageError = '';
  String enteredName = '';
  User firebaseUser;

  var scollContainer = ScrollController();

  final nameFocus = FocusNode();

  var scrollIsOpen = false;
  var communityFound = false;
  List<FocusNode> focusNodes;
  String errTxt = null;
  int totalMembersCount = 0;

  final _textUpdates = StreamController<String>();
  final profanityDetector = ProfanityDetector();
  bool canTestCommunity = false;
  bool testCommunity = false;
  final _debouncer = Debouncer(milliseconds: 600);
  TextEditingController cityController = TextEditingController(),
      stateController = TextEditingController(),
      countryController = TextEditingController(),
      streetAddress1Controller = TextEditingController(),
      pincodeController = TextEditingController();

  void initState() {
    if (widget.isCreateTimebank == false) {
      getModelData();
      Future.delayed(Duration.zero, () {
        createEditCommunityBloc.getChildTimeBanks(context);
      });
    } else {
      checkTestCommunityStatus();
    }

    super.initState();

    focusNodes = List.generate(8, (_) => FocusNode());
    globals.timebankAvatarURL = null;
    globals.timebankCoverURL = null;
    globals.addedMembersId = [];
    globals.addedMembersFullname = [];
    globals.addedMembersPhotoURL = [];
    selectedUsers = HashMap();

    // if (widget.isCreateTimebank) {
    //   _fetchCurrentlocation;
    // }

    searchTextController.addListener(() {
      _debouncer.run(() {
        String s = searchTextController.text;

        if (s.isEmpty) {
          setState(() {
            errTxt = null;
          });
        } else {
          if (communitynName != s) {
            setState(() {});
            SearchManager.searchCommunityForDuplicate(queryString: s.trim()).catchError((onError) {
              communityFound = false;
              errTxt = null;
            }).then((commFound) {
              if (commFound) {
                setState(() {
                  communityFound = true;
                  errTxt = S.of(context).timebank_name_exists;
                });
              } else {
                setState(() {
                  communityFound = false;
                  errTxt = null;
                });
              }
            });
          }
        }
      });
    });
  }

  Future<void> checkTestCommunityStatus() async {
    Future.delayed(Duration(milliseconds: 200), () {
      FirestoreManager.checkTestCommunityStatus(
              creatorId: SevaCore.of(context).loggedInUser.sevaUserID)
          .then((onValue) {
        setState(() {
          canTestCommunity = onValue;
        });
      });
    });
  }

  void getModelData() async {
    Future.delayed(Duration.zero, () {
      FirestoreManager.getCommunityDetailsByCommunityId(
              communityId: SevaCore.of(context).loggedInUser.currentCommunity)
          .then((onValue) {
        communityModel = onValue;
        communitynName = communityModel.name;
        taxPercentage = onValue.taxPercentage * 100;
        negativeCreditsThreshold = onValue.negativeCreditsThreshold ?? 0;
        searchTextController.text = communityModel.name;
        descriptionTextController.text = communityModel.about;
        setState(() {});
      });
    });

    timebankModel = await FirestoreManager.getTimeBankForId(timebankId: widget.timebankId);
    selectedAddress = timebankModel.address;
    location = timebankModel.location;

    if (timebankModel != null &&
        timebankModel.associatedParentTimebankId != null &&
        timebankModel.associatedParentTimebankId.isNotEmpty) {
      parentTimebank = await FirestoreManager.getTimeBankForId(
        timebankId: timebankModel.associatedParentTimebankId,
      );
      selectedTimebank = parentTimebank.name;
    }

    totalMembersCount = await FirestoreManager.getMembersCountOfAllMembers(
        communityId: SevaCore.of(context).loggedInUser.currentCommunity);
    setState(() {});
  }

  HashMap<String, UserModel> selectedUsers = HashMap();
  BuildContext parentContext;
  var aboutFocus = FocusNode();
  Map onActivityResult;
  ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    this.parentContext = context;

    return DoseForm(formKey: _formKey, child: createSevaX);
  }

  void moveToTop() {
    // _controller.jumpTo(0.0);
    _controller.animateTo(
      -100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void updateExitWithConfirmationValue(BuildContext context, int index, String value) {
    ExitWithConfirmation.of(context)?.fieldValues[index] = value;
  }

  Widget get createSevaX {
    var colums = StreamBuilder(
        stream: createEditCommunityBloc.createEditCommunity,
        builder: (_, snapshot) {
          if (snapshot.data != null) {
            if (selectedAddress != null) {
              if ((selectedAddress.length > 0 && snapshot.data.timebank.address.length == 0) ||
                  (snapshot.data.timebank.address != selectedAddress)) {
                snapshot.data.timebank.updateValueByKey('address', selectedAddress);
                createEditCommunityBloc.onChange(snapshot.data);
              }
            }

            return Builder(builder: (BuildContext context) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                controller: _controller,
                child: FadeAnimation(
                    1.4,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: widget.isCreateTimebank
                              ? Text(
                                  S.of(context).create_timebank_description,
                                  textAlign: TextAlign.center,
                                )
                              : Container(),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              children: <Widget>[
                                widget.isCreateTimebank
                                    ? SizedBox(
                                        height: 10,
                                      )
                                    : Container(),
                                widget.isCreateTimebank
                                    ? TimebankCoverPhoto()
                                    : TimebankCoverPhoto(
                                        coverUrl: (communityModel.cover_url == null ||
                                                communityModel.cover_url == '')
                                            ? null
                                            : communityModel.cover_url,
                                      ),
                                Text(''),
                                Text(
                                  "${S.of(context).cover_picture_label}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                widget.isCreateTimebank
                                    ? TimebankAvatar()
                                    : TimebankAvatar(
                                        photoUrl: communityModel.logo_url ?? '',
                                      ),
                                Text(''),
                                Text(
                                  "${S.of(context).timebank_logo} *",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(communityImageError,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 12,
                                    ))
                              ],
                            ),
                          ),
                        ),
                        headingText('${S.of(context).timebank_name} *'),
                        DoseTextField(
                          isRequired: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          currentNode: nameFocus,
                          textCapitalization: TextCapitalization.sentences,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(aboutFocus);
                          },
                          controller: searchTextController,
                          onChanged: (value) {
                            updateExitWithConfirmationValue(context, 1, value);
                          },
                          decoration: InputDecoration(
                            errorMaxLines: 2,
                            hintText: S.of(context).timebank_name_hint,
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          //TODO autocorrect required
                          // autocorrect: true,
                          maxLines: 1,
                          onSaved: (value) {
                            enteredName =
                                // value.replaceAll("[^a-zA-Z0-9_ ]*", "").trim();
                                value.trim();
                          },
                          // onSaved: (value) => enteredName = value,
                          validator: (value) {
                            if (value.trim().isEmpty || value == '') {
                              return S.of(context).timebank_name_error;
                            } else if (communityFound) {
                              return S.of(context).timebank_name_exists_error;
                            } else if (profanityDetector.isProfaneString(value)) {
                              return S.of(context).profanity_text_alert;
                            } else if (value.substring(0, 1).contains('_') &&
                                !AppConfig.testingEmails
                                    .contains(SevaCore.of(context).loggedInUser.email)) {
                              return 'Creating community with "_" is not allowed';
                            } else {
                              enteredName = value.replaceAll("[^a-zA-Z0-9]", "").trim();
                              snapshot.data.community.updateValueByKey(
                                  'name', value.replaceAll("[^a-zA-Z0-9]", "").trim());
                              createEditCommunityBloc.onChange(snapshot.data);
                            }

                            return null;
                          },
                        ),
                        headingText('${S.of(context).about} *'),
                        DoseTextField(
                          isRequired: true,
                          controller: descriptionTextController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          currentNode: aboutFocus,
                          decoration: InputDecoration(
                            errorMaxLines: 2,
                            hintText: S.of(context).timbank_about_hint,
                          ),
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          //  initialValue: timebankModel.missionStatement ?? "",
                          onChanged: (value) {
                            updateExitWithConfirmationValue(context, 2, value);
                            timebankModel.missionStatement = value;
                            communityModel.about = value;
                          },
                          validator: (value) {
                            if (value.trim().isEmpty) {
                              return S.of(context).timebank_tell_more;
                            } else if (profanityDetector.isProfaneString(value)) {
                              return S.of(context).profanity_text_alert;
                            } else {
                              snapshot.data.community.updateValueByKey('about', value);

                              snapshot.data.timebank.updateValueByKey('missionStatement', value);
                              createEditCommunityBloc.onChange(snapshot.data);
                              timebankModel.missionStatement = value;
                              communityModel.about = value;
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        headingText(S.of(context).select_categories_community_headding),
                        SizedBox(
                          height: 10,
                        ),
                        CommunityCategorySelector(
                          selectedCategories: communityModel.communityCategories ?? [],
                          onChanged: (List<CommunityCategoryModel> categoryList) {
                            communityModel.communityCategories =
                                categoryList.map((e) => e.id).toList();
                            snapshot.data.community.updateValueByKey(
                                'communityCategories', communityModel.communityCategories.toList());
                            setState(() {});
                          },
                        ),
                        // todo:: removed timebank members
                        // Offstage(
                        //   offstage: widget.isCreateTimebank,
                        //   child: Row(
                        //     children: <Widget>[
                        //       headingText(S.of(context).timebank_members),
                        //       Padding(
                        //         padding: EdgeInsets.only(left: 10, top: 15),
                        //         child: IconButton(
                        //           icon: Icon(
                        //             Icons.add_circle_outline,
                        //           ),
                        //           onPressed: () {
                        //             addVolunteers();
                        //           },
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Offstage(
                        //   offstage: widget.isCreateTimebank,
                        //   child: Row(
                        //     children: <Widget>[
                        //       totalMembersCount != 0
                        //           ? Text(
                        //               totalMembersCount.toString() ?? " ",
                        //               style: TextStyle(
                        //                   fontWeight: FontWeight.bold,
                        //                   fontFamily: 'Europa'),
                        //             )
                        //           : Container(),
                        //     ],
                        //   ),
                        // ),
                        // !widget.isCreateTimebank
                        //     ? Row(
                        //         children: <Widget>[
                        //           headingText(S.of(context).private_timebank),
                        //           Padding(
                        //             padding:
                        //                 const EdgeInsets.fromLTRB(2, 10, 0, 0),
                        //             child: infoButton(
                        //               context: context,
                        //               key: GlobalKey(),
                        //               type: InfoType.PRIVATE_TIMEBANK,
                        //             ),
                        //           ),
                        //           Column(
                        //             children: <Widget>[
                        //               Divider(),
                        //               Checkbox(
                        //                 value: widget.isCreateTimebank
                        //                     ? snapshot.data.timebank.private
                        //                     : timebankModel.private,
                        //                 onChanged: (bool value) {
                        //                   if (widget.isCreateTimebank) {
                        //                     if (timebankModel.private != null &&
                        //                         timebankModel.private == true) {
                        //                       timebankModel.private = false;
                        //                       snapshot.data.community
                        //                           .updateValueByKey(
                        //                               'private', false);
                        //                       communityModel.private = false;
                        //                       snapshot.data.timebank
                        //                           .updateValueByKey(
                        //                               'private', false);
                        //                       createEditCommunityBloc
                        //                           .onChange(snapshot.data);
                        //                     } else {
                        //                       _showPrivateTimebankAdvisory()
                        //                           .then((status) {
                        //                         if (status == 'Proceed') {
                        //                           timebankModel.private = true;
                        //                           snapshot.data.community
                        //                               .updateValueByKey(
                        //                                   'private', true);
                        //                           communityModel.private = true;
                        //                           snapshot.data.timebank
                        //                               .updateValueByKey(
                        //                                   'private', true);
                        //                           createEditCommunityBloc
                        //                               .onChange(snapshot.data);
                        //                         } else {
                        //                           timebankModel.private = false;
                        //                           snapshot.data.community
                        //                               .updateValueByKey(
                        //                                   'private', false);
                        //                           communityModel.private =
                        //                               false;
                        //                           snapshot.data.timebank
                        //                               .updateValueByKey(
                        //                                   'private', false);
                        //                           createEditCommunityBloc
                        //                               .onChange(snapshot.data);
                        //                         }
                        //                       });
                        //                     }
                        //                   } else {
                        //                     null;
                        //                   }
                        //                 },
                        //               ),
                        //             ],
                        //           ),
                        //         ],
                        //       )
                        //     : Offstage(),
                        Row(
                          children: <Widget>[
                            headingText(S.of(context).protected_timebank),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                              child: getInfoWidget(
                                infoKey: infoWindowKeys[0],
                                type: InfoType.PROTECTED_TIMEBANK,
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                            //   child: infoButton(
                            //     context: context,
                            //     key: GlobalKey(),
                            //     type: InfoType.PROTECTED_TIMEBANK,
                            //   ),
                            // ),
                            Spacer(),
                            Column(
                              children: <Widget>[
                                Divider(),
                                Checkbox(
                                  value: widget.isCreateTimebank
                                      ? snapshot.data.timebank.protected
                                      : timebankModel.protected,
                                  onChanged: (bool value) {
                                    timebankModel.protected = value;
                                    snapshot.data.timebank.updateValueByKey('protected', value);
                                    createEditCommunityBloc.onChange(snapshot.data);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            headingText(
                              S.of(context).prevent_accidental_delete,
                            ),
                            Spacer(),
                            Column(
                              children: <Widget>[
                                Divider(),
                                Checkbox(
                                  value: widget.isCreateTimebank
                                      ? snapshot.data.timebank.preventAccedentalDelete
                                      : timebankModel.preventAccedentalDelete,
                                  onChanged: (bool value) {
                                    timebankModel.preventAccedentalDelete = value;
                                    snapshot.data.timebank.updateValueByKey(
                                      'preventAccedentalDelete',
                                      value,
                                    );
                                    createEditCommunityBloc.onChange(snapshot.data);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Offstage(
                          offstage: !widget.isCreateTimebank,
                          child: Row(
                            children: <Widget>[
                              headingText(S.of(context).sandbox_community),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                child: infoButton(
                                  context: context,
                                  key: GlobalKey(),
                                  type: InfoType.TestCommunity,
                                ),
                              ),
                              Spacer(),
                              Column(
                                children: <Widget>[
                                  Divider(),
                                  Checkbox(
                                    value: testCommunity,
                                    onChanged: (bool value) {
                                      if (!canTestCommunity) {
                                        if (!testCommunity) {
                                          _showSanBoxdvisory(
                                                  title: S
                                                      .of(context)
                                                      .sandbox_dialog_title
                                                      .sentenceCase(),
                                                  description:
                                                      S.of(context).sandbox_community_description)
                                              .then((status) {
                                            if (status) {
                                              communityModel.payment = {
                                                "planId": PlanIds.enterprise_plan.label,
                                                "payment_success": true,
                                                "message": "You are on Enterprise Plan",
                                                "status": 200,
                                              };

                                              snapshot.data.community.updateValueByKey(
                                                'payment',
                                                communityModel.payment,
                                              );

                                              communityModel.testCommunity = true;
                                              snapshot.data.community.updateValueByKey(
                                                'testCommunity',
                                                true,
                                              );
                                              testCommunity = true;
                                              timebankModel.liveMode = true;

                                              setState(() {});
                                            }
                                          });
                                        } else {
                                          communityModel.payment = null;
                                          snapshot.data.community.updateValueByKey(
                                            'testCommunity',
                                            false,
                                          );
                                          testCommunity = false;
                                          timebankModel.liveMode = false;
                                          communityModel.testCommunity = false;

                                          setState(() {});
                                        }
                                      } else {
                                        showDialogForSuccess(
                                            dialogTitle:
                                                S.of(context).you_created_sandbox_community,
                                            err: true);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        HideWidget(
                          hide: widget.isCreateTimebank,
                          child: TransactionsMatrixCheck(
                            comingFrom: ComingFrom.Community,
                            upgradeDetails: AppConfig.upgradePlanBannerModel.community_sponsors,
                            transaction_matrix_type: 'community_sponsors',
                            child: SponsorsWidget(
                              textColor: Theme.of(context).primaryColor,
                              sponsorsMode:
                                  widget.isCreateTimebank ? SponsorsMode.CREATE : SponsorsMode.EDIT,
                              sponsors: timebankModel.sponsors,
                              isAdminVerified: GetUserVerified<bool>().verify(
                                userId: SevaCore.of(context).loggedInUser.sevaUserID,
                                creatorId: timebankModel.creatorId,
                                admins: timebankModel.admins,
                                organizers: timebankModel.organizers,
                              ),
                              onSponsorsAdded: (
                                List<SponsorDataModel> sponsorsData,
                                SponsorDataModel addedSponsors,
                              ) {
                                setState(() {
                                  snapshot.data.timebank.updateValueByKey(
                                    'sponsors',
                                    sponsorsData,
                                  );
                                  timebankModel.sponsors = sponsorsData;
                                });
                                logger.i(
                                    'Added Sponsors in Community:\n Name:${addedSponsors.name}\nLogo:${addedSponsors.logo}\nCreatedBy:${addedSponsors.createdBy}\nCreatedAt:${addedSponsors.createdAt}\n----------------------------------------------------------\n');
                              },
                              onSponsorsRemoved: (
                                List<SponsorDataModel> sponsorsData,
                                SponsorDataModel removedSponsors,
                              ) {
                                setState(() {
                                  timebankModel.sponsors = sponsorsData;
                                });
                                logger.i(
                                    'Remove Sponsors from Community:\n Name:${removedSponsors.name}\nLogo:${removedSponsors.logo}\nCreatedBy:${removedSponsors.createdBy}\nCreatedAt:${removedSponsors.createdAt}\n----------------------------------------------------------\n');
                              },
                              onError: (error) {
                                logger.e(error);
                              },
                            ),
                          ),
                        ),
                        widget.isCreateTimebank ? Container() : SizedBox(height: 10),
                        widget.isCreateTimebank
                            ? Container()
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  headingText(S.of(context).timebank_select_tax_percentage),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                    child: getInfoWidget(
                                      infoKey: infoWindowKeys[1],
                                      type: InfoType.TAX_CONFIGURATION,
                                    ),
                                  ),
                                  // Padding(
                                  //   padding:
                                  //       const EdgeInsets.fromLTRB(2, 15, 0, 0),
                                  //   child: infoButton(
                                  //     context: context,
                                  //     key: GlobalKey(),
                                  //     type: InfoType.TAX_CONFIGURATION,
                                  //   ),
                                  // ),
                                ],
                              ),
                        widget.isCreateTimebank
                            ? Container()
                            : Slider(
                                label: "${taxPercentage.toInt()}%",
                                value: taxPercentage,
                                min: 0,
                                max: 15,
                                divisions: 15,
                                onChanged: (value) {
                                  snapshot.data.community
                                      .updateValueByKey('taxPercentage', value / 100);
                                  setState(
                                    () {
                                      taxPercentage = value;
                                      communityModel.taxPercentage = value / 100;
                                    },
                                  );
                                },
                              ),
                        Offstage(
                          offstage: widget.isCreateTimebank,
                          child: Row(
                            children: <Widget>[
                              Text(
                                S.of(context).timebank_current_tax_percentage +
                                    ' : ${taxPercentage.toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Offstage(
                          offstage: widget.isCreateTimebank,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  headingText(S.of(context).negative_threshold_title),
                                  SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                    child: getInfoWidget(
                                      infoKey: infoWindowKeys[2],
                                      type: InfoType.NEGATIVE_CREDITS,
                                    ),
                                  ),

                                  // infoButton(
                                  //   context: context,
                                  //   key: GlobalKey(),
                                  //   type: InfoType.NEGATIVE_CREDITS,
                                  // ),
                                  // IconButton(
                                  //   key: infoWindowKeys[0],
                                  //   icon: Image.asset(
                                  //     'lib/assets/images/info.png',
                                  //     color: FlavorConfig
                                  //         .values.theme.primaryColor,
                                  //     height: 16,
                                  //     width: 16,
                                  //   ),
                                  //   onPressed: () {
                                  //     RenderBox renderBox = infoWindowKeys[0]
                                  //         .currentContext
                                  //         .findRenderObject();
                                  //     Offset buttonPosition =
                                  //         renderBox.localToGlobal(Offset.zero);
                                  //     logger.i(
                                  //         "====" + buttonPosition.toString());
                                  //     showDialogFromInfoWindow(
                                  //       context: context,
                                  //       key: infoWindowKeys[0],
                                  //       type: InfoType.NEGATIVE_CREDITS,
                                  //       buttonPosition: buttonPosition,
                                  //     );
                                  //   },
                                  // ),
                                ],
                              ),
                              Slider(
                                label:
                                    "${negativeCreditsThreshold.toInt()} ${S.of(context).seva_credits}",
                                value: negativeCreditsThreshold.abs() * -1,
                                min: -50,
                                max: 0,
                                divisions: 50,
                                onChanged: (value) {
                                  snapshot.data.community.updateValueByKey(
                                    'negativeCreditsThreshold',
                                    value,
                                  );
                                  setState(
                                    () {
                                      negativeCreditsThreshold = value;
                                      communityModel.negativeCreditsThreshold = value;
                                    },
                                  );
                                },
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    S.of(context).selected_value +
                                        '${negativeCreditsThreshold} ${S.of(context).seva_credits}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Offstage(
                            offstage: widget.isCreateTimebank,
                            child: headingText(S.of(context).timebank_has_parent)),
                        Offstage(
                          offstage: widget.isCreateTimebank,
                          child: Text(
                            S.of(context).timebank_location_has_parent_hint_text,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Offstage(
                          offstage: widget.isCreateTimebank,
                          child: TransactionsMatrixCheck(
                            comingFrom: ComingFrom.Community,
                            upgradeDetails: AppConfig.upgradePlanBannerModel.parent_timebanks,
                            transaction_matrix_type: "parent_timebanks",
                            child: Center(
                              child: ParentTimebankPickerWidget(
                                selectedTimebank: this.selectedTimebank,
                                onChanged: (CommunityModel selectedTimebank) {
                                  setState(() {
                                    this.selectedTimebank = selectedTimebank.name;
                                  });
                                  snapshot.data.timebank.updateValueByKey(
                                      'associatedParentTimebankId',
                                      selectedTimebank.primary_timebank);
                                  timebankModel.associatedParentTimebankId =
                                      selectedTimebank.primary_timebank;
                                  communityModel.parentTimebankId =
                                      selectedTimebank.primary_timebank;
                                  snapshot.data.community.updateValueByKey(
                                      'parentTimebankId', selectedTimebank.primary_timebank);
                                },
                              ),
                            ),
                          ),
                        ),
                        widget.isCreateTimebank ? Container() : SizedBox(height: 20),
                        headingText(S.of(context).timebank_location),
                        Text(
                          S.of(context).timebank_location_hint,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: LocationPickerWidget(
                            selectedAddress: selectedAddress,
                            location: location,
                            onChanged: (LocationDataModel dataModel) {
                              setState(() {
                                location = dataModel.geoPoint;
                                this.selectedAddress = dataModel.location;
                              });
                            },
                          ),
                        ),

                        SizedBox(height: 10),
                        widget.isCreateTimebank
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0),
                                child: tappableAddBillingDetails,
                              )
                            : Container(),
//                  Offstage(
//                    offstage: !widget.isCreateTimebank,
//                    child: Padding(
//                      padding: const EdgeInsets.symmetric(vertical: 10.0),
//                      child: tappableAddBillingDetails,
//                    ),
//                  ),
                        SizedBox(height: 10),
                        widget.isCreateTimebank
                            ? Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      // Text(
                                      //   'Looking for existing timebank',
                                      //   style: TextStyle(
                                      //     color: Colors.grey,
                                      //   ),
                                      // ),
                                      // tappableFindYourTeam,
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            alignment: Alignment.center,
                            child: CustomElevatedButton(
                              onPressed: () async {
                                var connResult = await Connectivity().checkConnectivity();
                                if (connResult == ConnectivityResult.none) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(S.of(context).check_internet),
                                      action: SnackBarAction(
                                        label: S.of(context).dismiss,
                                        onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (errTxt != null) {
                                  showDialogForSuccess(
                                    dialogTitle: S.of(context).timebank_name_exists,
                                    err: true,
                                  );
                                  return;
                                }
                                // show a dialog
                                if (widget.isCreateTimebank) {
                                  if (_formKey.currentState.validate()) {
                                    if (isBillingDetailsProvided) {
                                      setState(() {
                                        this._billingDetailsError = '';
                                      });
                                      if (!hasRegisteredLocation()) {
                                        showDialogForSuccess(
                                            dialogTitle: S.of(context).timebank_location_error,
                                            err: true);
                                        return;
                                      }
                                      if (globals.timebankAvatarURL == null) {
                                        setState(() {
                                          this.communityImageError =
                                              S.of(context).timebank_logo_error;
                                          moveToTop();
                                        });
                                      } else {
                                        showProgressDialog(
                                          S.of(context).creating_timebank,
                                        );

                                        setState(() {
                                          this.communityImageError = '';
                                        });

                                        // creation of community;
                                        snapshot.data.UpdateCommunityDetails(
                                          SevaCore.of(context).loggedInUser,
                                          globals.timebankAvatarURL,
                                          location,
                                          globals.timebankCoverURL,
                                        );
                                        // creation of default timebank;
                                        snapshot.data.UpdateTimebankDetails(
                                          SevaCore.of(context).loggedInUser,
                                          globals.timebankAvatarURL,
                                          globals.timebankCoverURL,
                                        );
                                        // updating the community with default timebank id
                                        snapshot.data.community.timebanks =
                                            [snapshot.data.timebank.id].cast<String>();
                                        snapshot.data.community.primary_timebank = snapshot.data
                                            .community.primary_timebank = snapshot.data.timebank.id;
                                        snapshot.data.community.location = location;
                                        snapshot.data.community.softDelete = false;
                                        snapshot.data.community.members = [
                                          SevaCore.of(context).loggedInUser.sevaUserID
                                        ];

                                        snapshot.data.community.billMe = false;

                                        await createEditCommunityBloc.createCommunity(
                                          snapshot.data,
                                          SevaCore.of(context).loggedInUser,
                                        );

                                        if (testCommunity == false) {
                                          //by default every community is on neighbourhood plan
                                          var result = await PaymentRepository.subscribe(
                                            communityId: snapshot.data.community.id,
                                            paymentMethodId: 'sample',
                                            planId: PlanIds.neighbourhood_plan,
                                            isPrivate: false,
                                            isBundlePricingEnabled: false,
                                          );

                                          // snapshot.data.community.payment = {
                                          //   "planId": "neighbourhood_plan",
                                          //   "payment_success": true,
                                          //   "message":
                                          //       "You are on Neighbourhood plan",
                                          //   "status": 200,
                                          // };
                                        }

                                        await CollectionRef.users
                                            .doc(SevaCore.of(context).loggedInUser.email)
                                            .update({
                                          'communities':
                                              FieldValue.arrayUnion([snapshot.data.community.id]),
                                          'currentCommunity': snapshot.data.community.id,
                                          'currentTimebank':
                                              snapshot.data.community.primary_timebank,
                                        });

                                        setState(() {
                                          SevaCore.of(context).loggedInUser.currentCommunity =
                                              snapshot.data.community.id;
                                          SevaCore.of(context).loggedInUser.currentTimebank =
                                              snapshot.data.community.primary_timebank;
                                        });

                                        globals.timebankAvatarURL = null;
                                        globals.timebankCoverURL = null;
                                        globals.webImageUrl = null;

                                        Navigator.pop(dialogContext);
                                        UserModel user = SevaCore.of(context).loggedInUser;
                                        //TODO reset
                                        _formKey.currentState.reset();
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => SevaCore(
                                              loggedInUser: user,
                                              child: HomePageRouter(),
                                            ),
                                          ),
                                          (Route<dynamic> route) => false,
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        this._billingDetailsError =
                                            S.of(context).timebank_account_error;
                                      });
                                    }
                                  }
                                } else {
                                  if (_formKey.currentState.validate()) {
                                    if (!hasRegisteredLocation()) {
                                      showDialogForSuccess(
                                          dialogTitle: S.of(context).timebank_location_error,
                                          err: true);
                                      return;
                                    }

                                    showProgressDialog(
                                      S.of(context).updating_timebank,
                                    );

                                    log('UPDATE CHECK 3: ' + globals.timebankAvatarURL.toString());
                                    log('UPDATE CHECK 4: ' + globals.timebankCoverURL.toString());

                                    if (globals.timebankAvatarURL != null) {
                                      communityModel.logo_url = globals.timebankAvatarURL;
                                      timebankModel.photoUrl = globals.timebankAvatarURL;
                                    }

                                    if (globals.timebankCoverURL != null) {
                                      communityModel.cover_url = globals.timebankCoverURL;
                                      timebankModel.cover_url = globals.timebankCoverURL;
                                      setState(() {});
                                    }

                                    timebankModel.name = searchTextController.text.trim();
                                    communityModel.name = searchTextController.text.trim();

                                    timebankModel.location = location;

                                    timebankModel.address = selectedAddress;
                                    // updating timebank with latest values
                                    await FirestoreManager.updateTimebank(
                                      timebankModel: timebankModel,
                                    ).then((onValue) {});
                                    communityModel.taxPercentage = taxPercentage / 100;

                                    communityModel.negativeCreditsThreshold =
                                        negativeCreditsThreshold;
//                            //updating community with latest values
                                    await FirestoreManager.updateCommunityDetails(
                                            communityModel: communityModel)
                                        .then((onValue) {});

                                    globals.timebankAvatarURL = null;
                                    globals.timebankCoverURL = null;
                                    globals.webImageUrl = null;
                                    if (dialogContext != null) {
                                      Navigator.pop(dialogContext);
                                    }
                                    //TODO reset
                                    _formKey.currentState.reset();
                                    if (widget.isFromFind) {
                                      Navigator.of(context).pop();
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SwitchTimebank(
                                            content: S.of(context).updating_timebank,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              shape: StadiumBorder(),
                              child: Text(
                                widget.isCreateTimebank
                                    ? S.of(context).create_timebank
                                    : S.of(context).save,
                                style: TextStyle(fontSize: 16.0, color: Colors.white),
                              ),
                              textColor: FlavorConfig.values.buttonTextColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 100),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Text(
                            '',
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    )),
              );
            });
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Text("");
        });
    var contain = Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: colums,
    );
    return contain;
  }

  getInfoWidget({
    GlobalKey infoKey,
    InfoType type,
  }) {
    return IconButton(
      key: infoKey,
      icon: Image.asset(
        'lib/assets/images/info.png',
        color:Theme.of(context).primaryColor,
        height: 16,
        width: 16,
      ),
      onPressed: () {
        RenderBox renderBox = infoKey.currentContext.findRenderObject();
        Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
        showDialogFromInfoWindow(
          context: context,
          key: infoKey,
          type: type,
          buttonPosition: buttonPosition,
        );
      },
    );
  }

  Future<bool> _showSanBoxdvisory({String title, String description}) {
    return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext _context) {
              return AlertDialog(
                title: Text(title),
                content: Text(description),
                actions: <Widget>[
                  CustomTextButton(
                    color: HexColor("#d2d2d2"),
                    textColor: Colors.white,
                    child: Text(
                      S.of(context).no,
                      style: TextStyle(fontSize: dialogButtonSize),
                    ),
                    onPressed: () {
                      Navigator.of(_context).pop(false);
                    },
                  ),
                  CustomElevatedButton(
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      S.of(context).yes,
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(_context).pop(true);
                    },
                  ),
                ],
              );
            }) ??
        false;
  }

  BuildContext dialogContext;

  bool hasRegisteredLocation() {
    return location != null;
  }

  void showProgressDialog(String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              title: Text(message),
              content: LinearProgressIndicator(
 backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
),
            ),
          );
        });
  }

  Widget headingText(String name) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget get tappableAddBillingDetails {
    return GestureDetector(
      onTap: () {
        FocusScope.of(parentContext).requestFocus(FocusNode());
        _billingBottomsheet(parentContext);
      },
      child: Column(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              S.of(context).timebank_configure_accounr_info,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 14,
              ),
            ),
            Divider(),
            Text(
              '+',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blue,
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _billingDetailsError,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 12,
              ),
            )
          ],
        ),
      ]),
    );
  }

  void _billingBottomsheet(BuildContext mcontext) {
    showModalBottomSheet(
      context: mcontext,
      // isScrollControlled: true,
      builder: (builder) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              child: _scrollingList(mcontext, focusNodes),
            ),
          ),
        );
      },
    );
  }

//   Future _setLocation(data, LocationDataModel dataModel) async {
//     setState(() {
//       this.selectedAddress = dataModel.location;
//     });
// //    timebank.updateValueByKey('locationAddress', address);
//     timebankModel.address = dataModel.location;
//     communityModel.location = location;
//     data.timebank.updateValueByKey('address', dataModel.location);
//     data.community.updateValueByKey('location', location);
//     createEditCommunityBloc.onChange(data);
//   }

//   Future _getLocation(data) async {
//     String address = await LocationUtility().getFormattedAddress(
//       location.latitude,
//       location.longitude,
//     );
//     setState(() {
//       this.selectedAddress = address;
//     });
// //    timebank.updateValueByKey('locationAddress', address);
//     timebankModel.address = address;
//     communityModel.location = location;
//     data.timebank.updateValueByKey('address', address);
//     data.community.updateValueByKey('location', location);
//     createEditCommunityBloc.onChange(data);
//   }

  // void fetchCurrentlocation() {
  //   Location().getLocation().then((onValue) {
  //     location = GeoFirePoint(onValue.latitude, onValue.longitude);
  //     LocationUtility()
  //         .getFormattedAddress(
  //       location.latitude,
  //       location.longitude,
  //     )
  //         .then((address) {
  //       setState(() {
  //         this.selectedAddress = address;
  //       });
  //     });
  //   });
  // }

  InputDecoration getData(String fieldValue) {
    return InputDecoration(
      errorStyle: TextStyle(
        color: Colors.red,
        wordSpacing: 5.0,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
      ),
      border: OutlineInputBorder(
        gapPadding: 0.0,
        borderRadius: BorderRadius.circular(1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1.0),
      ),
      hintText: fieldValue,
      alignLabelWithHint: false,
    );
  }

  Widget get _billingDetailsTitle {
    return Container(
//        margin: EdgeInsets.fromLTRB(10, 0, 20, 10),
        margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  S.of(context).account_information,
                  style: TextStyle(
                      color:Theme.of(context).primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    //_pc.close();
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Text(
                      ''' x ''',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  static InputDecoration getInputDecoration({String fieldTitle}) {
    return InputDecoration(
      errorMaxLines: 2,

      errorStyle: TextStyle(
        color: Colors.red,
        wordSpacing: 2.0,
      ),
//      focusedBorder: OutlineInputBorder(
//        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
//      ),
//      border: OutlineInputBorder(
//          gapPadding: 0.0, borderRadius: BorderRadius.circular(1.5)),
//      enabledBorder: OutlineInputBorder(
//        borderSide: BorderSide(color: Colors.green, width: 1.0),
//      ),
      hintText: fieldTitle,
      alignLabelWithHint: false,
    );
  }

  Widget _scrollingList(BuildContext context, List<FocusNode> focusNodes) {
    Widget _stateWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: DoseTextField(
          isRequired: true,
          controller: stateController,
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(focusNodes[2]);
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            updateExitWithConfirmationValue(context, 3, value);

            controller.community.billing_address.updateValueByKey('state', value);
            createEditCommunityBloc.onChange(controller);
          },
          /* initialValue: controller.community.billing_address.state != null
              ? '${controller.community.billing_address.state}'
              : '',*/
          validator: (value) {
            return value.isEmpty
                ? S.of(context).validation_error_required_fields
                : (profanityDetector.isProfaneString(value))
                    ? S.of(context).profanity_text_alert
                    : null;
          },
          currentNode: focusNodes[1],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: '${S.of(context).state} *',
          ),
        ),
      );
    }

    Widget _cityWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: DoseTextField(
          isRequired: true,
          controller: cityController,
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(focusNodes[1]);
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            updateExitWithConfirmationValue(context, 4, value);

            controller.community.billing_address.updateValueByKey('city', value);
            createEditCommunityBloc.onChange(controller);
          },
          /* initialValue: controller.community.billing_address.city != null
              ? '${controller.community.billing_address.city}'
              : '',*/
          validator: (value) {
            return value.isEmpty
                ? S.of(context).validation_error_required_fields
                : (profanityDetector.isProfaneString(value))
                    ? S.of(context).profanity_text_alert
                    : null;
          },
          currentNode: focusNodes[0],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: '${S.of(context).city} *',
          ),
        ),
      );
    }

    Widget _pinCodeWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: DoseTextField(
          isRequired: true,
          controller: pincodeController,
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(focusNodes[4]);
          },
          onChanged: (value) {
            updateExitWithConfirmationValue(context, 5, value);
            controller.community.billing_address.updateValueByKey('pincode', value);
            createEditCommunityBloc.onChange(controller);
          },
          /* initialValue: controller.community.billing_address.pincode != null
              ? '${controller.community.billing_address.pincode.toString()}'
              : '',*/
          validator: (value) {
            return value.isEmpty
                ? S.of(context).validation_error_required_fields
                : (profanityDetector.isProfaneString(value))
                    ? S.of(context).profanity_text_alert
                    : null;
          },
          currentNode: focusNodes[3],
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          maxLength: 15,
          decoration: getInputDecoration(
            fieldTitle: '${S.of(context).zip} *',
          ),
        ),
      );
    }

    Widget _additionalNotesWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (input) {
            FocusScope.of(context).unfocus();
            // scrollToBottom();
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            updateExitWithConfirmationValue(context, 6, value);

            controller.community.billing_address.updateValueByKey('additionalnotes', value);
            createEditCommunityBloc.onChange(controller);
          },
          initialValue: controller.community.billing_address.additionalnotes != null
              ? controller.community.billing_address.additionalnotes
              : '',
          validator: (value) {
            return (profanityDetector.isProfaneString(value))
                ? S.of(context).profanity_text_alert
                : null;
          },
          onSaved: (value) {},
          focusNode: focusNodes[7],
          textInputAction: TextInputAction.done,
          decoration: getInputDecoration(
            fieldTitle: S.of(context).additional_notes,
          ),
        ),
      );
    }

    Widget _streetAddressWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: DoseTextField(
          isRequired: true,
          controller: streetAddress1Controller,
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (input) {
            // FocusScope.of(context).requestFocus(focusNodes[5]);
            FocusScope.of(context).unfocus();
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            updateExitWithConfirmationValue(context, 7, value);

            controller.community.billing_address.updateValueByKey('street_address1', value);
            createEditCommunityBloc.onChange(controller);
          },
          validator: (value) {
            return value.isEmpty
                ? S.of(context).validation_error_required_fields
                : (profanityDetector.isProfaneString(value))
                    ? S.of(context).profanity_text_alert
                    : null;
          },
          currentNode: focusNodes[4],
          textInputAction: TextInputAction.done,
/*          initialValue: controller.community.billing_address.street_address1 != null
              ? '${controller.community.billing_address.street_address1}'
              : '',*/
          decoration: getInputDecoration(
            fieldTitle: "${S.of(context).street_add1} *",
          ),
        ),
      );
    }

    Widget _streetAddressTwoWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textCapitalization: TextCapitalization.sentences,
            onFieldSubmitted: (input) {
              FocusScope.of(context).unfocus();
            },
            keyboardType: TextInputType.text,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 8, value);

              controller.community.billing_address.updateValueByKey('street_address2', value);
              createEditCommunityBloc.onChange(controller);
            },
            validator: (value) {
              return (profanityDetector.isProfaneString(value))
                  ? S.of(context).profanity_text_alert
                  : null;
            },
            focusNode: focusNodes[5],
            textInputAction: TextInputAction.done,
            initialValue: controller.community.billing_address.street_address2 != null
                ? controller.community.billing_address.street_address2
                : '',
            decoration: getInputDecoration(
              fieldTitle: S.of(context).street_add2,
            )),
      );
    }

    Widget _companyNameWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(focusNodes[7]);
            // scrollToBottom();
          },
          validator: (value) {
            return (profanityDetector.isProfaneString(value))
                ? S.of(context).profanity_text_alert
                : null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            updateExitWithConfirmationValue(context, 9, value);

            controller.community.billing_address.updateValueByKey('companyname', value);
            createEditCommunityBloc.onChange(controller);
          },
          initialValue: controller.community.billing_address.companyname != null
              ? controller.community.billing_address.companyname
              : '',
          focusNode: focusNodes[6],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: S.of(context).company_name,
          ),
        ),
      );
    }

    Widget _countryNameWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: DoseTextField(
          isRequired: true,
          controller: countryController,
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(focusNodes[3]);
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            updateExitWithConfirmationValue(context, 10, value);
            controller.community.billing_address.updateValueByKey('country', value);
            createEditCommunityBloc.onChange(controller);
          },
          /*   initialValue: controller.community.billing_address.country != null
                ? '${controller.community.billing_address.country}'
                : '',*/
          validator: (value) {
            return value.isEmpty
                ? S.of(context).validation_error_required_fields
                : (profanityDetector.isProfaneString(value))
                    ? S.of(context).profanity_text_alert
                    : null;
          },
          currentNode: focusNodes[2],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: '${S.of(context).country} *',
          ),
        ),
      );
    }

    Widget _continueBtn(controller) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(100, 10, 100, 20),
        child: CustomElevatedButton(
          child: Text(
            S.of(context).continue_text,
            style: Theme.of(context).primaryTextTheme.button,
          ),
          onPressed: () {
            FocusScope.of(context).requestFocus(FocusNode());
            if (_billingInformationKey.currentState.validate()) {
              if (controller.community.billing_address.country == null) {
                scrollToTop();
              } else {
                _billingInformationKey.currentState.save();
                isBillingDetailsProvided = true;
                Navigator.pop(context);
              }
            }
          },
        ),
      );
    }

    return Container(
      // var scrollController = Sc
      //adding a margin to the top leaves an area where the user can swipe
      //to open/close the sliding panel
      margin: const EdgeInsets.only(top: 15.0),
      color: Colors.white,
      child: DoseForm(
        formKey: _billingInformationKey,
        child: StreamBuilder(
          stream: createEditCommunityBloc.createEditCommunity,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                controller: scollContainer,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                children: <Widget>[
                  _billingDetailsTitle,
                  _cityWidget(snapshot.data),
                  _stateWidget(snapshot.data),
                  _countryNameWidget(snapshot.data),
                  _pinCodeWidget(snapshot.data),
                  _streetAddressWidget(snapshot.data),
                  _streetAddressTwoWidget(snapshot.data),
                  _companyNameWidget(snapshot.data),
                  _additionalNotesWidget(snapshot.data),
                  _continueBtn(snapshot.data),
                ],
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return Text("");
          },
        ),
      ),
    );
  }

  void scrollToTop() {
    scollContainer.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void scrollToBottom() {
    scollContainer.animateTo(
      scollContainer.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void showDialogForSuccess({String dialogTitle, bool err}) {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogTitle),
            actionsPadding: EdgeInsets.only(right: 20),
            actions: <Widget>[
              CustomTextButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop();
                },
              ),
            ],
          );
        });
  }

  void dispose() {
    super.dispose();
    _textUpdates.close();
  }
}
