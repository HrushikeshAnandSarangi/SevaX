import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
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
  MAX_CREDITS,
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
  InfoType.MAX_CREDITS: "maxCredit",
};

Widget infoButton({
  @required BuildContext context,
  @required GlobalKey key,
  @required InfoType type,
}) {
  assert(context != null);
  assert(key != null);
  assert(type != null);
  var temp = AppLocalizations.of(context).translate('info_window', 'mapper');
  Map<String, dynamic> details =
      json.decode(AppConfig.remoteConfig.getString(temp));
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
      showDialog(
        context: context,
        builder: (BuildContext _context) {
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
                            details[infoKeyMapper[type]],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            child: Text(AppLocalizations.of(context)
                                .translate('notifications', 'ok')),
                            onPressed: () {
                              Navigator.of(_context).pop();
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
