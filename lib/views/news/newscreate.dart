import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/newsimage/newsimage.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/utils/feeds_web_scrapper.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

class NewsCreate extends StatelessWidget {
  final String timebankId;
  final TimebankModel timebankModel;
  NewsCreate({this.timebankId, this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: WillPopScope(
        onWillPop: () async {
          globals.newsImageURL = null;
          globals.newsDocumentURL = null;
          globals.newsDocumentName = null;
          globals.webImageUrl = null;
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              S.of(context).create_feed,
              style: TextStyle(fontSize: 18),
            ),
            centerTitle: false,
            actions: <Widget>[
              //  OutlineButton(
              //         //color: Colors.indigo,
              //         onPressed: () {
              //           // Validate will return true if the form is valid, or false if
              //           // the form is invalid.

              //           if (_formState.currentState.formKey.currentState.validate()) {
              //             // If the form is valid, we want to show a Snackbar
              //             Scaffold.of(context).showSnackBar(
              //                 SnackBar(content: Text('Creating Post')));
              //             _formState.currentState.writeToDB();
              //           }
              //         },
              //         highlightColor: Colors.white,
              //         child: Text(
              //           'Save',
              //           style: TextStyle(color: Colors.white),
              //         ),
              //       ),
            ],
          ),
          body: NewsCreateForm(
            timebankId: timebankId,
            timebankModel: timebankModel,
          ),
        ),
      ),
    );
  }
}

// Create a Form Widget
class NewsCreateForm extends StatefulWidget {
  final String timebankId;
  final TimebankModel timebankModel;
  NewsCreateForm({Key key, this.timebankId, this.timebankModel})
      : super(key: key);
  @override
  NewsCreateFormState createState() {
    return NewsCreateFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class NewsCreateFormState extends State<NewsCreateForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final formKey = GlobalKey<FormState>();
  String imageUrl;
  String photoCredits;
  NewsModel newsObject = NewsModel();
  TextStyle textStyle;

  List<DataModel> dataList = [];
  DataModel selectedEntity;
  GeoFirePoint location;
  String selectedAddress;
  final profanityDetector = ProfanityDetector();

  List<String> selectedTimebanks = [];
  Future<void> writeToDB() async {
    newsObject.placeAddress = this.selectedAddress;

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    newsObject.isPinned = false;
    newsObject.id = '${SevaCore.of(context).loggedInUser.email}*$timestamp';
    newsObject.email = SevaCore.of(context).loggedInUser.email;
    newsObject.fullName = SevaCore.of(context).loggedInUser.fullname;
    newsObject.communityId = SevaCore.of(context).loggedInUser.currentCommunity;
    newsObject.sevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
    newsObject.newsImageUrl = globals.newsImageURL ?? '';
    newsObject.postTimestamp = timestamp;
    newsObject.location = location;
    newsObject.root_timebank_id = FlavorConfig.values.timebankId;
    newsObject.photoCredits = photoCredits == null ? "" : photoCredits;
    newsObject.userPhotoURL = SevaCore.of(context).loggedInUser.photoURL;
    newsObject.newsDocumentUrl = globals.newsDocumentURL ?? '';
    newsObject.newsDocumentName = globals.newsDocumentName ?? '';
    newsObject.softDelete = false;
    newsObject.timebanksPosted = selectedTimebanks;
    newsObject.liveMode = !AppConfig.isTestCommunity;
//    EntityModel entityModel = _getSelectedEntityModel;
    EntityModel entityModel = EntityModel(
      entityId: widget.timebankId,
      //entityName: FlavorConfig.timebankName,
      entityType: EntityType.timebank,
    );

    newsObject.entity = entityModel;

    await FirestoreManager.createNews(newsObject: newsObject);
    globals.newsImageURL = null;
    globals.newsDocumentURL = null;
    globals.newsDocumentName = null;
    globals.webImageUrl = null;

    if (dialogContext != null) {
      Navigator.pop(dialogContext);
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    dataList.add(EntityModel(entityType: EntityType.general));
    selectedTimebanks.add(this.widget.timebankModel.id);
  }

  @override
  void didChangeDependencies() {
    FirestoreManager.FirestoreManager.getEntityDataListStream(
      userEmail: SevaCore.of(context).loggedInUser.email,
    ).listen(
      (dataList) {
        setState(() {
          dataList.forEach((data) => this.dataList.add(data));
        });
      },
    );
    super.didChangeDependencies();
  }

  TextEditingController subheadingController = TextEditingController();

  BuildContext dialogContext;
  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context).textTheme.title;
    // Build a Form widget using the formKey we created above
    return Form(
      key: formKey,
      child: FadeAnimation(
        1.5,
        Container(
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 0.0),
                            child: Container(
                              height: 200,
                              child: TextFormField(
                                // focusNode: postNode,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: subheadingController,
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  errorMaxLines: 2,
                                  labelStyle: TextStyle(color: Colors.grey),
                                  alignLabelWithHint: false,
                                  hintText: S.of(context).create_feed_desc_hint,
                                  labelText:
                                      S.of(context).create_feed_placeholder,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(12.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(12.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(12.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(0.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                textInputAction: TextInputAction.newline,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onChanged: (value) {
                                  ExitWithConfirmation.of(context)
                                      .fieldValues[1] = value;
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return S
                                        .of(context)
                                        .validation_error_general_text;
                                  }
                                  if (profanityDetector
                                      .isProfaneString(value)) {
                                    return S.of(context).profanity_text_alert;
                                  }
                                  newsObject.subheading = value;
                                },
                              ),
                            )),
                      ],
                    ),
                  ),

                  if (AppConfig.paymentStatusMap['planId'] == 'grande_plan' ||
                      AppConfig.paymentStatusMap['planId'] == 'venti_plan')
                    Offstage(
                      offstage: !isAccessAvailable(widget.timebankModel,
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      child: Center(
                        child: TransactionsMatrixCheck(
                          comingFrom: ComingFrom.Home,
                          upgradeDetails:
                              AppConfig.upgradePlanBannerModel.parent_timebanks,
                          transaction_matrix_type: "parent_timebanks",
                          child: RaisedButton(
                            textColor: Colors.green,
                            elevation: 0,
                            child: Container(
                              constraints: BoxConstraints.loose(
                                Size(MediaQuery.of(context).size.width - 200,
                                    50),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Posting to ${((this.selectedTimebanks.length > 1) ? this.selectedTimebanks.length.toString() + ' Seva Communities' : this.widget.timebankModel.name)}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down)
                                ],
                              ),
                            ),
                            color: Colors.grey[200],
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              _silblingTimebankSelectionBottomsheet(
                                context,
                                this.widget.timebankModel,
                                selectedTimebanks,
                                (selectedTimebanks) => {
                                  setState(
                                    () =>
                                        {selectedTimebanks = selectedTimebanks},
                                  )
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  // Text(""),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Center(
                      child: NewsImage(
                        photoCredits: "",
                        geoFirePointLocation: location,
                        selectedAddress: selectedAddress,
                        onLocationDataModelUpdate:
                            (LocationDataModel dataModel) {
                          location = dataModel.geoPoint;
                          setState(() {
                            this.selectedAddress = dataModel.location;
                          });
                        },
                        onCreditsEntered: (photoCreditsFromNews) {
                          photoCredits = photoCreditsFromNews;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),

              Container(
                child: SizedBox(
                  width: 200,
                  child: RaisedButton(
                    onPressed: () async {
                      var connResult = await Connectivity().checkConnectivity();
                      if (connResult == ConnectivityResult.none) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).check_internet),
                            action: SnackBarAction(
                              label: S.of(context).dismiss,
                              onPressed: () =>
                                  Scaffold.of(context).hideCurrentSnackBar(),
                            ),
                          ),
                        );
                        return;
                      }

                      if (formKey.currentState.validate()) {
                        // If the form is valid, we want to show a Snackbar
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (createDialogContext) {
                              dialogContext = createDialogContext;
                              return AlertDialog(
                                title: Text(S.of(context).creating_feed),
                                content: LinearProgressIndicator(),
                              );
                            });
                        scrapeURLFromSubheading(subheadingController.text);
                        scrapeHashTagsFromSubHeadings(
                            subheadingController.text);

                        if (newsObject.urlsFromPost.length > 0) {
                          await scrapeURLDetails(newsObject.urlsFromPost.first);
                        }
                        writeToDB();
                      }
                    },
                    child: Text(
                      S.of(context).create_feed,
                      style: Theme.of(context).primaryTextTheme.button,
                    ),
                  ),
                ),
              ),
              // Text(sevaUserID),
            ],
          )),
        ),
      ),
    );
  }

  void scrapeURLFromSubheading(String subHeadings) {
    List<String> scappedURLs = List();
    RegExp regExp = RegExp(
      r'(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])',
      caseSensitive: false,
      multiLine: false,
    );

    regExp.allMatches(subHeadings).forEach((match) {
      var scapedUrl = subHeadings.substring(match.start, match.end);
      scappedURLs
          .add(scapedUrl.contains("http") ? scapedUrl : "http://" + scapedUrl);
    });

    newsObject.urlsFromPost = scappedURLs;
  }

  void scrapeHashTagsFromSubHeadings(String subHeadings) {
    // HashTag Extraction
    List<String> hashTags = List();

    RegExp exp = RegExp(r"([#,@][^\s#\@]*)");
    Iterable<RegExpMatch> matches = exp.allMatches(subHeadings);
    matches.map((x) => x[0]).forEach((m) => hashTags.add(m));

    newsObject.hashTags = hashTags;
  }

  Future<void> scrapeURLDetails(String subHeadings) async {
    FeedsWebScraper webScraper = FeedsWebScraper(url: subHeadings);

    try {
      if (await webScraper.loadData()) {
        var result = webScraper.getScrapedData();
        if (result != null) {
          newsObject.title = result.title;
          newsObject.imageScraped = result.image ?? "NoData";
          newsObject.description = result.body;
        }
      }
      return;
    } on Exception catch (e) {
      return;
    }

    // newsObject = await fetchPosts(
    //     url: newsObject.urlsFromPost[0], newsObject: newsObject);
  }
}

//   Widget get entityDropdown {
//     return Container(
//       padding: EdgeInsets.only(bottom: 20.0),
//       child: DropdownButtonFormField<DataModel>(
//         decoration: InputDecoration.collapsed(
//           hintText:
//               '+ ${S.of(context).category}',
//           hintStyle: Theme.of(context).textTheme.title.copyWith(
//                 color: Theme.of(context).hintColor,
//               ),
//         ),
//         validator: (value) {
//           if (value == null) {
//             return S.of(context).select_category;
//           }
//         },
//         items: dataList.map((dataModel) {
//           if (dataModel.runtimeType == EntityModel) {
//             return DropdownMenuItem<DataModel>(
//               child: Text(
//                   AppLocalizations.of(context).translate('homepage', 'general'),
//                   style: textStyle),
//               value: dataModel,
//             );
//           } else if (dataModel.runtimeType == TimebankModel) {
//             TimebankModel model = dataModel;
//             return DropdownMenuItem<DataModel>(
//               child: Text(
//                 '${model.name}',
//                 style: textStyle,
//               ),
//               value: model,
//             );
//           } else if (dataModel.runtimeType == CampaignModel) {
//             CampaignModel model = dataModel;
//             return DropdownMenuItem<DataModel>(
//               child: Text(
//                 '${model.name}',
//                 style: textStyle,
//               ),
//               value: model,
//             );
//           }
//           return DropdownMenuItem<DataModel>(
//             child: Text(
//               AppLocalizations.of(context).translate('homepage', 'undefined'),
//               style: textStyle,
//             ),
//             value: null,
//           );
//         }).toList(),
//         value: selectedEntity,
//         onChanged: (dataModel) {
//           setState(() {
//             this.selectedEntity = dataModel;
//           });
//         },
//       ),
//     );
//   }
// }

void _silblingTimebankSelectionBottomsheet(BuildContext mcontext,
    TimebankModel timebank, List<String> selectedTimebanks, onChanged) {
  showModalBottomSheet(
    context: mcontext,
    builder: (BuildContext bc) {
      return Container(
        child: Builder(builder: (context) {
          return Scaffold(
              appBar: AppBar(
                elevation: 0.5,
                automaticallyImplyLeading: true,
                title: Text(
                  S.of(context).select_parent_timebank,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              body: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SearchSiblingTimebanks(
                  keepOnBackPress: false,
                  loggedInUser: SevaCore.of(context).loggedInUser,
                  selectedTimebank: timebank,
                  selectedTimebanks: selectedTimebanks,
                  showBackBtn: false,
                  isFromHome: false,
                  onChanged: onChanged,
                ),
              ));
        }),
      );
    },
  );
}

class SearchSiblingTimebanks extends StatefulWidget {
  final bool keepOnBackPress;
  final UserModel loggedInUser;
  final bool showBackBtn;
  final bool isFromHome;
  TimebankModel selectedTimebank;
  List<String> selectedTimebanks;
  final ValueChanged onChanged;
  SearchSiblingTimebanks({
    @required this.keepOnBackPress,
    @required this.loggedInUser,
    @required this.showBackBtn,
    @required this.isFromHome,
    @required this.selectedTimebank,
    this.selectedTimebanks,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return SearchSiblingTimebanksViewState();
  }
}

class SearchSiblingTimebanksViewState extends State<SearchSiblingTimebanks> {
  @override
  void initState() {
    super.initState();
    communityBloc.searchTimebankSiblingsByParentId(
        this.widget.selectedTimebank.id, this.widget.selectedTimebank);
  }

  @override
  void dispose() {
//    communityBloc.dispose();
    super.dispose();
  }

  build(context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        Text(
          S.of(context).look_for_existing_siblings,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 20),
        Expanded(
          child: buildList(),
        )
      ]),
    );
  }

  Widget buildList() {
    // ListView contains a group of widgets that scroll inside the drawer
    return StreamBuilder(
        stream: communityBloc.allSiblingTimebanks,
        builder: (context, AsyncSnapshot<TimebankListModel> snapshot) {
          if (snapshot.hasData) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.data.timebanks.length != 0) {
                List<TimebankModel> timebanks = snapshot.data.timebanks;
//                timebanks.insert(0, this.widget.selectedTimebank);
                return Padding(
                  padding: EdgeInsets.only(left: 0, right: 0, top: 5.0),
                  child: ListView.builder(
                    itemCount: timebanks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return timeBankWidget(
                          timebankModel: timebanks[index],
                          context: context,
                          isSelected: this
                              .widget
                              .selectedTimebanks
                              .contains(timebanks[index].id));
                    },
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 100, horizontal: 60),
                  child: Center(
                    child: Text(S.of(context).no_timebanks_found,
                        style: TextStyle(fontFamily: "Europa", fontSize: 14)),
                  ),
                );
              }
            }
          } else if (snapshot.hasError) {
            return Text(S.of(context).try_later);
          }
          return Text("");
        });
  }

  Widget timeBankWidget(
      {TimebankModel timebankModel, BuildContext context, bool isSelected}) {
    return Offstage(
      offstage: timebankModel.softDelete,
      child: ListTile(
        // onTap: goToNext(snapshot.data),
        title: Text(timebankModel.name,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Checkbox(
            value: isSelected,
            onChanged: (bool value) {
              if (isSelected &&
                  timebankModel.id != this.widget.selectedTimebanks[0]) {
                this
                    .widget
                    .selectedTimebanks
                    .removeWhere((item) => item == timebankModel.id);
              } else if (!isSelected &&
                  timebankModel.id != this.widget.selectedTimebanks[0]) {
                this.widget.selectedTimebanks.add(timebankModel.id);
              }
              this.widget.onChanged(this.widget.selectedTimebanks);
              setState(() => this.widget.selectedTimebanks =
                  this.widget.selectedTimebanks);
            },
          )
        ]),
      ),
    );
  }
}
