import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import '../flavor_config.dart';

class ImageUrlView extends StatefulWidget {
  @override
  _ImageUrlViewState createState() => _ImageUrlViewState();
}

class _ImageUrlViewState extends State<ImageUrlView> {
  TextEditingController imageUrlTextController = new TextEditingController();
  List<String> imageUrls = [];
  String urlError = '';
  String imageUrl = '';
  ProfanityImageModel profanityImageModel;
  ProfanityStatusModel profanityStatusModel;
  bool _saving = false;

  _ImageUrlViewState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Center(
              child: Text(S.of(context).cancel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Europa',
                  )),
            ),
          ),
        ),
        title: Text(S.of(context).add_image_url,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Europa',
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              if (imageUrls != null && imageUrls.isNotEmpty) {
                globals.webImageUrl = imageUrls[0];
                print('glg ${globals.webImageUrl}');

                Navigator.of(context).pop();
              } else {
                _showImageUrlAlert(context);
              }
            },
            child: Text(
              S.of(context).continue_text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Europa',
              ),
            ),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              TextFormField(
                controller: imageUrlTextController,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.url,
                onChanged: (value) {
                  if (value.length > 5) {
                    scrapeURLFromTextField(value);

//                    if (value.substring(value.length - 4).contains('.jpg') ||
//                        value.substring(value.length - 5).contains('.jpeg') ||
//                        value.substring(value.length - 4).contains('.png')) {
//                      scrapeURLFromTextField(value);
//                    } else {
//                      setState(() {
//                        urlError = S.of(context).only_images_types_allowed;
//                      });
//                    }
                  }
                },
                decoration: InputDecoration(
                  errorText: urlError,
                  hintText: S.of(context).image_url_hint,
                  hintStyle: hintTextStyle,
                  prefixIcon: Icon(Icons.language),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.cancel),
                    color: Colors.grey,
                    splashColor: Colors.transparent,
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) {
                          imageUrlTextController.clear();
                          imageUrls.clear();
                          imageUrl = null;
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              imageUrls != null && imageUrls.isNotEmpty
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[0],
                        fit: BoxFit.cover,
                        height: 200,
                        placeholderFadeInDuration: Duration(seconds: 10),
                        errorWidget: (context, url, error) => Container(
                            height: 80,
                            child: Center(
                              child: Text(
                                S.of(context).no_image_available,
                                textAlign: TextAlign.center,
                              ),
                            )),
                        placeholder: (context, url) {
                          return LoadingIndicator();
                        },
                      ),
                    )
                  : Offstage(),
            ],
          ),
        ),
      ),
    );
  }

  void scrapeURLFromTextField(String textContent) async {
    List<String> scappedURLs = List();
    String scapedUrl;
    RegExp regExp = RegExp(
      r'(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])',
      caseSensitive: false,
      multiLine: false,
    );

//    regExp.allMatches(textContent).forEach((match) {
//      scapedUrl = textContent.substring(match.start, match.end);
//      scappedURLs
//          .add(scapedUrl.contains("http") ? scapedUrl : "http://" + scapedUrl);

    if (regExp.hasMatch(textContent)) {
      print(true);
      String match = regExp.stringMatch(textContent);
      print(match);
      setState(() {
        this.urlError = '';
        this._saving = true;
      });
      await profanityCheck(imageURL: match);
    } else {
      print('not url');
    }
  }

  Future<void> profanityCheck({String imageURL}) async {
    // _newsImageURL = imageURL;
    profanityImageModel = await checkProfanityForImage(imageUrl: imageURL);
    if (profanityImageModel == null) {
      setState(() {
        this._saving = false;
      });
      showFailedLoadImage(context: context).then((value) {
        imageUrlTextController.clear();
        imageUrls.clear();
        setState(() {});
      });
    } else {
      profanityStatusModel =
          await getProfanityStatus(profanityImageModel: profanityImageModel);
      setState(() {
        this._saving = false;
      });
      if (profanityStatusModel.isProfane) {
        print('profane');

        showProfanityImageAlert(
                context: context, content: profanityStatusModel.category)
            .then((status) {
          imageUrlTextController.clear();
          imageUrls.clear();
          setState(() {});
        });
      } else {
        imageUrls.add(imageURL);
        setState(() {});
      }
    }
  }

  TextStyle hintTextStyle = TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: Colors.grey,
    fontFamily: 'Europa',
  );



  void _showImageUrlAlert(BuildContext mContext) {
    // flutter defined function
    showDialog(
      context: mContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).imageurl_alert),
          content: Text(S.of(context).image_url_alert_desc),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: Text(S.of(context).close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
