//import 'package:flutter/material.dart';
//import 'package:sevaexchange/flavor_config.dart';
//import 'package:sevaexchange/models/user_model.dart';
//import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
//
//class TimebankUserAddedDialogView extends StatelessWidget {
//  final UserAddedModel userAddedModel;
//  final String timeBankId;
//  final String notificationId;
//  final UserModel userModel;
//
//  TimebankUserAddedDialogView(
//      {this.userAddedModel,
//      this.timeBankId,
//      this.notificationId,
//      this.userModel});
//
//  @override
//  Widget build(BuildContext context) {
//    return AlertDialog(
//      shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.all(Radius.circular(25.0))),
//      content: Form(
//        //key: _formKey,
//        child: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            _getCloseButton(context),
//            Container(
//              height: 70,
//              width: 70,
//              child: CircleAvatar(
//                backgroundImage: NetworkImage(userAddedModel.timebankImage),
//              ),
//            ),
//            Padding(
//              padding: EdgeInsets.all(4.0),
//            ),
//            Padding(
//              padding: EdgeInsets.all(4.0),
//              child: Text(
//                "Added to Seva Community",
//                style: TextStyle(
//                  fontSize: 18,
//                  fontWeight: FontWeight.w600,
//                ),
//              ),
//            ),
//            Padding(
//              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
//              child: Text(
//                userAddedModel.timebankName ??
//                    "Seva Community name not updated",
//              ),
//            ),
////              Padding(
////                padding: EdgeInsets.all(0.0),
////                child: Text(
////                  "About ${requestInvitationModel.}",
////                  style: TextStyle(
////                      fontSize: 13, fontWeight: FontWeight.bold),
////                ),
////              ),
//            Padding(
//              padding: EdgeInsets.all(8.0),
//              child: Text(
//                "${userAddedModel.adminName} added you to ${userAddedModel.timebankName} Seva Community",
//                maxLines: 5,
//                overflow: TextOverflow.ellipsis,
//                textAlign: TextAlign.center,
//              ),
//            ),
//
//            Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                Container(
//                  width: double.infinity,
//                  child: RaisedButton(
//                    color: FlavorConfig.values.theme.primaryColor,
//                    child: Text(
//                      'Ok',
//                      style:
//                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
//                    ),
//                    onPressed: () {
//                      Navigator.of(context).pop();
//                    },
//                  ),
//                ),
//              ],
//            )
//          ],
//        ),
//      ),
//    );
//  }
//
//  Widget _getCloseButton(BuildContext context) {
//    return Padding(
//      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//      child: Container(
//        alignment: FractionalOffset.topRight,
//        child: Container(
//          width: 20,
//          height: 20,
//          decoration: BoxDecoration(
//            image: DecorationImage(
//              image: AssetImage(
//                'lib/assets/images/close.png',
//              ),
//            ),
//          ),
//          child: Material(
//            color: Colors.transparent,
//            child: InkWell(
//              onTap: () {
//                Navigator.pop(context);
//              },
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//}
