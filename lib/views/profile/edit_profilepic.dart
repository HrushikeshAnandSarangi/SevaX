import 'dart:developer';
import 'dart:io';
import 'package:sevaexchange/flavor_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/components/newsimage/image_picker_handler.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class EditProfilePic extends StatefulWidget {
  @override
  _EditProfilePicState createState() => _EditProfilePicState();
}

class _EditProfilePicState extends State<EditProfilePic>
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

  @override
  void initState() {
    super.initState();
    AnimationController _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    imagePicker = ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Update Profile Pic',
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
          if (selectedImage == null) {
            showDialog(
              context: context,
              builder: (BuildContext viewContext) {
                // return object of type Dialog
                return AlertDialog(
                  title: Text('Update Photo?'),
                  content: Text('Please Change your profile pic and Update.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Add Photo'),
                      onPressed: () {
                        Navigator.pop(viewContext);
                        imagePicker.showDialog(context);
                        isLoading = false;
                      },
                    ),
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(viewContext);
                        isLoading = false;
                      },
                    )
                  ],
                );
              },
            );
          } else {
            await createUser();
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
              child: Text('Update Profile Pic'),
            ),
          ],
        ),
        color: Theme.of(context).accentColor,
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
    return SizedBox(
      height: 200,
      width: 200,
      child: Container(
//        onTap: isLoading
//            ? null
//            : () {
//                imagePicker.showDialog(context);
//              },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: selectedImage != null ? FileImage(selectedImage) : NetworkImage(SevaCore.of(context).loggedInUser.photoURL),
            ),
          ),
        ),
      ),
    );
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
  Future createUser() async {
    if (this.selectedImage != null) {
      String imageUrl = await uploadImage(SevaCore.of(context).loggedInUser.email);
      setState(() {
        SevaCore.of(context).loggedInUser.photoURL = imageUrl;
      });
    }
    await FirestoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
  }


  Future<String> uploadImage(String email) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child(email + '.jpg');
    StorageUploadTask uploadTask = ref.putFile(
      selectedImage,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'News Image'},
      ),
    );
    // StorageUploadTask uploadTask = ref.putFile(File.)
    String imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();
    return imageURL;
  }

  Widget get logo {
    return Container(
      child: Column(
        children: <Widget>[
          FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
              ? Text(
            'Humanity\nFirst'.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 5,
              fontSize: 24,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700,
            ),
          )
              : Offstage(),
          SizedBox(
            height: 16,
          ),
          FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
              ? Image.asset(
            'lib/assets/Y_from_Andrew_Yang_2020_logo.png',
            height: 70,
            fit: BoxFit.fill,
            width: 80,
          )
              : FlavorConfig.appFlavor == Flavor.TULSI
              ? SvgPicture.asset(
            'lib/assets/tulsi_icons/tulsi2020_icons_tulsi2020-logo.svg',
            height: 100,
            fit: BoxFit.fill,
            width: 100,
            color: Colors.white,
          )
              : FlavorConfig.appFlavor == Flavor.TOM
              ? SvgPicture.asset(
            'lib/assets/ts2020-logo-w.svg',
            height: 90,
            fit: BoxFit.fill,
            width: 90,
          )
              : Image.asset(
            'lib/assets/images/seva-x-logo.png',
            height: 30,
            fit: BoxFit.fill,
            width: 100,
          )
        ],
      ),
    );
  }
}
