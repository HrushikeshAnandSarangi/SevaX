import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/utils/location_utility.dart';
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

  NewsImageState createState() => NewsImageState(onLocationDataModelUpdate);
}

@override
class NewsImageState extends State<NewsImage>
    with TickerProviderStateMixin, NewsImagePickerListener {
  bool _isImageBeingUploaded = false;
  Function(LocationDataModel) onLocationDataModelUpdate;
  NewsImageState(this.onLocationDataModelUpdate);
  String selectedAddress;

  NewsImagePickerHandler imagePicker;
  //document related variables
  bool _isDocumentBeingUploaded = false;
  File _file;
  List<File> _files;
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.custom;

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

    // _newsImageURL = imageURL;
    globals.newsImageURL = imageURL;

    // _setAvatarURL();
    // _updateDB();
    return imageURL;
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
  userDoc(String _doc, String fileName) {
    // TODO: implement userDoc
    setState(() {
      this._path = _doc;
      this._fileName = fileName;
      this._isDocumentBeingUploaded = true;
    });

    uploadDocument().then((_) {
      setState(() => this._isDocumentBeingUploaded = false);
    });
    return null;
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
    print("url of document $documentURL");
    // _setAvatarURL();
    // _updateDB();
    return documentURL;
  }

  @override
  void initState() {
    if (widget.geoFirePointLocation == null) _fetchCurrentlocation;
    super.initState();
    print("locaton on newsimage ${widget.geoFirePointLocation?.coords}");
    selectedAddress = widget.selectedAddress;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = NewsImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => imagePicker.showDialog(context),
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
                        height: 50,
                        width: 50,
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
                            Container(
                              height: 200,
                              width: 200,
                              child: FadeInImage(
                                image: NetworkImage(globals.newsImageURL),
                                placeholder: AssetImage(
                                  'lib/assets/images/noimagefound.png',
                                ),
                              ),
                            ),
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
                                  hintText: '+ Photo Credits',
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
                      height: 50,
                      width: 50,
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
                _image != null ? "Change attachment" : "Add attachment",
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
              onLocationDataModelUpdate(dataModel);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void get _fetchCurrentlocation async {
    try {
      Location templocation = new Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await templocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await templocation.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await templocation.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await templocation.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      Location().getLocation().then((onValue) {
        print("Location1:$onValue");
        GeoFirePoint location =
            GeoFirePoint(onValue.latitude, onValue.longitude);

        LocationUtility()
            .getFormattedAddress(
          location.latitude,
          location.longitude,
        )
            .then((address) {
          onLocationDataModelUpdate(LocationDataModel(
            address,
            location.latitude,
            location.longitude,
          ));
          setState(() {
            this.selectedAddress = address;
          });
        });
      });
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        //error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        //error = e.message;
      }
    }
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
