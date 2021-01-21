import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/new_baseline/services/firestore_service/firestore_service.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

import '../../globals.dart' as globals;
import 'news_image_picker_handler.dart';

class NewsImage extends StatefulWidget {
  final String photoCredits;
  final String selectedAddress;
  final GeoFirePoint geoFirePointLocation;

  final ValueChanged<String> onCreditsEntered;
  final Function(LocationDataModel) onLocationDataModelUpdate;

  NewsImage({
    this.photoCredits,
    this.geoFirePointLocation,
    this.onLocationDataModelUpdate,
    this.onCreditsEntered,
    this.selectedAddress,
  });

  NewsImageState createState() => NewsImageState();
}

@override
class NewsImageState extends State<NewsImage>
    with
        TickerProviderStateMixin,
        NewsImagePickerListener,
        WidgetsBindingObserver {
  bool _isImageBeingUploaded = false;
  // Function(LocationDataModel) onLocationDataModelUpdate;
  String selectedAddress;

  NewsImagePickerHandler imagePicker;
  //document related variables
  bool _isDocumentBeingUploaded = false;

  String _fileName;
  String _path;

  final int tenMegaBytes = 10485760;
  final int hundreKb = 14857;
  BuildContext parentContext;
  ProfanityImageModel profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();
  File _image;
  AnimationController _controller;

  Future<String> uploadImage() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('newsimages')
        .child(
            SevaCore.of(context).loggedInUser.email + timestampString + '.jpg');
    StorageUploadTask uploadTask = ref.putFile(
      _image,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'News Image'},
      ),
    );
    String imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();

    await profanityCheck(imageURL: imageURL);

    // _setAvatarURL();
    // _updateDB();
    return imageURL;
  }

  Future<void> profanityCheck({String imageURL}) async {
    // _newsImageURL = imageURL;
    profanityImageModel = await checkProfanityForImage(imageUrl: imageURL);
    if (profanityImageModel == null) {
      showFailedLoadImage(context: context).then((value) {
        globals.newsImageURL = null;
      });
    } else {
      profanityStatusModel =
          await getProfanityStatus(profanityImageModel: profanityImageModel);

      if (profanityStatusModel.isProfane) {
        showProfanityImageAlert(
                context: context, content: profanityStatusModel.category)
            .then((status) {
          if (status == 'Proceed') {
            FirebaseStorage.instance
                .getReferenceFromUrl(imageURL)
                .then((reference) {
              reference.delete();
              globals.newsImageURL = null;
            });
          } else {}
        });
      } else {
        globals.newsImageURL = imageURL;
      }
    }
  }

  void userImage(File _image) {
    setState(() {
      this._image = _image;
      this._isImageBeingUploaded = true;
    });
    uploadImage().then((_) {
      setState(() => this._isImageBeingUploaded = false);
    });
  }

  @override
  void userDoc(String _doc, String fileName) {
    setState(() {
      this._path = _doc;
      this._fileName = fileName;
      this._isDocumentBeingUploaded = true;
    });
    checkPdfSize();
  }

  void checkPdfSize() async {
    var file = File(_path);
    final bytes = await file.lengthSync();
    if (bytes > tenMegaBytes) {
      this._isDocumentBeingUploaded = false;
      getAlertDialog(parentContext);
    } else {
      uploadDocument().then((_) {
        setState(() => this._isDocumentBeingUploaded = false);
      });
    }
  }

  Future<dynamic> getAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).large_file_alert),
          content: Text(S.of(context).validation_error_file_size),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
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

  Future<String> uploadDocument() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('news_documents')
        .child(SevaCore.of(context).loggedInUser.email +
            timestampString +
            _fileName);
    StorageUploadTask uploadTask = ref.putFile(
      File(_path),
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'News Document'},
      ),
    );
    String documentURL =
        await (await uploadTask.onComplete).ref.getDownloadURL();

    // _newsImageURL = imageURL;
    globals.newsDocumentURL = documentURL;
    globals.newsDocumentName = _fileName;

    // _setAvatarURL();
    // _updateDB();
    return documentURL;
  }

  @override
  void initState() {
    // if (widget.geoFirePointLocation == null) _fetchCurrentlocation;

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selectedAddress = widget.selectedAddress;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
//    globals.newsDocumentURL = null;
//    globals.newsDocumentName = null;
    imagePicker = NewsImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (globals.webImageUrl != null && globals.webImageUrl.isNotEmpty) {
        globals.newsImageURL = globals.webImageUrl;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        imagePicker.showDialog(context);
      },
      child: Column(
        children: <Widget>[
          _isImageBeingUploaded
              ? Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Container(
                    color: Colors.grey[100],
                    height: 150,
                    width: 150,
                    child: Center(
                      child: Container(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                )
              : Container(
                  child: globals.newsImageURL == null
                      ? Offstage()
                      : Column(
                          children: <Widget>[
                            Stack(
                              children: [
                                Center(
                                  child: Container(
                                    height: 200,
                                    width: 200,
                                    child: FadeInImage(
                                      image: NetworkImage(globals.newsImageURL),
                                      placeholder: AssetImage(
                                        'lib/assets/images/noimagefound.png',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          globals.newsImageURL = null;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Icon(
                                          Icons.cancel,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //Text(profanityImageModel.toString()),
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                  MediaQuery.of(context).size.width / 4,
                                  0,
                                  MediaQuery.of(context).size.width / 4,
                                  0),
                              child: TextFormField(
                                initialValue: widget.photoCredits != null
                                    ? widget.photoCredits
                                    : '',
                                decoration: InputDecoration(
                                  hintText: '+ ${S.of(context).photo_credits}',
                                ),
                                keyboardType: TextInputType.text,
                                textAlign: TextAlign.center,
                                //style: textStyle,
                                onChanged: (credits) {
                                  widget.onCreditsEntered(credits);
                                },
                              ),
                            ),
                          ],
                        ),
                ),
          _isDocumentBeingUploaded
              ? Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Container(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : Container(
                  child: globals.newsDocumentURL == null
                      ? Offstage()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.grey[100],
                            child: ListTile(
                              leading: Icon(Icons.attachment),
                              title: Text(
                                globals.newsDocumentName ?? "Document.pdf",
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () => setState(() {
                                  globals.newsDocumentURL = null;
                                  globals.newsDocumentName = null;
                                }),
                              ),
                            ),
                          ),
                        ),
                ),
          FlatButton.icon(
            icon: Icon(Icons.attachment),
            color: Colors.grey[200],
            label: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                globals.newsDocumentURL != null || globals.newsImageURL != null
                    ? S.of(context).change_attachment
                    : S.of(context).add_attachment,
              ),
            ),
            onPressed: () {
              imagePicker.showDialog(context);
            },
          ),
          LocationPickerWidget(
            location: widget.geoFirePointLocation,
            selectedAddress: selectedAddress,
            onChanged: (LocationDataModel dataModel) {
              selectedAddress = dataModel.location;
              widget.onLocationDataModelUpdate(dataModel);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  // void get _fetchCurrentlocation async {
  //   try {
  //     Location templocation = Location();
  //     bool _serviceEnabled;
  //     PermissionStatus _permissionGranted;

  //     _serviceEnabled = await templocation.serviceEnabled();
  //     if (!_serviceEnabled) {
  //       _serviceEnabled = await templocation.requestService();
  //       if (!_serviceEnabled) {
  //         return;
  //       }
  //     }

  //     _permissionGranted = await templocation.hasPermission();
  //     if (_permissionGranted == PermissionStatus.denied) {
  //       _permissionGranted = await templocation.requestPermission();
  //       if (_permissionGranted != PermissionStatus.granted) {
  //         return;
  //       }
  //     }
  //     Location().getLocation().then((onValue) {
  //       GeoFirePoint location =
  //           GeoFirePoint(onValue.latitude, onValue.longitude);

  //       LocationUtility()
  //           .getFormattedAddress(
  //         location.latitude,
  //         location.longitude,
  //       )
  //           .then((address) {
  //         widget.onLocationDataModelUpdate(LocationDataModel(
  //           address,
  //           location.latitude,
  //           location.longitude,
  //         ));
  //         setState(() {
  //           this.selectedAddress = address;
  //         });
  //       });
  //     });
  //   } on PlatformException catch (e) {
  //     if (e.code == 'PERMISSION_DENIED') {
  //       //error = e.message;
  //     } else if (e.code == 'SERVICE_STATUS_ERROR') {
  //       //error = e.message;
  //     }
  //   }
  // }

  @override
  addWebImageUrl() {
    // TODO: implement addWebImageUrl
    setState(() {
      if (globals.webImageUrl != null && globals.webImageUrl.isNotEmpty) {
        globals.newsImageURL = globals.webImageUrl;
        setState(() {});
      }
    });
  }
}

//   Future _getLocation() async {
//     // String address = await LocationUtility().getFormattedAddress(
//     //   widget.geoFirePointLocation.latitude,
//     //   widget.geoFirePointLocation.longitude,
//     // );

//     // setState(() {
//     //   this.widget.selectedAddress = address;
//     // });
//   }
// }
