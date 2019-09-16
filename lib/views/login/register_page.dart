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
          'Register',
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
                SizedBox(height: 32),
                _imagePicker,
                _formFields,
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

  Widget get _imagePicker {
    return SizedBox(
      height: 80,
      width: 100,
      child: GestureDetector(
        onTap: isLoading
            ? null
            : () {
                imagePicker.showDialog(context);
              },
        child: selectedImage == null
            ? Container(
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  color: Colors.grey[300],
                ),
              )
            : Container(
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
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
            hint: 'Full Name',
            validator: (value) => value.isEmpty ? 'Name cannot be empty' : null,
            capitalization: TextCapitalization.words,
            onSave: (value) => this.fullName = value,
          ),
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
      padding: const EdgeInsets.all(8.0),
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
                  _scaffoldKey.currentState.removeCurrentSnackBar();
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text('Select an image to get started'),
                      action: SnackBarAction(
                        label: 'Dismiss',
                        onPressed: () =>
                            _scaffoldKey.currentState.hideCurrentSnackBar(),
                      ),
                    ),
                  );
                  isLoading = false;
                  return;
                }
                if (!_formKey.currentState.validate()) {
                  isLoading = false;
                  return;
                }
                _formKey.currentState.save();
                await createUser();
                isLoading = false;
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
    print('Called createUser');
    Auth auth = AuthProvider.of(context).auth;
    try {
      UserModel user = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: fullName,
      );
      String imageUrl = await uploadImage(user.email);
      user.photoURL = imageUrl;
      await FirestoreManager.updateUser(user: user);
      Navigator.pop(context, user);
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
      print('createUser: error: ${error.toString()}');
      return null;
    }
  }

  @override
  void userImage(File _image) {
    if (_image == null) return;
    setState(() {
      this.selectedImage = _image;
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
