import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/change_ownership_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';

class ChangeOwnershipDialog extends StatefulWidget {
  final ChangeOwnershipModel changeOwnershipModel;
  final String timeBankId;
  final String notificationId;

  ChangeOwnershipDialog({
    this.changeOwnershipModel,
    this.timeBankId,
    this.notificationId,
  });

  @override
  _ChangeOwnershipDialogViewState createState() =>
      _ChangeOwnershipDialogViewState(
        changeOwnershipModel,
        timeBankId,
        notificationId,
      );
}

class _ChangeOwnershipDialogViewState extends State<ChangeOwnershipDialog> {
  final ChangeOwnershipModel changeOwnershipModel;
  final String timeBankId;
  final String notificationId;

  _ChangeOwnershipDialogViewState(
    this.changeOwnershipModel,
    this.timeBankId,
    this.notificationId,
  );
  List<FocusNode> focusNodes;
  CommunityModel communityModel = CommunityModel({});
  GlobalKey<FormState> _billingInformationKey = GlobalKey();
  BuildContext progressContext;
  var scollContainer = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNodes = List.generate(8, (_) => FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      content: Form(
        //key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getCloseButton(context),
            Container(
              height: 70,
              width: 70,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    changeOwnershipModel.creatorPhotoUrl ??
                        defaultUserImageURL),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                AppLocalizations.of(context)
                    .translate('change_ownership', 'change_ownership_title'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                changeOwnershipModel.timebank ?? "Timebank name not updated",
              ),
            ),
//              Padding(
//                padding: EdgeInsets.all(0.0),
//                child: Text(
//                  "About ${requestInvitationModel.}",
//                  style: TextStyle(
//                      fontSize: 13, fontWeight: FontWeight.bold),
//                ),
//              ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                changeOwnershipModel.message ?? "Description not yet updated",
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                  AppLocalizations.of(context)
                      .translate('change_ownership', 'change_alert'),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    color: FlavorConfig.values.theme.primaryColor,
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('change_ownership', 'accept'),
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      //Once approved
                      _billingBottomsheet(context);
                      // showProgressDialog(context, 'Accepting Invitation');
//                      approveInvitation(
//                        model: changeOwnershipModel,
//                        notificationId: widget.notificationId,
//                      );

//                      if (progressContext != null) {
//                        Navigator.pop(progressContext);
//                      }

                      // Navigator.of(context).pop();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                ),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('notifications', 'decline'),
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      // request declined
                      //   showProgressDialog(context, 'Rejecting Invitation');

                      declineInvitationbRequest(
                        model: changeOwnershipModel,
                        notificationId: widget.notificationId,
                      );

                      if (progressContext != null) {
                        Navigator.pop(progressContext);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  BuildContext dialogContext;

  void showProgressDialog(BuildContext context, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          progressContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(),
          );
        });
  }

  void scrollToTop() {
    scollContainer.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void scrollToBottom() {
    scollContainer.animateTo(
      scollContainer.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void declineInvitationbRequest({
    ChangeOwnershipModel model,
    String notificationId,
  }) {
//    rejectInviteRequest(
//      requestId: model.requestId,
//      rejectedUserId: userModel.sevaUserID,
//      notificationId: notificationId,
//    );
//
//    FirestoreManager.readUserNotification(notificationId, userModel.email);
  }

  void approveInvitation({
    ChangeOwnershipModel model,
    String notificationId,
  }) {
//    FirestoreManager.readUserNotification(notificationId, user.email);
  }
  void _billingBottomsheet(BuildContext mcontext) {
    showModalBottomSheet(
        context: mcontext,
        builder: (BuildContext bc) {
          return Container(
            child: _scrollingList(focusNodes, bc),
          );
        });
  }

  Widget _scrollingList(List<FocusNode> focusNodes, BuildContext bc) {
    print(focusNodes);
    Widget _cityWidget(String city) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (input) {
            // FocusScope.of(bc).requestFocus(focusNodes[0]);
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            print(value);
            communityModel.billing_address.city = value;
          },
          focusNode: focusNodes[0],
          initialValue: city != null ? city : '',
          validator: (value) {
            return value.isEmpty
                ? AppLocalizations.of(context)
                    .translate('createtimebank', 'err_empty')
                : null;
          },
          decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(context)
                  .translate('createtimebank', 'city')),
        ),
      );
    }

    Widget _stateWidget(String state) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (input) {
            // FocusScope.of(bc).requestFocus(focusNodes[1]);
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            communityModel.billing_address.state = value;
          },
          initialValue: state != null ? state : '',
          validator: (value) {
            return value.isEmpty
                ? AppLocalizations.of(context)
                    .translate('createtimebank', 'err_empty')
                : null;
          },
          focusNode: focusNodes[1],
          decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(context)
                  .translate('createtimebank', 'state')),
        ),
      );
    }

    Widget _pinCodeWidget(int pinCode) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (input) {
            // FocusScope.of(bc).requestFocus(focusNodes[3]);
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            print(value);
            communityModel.billing_address.pincode = int.parse(value);
          },
          initialValue: pinCode != null ? pinCode.toString() : '',
          validator: (value) {
            return value.isEmpty
                ? AppLocalizations.of(context)
                    .translate('createtimebank', 'err_empty')
                : null;
          },
          focusNode: focusNodes[3],
          keyboardType: TextInputType.number,
          maxLength: 15,
          decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(context)
                  .translate('createtimebank', 'zip')),
        ),
      );
    }

    Widget _additionalNotesWidget(String notes) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (input) {
            scrollToBottom();
          },
          onChanged: (value) {
            communityModel.billing_address.additionalnotes = value;
          },
          initialValue: notes != null ? notes : '',
          focusNode: focusNodes[7],
          textInputAction: TextInputAction.done,
          decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(context)
                  .translate('createtimebank', 'additional_notes')),
        ),
      );
    }

    Widget _streetAddressWidget(String street_address1) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (input) {
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            communityModel.billing_address.street_address1 = value;
          },
          validator: (value) {
            return value.isEmpty
                ? AppLocalizations.of(context)
                    .translate('createtimebank', 'err_empty')
                : null;
          },
          focusNode: focusNodes[4],
          textInputAction: TextInputAction.done,
          initialValue: street_address1 != null ? street_address1 : '',
          decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(context)
                  .translate('createtimebank', 'street_add1')),
        ),
      );
    }

    Widget _streetAddressTwoWidget(String street_address2) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            onFieldSubmitted: (input) {
              // FocusScope.of(bc).requestFocus(focusNodes[6]);
              FocusScope.of(bc).unfocus();
            },
            onChanged: (value) {
              communityModel.billing_address.street_address2 = value;
            },
            focusNode: focusNodes[5],
            textInputAction: TextInputAction.done,
            initialValue: street_address2 != null ? street_address2 : '',
            decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(context)
                  .translate('createtimebank', 'street_add2'),
            )),
      );
    }

    Widget _countryNameWidget(String country) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (input) {
            // FocusScope.of(bc).requestFocus(focusNodes[2]);
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            communityModel.billing_address.country = value;
          },
          initialValue: country != null ? country : '',
          validator: (value) {
            return value.isEmpty
                ? AppLocalizations.of(context)
                    .translate('createtimebank', 'err_empty')
                : null;
          },
          focusNode: focusNodes[2],
          decoration: getInputDecoration(
            fieldTitle: AppLocalizations.of(context)
                .translate('createtimebank', 'country_name'),
          ),
        ),
      );
    }

    Widget _companyNameWidget(String companyname) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,

          onFieldSubmitted: (input) {
            // FocusScope.of(bc).requestFocus(focusNodes[7]);
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            communityModel.billing_address.companyname = value;
          },
          initialValue: companyname != null ? companyname : '',
          // validator: (value) {
          //   return value.isEmpty ? 'Field cannot be left blank*' : null;
          // },
          focusNode: focusNodes[6],
          textInputAction: TextInputAction.done,
          decoration: getInputDecoration(
            fieldTitle: AppLocalizations.of(context)
                .translate('createtimebank', 'company_name'),
          ),
        ),
      );
    }

    Widget _continueBtn(controller) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(100, 10, 100, 20),
        child: RaisedButton(
          child: Text(
            AppLocalizations.of(context)
                .translate('createtimebank', 'continue'),
            style: Theme.of(bc).primaryTextTheme.button,
          ),
          onPressed: () async {
            FocusScope.of(bc).requestFocus(new FocusNode());
            if (_billingInformationKey.currentState.validate()) {
              if (communityModel.billing_address.country == null) {
                scrollToTop();
              } else {
                print("All Good");
//                showProgressDialog(
//                    bc,
//                    AppLocalizations.of(context)
//                        .translate('createtimebank', 'updating_details'));
//
//                if (progressContext != null) {
//                  Navigator.pop(progressContext);
//                }
                Navigator.pop(context);
                // _pc.close();
                //scrollIsOpen = false;
              }
            }
          },
        ),
      );
    }

    return Container(
      // var scrollController = Sc
      //adding a margin to the top leaves an area where the user can swipe
      //to open/close the sliding panel
      margin: const EdgeInsets.only(top: 15.0),
      color: Colors.white,
      child: Form(
        key: _billingInformationKey,
        child: ListView(
          controller: scollContainer,
          children: <Widget>[
            _billingDetailsTitle,
            _cityWidget(communityModel.billing_address.city),
            _stateWidget(communityModel.billing_address.state),
            _countryNameWidget(communityModel.billing_address.country),
            _pinCodeWidget(communityModel.billing_address.pincode),
            _streetAddressWidget(
                communityModel.billing_address.street_address1),
            _streetAddressTwoWidget(
                communityModel.billing_address.street_address2),
            _companyNameWidget(communityModel.billing_address.companyname),
            _additionalNotesWidget(
                communityModel.billing_address.additionalnotes),
            _continueBtn(communityModel),
          ],
        ),
      ),
    );
  }

  Widget get _billingDetailsTitle {
    return Container(
//        margin: EdgeInsets.fromLTRB(10, 0, 20, 10),
        margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)
                      .translate('createtimebank', 'profile_info_title'),
                  style: TextStyle(
                      color: FlavorConfig.values.theme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    //_pc.close();
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Text(
                      ''' x ''',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/close.png',
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration getInputDecoration({String fieldTitle}) {
    return InputDecoration(
      errorStyle: TextStyle(
        color: Colors.red,
        wordSpacing: 2.0,
      ),
//      focusedBorder: OutlineInputBorder(
//        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
//      ),
//      border: OutlineInputBorder(
//          gapPadding: 0.0, borderRadius: BorderRadius.circular(1.5)),
//      enabledBorder: OutlineInputBorder(
//        borderSide: BorderSide(color: Colors.green, width: 1.0),
//      ),
      hintText: fieldTitle,

      alignLabelWithHint: true,
    );
  }
}
