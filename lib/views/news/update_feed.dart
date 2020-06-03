import 'dart:ffi';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/components/newsimage/newsimage.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';

class UpdateNewsFeed extends StatelessWidget {
  final GlobalKey<NewsCreateFormState> _formState = GlobalKey();
  final String timebankId;
  final NewsModel newsMmodel;
  String photoCredits;

  UpdateNewsFeed({this.timebankId, this.newsMmodel});

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
            "Update feed",
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: NewsCreateForm(
          timebankId: timebankId,
          newsModel: newsMmodel,
        ),
      ),
    );
  }
}

// Create a Form Widget
class NewsCreateForm extends StatefulWidget {
  final String timebankId;
  NewsModel newsModel;

  NewsCreateForm({Key key, this.timebankId, this.newsModel}) : super(key: key);
  @override
  NewsCreateFormState createState() {
    return NewsCreateFormState(newsObject: newsModel);
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

  NewsModel newsObject;
  TextStyle textStyle;
  NewsCreateFormState({this.newsObject}) {
    print("Getting news Feed -> $newsObject");

    globals.newsImageURL = newsObject.newsImageUrl;
    // _getLocation();
  }

  List<DataModel> dataList = [];
  DataModel selectedEntity;
  GeoFirePoint location;
  String selectedAddress;

  Future<void> writeToDB() async {
    newsObject.placeAddress = selectedAddress;
    newsObject.email = SevaCore.of(context).loggedInUser.email;
    newsObject.fullName = SevaCore.of(context).loggedInUser.fullname;
    newsObject.sevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
    newsObject.newsImageUrl = globals.newsImageURL ?? '';
    newsObject.location = location;
    newsObject.root_timebank_id = FlavorConfig.values.timebankId;
    newsObject.photoCredits = photoCredits != null ? photoCredits : '';
    newsObject.newsDocumentUrl =
        globals.newsDocumentURL ?? newsObject.newsDocumentUrl ?? '';
    newsObject.newsDocumentName =
        globals.newsDocumentName ?? newsObject.newsDocumentName ?? '';
    //EntityModel entityModel = _getSelectedEntityModel;
    EntityModel entityModel = EntityModel(
      entityId: widget.timebankId,
      //entityName: FlavorConfig.timebankName,
      entityType: EntityType.timebank,
    );

    newsObject.entity.entityType = entityModel.entityType;
    newsObject.entity.entityName = entityModel.entityName;

    // await FirestoreManager.createNews(newsObject: newsObject);
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

//  EntityModel get _getSelectedEntityModel {
//    if (this.selectedEntity.runtimeType == TimebankModel) {
//      TimebankModel model = this.selectedEntity;
//      return EntityModel(
//        entityId: model.id,
//        entityName: model.name,
//        entityType: EntityType.timebank,
//      );
//    } else if (this.selectedEntity.runtimeType == CampaignModel) {
//      CampaignModel model = this.selectedEntity;
//      return EntityModel(
//        entityId: model.id,
//        entityName: model.name,
//        entityType: EntityType.campaign,
//      );
//    } else {
//      return EntityModel(entityType: EntityType.general);
//    }
//  }

  @override
  void initState() {
    super.initState();
    selectedAddress = newsObject.placeAddress;
    location = newsObject.location;

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

  prefix0.TextEditingController subheadingController = TextEditingController();

  BuildContext dialogContext;

  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context).textTheme.title;
    // Build a Form widget using the formKey we created above
    return Form(
        key: formKey,
        child: Container(
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
                  // Container(
                  //   alignment: Alignment(1.0, 0),
                  //   padding: const EdgeInsets.only(right: 10.0, bottom: 10),
                  //   child:
                  //   RaisedButton(
                  //     shape: StadiumBorder(),
                  //     color: Colors.indigoAccent,
                  //     onPressed: () {
                  //       // Validate will return true if the form is valid, or false if
                  //       // the form is invalid.

                  //       if (formKey.currentState.validate()) {
                  //         // If the form is valid, we want to show a Snackbar
                  //         Scaffold.of(context).showSnackBar(
                  //             SnackBar(content: Text('Creating Post')));
                  //         writeToDB();
                  //       }
                  //     },
                  //     child: Text(
                  //       'Save News Post',
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //   ),
                  // ),

//              entityDropdown,

                  Text(""),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Column(
                      children: <Widget>[
                        // Padding(
                        //   padding: EdgeInsets.only(bottom: 20.0),
                        //   child: TextFormField(
                        //     decoration: InputDecoration(
                        //       hintText: 'Your feed title',
                        //       labelText: '+ Feed Title',
                        //       border: OutlineInputBorder(
                        //         borderRadius: const BorderRadius.all(
                        //           const Radius.circular(10.0),
                        //         ),
                        //         borderSide: new BorderSide(
                        //           color: Colors.black,
                        //           width: 0.5,
                        //         ),
                        //       ),
                        //     ),
                        //     keyboardType: TextInputType.text,
                        //     //style: textStyle,
                        //     validator: (value) {
                        //       if (value.isEmpty) {
                        //         return 'Please enter the Post Title';
                        //       }
                        //       newsObject.title = value;
                        //     },
                        //   ),
                        // ),

                        Padding(
                          padding: EdgeInsets.only(bottom: 0.0),
                          child: TextFormField(
                            // controller: subheadingController,
                            initialValue: newsObject.subheading,
                            autofocus: true,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              alignLabelWithHint: false,
                              hintText: 'Text, URL and Hashtags ',
                              labelText: 'What would you like to share',
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(0.0),
                                ),
                                borderSide: new BorderSide(
                                  color: Colors.black,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            maxLines: 5,
                            onChanged: (value) {
                              print("omChanged $value");
                              widget.newsModel.subheading = value;
                            },
                            validator: (value) {
                              print("validator");
                              if (value.isEmpty) {
                                return 'Please enter some text';
                              }
                              newsObject.subheading = value;
                              // print("object");
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
                        //       borderSide: new BorderSide(
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
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Center(
                      child: NewsImage(
                        photoCredits: newsObject.photoCredits,
                        geoFirePointLocation: location,
                        selectedAddress: selectedAddress,
                        onLocationDataModelUpdate:
                            (LocationDataModel dataModel) async {
                          location = dataModel.geoPoint;
                          setState(() {
                            this.selectedAddress = dataModel.location;
                          });
                          // await _getLocation();
                        },
                        onCreditsEntered: (photoCreditsFromNews) {
                          // print("" + photoCredits);
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
                child: RaisedButton(
                  shape: StadiumBorder(),
                  onPressed: () async {
                    //  print("address $selectedAddress");
                    var connResult = await Connectivity().checkConnectivity();
                    if (connResult == ConnectivityResult.none) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("Please check your internet connection."),
                          action: SnackBarAction(
                            label: 'Dismiss',
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
                                title: Text('Updating Feed'),
                                content: LinearProgressIndicator(),
                              );
                            });
                        scrapeURLFromSubheading(newsObject.subheading);
                        scrapeHashTagsFromSubHeadings(newsObject.subheading);

                        if (newsObject.urlsFromPost.length > 0) {
                          await scrapeURLDetails(newsObject.subheading);
                        }

                        writeToDB();
                      }
                    } else {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Location not added'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Update feed',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Text(sevaUserID),
            ],
          )),
        ));
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

    RegExp exp = new RegExp(r"([#,@][^\s#\@]*)");
    Iterable<RegExpMatch> matches = exp.allMatches(subHeadings);
    matches.map((x) => x[0]).forEach((m) => hashTags.add(m));

    newsObject.hashTags = hashTags;
    // print("${newsObject.hashTags}");
  }

  Future scrapeURLDetails(String subHeadings) async {
    await fetchPosts(newsObject.urlsFromPost[0]);
    // print("Final Project $newsObject");
  }

  Widget get entityDropdown {
    return Container(
      padding: EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField<DataModel>(
        decoration: InputDecoration.collapsed(
          hintText: '+ Category',
          hintStyle: Theme.of(context).textTheme.title.copyWith(
                color: Theme.of(context).hintColor,
              ),
        ),
        validator: (value) {
          if (value == null) {
            return 'Please select a category';
          }
        },
        items: dataList.map((dataModel) {
          if (dataModel.runtimeType == EntityModel) {
            return DropdownMenuItem<DataModel>(
              child: Text('General', style: textStyle),
              value: dataModel,
            );
          } else if (dataModel.runtimeType == TimebankModel) {
            TimebankModel model = dataModel;
            return DropdownMenuItem<DataModel>(
              child: Text(
                '${model.name}',
                style: textStyle,
              ),
              value: model,
            );
          } else if (dataModel.runtimeType == CampaignModel) {
            CampaignModel model = dataModel;
            return DropdownMenuItem<DataModel>(
              child: Text(
                '${model.name}',
                style: textStyle,
              ),
              value: model,
            );
          }
          return DropdownMenuItem<DataModel>(
            child: Text(
              'Undefined',
              style: textStyle,
            ),
            value: null,
          );
        }).toList(),
        value: selectedEntity,
        onChanged: (dataModel) {
          setState(() {
            this.selectedEntity = dataModel;
          });
        },
      ),
    );
  }

  Future _getLocation() async {
    String address = await LocationUtility().getFormattedAddress(
      location.latitude,
      location.longitude,
    );
    setState(() {
      this.selectedAddress = address;
    });
  }

  Future<Void> fetchPosts(String url) async {
    print("started fetch");
    // url = "https://en.wikipedia.org/wiki/The_War_on_Normal_People";
    final response = await http.get(
      url,
    );
    var document = parse(response.body);

    var images = document.getElementsByTagName("img");

    var imagesList = [];

    images
        .map((element) => {
              if (element.attributes['src'] != null &&
                  element.attributes['src'].contains("http"))
                {
                  imagesList.add(element.attributes['src']),
                  print("Added ${element.attributes['src']}"),
                }
            })
        .toList();

    print(imagesList);

    if (imagesList.length > 1) {
      print(" Final output ->  ${imagesList[imagesList.length ~/ 2]}");
      newsObject.imageScraped = imagesList[imagesList.length ~/ 2];
    } else if (imagesList.length > 0) {
      print("Final output ${imagesList[0]}");
      newsObject.imageScraped = imagesList[0];
    } else {
      print("No image scraped");
      newsObject.imageScraped = "NoData";
    }

    // for (var i = 0; i < images.length; i++) {
    //   if (images[i].attributes['src'] != null) {
    //     // newsObject.imageScraped = images[i].attributes['img'];
    //     print("Got the src :-> " + images[i].attributes['img']);
    //   }
    // }

    // print("Fromimage selector $imagfes ");

    var links = document.querySelectorAll('title');
    for (var link in links) {
      if (link.text != null) {
        newsObject.title = link.text;
        break;
      }
    }

    var para = document.querySelectorAll('p');

    for (var link in para) {
      if (link.text != null) {
        if (newsObject.description == null) {
          newsObject.description = link.text;
        } else if (newsObject.description.length < link.text.length)
          newsObject.description = link.text;
        else {
          newsObject.description = newsObject.description + "\n" + link.text;
        }
      }
    }
  }
}
