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
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/scraper.dart';
import 'package:sevaexchange/views/core.dart';

class NewsCreate extends StatelessWidget {
  final String timebankId;
  NewsCreate({this.timebankId});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        globals.newsImageURL = null;
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
        ),
      ),
    );
  }
}

// Create a Form Widget
class NewsCreateForm extends StatefulWidget {
  final String timebankId;
  NewsCreateForm({Key key, this.timebankId}) : super(key: key);
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
  bool autoValidateText = false;
  Future<void> writeToDB() async {
    // print("Credit goes to ${}");

    newsObject.placeAddress = this.selectedAddress;

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    newsObject.isPinned = false;
    newsObject.id = '${SevaCore.of(context).loggedInUser.email}*$timestamp';
    newsObject.email = SevaCore.of(context).loggedInUser.email;
    newsObject.fullName = SevaCore.of(context).loggedInUser.fullname;
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

//    EntityModel entityModel = _getSelectedEntityModel;
    EntityModel entityModel = EntityModel(
      entityId: widget.timebankId,
      //entityName: FlavorConfig.timebankName,
      entityType: EntityType.timebank,
    );

    newsObject.entity = entityModel;

    print("Model goes like this : $entityModel");
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
    // fetchCurrentlocation();
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
                          child: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: subheadingController,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              errorMaxLines: 2,
                              labelStyle: TextStyle(color: Colors.grey),
                              alignLabelWithHint: false,
                              hintText: S.of(context).create_feed_hint,
                              labelText: S.of(context).create_feed_placeholder,
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
                            keyboardType: TextInputType.text,
                            maxLines: 5,
                            autovalidate: autoValidateText,
                            onChanged: (value) {
                              if (value.length > 1) {
                                setState(() {
                                  autoValidateText = true;
                                });
                              } else {
                                setState(() {
                                  autoValidateText = false;
                                });
                              }
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return S
                                    .of(context)
                                    .validation_error_general_text;
                              }
                              if (profanityDetector.isProfaneString(value)) {
                                return S.of(context).profanity_text_alert;
                              }
                              newsObject.subheading = value;
                              // print("object");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        //   (geoLocationPointSelected) async {
                        // print("location is $geoLocationPointSelected");
                        // location = geoLocationPointSelected;
                        // await _getLocation();
                        // print("Location is updated to ");
                        // },
                        onCreditsEntered: (photoCreditsFromNews) {
                          print("Hello its me:" + photoCreditsFromNews);
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
                      if (location != null) {
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
                            await scrapeURLDetails(subheadingController.text);
                          }

                          writeToDB();
                        }
                      } else {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).location_not_added),
                          ),
                        );
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
    // print("${newsObject.urlsFromPost}");
  }

  void scrapeHashTagsFromSubHeadings(String subHeadings) {
    // HashTag Extraction
    List<String> hashTags = List();

    RegExp exp = RegExp(r"([#,@][^\s#\@]*)");
    Iterable<RegExpMatch> matches = exp.allMatches(subHeadings);
    matches.map((x) => x[0]).forEach((m) => hashTags.add(m));

    newsObject.hashTags = hashTags;
    // print("${newsObject.hashTags}");
  }

  Future scrapeURLDetails(String subHeadings) async {
    newsObject = await fetchPosts(
        url: newsObject.urlsFromPost[0], newsObject: newsObject);
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
