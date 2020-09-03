import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/newsimage/image_picker_handler.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class EditTimebankPic extends StatefulWidget {
  @override
  final TimebankModel timebankModel;

  EditTimebankPic({
    @required this.timebankModel,
  });
  _EditTimebankPicState createState() => _EditTimebankPicState();
}

class _EditTimebankPicState extends State<EditTimebankPic>
    with ImagePickerListener, SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _shouldObscure = true;
  bool _isLoading = false;

  String fullName;
  String password;
  String email;
  String imageUrl;
  File selectedImage;
  String isImageSelected = 'Update Photo';
  ImagePickerHandler imagePicker;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AnimationController _controller = AnimationController(
      TickerProvider: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    this.nameController = TextEditingController();
    nameController.text = widget.timebankModel.name;
    imagePicker = ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          FlavorConfig.values.timebankName == "Yang 2020"
              ? "Update Yang gang"
              : "Update Timebank",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 16),
                logo,
                SizedBox(height: 16),
                _imagePicker,
                _profileBtn,
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                    ),
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: "Name",
                        //errorText: nameController.text.isEmpty == true ? FlavorConfig.values.timebankName == "Yang 2020" ? "Enter Yang gang name" : "Enter Timebank name" : "",
                        // errorStyle:,
                        hintText:
                            FlavorConfig.values.timebankName == "Yang 2020"
                                ? "Enter Yang gang name"
                                : "Enter Timebank name",
                        labelStyle: TextStyle(
                          fontSize: 13.0,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(height: 32),
                registerButton,
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get shouldObscure => this._shouldObscure;
  set shouldObscure(bool shouldObscure) {
    setState(() => this._shouldObscure = shouldObscure);
  }

  bool get isLoading => this._isLoading;
  set isLoading(bool isLoading) {
    setState(() => this._isLoading = isLoading);
  }

  Widget get registerButton {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: RaisedButton(
        onPressed: isLoading
            ? null
            : () async {
                isLoading = true;
                if (selectedImage == null &&
                    widget.timebankModel.name == nameController.text) {
                  isLoading = false;
                } else {
                  widget.timebankModel.name = nameController.text;
                  await updateTimebank();
                  isLoading = false;
                  Navigator.pop(context);
                }
              },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLoading)
              SizedBox(
                height: 18,
                width: 18,
                child: Theme(
                  data: ThemeData(accentColor: Colors.white),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                FlavorConfig.values.timebankName == "Yang 2020"
                    ? "Update Yang gang"
                    : "Update Timebank",
              ),
            ),
          ],
        ),
        color: selectedImage == null &&
                widget.timebankModel.name == nameController.text
            ? Colors.grey
            : Theme.of(context).accentColor,
        textColor: FlavorConfig.values.buttonTextColor,
        shape: StadiumBorder(),
      ),
    );
  }

  Widget get _profileBtn {
    return SizedBox(
      height: 35,
      width: 120,
      child: Container(
        padding: EdgeInsets.only(top: 5.0),
        child: RaisedButton(
          onPressed: isLoading
              ? null
              : () {
                  imagePicker.showDialog(context);
                },
          color: Colors.grey,
          child: Text(
            this.isImageSelected,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget get _imagePicker {
    if (widget.timebankModel.photoUrl == null) {
      return SizedBox(
        height: 200,
        width: 200,
        child: Container(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: selectedImage != null
                    ? FileImage(selectedImage)
                    : AssetImage('lib/assets/images/profile.png'),
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 200,
        width: 200,
        child: Container(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: selectedImage != null
                    ? FileImage(selectedImage)
                    : NetworkImage(widget.timebankModel.photoUrl == null
                        ? 'lib/assets/images/profile.png'
                        : widget.timebankModel.photoUrl),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  void userImage(File _image) {
    if (_image == null) return;
    setState(() {
      this.selectedImage = _image;
      // File some = File.fromRawPath();
      isImageSelected = 'Update Photo';
    });
  }

  Future updateTimebank() async {
    if (this.selectedImage != null) {
      String imageUrl = await _uploadImage();
      widget.timebankModel.photoUrl = imageUrl;
    }
    await FirestoreManager.updateTimebank(timebankModel: widget.timebankModel);
  }

  @override
  Future<String> _uploadImage() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('timebanklogos')
        .child(
            SevaCore.of(context).loggedInUser.email + timestampString + '.jpg');
    StorageUploadTask uploadTask = ref.putFile(
      selectedImage,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Timebank Logo'},
      ),
    );
    String imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();
    return imageURL;
  }

//  Future<String> uploadImage(String email) async {
//    StorageReference ref = FirebaseStorage.instance
//        .ref()
//        .child('profile_images')
//        .child(email + '.jpg');
//    StorageUploadTask uploadTask = ref.putFile(
//      selectedImage,
//      StorageMetadata(
//        contentLanguage: 'en',
//        customMetadata: <String, String>{'activity': 'News Image'},
//      ),
//    );
//    // StorageUploadTask uploadTask = ref.putFile(File.)
//    String imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();
//    return imageURL;
//  }

  Widget get logo {
    return Container(
      child: Column(
        children: <Widget>[
          Image.asset(
            'lib/assets/images/seva-x-logo.png',
            height: 30,
            fit: BoxFit.fill,
            width: 100,
          )
        ],
      ),
    );
  }

  @override
  addWebImageUrl() {
    // TODO: implement addWebImageUrl
    print('');
  }
}
