import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;
import 'package:sevaexchange/widgets/custom_chip.dart';

class SkillsPage extends StatefulWidget {
  final UserModel user;

  final bool isFromProfilePage;

  SkillsPage({
    this.user,
    this.isFromProfilePage = false,
  });
  @override
  _SkillViewNewState createState() => _SkillViewNewState();
}

class _SkillViewNewState extends State<SkillsPage> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();
  bool autovalidate = false;
  Map<String, dynamic> skills = {};
  Map<String, dynamic> _selectedSkills = {};
  UserModel user;
  @override
  void initState() {
    user = widget.user;
    Firestore.instance
        .collection('skills')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot data) {
        skills[data.documentID] = data['name'];
      });
      if (user.skills.length > 0) {
        user.skills.forEach((id) {
          _selectedSkills[id] = skills[id];
        });
      }
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isFromProfilePage) {
          Navigator.pop(context);
        } else {
          _showDialog();
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Skills',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                'What skills are you good at that you\'d like to share with your community?',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              TypeAheadField<String>(
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                hideOnError: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    filled: true,
                    fillColor: Colors.grey[300],
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(25.7)),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    suffixIcon: InkWell(
                      splashColor: Colors.transparent,
                      child: Icon(
                        Icons.clear,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _textEditingController.clear();
                        controller.close();
                      },
                    ),
                  ),
                ),
                suggestionsBoxController: controller,
                suggestionsCallback: (pattern) async {
                  List<String> dataCopy = [];
                  skills.forEach((id, skill) => dataCopy.add(skill));
                  dataCopy.retainWhere(
                      (s) => s.toLowerCase().contains(pattern.toLowerCase()));

                  return await Future.value(dataCopy);
                },
                itemBuilder: (context, suggestion) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                },
                noItemsFoundBuilder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No matching skills found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  _textEditingController.clear();
                  if (!_selectedSkills.containsValue(suggestion)) {
                    controller.close();
                    String id =
                        skills.keys.firstWhere((k) => skills[k] == suggestion);
                    _selectedSkills[id] = suggestion;
                    setState(() {});
                  }
                },
              ),
              SizedBox(height: 20),
              ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Wrap(
                    runSpacing: 5.0,
                    spacing: 5.0,
                    children: _selectedSkills.values
                        .toList()
                        .map(
                          (value) => value == null
                              ? Container()
                              : CustomChip(
                                  title: value,
                                  onDelete: () {
                                    String id = skills.keys
                                        .firstWhere((k) => skills[k] == value);
                                    _selectedSkills.remove(id);
                                    setState(() {});
                                  },
                                ),
                        )
                        .toList(),
                  ),
                ],
              ),
              Spacer(),
              SizedBox(
                width: 134,
                child: RaisedButton(
                  onPressed: () {
                    List<String> selectedID = [];
                    _selectedSkills.forEach((id, _) => selectedID.add(id));
                    user.skills = selectedID;
                    fireStoreManager.updateUser(user: user).then((_) {
                      // customRouter(context: context, user: user);
                    });
                  },
                  child: Text(
                    user.skills == null ? 'Next' : 'Update',
                    style: Theme.of(context).primaryTextTheme.button,
                  ),
                ),
              ),
              !widget.isFromProfilePage
                  ? FlatButton(
                      onPressed: () {
                        if (widget.isFromProfilePage) {
                          Navigator.pop(context);
                        } else {
                          AppConfig.prefs.setBool(AppConfig.skip_skill, true);
                          // customRouter(context: context, user: user);
                        }
                      },
                      child: Text(
                        AppConfig.prefs.getBool(AppConfig.skip_skill) == null
                            ? 'Skip'
                            : 'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 200,
                child: RaisedButton(
                  child: Text("Log out"),
                  onPressed: () {
                    _signOut(context);
                  },
                ),
              ),
              Container(
                width: 200,
                child: RaisedButton(
                  child: Text("Exit app"),
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                ),
              ),
              Container(
                width: 200,
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
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
