import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/app_config.dart';

import '../flavor_config.dart';

enum InfoType {
  GROUPS,
  PROJECTS,
  REQUESTS,
  OFFERS,
  PROTECTED_TIMEBANK,
  PRIVATE_TIMEBANK,
  PRIVATE_GROUP,
  TAX_CONFIGURATION,
}

Map<InfoType, String> infoKeyMapper = {
  InfoType.GROUPS: "groupsInfo",
  InfoType.PROJECTS: "projectsInfo",
  InfoType.REQUESTS: "requestsInfo",
  InfoType.OFFERS: "offersInfo",
  InfoType.PROTECTED_TIMEBANK: "protectedTimebankInfo",
  InfoType.PRIVATE_TIMEBANK: "privateTimebankInfo",
  InfoType.PRIVATE_GROUP: "privateGroupInfo",
  InfoType.TAX_CONFIGURATION: "taxInfo",
};

Map<InfoType, String> infoDescriptionMapper = {
  InfoType.GROUPS:
      'A Timebank (or Community) is divided into Groups. For example, a School Community would have Groups for Technology Committee, Fund Raising, Classroom, etc.',
  InfoType.PROJECTS:
      'Projects are logical collections under a Group. For example, the Technology Committee Group can have the following Projects: School web page, Equipment, Apps, etc.',
  InfoType.REQUESTS:
      'Requests are either created by Time Admins - for community tasks that need to be performed (eg. Weed the school yard) , or by Users who need help from the community for things they need to be done (eg. seniors needing groceries delivered). Requests for a Timebank would be listed under a Project.',
  InfoType.OFFERS:
      'Users can either make Offers to the Timebank (eg. I can build HTML pages on Saturday mornings from 9 to 11 am) or to the other members in the Community (eg. I can teach a 4-week class on Making Quilts on Sunday afternoons from 2 to 4 pm). The offers to the Timebank needs to be accepted by an Admin. At this time the Offer gets converted to a Request.',
  InfoType.PROTECTED_TIMEBANK:
      'Check this box if you want to disable user-to-user transactions. That is, “Requests” can only be originated by the designated Admins of this Timebank. Typically, Protected Timebanks are used for Political Campaigns and certain Nonprofit Organizations',
  InfoType.PRIVATE_TIMEBANK:
      'Check this box if you would like your Timebank not to be discovered by anyone browsing - either by the name of the Timebank or the location of the Timebank. Note that everyone always needs a code to join your Timebank. A “Private Timebank” provides an additional level of privacy.',
  InfoType.PRIVATE_GROUP:
      'Check this box if you want to create a Private Group.  That is, users cannot find this Private Group (from the Explore tab) and request to join. They need to be explicitly invited by one of the admins of the Group. Activity within Private Groups are not displayed in Search results.',
  InfoType.TAX_CONFIGURATION:
      'At the time that a user is credited Seva Credits for completing a request (for the Timebank), the Timebank Admin can specify a Tax - which is credited to the Timebank. Slide the ruler to specify the amount of the Tax.',
};

Widget infoButton({
  @required BuildContext context,
  @required GlobalKey key,
  @required InfoType type,
}) {
  assert(context != null);
  assert(key != null);
  assert(type != null);
  Map<String, dynamic> details =
      json.decode(AppConfig.remoteConfig.getString('i_button_info'));
  return IconButton(
    key: key,
    icon: Image.asset(
      'lib/assets/images/info.png',
      color: FlavorConfig.values.theme.primaryColor,
      height: 16,
      width: 16,
    ),
    onPressed: () {
      RenderBox renderBox = key.currentContext.findRenderObject();
      Size buttonSize = renderBox.size;
      Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
      print(
          "$buttonSize   $buttonPosition ${MediaQuery.of(context).size.height}");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          bool _isDialogBottom = buttonPosition.dy >
              (MediaQuery.of(context).size.height / 2) + 100;
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned(
                top: _isDialogBottom ? null : (buttonPosition.dy - 30),
                bottom: _isDialogBottom
                    ? MediaQuery.of(context).size.height -
                        buttonPosition.dy -
                        45
                    : null,
                left: buttonPosition.dx + 8,
                child: ClipPath(
                  clipper:
                      _isDialogBottom ? ReverseArrowClipper() : ArrowClipper(),
                  child: Container(
                    height: 60,
                    width: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: _isDialogBottom ? null : (buttonPosition.dy + 20),
                bottom: _isDialogBottom
                    ? MediaQuery.of(context).size.height - buttonPosition.dy
                    : null,
                left: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            details[infoKeyMapper[type]] ??
                                infoDescriptionMapper[key],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ReverseArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height / 2);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
