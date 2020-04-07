import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/components/newsimage/image_picker_handler.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/onboarding/skills_view.dart';

import '../core.dart';

class EditProfilePage extends StatefulWidget {
  UserModel userModel;

  EditProfilePage({this.userModel});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with ImagePickerListener, SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _firestore = Firestore.instance;

  bool _shouldObscure = true;
  bool _isLoading = false;

  String fullName;
  String password;
  String email;
  String imageUrl;
  String confirmPassword;
  File selectedImage;
  String isImageSelected = 'Add Photo';
  ImagePickerHandler imagePicker;
  UserModel usermodel;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    AnimationController _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    this.usermodel = widget.userModel;
    imagePicker = ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: ListView(
          children: <Widget>[
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),

                  Stack(
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.zero,
                        child: _imagePicker,
                      ),
                      Positioned(
                        width: 50,
                        height: 50,
                        right: 5.0,
                        bottom: 5.0,
                        child: FloatingActionButton(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                          ),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            imagePicker.showDialog(context);
                            isLoading = false;
                          },
                        ),
                      ),
                    ],
                  ),
                  //registerButton,
                ],
              ),
            ),
            SizedBox(height: 50),
            detailsBuilder(
              title: "Name",
              text: widget.userModel.fullname,
              onTap: _updateName,
            ),
            detailsBuilder(
              title: "Bio",
              text: widget.userModel.bio ?? "Add your bio",
              onTap: _updateBio,
            ),
            detailsBuilder(
              title: "Interests",
              text: "Click here to see your interests",
              onTap: () => _navigateToInterestsView(usermodel),
            ),
            detailsBuilder(
              title: "Skills",
              text: "Click here to see your skills",
              onTap: () => _navigateToSkillsView(usermodel),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 3.5,
                vertical: 20,
              ),
              child: Container(
                width: 134,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text(
                    'Logout',
                  ),
                  onPressed: logOut,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding detailsBuilder({String title, String text, Function onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(text ?? ""),
            SizedBox(height: 5),
            Divider(
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  Future _navigateToInterestsView(UserModel loggedInUser) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InterestViewNew(
          userModel: loggedInUser,
          onSelectedInterests: (interests) {
            Navigator.pop(context);
            loggedInUser.interests = interests;
            updateUserData(loggedInUser);
          },
          onSkipped: () {
            Navigator.pop(context);
            loggedInUser.interests = [];
            updateUserData(loggedInUser);
          },
        ),
      ),
    );
  }

  Future _navigateToSkillsView(UserModel loggedInUser) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SkillViewNew(
          userModel: loggedInUser,
          onSelectedSkills: (skills) {
            Navigator.pop(context);
            loggedInUser.skills = skills;
            updateUserData(loggedInUser);
          },
          onSkipped: () {
            Navigator.pop(context);
            loggedInUser.skills = [];
            updateUserData(loggedInUser);
          },
        ),
      ),
    );
  }

  Future updateUserData(UserModel user) async {
    await FirestoreManager.updateUser(user: user);
  }

  Future updateProfilePic() async {
    if (this.selectedImage != null) {
      setState(() {
        this._saving = true;
      });
      String imageUrl =
          await uploadImage(SevaCore.of(context).loggedInUser.email);
      setState(() {
        SevaCore.of(context).loggedInUser.photoURL = imageUrl;
      });
    }
    await FirestoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
    setState(() {
      this._saving = false;
    });
  }

  Future updateName() async {
    setState(() {
      this._saving = true;
    });
    SevaCore.of(context).loggedInUser.fullname = widget.userModel.fullname;
    await FirestoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
    setState(() {
      this._saving = false;
    });
  }

  Future updateBio() async {
    setState(() {
      this._saving = true;
    });
    SevaCore.of(context).loggedInUser.bio = widget.userModel.bio;
    await FirestoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
    setState(() {
      this._saving = false;
    });
  }

  bool get shouldObscure => this._shouldObscure;

  set shouldObscure(bool shouldObscure) {
    setState(() => this._shouldObscure = shouldObscure);
  }

  bool get isLoading => this._isLoading;

  set isLoading(bool isLoading) {
    setState(() => this._isLoading = isLoading);
  }

  Widget get _imagePicker {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.45,
      width: MediaQuery.of(context).size.width * 0.45,
      child: Container(
        child: Hero(
          tag: "ProfileImage",
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                widget.userModel.photoURL ??
                    'https://icon-library.net/images/user-icon-image/user-icon-image-21.jpg',
              ),
              backgroundColor: Colors.white,
              radius: MediaQuery.of(context).size.width / 4.5,
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
      this.updateProfilePic();
      // File some = File.fromRawPath();
      //isImageSelected = 'Update Photo';
    });
  }

  _updateName() {
    return showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text('Update name', style: TextStyle(fontSize: 15.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: InputDecoration(hintText: 'Enter name'),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 17.0),
                  initialValue: widget.userModel.fullname,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter name to update';
                    }
                    widget.userModel.fullname = value;
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      'Update',
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () {
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      Navigator.pop(viewContext);
                      updateName();
                      isLoading = false;
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: dialogButtonSize, color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(viewContext);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _updateBio() {
    return showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text('Update bio', style: TextStyle(fontSize: 15.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  //key: _formKey,
                  decoration: InputDecoration(hintText: 'Enter bio'),
                  maxLength: 150,
                  maxLengthEnforced: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 17.0),
                  initialValue: widget.userModel.bio,
                  onChanged: (value) {
                    print("${value.length}");
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter bio to update';
                    }
                    widget.userModel.bio = value;
                  },
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Spacer(),
                  FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      'Update',
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () {
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      Navigator.pop(viewContext);
                      updateBio();
                      isLoading = false;
//                            setState(() {
//                              widget.userModel.bio = this.usermodel.bio;
//                            });
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: dialogButtonSize, color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(viewContext);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
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

  Future addUserToTimebank(UserModel loggedInUser) async {
    TimebankModel timebankModel = await FirestoreManager.getTimeBankForId(
      timebankId: FlavorConfig.values.timebankId,
    );
    List<String> _members = timebankModel.members;
    timebankModel.members = [..._members, loggedInUser.email];
    await FirestoreManager.updateTimebank(timebankModel: timebankModel);
  }

  void logOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Logout"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Are you sure you want to logout?"),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Spacer(),
                  FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: new Text(
                      "Logout",
                      style: TextStyle(fontFamily: 'Europa'),
                    ),
                    onPressed: () {
                      // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                      //   statusBarBrightness: Brightness.light,
                      //   statusBarColor: Colors.white,
                      // ));
                      Navigator.of(context).pop();
                      _signOut(context);
                    },
                  ),
                  new FlatButton(
                    child: new Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red, fontFamily: 'Europa'),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    // Navigator.pop(context);
    var auth = AuthProvider.of(context).auth;
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AuthRouter(),
      ),
    );
  }
}
