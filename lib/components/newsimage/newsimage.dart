import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart';
import 'package:sevaexchange/new_baseline/services/firestore_service/firestore_service.dart';
import 'package:sevaexchange/new_baseline/services/firestore_service/firestore_service.dart'
    as prefix0;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/news/newscreate.dart';

import '../../globals.dart' as globals;
import 'dart:io';
import '../location_picker.dart';
import './image_picker_handler.dart';

class NewsImage extends StatefulWidget {
  String photoCredits;
  String selectedAddress;
  GeoFirePoint geoFirePointLocation;

  Function(String) onCreditsEntered;
  Function(GeoFirePoint) geoFirePointLocationCallback;

  NewsImage(
      {String photoCredits,
      GeoFirePoint geoFirePointLocation,
      Function(String) onCreditsEntered,
      Function(GeoFirePoint) geoFirePointLocationCallback}) {
    this.onCreditsEntered = onCreditsEntered;
    this.geoFirePointLocationCallback = geoFirePointLocationCallback;
    this.photoCredits = photoCredits;
  }

  NewsImageState createState() =>
      NewsImageState(onCreditsEntered, geoFirePointLocationCallback);
}

@override
class NewsImageState extends State<NewsImage>
    with TickerProviderStateMixin, ImagePickerListener {
  bool _isImageBeingUploaded = false;
  Function(GeoFirePoint) geoFirePointLocationCallback;
  Function(String) onCreditsEntered;
  NewsImageState(this.onCreditsEntered, this.geoFirePointLocationCallback);

  ImagePickerHandler imagePicker;

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
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = ImagePickerHandler(this, _controller);
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
                                child: CircularProgressIndicator()))))
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
                                    onCreditsEntered(credits);
                                  },
                                  validator: (value) {},
                                ),
                              ),
                            ],
                          ),
                  ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 20),
              child: Container(
                // height: 60,
                // width: 100,
                // color: Colors.grey[100],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Offstage(
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
                        child: FlatButton.icon(
                          icon: Icon(Icons.image),
                          color: Colors.grey[200],
                          label: Text(
                            "",
                          ),
                          onPressed: () {
                            imagePicker.showDialog(context);
                          },
                        ),
                      ),
                      offstage: false,
                    ),
                    Offstage(
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
                        child: FlatButton.icon(
                          icon: Icon(Icons.add_location),
                          label: Text(
                            "",
                          ),
                          color: Colors.grey[200],
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<GeoFirePoint>(
                                builder: (context) => LocationPicker(
                                  selectedLocation: widget.geoFirePointLocation,
                                ),
                              ),
                            ).then((point) {
                              if (point != null) {
                                widget.geoFirePointLocation = point;
                                print("Setting data ");
                                geoFirePointLocationCallback(point);
                              }
                              // _getLocation();
                            });
                            // imagePicker.showDialog(context);
                          },
                        ),
                      ),
                      offstage: false,
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Future _getLocation() async {
    // String address = await LocationUtility().getFormattedAddress(
    //   widget.geoFirePointLocation.latitude,
    //   widget.geoFirePointLocation.longitude,
    // );

    // setState(() {
    //   this.widget.selectedAddress = address;
    // });
  }
}
