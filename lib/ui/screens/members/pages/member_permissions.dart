import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/configuaration_model.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class MemberPermissions extends StatefulWidget {
  final TimebankModel timebankModel;

  MemberPermissions({this.timebankModel});

  @override
  _MemberPermissionsState createState() => _MemberPermissionsState();
}

class _MemberPermissionsState extends State<MemberPermissions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String selectedRole = '';
  List<String> roles = [];
  List<String> all_permissions = [];

  List<ConfigurationModel> configurationsList = [];
  List<ConfigurationModel> generalList = [];
  List<ConfigurationModel> requestsList = [];
  List<ConfigurationModel> eventsList = [];
  List<ConfigurationModel> offerList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUp();
  }

  void setUp() {
    Future.delayed(Duration.zero, () {
      FirestoreManager.getAllConfiguarations().then((value) {
        configurationsList = value;
        filterPermissions(value);
      });
      roles = [S.of(context).super_admin, S.of(context).admin, 'Member'];
      // general_permissions = [
      //   'Create Feeds',
      //   'Invite / Invite bulk members',
      //   'Manage Users',
      //   'Manage report feeds',
      //   'Billing Access'
      // ];
      // event_permissions = ['Create Events', 'Manage Events'];
      // request_permissions = [
      //   'Create Time Request',
      //   'Create Money Request',
      //   'Create Goods Request',
      //   'Accept requests',
      //   'Create Borrow Request',
      //   'Personal Requests'
      // ];
      // offer_persmissions = [
      //   'Create Time Offers',
      //   'Create Money Offers',
      //   'Create Goods Offers',
      //   'Accept Offers'
      // ];
      selectedRole = S.of(context).super_admin;
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Manage Permissions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              onPressed: () async {
                updateConfigurations();
                Navigator.of(context).pop();
              }),
        ],
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
              } else if (value == S.of(context).admin) {
                all_permissions =
                    widget.timebankModel.timebankConfigurations.admin ?? [];
              } else {
                all_permissions =
                    widget.timebankModel.timebankConfigurations.superAdmin ??
                        [];
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
    setState(() {});
  }

  Future<void> updateConfigurations() async {
    if (selectedRole == S.of(context).super_admin &&
        widget.timebankModel.timebankConfigurations.superAdmin.length !=
            all_permissions) {
      updateQuery();
      widget.timebankModel.timebankConfigurations.superAdmin = all_permissions;
    } else if (selectedRole == S.of(context).admin &&
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
          selectedRole.toLowerCase().replaceAll(' ', '_'): all_permissions
    });
  }
}
