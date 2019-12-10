import 'dart:developer';
import 'dart:io';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/components/newsimage/image_picker_handler.dart';
import 'package:sevaexchange/main.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/profile/edit_skills.dart';

import '../core.dart';
import 'edit_interests.dart';

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
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: ListView(children: <Widget>[
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    //child: _imagePicker,
                  ),
                  Stack(
                    children: <Widget>[
                      new Container(
                          padding: EdgeInsets.zero, child: _imagePicker),
                      Positioned(
                          width: 50,
                          height: 50,
                          right: 5.0,
                          bottom: 5.0,
                          child: FloatingActionButton(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            onPressed: () {
                              imagePicker.showDialog(context);
                              isLoading = false;
                            },
                          )),
                    ],
                  ),
                  //registerButton,
                ],
              ),
            ),
            SizedBox(height: 50),
            GestureDetector(
              child: Container(
                child: Card(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 10.0),
                        child: Text(
                          'Name',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 10.0),
                        child: Text(widget.userModel.fullname),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 5.0),
                        child: Divider(
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                print('name clicked');
                return showDialog(
                  context: context,
                  builder: (BuildContext viewContext) {
                    // return object of type Dialog
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      title:
                          Text('Update name', style: TextStyle(fontSize: 15.0)),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          //key: _formKey,
                          decoration: InputDecoration(hintText: 'Enter name'),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(fontSize: 17.0),
                          initialValue: widget.userModel.fullname,
                          onChanged: (value) {
//                            if (value.isEmpty == false) {
//                              this.usermodel.fullname = value;
//                            }
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter name to update';
                            }
                            widget.userModel.fullname = value;
                          },
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Update'),
                          onPressed: () {
                            if (!_formKey.currentState.validate()) {
                              return;
                            }
                            Navigator.pop(viewContext);
                            updateName();
                            isLoading = false;
//                            setState(() {
//                              widget.userModel.fullname =
//                                  this.usermodel.fullname;
//                            });
                          },
                        ),
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(viewContext);
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ),
            GestureDetector(
              child: Card(
                color: Colors.transparent,
                elevation: 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text(
                        'Bio',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text(widget.userModel.bio == null
                          ? 'Add your bio'
                          : widget.userModel.bio),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 5.0),
                      child: Divider(
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                return showDialog(
                  context: context,
                  builder: (BuildContext viewContext) {
                    // return object of type Dialog
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      title:
                          Text('Update bio', style: TextStyle(fontSize: 15.0)),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          //key: _formKey,
                          decoration: InputDecoration(hintText: 'Enter bio'),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(fontSize: 17.0),
                          initialValue: widget.userModel.bio,
                          onChanged: (value) {
//                            if (value.isEmpty == false) {
//                              this.usermodel.bio = value;
//                            }
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter bio to update';
                            }
                            widget.userModel.bio = value;
                          },
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Update'),
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
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(viewContext);
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ),
//            GestureDetector(
//              child: Card(
//                color: Colors.transparent,
//                elevation: 0.0,
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Padding(
//                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
//                      child: Text(
//                        'Email',
//                        style: TextStyle(
//                            fontSize: 15.0,
//                            fontWeight: FontWeight.w600,
//                            color: Colors.black45,
//                        ),
//                      ),
//                    ),
//                    Padding(
//                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
//                      child: Text(widget.userModel.email,style: TextStyle(color: Colors.black45,),),
//
//                    ),
//                    Padding(
//                      padding: EdgeInsets.only(left: 30.0, top: 5.0),
//                      child: Divider(
//                        color: Colors.black45,
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//              onTap: () {
//                print('email clicked');
//              },
//            ),
            GestureDetector(
              child: Card(
                color: Colors.transparent,
                elevation: 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text(
                        'Interests',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text('Click here to see your interests'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 5.0),
                      child: Divider(
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                print('interests clicked');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return EditInterests();
                    },
                  ),
                );
              },
            ),
            GestureDetector(
              child: Card(
                color: Colors.transparent,
                elevation: 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text(
                        'Skills',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text('Click here to see your skills'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 5.0),
                      child: Divider(
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return EditSkills();
                    },
                  ),
                );
                print('Skills clicked');
              },
            ),
          ]),
        ));
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
      height: 150,
      width: 150,
      child: Container(
//        onTap: isLoading
//            ? null
//            : () {
//                imagePicker.showDialog(context);
//              },
        child: Container(
          decoration: ShapeDecoration(
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.white,
                width: 2.0,
              ),
            ),
            image: DecorationImage(
              image: selectedImage != null
                  ? FileImage(selectedImage)
                  : NetworkImage(widget.userModel.photoURL),
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
}
