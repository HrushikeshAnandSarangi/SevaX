import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/configuaration_model.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/helpers/configurations_list.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/widgets/hide_widget.dart';

class MemberPermissions extends StatefulWidget {
  final TimebankModel timebankModel;
  MemberPermissions({this.timebankModel});

  @override
  _MemberPermissionsState createState() => _MemberPermissionsState();
}

class _MemberPermissionsState extends State<MemberPermissions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String selectedRole = '';
  String selectedRoleId = '';
  List<String> roles = [];
  List<String> all_permissions = [];
  bool isNotGroup = false;
  List<ConfigurationModel> configurationsList = [];
  List<ConfigurationModel> generalList = [];
  List<ConfigurationModel> requestsList = [];
  List<ConfigurationModel> eventsList = [];
  List<ConfigurationModel> offerList = [];
  List<ConfigurationModel> groupsList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isNotGroup = isPrimaryTimebank(
        parentTimebankId: widget.timebankModel.parentTimebankId);
    setUp();
  }

  void setUp() {
    Future.delayed(Duration.zero, () async {
      configurationsList = ConfigurationsList().getData();
      filterPermissions(configurationsList);
      roles = [S.of(context).super_admin, S.of(context).admin, 'Member'];

      selectedRole = S.of(context).super_admin;
      selectedRoleId = 'super_admin';
      if (widget.timebankModel.timebankConfigurations != null &&
          widget.timebankModel.timebankConfigurations.superAdmin != null) {
        all_permissions =
            widget.timebankModel.timebankConfigurations.superAdmin ?? [];
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            updateConfigurations().then(
              (value) => Navigator.of(context).pop(),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          'Manage Permissions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      child: Container(
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundImage: NetworkImage(
                              SevaCore.of(context).loggedInUser.photoURL ??
                                  defaultUserImageURL),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      SevaCore.of(context).loggedInUser.fullname ?? '',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              titleText(
                title: 'Role',
              ),
              roleWidget(),
              SizedBox(
                height: 20,
              ),
              titleText(
                title: 'General Permissions',
              ),
              generalPermissionsWidget(),
              SizedBox(
                height: 10,
              ),
              titleText(
                title: 'Events Permissions',
              ),
              eventPermissionsWidget(),
              SizedBox(
                height: 10,
              ),
              titleText(
                title: 'Request Permissions',
              ),
              requestPermissionsWidget(),
              SizedBox(
                height: 10,
              ),
              titleText(
                title: 'Offer Permissions',
              ),
              offerPermissionsWidget(),
              SizedBox(
                height: 10,
              ),
              HideWidget(
                hide: !isNotGroup,
                child: titleText(
                  title: 'Group Permissions',
                ),
              ),
              groupPermissionsWidget(),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget roleWidget() {
    return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 4 / 1,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.2,
        children: List.generate(
          roles.length,
          (index) => _optionRadioButton<String>(
            groupvalue: selectedRole,
            onChanged: (value) async {
              await updateConfigurations();
              selectedRole = value;
              if (value == 'Member') {
                all_permissions =
                    widget.timebankModel.timebankConfigurations.member ?? [];

                selectedRoleId = 'member';
              } else if (value == S.of(context).admin) {
                all_permissions =
                    widget.timebankModel.timebankConfigurations.admin ?? [];
                selectedRoleId = 'admin';
              } else {
                all_permissions =
                    widget.timebankModel.timebankConfigurations.superAdmin ??
                        [];
                selectedRoleId = 'super_admin';
              }
              setState(() {});
            },
            title: roles[index],
            value: roles[index],
          ),
        ));
  }

  Widget generalPermissionsWidget() {
    return ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(
          generalList.length,
          (index) => CheckboxListTile(
            checkColor: Colors.black,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(generalList[index].title_en),
            value: all_permissions.contains(generalList[index].id),
            onChanged: (value) {
              if (value) {
                all_permissions.add(generalList[index].id);
              } else {
                all_permissions.remove(generalList[index].id);
              }
              setState(() {});
            },
          ),
        ));
  }

  Widget requestPermissionsWidget() {
    return ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(
          requestsList.length,
          (index) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(requestsList[index].title_en),
            value: all_permissions.contains(requestsList[index].id),
            onChanged: (value) {
              if (value) {
                all_permissions.add(requestsList[index].id);
              } else {
                all_permissions.remove(requestsList[index].id);
              }
              setState(() {});
            },
          ),
        ));
  }

  Widget eventPermissionsWidget() {
    return ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(
          eventsList.length,
          (index) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(eventsList[index].title_en),
            value: all_permissions.contains(eventsList[index].id),
            onChanged: (value) {
              if (value) {
                all_permissions.add(eventsList[index].id);
              } else {
                all_permissions.remove(eventsList[index].id);
              }
              setState(() {});
            },
          ),
        ));
  }

  Widget offerPermissionsWidget() {
    return ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(
          offerList.length,
          (index) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(offerList[index].title_en),
            value: all_permissions.contains(offerList[index].id),
            onChanged: (value) {
              if (value) {
                all_permissions.add(offerList[index].id);
              } else {
                all_permissions.remove(offerList[index].id);
              }
              setState(() {});
            },
          ),
        ));
  }

  Widget groupPermissionsWidget() {
    return ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(
          groupsList.length,
          (index) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(groupsList[index].title_en),
            value: all_permissions.contains(offerList[index].id),
            onChanged: (value) {
              if (value) {
                all_permissions.add(groupsList[index].id);
              } else {
                all_permissions.remove(groupsList[index].id);
              }
              setState(() {});
            },
          ),
        ));
  }

  Widget _optionRadioButton<T>({
    String title,
    T value,
    T groupvalue,
    Function onChanged,
    bool isEnabled = true,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Text(title),
      leading: Radio<T>(
        value: value,
        groupValue: groupvalue,
        onChanged: (isEnabled ?? true) ? onChanged : null,
      ),
    );
  }

  Widget titleText({String title}) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18, color: FlavorConfig.values.theme.primaryColor),
    );
  }

  Future<void> filterPermissions(
      List<ConfigurationModel> mainCategories) async {
    generalList = List<ConfigurationModel>.from(
        mainCategories.where((element) => element.type == 'general'));
    requestsList = List<ConfigurationModel>.from(
        mainCategories.where((element) => element.type == 'request'));
    eventsList = List<ConfigurationModel>.from(
        mainCategories.where((element) => element.type == 'events'));
    offerList = List<ConfigurationModel>.from(
        mainCategories.where((element) => element.type == 'offer'));
    if (isNotGroup) {
      groupsList = List<ConfigurationModel>.from(
          mainCategories.where((element) => element.type == 'group'));
    }
    setState(() {});
  }

  Future<void> updateConfigurations() async {
    if (selectedRoleId == 'super_admin' &&
        widget.timebankModel.timebankConfigurations.superAdmin.length !=
            all_permissions) {
      updateQuery();
      widget.timebankModel.timebankConfigurations.superAdmin = all_permissions;
    } else if (selectedRoleId == 'admin' &&
        widget.timebankModel.timebankConfigurations.admin.length !=
            all_permissions) {
      updateQuery();
      widget.timebankModel.timebankConfigurations.admin = all_permissions;
    } else if (widget.timebankModel.timebankConfigurations.member.length !=
        all_permissions) {
      updateQuery();
      widget.timebankModel.timebankConfigurations.member = all_permissions;
    } else {
      //nothing
    }
  }

  Future<void> updateQuery() async {
    await Firestore.instance
        .collection('timebanknew')
        .document(widget.timebankModel.id)
        .updateData({
      'timebankConfigurations.' +
          selectedRoleId.toLowerCase().replaceAll(' ', '_'): all_permissions
    });
  }
}
