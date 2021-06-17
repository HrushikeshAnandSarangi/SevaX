import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/views/invitation/TimebankCodeModel.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:share/share.dart';

import '../../flavor_config.dart';

class TimebankCodeWidget extends StatefulWidget {
  final TimebankCodeModel timebankCodeModel;
  final String timebankName;
  final UserModel user;

  TimebankCodeWidget(
      {this.timebankCodeModel, this.timebankName, @required this.user});

  @override
  _TimebankCodeWidgetState createState() => _TimebankCodeWidgetState();
}

class _TimebankCodeWidgetState extends State<TimebankCodeWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 20),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 10),
            ],
          ),
          Container(
            width: 800,
            margin: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 10,
            ),
            child: Card(
              child: Container(
                margin: const EdgeInsets.only(left: 10, bottom: 20, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: headingTitle(
                        S.of(context).copy_and_share_code,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Container(
                        width: 320,
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        // height: 125,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SelectableText(
                                S.of(context).timebank_code +
                                    widget.timebankCodeModel.timebankCode,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                S.of(context).not_yet_redeemed,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                DateTime.now().millisecondsSinceEpoch >
                                        widget.timebankCodeModel.validUpto
                                    ? S.of(context).expired
                                    : S.of(context).active,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Tooltip(
                                    message: S.of(context).copy_community_code,
                                    child: InkWell(
                                      onTap: () {
                                        ClipboardData data = ClipboardData(
                                            text: shareText(
                                          widget.timebankCodeModel,
                                          widget.user.fullname,
                                        ));
                                        Clipboard.setData(data);

                                        SnackBar snackbar = SnackBar(
                                          content: Text(S
                                              .of(context)
                                              .copied_to_clipboard),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar);
                                      },
                                      child: Text(
                                        S.of(context).copy_code,
                                        style: TextStyle(
                                          color: FlavorConfig
                                              .values.theme.primaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                      ),
                                      iconSize: 25,
                                      onPressed: () async {
                                        await deleteShareCode(widget
                                            .timebankCodeModel.timebankCodeId);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                        child: Text(
                      widget.timebankCodeModel.timebankCode,
                      style: TextStyle(fontSize: 36, color: Colors.black54),
                    )),
                    Center(
                      child: CustomElevatedButton(
                        onPressed: () {
                          Share.share(
                            shareText(
                              widget.timebankCodeModel,
                              widget.user.fullname,
                            ),
                          );
                        },
                        color: FlavorConfig.values.theme.primaryColor,
                        textColor: Colors.white,
                        child: Text(S.of(context).share_code),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Center(
                        child: Text(
                      S.of(context).share_code_msg,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    )),
                    SizedBox(
                      width: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String shareText(TimebankCodeModel timebankCode, String name) {
    return '''$name has invited you to join their 
    "${widget.timebankName}" Seva Community. Seva means "selfless service" in Sanskrit.
     Seva Communities are based on a mutual-reciprocity system,
      where community members help each other out in exchange for Seva Credits that can be redeemed for services they need.
       To learn more about being a part of a Seva Community, here's a short explainer video.
        https://youtu.be/xe56UJyQ9ws \n\nHere is what you'll need to know: \nFirst,
         depending on where you click the link from, whether it's your web browser or mobile phone,
          the link will either take you to our main https://www.sevaxapp.com web page where you can register on the web directly or it will take you from your mobile phone to the App or Google Play Stores, 
          where you can download our SevaX App. Once you have registered on the SevaX mobile app or the website,
           you can explore Seva Communities near you. Type in the "${widget.timebankName}" and enter code "${timebankCode.timebankCode}" when prompted.
           \n\nClick to Join $name 
           and their Seva Community via this dynamic link at https://sevaexchange.page.link/sevaxapp.
           \n\nThank you for being a part of our Seva Exchange movement!\n-the Seva Exchange team\n\nPlease email us at support@sevaexchange.com 
           if you have any questions or issues joining with the link given.
    ''';
  }

  Future<void> deleteShareCode(String timebankCodeId) async {
    await CollectionRef.timebankCodes.doc(timebankCodeId).delete();
  }

  Widget headingTitle(String label) {
    return Container(
      height: 25,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}
