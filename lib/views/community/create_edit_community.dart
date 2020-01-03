import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';

class CreateEditCommunityView extends StatelessWidget {
  final String timebankId;

  CreateEditCommunityView({@required this.timebankId});

  @override
  Widget build(BuildContext context) {
    var title = 'Create your Community';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.5,
        backgroundColor: Color(0xFFFFFFFF),
        leading: BackButton(color: Colors.black54),
        title: Text(
          title,
          style: TextStyle(
              color: Colors.black54, fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: CreateEditCommunityViewForm(
        timebankId: timebankId,
      ),
    );
  }
}

// Create a Form Widget
class CreateEditCommunityViewForm extends StatefulWidget {
  final String timebankId;

  CreateEditCommunityViewForm({@required this.timebankId});

  @override
  CreateEditCommunityViewFormState createState() {
    return CreateEditCommunityViewFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class CreateEditCommunityViewFormState
    extends State<CreateEditCommunityViewForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
  }

  HashMap<String, UserModel> selectedUsers = HashMap();
  String memberAssignment = "+ Add Members";

  Map onActivityResult;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(children: <Widget>[createSevaX])));

  }

  Widget get createSevaX {
    return StreamBuilder(
        stream: createEditCommunityBloc.createEditCommunity,
        builder:
            (context, AsyncSnapshot<CommunityCreateEditController> snapshot) {
          if (snapshot.hasData) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Text(
                      'Timebank is where you can create requests and get offers with in your team.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Column(
                          children: <Widget>[
                            TimebankAvatar(),
                            Text(''),
                            Text(
                              'Your Logo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )),
                  headingText('Name your Community'),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Ex: Pets-in-town, Citizen collab",
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    initialValue: snapshot.data.community.name,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Community name cannot be empty';
                      } else {
                        snapshot.data.community.updateValueByKey('name', value);
                      }
                      return "";
                    },
                  ),
                  headingText('About'),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Ex: A bit more about your team',
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Tell us more about your community.';
                      }
                      snapshot.data.timebank.updateValueByKey('about', value);
                      return "";
                    },
                  ),
                  Row(
                    children: <Widget>[
                      headingText('Private team'),
                      Column(
                        children: <Widget>[
                          Divider(),
                          Checkbox(
                            value: snapshot.data.timebank.protected,
                            onChanged: (bool value) {
                              snapshot.data.timebank
                                  .updateValueByKey('protected', value);
                              return "";
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'With private team, new members needs yor approval to join team',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  headingText('Is this pin at a right place?'),
                  Container(
//            margin: EdgeInsets.only(left: 20),
                    child: Row(
                      children: <Widget>[
                        FlatButton.icon(
                            icon: Icon(Icons.add_location),
                            label: Text(
                              "",
                            ),
                            color: Colors.grey[200]),
                      ],
                    ),
                  ),
                ]);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Expanded(
            child: Text(""),
          );
        });
  }

  Widget headingText(String name) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
