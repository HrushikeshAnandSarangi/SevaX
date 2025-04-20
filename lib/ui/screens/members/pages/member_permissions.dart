import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/configuration_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/configurations_list.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class MemberPermissions extends StatefulWidget {
  final TimebankModel timebankModel;
  MemberPermissions({required this.timebankModel});

  @override
  _MemberPermissionsState createState() => _MemberPermissionsState();
}

enum Role {
  SUPER_ADMIN,
  ADMIN,
  MEMBER,
}

extension Label on Role {
  String getLabel(BuildContext context) {
    String label = '';
    switch (this) {
      case Role.SUPER_ADMIN:
        label = S.of(context).super_admin;
        break;
      case Role.ADMIN:
        label = S.of(context).admin;
        break;
      case Role.MEMBER:
        label = S.of(context).members;
        break;
    }
    return label;
  }
}

class _MemberPermissionsState extends State<MemberPermissions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Role selectedRole = Role.SUPER_ADMIN;
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
        backgroundColor: Theme.of(context).primaryColor,
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
          S.of(context).manage_permissions,
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
              HideWidget(
                hide: selectedRole == Role.MEMBER,
                child: titleText(
                  title: 'Events Permissions',
                ),
                secondChild: SizedBox.shrink(),
              ),
              HideWidget(
                hide: selectedRole == Role.MEMBER,
                child: eventPermissionsWidget(),
                secondChild: SizedBox.shrink(),
              ),
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
                secondChild: SizedBox.shrink(),
              ),
              groupPermissionsWidget(),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 95,
                  child: CustomElevatedButton(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 3,
                    textColor: Colors.white,
                    onPressed: () {
                      updateConfigurations().then(
                        (value) => Navigator.of(context).pop(),
                      );
                    },
                    child: Text(S.of(context).save),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
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
      children: Role.values
          .map(
            (role) => _optionRadioButton<Role>(
              groupvalue: selectedRole,
              onChanged: (Role? value) {
                if (value == null) return;
                updateConfigurations().then((_) {
                  selectedRole = value;
                  switch (value) {
                    case Role.SUPER_ADMIN:
                      configurationsList = ConfigurationsList().getData();
                      filterPermissions(configurationsList);
                      all_permissions = widget
                          .timebankModel.timebankConfigurations.superAdmin!;
                      break;
                    case Role.ADMIN:
                      configurationsList = ConfigurationsList().getData();
                      filterPermissions(configurationsList);
                      all_permissions =
                          widget.timebankModel.timebankConfigurations.admin!;
                      break;
                    case Role.MEMBER:
                      configurationsList = ConfigurationsList().getMemberData();
                      filterPermissions(configurationsList);
                      all_permissions =
                          widget.timebankModel.timebankConfigurations.member!;
                      break;
                  }
                  setState(() {});
                });
              },
              title: role.getLabel(context),
              value: role,
            ),
          )
          .toList(),
    );
  }

  Widget generalPermissionsWidget() {
    return ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(
          generalList.length,
          (index) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(generalList[index].titleEn),
            value: all_permissions.contains(generalList[index].id),
            onChanged: (value) {
              if (value!) {
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
            title: Text(requestsList[index].titleEn),
            value: all_permissions.contains(requestsList[index].id),
            onChanged: (value) {
              if (value!) {
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
            title: Text(eventsList[index].titleEn),
            value: all_permissions.contains(eventsList[index].id),
            onChanged: (value) {
              if (value!) {
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
            title: Text(offerList[index].titleEn),
            value: all_permissions.contains(offerList[index].id),
            onChanged: (value) {
              if (value!) {
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
            title: Text(groupsList[index].titleEn),
            value: all_permissions.contains(groupsList[index].id),
            onChanged: (value) {
              if (value!) {
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
    required String title,
    required T value,
    required T groupvalue,
    required ValueChanged<T?>? onChanged,
    bool isEnabled = true,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Text(title),
      leading: Radio<T>(
        value: value,
        groupValue: groupvalue,
        onChanged: isEnabled ? onChanged : null,
      ),
    );
  }

  Widget titleText({String? title}) {
    return Text(
      title!,
      style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
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
    updateQuery();
    switch (selectedRole) {
      case Role.SUPER_ADMIN:
        widget.timebankModel.timebankConfigurations.superAdmin =
            all_permissions;
        AppConfig.timebankConfigurations!.superAdmin = all_permissions;
        break;
      case Role.ADMIN:
        widget.timebankModel.timebankConfigurations.admin = all_permissions;
        AppConfig.timebankConfigurations!.admin = all_permissions;
        break;

        break;
      case Role.MEMBER:
        AppConfig.timebankConfigurations!.member = all_permissions;

        widget.timebankModel.timebankConfigurations.member = all_permissions;
    }
  }

  Future<void> updateQuery() async {
    await CollectionRef.timebank.doc(widget.timebankModel.id).update(
      {
        'timebankConfigurations.' +
            selectedRole
                .toString()
                .toLowerCase()
                .split('.')[1]
                .replaceAll(' ', '_'): all_permissions
      },
    );
  }
}
