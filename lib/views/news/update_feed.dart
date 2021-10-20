import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:doseform/main.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/newsimage/newsimage.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/utils/feeds_web_scrapper.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/news/newscreate.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

class UpdateNewsFeed extends StatelessWidget {
  final String timebankId;
  final NewsModel newsMmodel;
  final TimebankModel timebankModel;
  String photoCredits;

  UpdateNewsFeed({this.timebankId, this.newsMmodel, this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: WillPopScope(
        onWillPop: () async {
          globals.newsImageURL = null;
          globals.newsDocumentName = null;
          globals.newsDocumentURL = null;
          globals.webImageUrl = null;

          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              S.of(context).update_feed,
              style: TextStyle(fontSize: 18),
            ),
          ),
          body: prefix0.SingleChildScrollView(
            child: NewsCreateForm(
              timebankId: timebankId,
              newsModel: newsMmodel,
              timebankModel: timebankModel,
            ),
          ),
        ),
      ),
    );
  }
}

// Create a Form Widget
class NewsCreateForm extends StatefulWidget {
  final String timebankId;
  NewsModel newsModel;
  final TimebankModel timebankModel;

  NewsCreateForm({Key key, this.timebankId, this.newsModel, this.timebankModel}) : super(key: key);
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
  final formKey = GlobalKey<DoseFormState>();
  String imageUrl;
  String photoCredits;

  NewsModel newsObject;
  TextStyle textStyle;

  List<DataModel> dataList = [];
  DataModel selectedEntity;
  GeoFirePoint location;
  String selectedAddress;
  List<String> selectedTimebanks = [];
  Future<void> writeToDB() async {
    log('url  ${globals.newsImageURL}');
    newsObject.placeAddress = selectedAddress;
    newsObject.email = SevaCore.of(context).loggedInUser.email;
    newsObject.fullName = SevaCore.of(context).loggedInUser.fullname;
    newsObject.sevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
    newsObject.newsImageUrl = globals.newsImageURL ?? '';
    newsObject.location = location;
    newsObject.root_timebank_id = FlavorConfig.values.timebankId;
    newsObject.photoCredits = photoCredits != null ? photoCredits : '';
    newsObject.newsDocumentUrl = globals.newsDocumentURL;
    newsObject.newsDocumentName = globals.newsDocumentName;
    newsObject.timebanksPosted = selectedTimebanks;

    await FirestoreManager.updateNews(newsObject: newsObject);
    globals.newsImageURL = null;
    globals.newsDocumentName = null;
    globals.newsDocumentURL = null;
    if (dialogContext != null) {
      Navigator.pop(dialogContext);
    }
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void initState() {
    newsObject = widget.newsModel;
    globals.newsImageURL = newsObject.newsImageUrl;
    globals.newsDocumentURL = newsObject.newsDocumentUrl;
    globals.newsDocumentName = newsObject.newsDocumentName;
    selectedTimebanks.add(this.widget.timebankModel.id);
    super.initState();

    selectedAddress = newsObject.placeAddress;
    location = newsObject.location;

    subheadingController.text = newsObject.subheading;

    dataList.add(EntityModel(entityType: EntityType.general));
//    ApiManager.getTimeBanksForUser(userEmail: globals.email)
//        .then((List<TimebankModel> timeBankModelList) {
//      setState(() {
//        timeBankModelList.forEach((model) {
//          dataList.add(model);
//        });
//      });
//    });
//
//    ApiManager.getCampaignsForUser(userEmail: globals.email)
//        .then((List<CampaignModel> campaignModelList) {
//      setState(() {
//        campaignModelList.forEach((model) {
//          dataList.add(model);
//        });
//      });
//    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  prefix0.TextEditingController subheadingController = TextEditingController();

  BuildContext dialogContext;

  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context).textTheme.headline6;
    // Build a Form widget using the formKey we created above
    return DoseForm(
        formKey: formKey,
        child: prefix0.Column(
          children: [
            Container(
              // margin: EdgeInsets.all(10),
              // padding: EdgeInsets.all(10.0),
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
                        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(bottom: 0.0),
                              child: DoseTextField(
                                isRequired: true,
                                controller: subheadingController,
                                // initialValue: newsObject.subheading,
                                textInputAction: TextInputAction.newline,
                                // autofocus: true,
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  alignLabelWithHint: false,
                                  hintText: S.of(context).create_feed_desc_hint,
                                  labelText: S.of(context).create_feed_placeholder,
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
                                onChanged: (value) {
                                  ExitWithConfirmation.of(context).fieldValues[1] = value;
                                  widget.newsModel.subheading = value;
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return S.of(context).validation_error_general_text;
                                  }
                                  newsObject.subheading = value;
                                  return null;
                                },
                              ),
                            ),
                            Text(""),
                            // TextFormField(
                            //   decoration: InputDecoration(
                            //     hintText: 'Your news and any #hashtags',
                            //     labelText: 'Photo Credits',
                            //     border: OutlineInputBorder(
                            //       borderRadius: const BorderRadius.all(
                            //         const Radius.circular(10.0),
                            //       ),
                            //       borderSide: BorderSide(
                            //         color: Colors.black,
                            //         width: 0.5,
                            //       ),
                            //     ),
                            //   ),
                            //   keyboardType: TextInputType.multiline,
                            //   //style: textStyle,
                            //   maxLines: null,
                            //   validator: (value) {
                            //     if (value.isEmpty) {
                            //       return 'Please enter some text';
                            //     }
                            //     newsObject.description = value;
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      // Container(
                      //   padding: EdgeInsets.fromLTRB(
                      //       MediaQuery.of(context).size.width / 4,
                      //       0,
                      //       MediaQuery.of(context).size.width / 4,
                      //       0),
                      //   child: TextFormField(
                      //     initialValue: newsObject.photoCredits,
                      //     onChanged: (value) {
                      //       newsObject.photoCredits = value;
                      //     },
                      //     decoration: InputDecoration(
                      //       hintText: '+ Photo Credits',
                      //     ),
                      //     keyboardType: TextInputType.text,
                      //     textAlign: TextAlign.center,
                      //     //style: textStyle,
                      //     validator: (value) {
                      //       // if (value.isEmpty) {
                      //       //   return 'Please enter some text';
                      //       // }
                      //       newsObject.photoCredits = value;
                      //     },
                      //   ),
                      // ),
                      // Text(""),
                      Offstage(
                        offstage:
                            !isAccessAvailable(widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID) ||
                                !isPrimaryTimebank(parentTimebankId: widget.timebankModel.parentTimebankId),
                        child: Center(
                          child: TransactionsMatrixCheck(
                            comingFrom: ComingFrom.Home,
                            upgradeDetails: AppConfig.upgradePlanBannerModel.parent_timebanks,
                            transaction_matrix_type: "parent_timebanks",
                            child: CustomElevatedButton(
                              textColor: Colors.green,
                              elevation: 0,
                              child: Container(
                                constraints: BoxConstraints.loose(
                                  Size(
                                    MediaQuery.of(context).size.width - 200,
                                    50,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "${S.of(context).posting_to_text} ${((this.selectedTimebanks.length > 1) ? this.selectedTimebanks.length.toString() + ' Seva Communities' : this.widget.timebankModel.name)}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down)
                                  ],
                                ),
                              ),
                              // color: Colors.grey[200],
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                _silblingTimebankSelectionBottomsheet(
                                  context,
                                  this.widget.timebankModel,
                                  selectedTimebanks,
                                  (selectedTimebanks) => {
                                    setState(
                                      () => {selectedTimebanks = selectedTimebanks},
                                    )
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Center(
                          child: NewsImage(
                            photoCredits: newsObject.photoCredits,
                            geoFirePointLocation: location,
                            selectedAddress: selectedAddress,
                            onLocationDataModelUpdate: (LocationDataModel dataModel) async {
                              location = dataModel.geoPoint;
                              setState(() {
                                this.selectedAddress = dataModel.location;
                              });
                              // await _getLocation();
                            },
                            onCreditsEntered: (photoCreditsFromNews) {
                              photoCredits = photoCreditsFromNews;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    alignment: Alignment(0, 1),
                    padding: const EdgeInsets.only(top: 10.0),
                    child: CustomElevatedButton(
                      shape: StadiumBorder(),
                      onPressed: () async {
                        var connResult = await Connectivity().checkConnectivity();
                        if (connResult == ConnectivityResult.none) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(S.of(context).check_internet),
                              action: SnackBarAction(
                                label: S.of(context).dismiss,
                                onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
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
                                  title: Text(S.of(context).updating_feed),
                                  content: LinearProgressIndicator(
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                );
                              });
                          scrapeURLFromSubheading(newsObject.subheading);
                          scrapeHashTagsFromSubHeadings(newsObject.subheading);

                          if (newsObject.urlsFromPost.length > 0) {
                            await scrapeURLDetails(newsObject.urlsFromPost.first);
                          } else {
                            newsObject.title = '';
                            newsObject.imageScraped = "NoData";
                            newsObject.newsImageUrl = '';
                            newsObject.description = '';
                          }

                          writeToDB();
                        }
                      },
                      child: Text(
                        S.of(context).update_feed,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Text(sevaUserID),
                ],
              )),
            ),
          ],
        ));
  }

  void scrapeURLFromSubheading(String subHeadings) {
    List<String> scappedURLs = [];
    RegExp regExp = RegExp(
      r'(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])',
      caseSensitive: false,
      multiLine: false,
    );

    regExp.allMatches(subHeadings).forEach((match) {
      var scapedUrl = subHeadings.substring(match.start, match.end);
      scappedURLs.add(scapedUrl.contains("http") ? scapedUrl : "http://" + scapedUrl);
    });

    newsObject.urlsFromPost = scappedURLs;
  }

  void scrapeHashTagsFromSubHeadings(String subHeadings) {
    // HashTag Extraction
    List<String> hashTags = [];

    RegExp exp = RegExp(r"([#,@][^\s#\@]*)");
    Iterable<RegExpMatch> matches = exp.allMatches(subHeadings);
    matches.map((x) => x[0]).forEach((m) => hashTags.add(m));

    newsObject.hashTags = hashTags;
  }

  Future scrapeURLDetails(String subHeadings) async {
    // newsObject = await fetchPosts(
    //     url: newsObject.urlsFromPost[0],
    //     newsObject: newsObject); //
    FeedsWebScraper webScraper = FeedsWebScraper(url: subHeadings);

    try {
      if (await webScraper.loadData()) {
        var result = webScraper.getScrapedData();
        if (result != null) {
          newsObject.title = result.title;
          newsObject.imageScraped = result.image;
          newsObject.newsImageUrl = result.image;
          newsObject.description = result.body;
        }
      }
      return;
    } on Exception catch (e) {
      return;
    }
  }

  void _silblingTimebankSelectionBottomsheet(
      BuildContext mcontext, TimebankModel timebank, List<String> selectedTimebanks, onChanged) {
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
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
}
