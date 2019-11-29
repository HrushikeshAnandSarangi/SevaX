import 'dart:developer';
import 'dart:io';
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

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
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
  bool isEmailVerified = false;
  bool sentOTP = false;
  var codeArray = ['mango', 'orange', 'apple', 'plum', 'banana', 'custard', 'papaya', 'grapes', 'pear', 'avacado'];

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
          'Register',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
//        child: SingleChildScrollView(
//          child: Center(
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 16),
                    logo,
                    SizedBox(height: 16),
                    _imagePicker,
                    _profileBtn,
                    _formFields,
                    SizedBox(height: 32),
                    registerButton,
                  ],
                ),
              ],
            ),
//          ),
//        ),
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
      height: 80,
      width: 120,
      child: Container(
//        onTap: isLoading
//            ? null
//            : () {
//                imagePicker.showDialog(context);
//              },
        child: selectedImage == null
            ? Container(
                decoration: BoxDecoration(
                  //shape: CircleBorder(),
                  //shape: ShapeBorder.,
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.grey[300],
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: FileImage(selectedImage),
                  ),
                ),
              ),
      ),
    );
  }

  Widget get _formFields {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          getFormField(
            hint: 'Email Address',
            validator: (value) {
              if (!isValidEmail(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
            capitalization: TextCapitalization.none,
            onSave: (value) => this.email = value,
          ),
          getFormField(
            hint: 'Full Name',
            validator: (value) => value.isEmpty ? 'Name cannot be empty' : null,
            capitalization: TextCapitalization.words,
            onSave: (value) => this.fullName = value,
          ),
          getFormField(
            hint: 'Password',
            shouldObscure: shouldObscure,
            validator: (value) {
              this.password = '';
              if (value.length < 6) {
                return 'Password should have atleast 6 characters';
              }
              this.password = value;
              return null;
            },
            onSave: (value) {
              this.password = value;
            },
            suffix: GestureDetector(
              onTap: () => shouldObscure = !shouldObscure,
              child: Icon(Icons.remove_red_eye),
            ),
          ),
          getFormField(
            hint: 'Confirm Password',
            shouldObscure: shouldObscure,
            validator: (value) {
              if (value.length < 6) {
                return 'Password should have atleast 6 characters';
              }
              if (value != password) {
                return 'Passwords do not match';
              }
              return null;
            },
            suffix: GestureDetector(
              onTap: () => shouldObscure = !shouldObscure,
              child: Icon(Icons.remove_red_eye),
            ),
          ),
        ],
      ),
    );
  }

  Widget getFormField({
    String hint,
    String Function(String value) validator,
    Function(String value) onSave,
    bool shouldObscure = false,
    Widget suffix,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0, top: 8.0),
      child: TextFormField(
        enabled: !isLoading,
        decoration: InputDecoration(
          labelText: hint,
          suffix: suffix,
        ),
        textCapitalization: capitalization,
        validator: validator,
        onSaved: onSave,
        obscureText: shouldObscure,
      ),
    );
  }

  Widget get registerButton {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                       title: Text('Add Photo?'),
                       content: Text('Do you want to add profile pic?'),
                       actions: <Widget>[
                         FlatButton(
                           child: Text('Skip'),
                           onPressed: () async {
                             Navigator.pop(viewContext);
                             if (!_formKey.currentState.validate()) {
                               isLoading = false;
                               return;
                             }
                             _formKey.currentState.save();
                             await createUser();
                             isLoading = false;
                           },
                         ),
                         FlatButton(
                           child: Text('Add Photo'),
                           onPressed: () {
                             Navigator.pop(viewContext);
                             imagePicker.showDialog(context);
                               isLoading = false;
                               return;
                           },
                         ),
                       ],
                     );
                   },
                  );
                } else {
                  if (!_formKey.currentState.validate()) {
                    isLoading = false;
                    return;
                  }
                  _formKey.currentState.save();
                  await createUser();
                  isLoading = false;
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
              child: Text('Register'),
            ),
          ],
        ),
        color: Theme.of(context).accentColor,
        textColor: FlavorConfig.values.buttonTextColor,
        shape: StadiumBorder(),
      ),
    );
  }

  bool isValidEmail(String email) {
    RegExp regex =
        RegExp(r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)');
    return regex.hasMatch(email);
  }

  Future createUser() async {
    log('Called createUser');
    Auth auth = AuthProvider.of(context).auth;
    try {
      UserModel user = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: fullName,
      );
      if (this.selectedImage != null) {
        String imageUrl = await uploadImage(user.email);
        user.photoURL = imageUrl;
      } else {
          user.photoURL = "https://icon-library.net/images/user-icon-image/user-icon-image-21.jpg";
      }
      await FirestoreManager.updateUser(user: user);
      Navigator.pop(context, user);
      // Navigator.popUntil(context, (r) => r.isFirst);
    } on PlatformException catch (error) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(error.message),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
          ),
        ),
      );
      return null;
    } catch (error) {
      log('createUser: error: ${error.toString()}');
      return null;
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
