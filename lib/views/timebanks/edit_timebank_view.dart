import 'dart:developer';
import 'dart:io';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
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
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/profile/edit_skills.dart';

import '../core.dart';

class EditTimebankView extends StatefulWidget {
  TimebankModel timebankModel;

  EditTimebankView({this.timebankModel});

  @override
  _EditTimebankViewState createState() => _EditTimebankViewState();
}

class _EditTimebankViewState extends State<EditTimebankView>
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
  TimebankModel timebankModel;
  bool _saving = false;
  GeoFirePoint location;
  String selectedAddress;

  @override
  void initState() {
    super.initState();
    AnimationController _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    this.location = widget.timebankModel.location;
    _getLocation();
    this.timebankModel = widget.timebankModel;
    imagePicker = ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  Future _getLocation() async {
    String address = await LocationUtility().getFormattedAddress(
      location.latitude,
      location.longitude,
    );
    log('_getLocation: $address');
    setState(() {
      this.selectedAddress = address;
    });
  }

  ImageProvider _getImage(TimebankModel model) {
    if (model.photoUrl == null) {
      return AssetImage('lib/assets/images/profile.png');
    } else {
      return NetworkImage(model.photoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            widget.timebankModel.name,
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
                          'Yang Gang Chapter',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 10.0),
                        child: Text(widget.timebankModel.name),
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
                      title: Text(
                          'Update ${FlavorConfig.values.timebankName == "Yang 2020" ? "Yang Gang Chapter" : "Timebank name"}',
                          style: TextStyle(fontSize: 15.0)),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          //key: _formKey,
                          decoration: InputDecoration(
                            hintText:
                                FlavorConfig.values.timebankName == "Yang 2020"
                                    ? "Enter Yang Gang Chapter"
                                    : "Enter Timebank name",
                          ),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(fontSize: 17.0),
                          initialValue: widget.timebankModel.name,
                          onChanged: (value) {
//                            if (value.isEmpty == false) {
//                              this.timebankModel.name = value;
//                            }
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter ${FlavorConfig.values.timebankName == "Yang 2020" ? "Enter Yang Gnag Chapter" : "Enter Timebank name"} to update';
                            }
                            widget.timebankModel.name = value;
                          },
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
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
                            updateTimebank();
                            isLoading = false;
                            setState(() {
                              widget.timebankModel.name =
                                  this.timebankModel.name;
                            });
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: dialogButtonSize,
                            ),
                          ),
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
                        'Mission Statement',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text(widget.timebankModel.missionStatement),
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
                      title: Text('Update Mission Statement',
                          style: TextStyle(fontSize: 15.0)),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          //key: _formKey,
                          decoration: InputDecoration(
                              hintText: 'Enter Mission Statement'),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(fontSize: 17.0),
                          initialValue: widget.timebankModel.missionStatement,
                          onChanged: (value) {
//                            if (value.isEmpty == false) {
//                              this.timebankModel.missionStatement = value;
//                            }
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter Mission Statement to update';
                            }
                            widget.timebankModel.missionStatement = value;
                          },
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
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
                            updateTimebank();
                            isLoading = false;
//                            setState(() {
//                              widget.timebankModel.missionStatement = this.timebankModel.missionStatement;
//                            });
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: dialogButtonSize,
                            ),
                          ),
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
                        'Email',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text(widget.timebankModel.emailId),
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
                      title: Text('Update Email',
                          style: TextStyle(fontSize: 15.0)),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          //key: _formKey,
                          decoration: InputDecoration(hintText: 'Enter Email'),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(fontSize: 17.0),
                          initialValue: widget.timebankModel.emailId,
                          onChanged: (value) {
//                            if (value.isEmpty == false) {
//                              this.timebankModel.missionStatement = value;
//                            }
                          },
                          validator: (value) {
                            if (!isValidEmail(value)) {
                              return 'Enter a valid email address';
                            }
                            widget.timebankModel.emailId = value;
                          },
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
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
                            updateTimebank();
                            isLoading = false;
//                            setState(() {
//                              widget.timebankModel.emailId = this.timebankModel.emailId;
//                            });
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: dialogButtonSize,
                            ),
                          ),
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
                        'Phone Number',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text(widget.timebankModel.phoneNumber),
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
                      title: Text('Update Phone Number',
                          style: TextStyle(fontSize: 15.0)),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          //key: _formKey,
                          decoration:
                              InputDecoration(hintText: 'Enter Phone Number'),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(fontSize: 17.0),
                          initialValue: widget.timebankModel.phoneNumber,
                          onChanged: (value) {
//                            if (value.isEmpty == false) {
//                              this.timebankModel.phoneNumber = value;
//                            }
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter Phone Number to update';
                            }
                            widget.timebankModel.phoneNumber = value;
                          },
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
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
                            updateTimebank();
                            isLoading = false;
//                            setState(() {
//                              widget.timebankModel.phoneNumber = this.timebankModel.phoneNumber;
//                            });
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: dialogButtonSize,
                            ),
                          ),
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
                        'Address',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text(widget.timebankModel.address),
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
                      title: Text('Update Address',
                          style: TextStyle(fontSize: 15.0)),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          //key: _formKey,
                          decoration:
                              InputDecoration(hintText: 'Enter Address'),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(fontSize: 17.0),
                          initialValue: widget.timebankModel.address,
                          onChanged: (value) {
//                            if (value.isEmpty == false) {
//                              this.timebankModel.address = value;
//                            }
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter Address to update';
                            }
                            widget.timebankModel.address = value;
                          },
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
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
                            updateTimebank();
                            isLoading = false;
//                            setState(() {
//                              widget.timebankModel.address = this.timebankModel.address;
//                            });
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: dialogButtonSize,
                            ),
                          ),
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
                        'Location',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      child: Text(
                        selectedAddress == null || selectedAddress.isEmpty
                            ? 'Add Location'
                            : selectedAddress,
                      ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute<GeoFirePoint>(
                    builder: (context) => LocationPicker(
                      selectedLocation: location,
                    ),
                  ),
                ).then((point) {
                  if (point != null) location = point;
                  _getLocation();
                  widget.timebankModel.location = location;
                  updateTimebank();
                  log('ReceivedLocation: $selectedAddress');
                });
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
          ]),
        ));
  }

  bool isValidEmail(String email) {
    RegExp regex =
        RegExp(r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)');
    return regex.hasMatch(email);
  }

  Future updateProfilePic() async {
    if (this.selectedImage != null) {
      setState(() {
        this._saving = true;
      });
      String imageUrl = await uploadImage();
      setState(() {
        //SevaCore.of(context).loggedInUser.photoURL = imageUrl;
        widget.timebankModel.photoUrl = imageUrl;
      });
    }
    await FirestoreManager.updateTimebank(timebankModel: widget.timebankModel);
    setState(() {
      this._saving = false;
    });
  }

  Future updateTimebank() async {
    setState(() {
      this._saving = true;
    });
//    setState(() {
//      //SevaCore.of(context).loggedInUser.photoURL = imageUrl;
//      //widget.timebankModel.photoUrl = imageUrl;
//    });
    await FirestoreManager.updateTimebank(timebankModel: widget.timebankModel);
    setState(() {
      this._saving = false;
    });
  }

//  Future updateName() async {
//    setState(() {
//      this._saving = true;
//    });
////    setState(() {
////      //SevaCore.of(context).loggedInUser.photoURL = imageUrl;
////      //widget.timebankModel.photoUrl = imageUrl;
////    });
//    await FirestoreManager.updateTimebank(timebankModel: widget.timebankModel);
//    setState(() {
//      this._saving = false;
//    });
//  }

//  Future updateMail() async {
//    setState(() {
//      this._saving = true;
//    });
////    setState(() {
////      //SevaCore.of(context).loggedInUser.photoURL = imageUrl;
////      //widget.timebankModel.photoUrl = imageUrl;
////    });
//    await FirestoreManager.updateTimebank(timebankModel: widget.timebankModel);
//    setState(() {
//      this._saving = false;
//    });
//  }
//
//  Future updateStatement() async {
//    setState(() {
//      this._saving = true;
//    });
//    //SevaCore.of(context).loggedInUser.bio = this.timebankModel.bio;
//    await FirestoreManager.updateTimebank(timebankModel: widget.timebankModel);
//    setState(() {
//      this._saving = false;
//    });
//  }
//
//  Future updatePhoneNumber() async {
//    setState(() {
//      this._saving = true;
//    });
//    //SevaCore.of(context).loggedInUser.bio = this.timebankModel.bio;
//    await FirestoreManager.updateTimebank(timebankModel: widget.timebankModel);
//    setState(() {
//      this._saving = false;
//    });
//  }
//
//  Future updateAddress() async {
//    setState(() {
//      this._saving = true;
//    });
//    //SevaCore.of(context).loggedInUser.bio = this.timebankModel.bio;
//    await FirestoreManager.updateTimebank(timebankModel: widget.timebankModel);
//    setState(() {
//      this._saving = false;
//    });
//  }

//  Future updateStatement() async {
//    setState(() {
//      this._saving = true;
//    });
//    //SevaCore.of(context).loggedInUser.bio = this.timebankModel.bio;
//    await FirestoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
//    setState(() {
//      this._saving = false;
//    });
//  }

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
                  : _getImage(widget.timebankModel),
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

  @override
  Future<String> uploadImage() async {
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

  Future addUserToTimebank(UserModel loggedInUser) async {
    TimebankModel timebankModel = await FirestoreManager.getTimeBankForId(
      timebankId: FlavorConfig.values.timebankId,
    );
    List<String> _members = timebankModel.members;
    timebankModel.members = [..._members, loggedInUser.email];
    await FirestoreManager.updateTimebank(timebankModel: timebankModel);
  }
}
