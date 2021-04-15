import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/views/invitation/TimebankCodeModel.dart';
import 'package:share/share.dart';
import 'package:sevaexchange/views/core.dart';

import '../../flavor_config.dart';

class TimebankCodeWidget extends StatefulWidget {
  final TimebankCodeModel timebankCodeModel;
  final String timebankName;

  TimebankCodeWidget({this.timebankCodeModel, this.timebankName});

  @override
  _TimebankCodeWidgetState createState() => _TimebankCodeWidgetState();
}

class _TimebankCodeWidgetState extends State<TimebankCodeWidget>{
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
              top: 10,
            ),
            child: Card(
              child: Container(
                margin: const EdgeInsets.only(left: 30, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: headingTitle(
                        'Code Generated: Copy the code and share to your friends',
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Tooltip(
                                    message: "Copy Community Code",
                                    child: InkWell(
                                      onTap: () {


                                          Share.share(shareText(widget.timebankCodeModel));

                                      },
                                      child: Text(
                                        S.of(context).share_code,
                                        style: TextStyle(
                                          color:
                                          FlavorConfig.values.theme.primaryColor,
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
                                      onPressed: ()async {
                                       await deleteShareCode(widget.timebankCodeModel.timebankCodeId);
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
                    SizedBox(height: 30,),
                    Center(child: Text(widget.timebankCodeModel.timebankCode,style: TextStyle(fontSize: 36,color: Colors.black54),)),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(onPressed: (){

                              Share.share(shareText(widget.timebankCodeModel));

                          },color:FlavorConfig.values.theme.primaryColor,textColor:Colors.white,child: Text('Share'),),
                          RaisedButton(onPressed: (){
                              ClipboardData data = ClipboardData(
                                  text: shareText(widget.timebankCodeModel));
                              Clipboard.setData(data);

                              SnackBar snackbar = SnackBar(
                                content: Text("Copied Community Code"),
                              );
                              _scaffoldKey.currentState
                                  .showSnackBar(snackbar);

                          },color:FlavorConfig.values.theme.primaryColor,textColor:Colors.white,child: Text('Copy to clipboard'),)

                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Center(child: Text('You can share the code to invite them to your timebank timebank',style: TextStyle(fontSize: 20,),)),
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
  String shareText(TimebankCodeModel timebankCode) {
    return '''${SevaCore.of(context).loggedInUser.fullname} has invited you to join their 
    "${widget.timebankName}" Seva Community. Seva means "selfless service" in Sanskrit.
     Seva Communities are based on a mutual-reciprocity system,
      where community members help each other out in exchange for Seva Credits that can be redeemed for services they need.
       To learn more about being a part of a Seva Community, here's a short explainer video.
        https://youtu.be/xe56UJyQ9ws \n\nHere is what you'll need to know: \nFirst,
         depending on where you click the link from, whether it's your web browser or mobile phone,
          the link will either take you to our main https://www.sevaxapp.com web page where you can register on the web directly or it will take you from your mobile phone to the App or Google Play Stores, 
          where you can download our SevaX App. Once you have registered on the SevaX mobile app or the website,
           you can explore Seva Communities near you. Type in the "${widget.timebankName}" and enter code "${timebankCode.timebankCode}" when prompted.
           \n\nClick to Join ${SevaCore.of(context).loggedInUser.fullname} 
           and their Seva Community via this dynamic link at https://sevaexchange.page.link/sevaxapp.
           \n\nThank you for being a part of our Seva Exchange movement!\n-the Seva Exchange team\n\nPlease email us at support@sevaexchange.com 
           if you have any questions or issues joining with the link given.
    ''';
  }
  Future<void> deleteShareCode(String timebankCodeId) async{
   await Firestore.instance
        .collection("timebankCodes")
        .document(timebankCodeId)
        .delete();
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
