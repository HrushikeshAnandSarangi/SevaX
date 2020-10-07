import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/workshop/approvedUsers.dart';

class RequestCardView extends StatefulWidget {
  final RequestModel requestItem;

  RequestCardView({
    Key key,
    @required this.requestItem,
  }) : super(key: key);

  @override
  _RequestCardViewState createState() => _RequestCardViewState();
}

class _RequestCardViewState extends State<RequestCardView> {
  void _acceptRequest() {
    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.add(SevaCore.of(context).loggedInUser.email);
    widget.requestItem.acceptors = acceptorList.toList();
    FirestoreManager.acceptRequest(
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }

  void _withdrawRequest() {
    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.remove(SevaCore.of(context).loggedInUser.email);
    widget.requestItem.acceptors = acceptorList.toList();
    FirestoreManager.acceptRequest(
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      isWithdrawal: true,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          widget.requestItem.sevaUserId ==
                  SevaCore.of(context).loggedInUser.sevaUserID
              ? IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditRequest(
                          timebankId:
                              SevaCore.of(context).loggedInUser.currentTimebank,
                          requestModel: widget.requestItem,
                        ),
                      ),
                    );
                  },
                )
              : Offstage(),
          widget.requestItem.sevaUserId ==
                      SevaCore.of(context).loggedInUser.sevaUserID &&
                  widget.requestItem.acceptors.length == 0
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext viewcontext) {
                        return AlertDialog(
                          title: Text(S
                              .of(context)
                              .request_delete_confirmation_message),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(
                                S.of(context).no,
                                style: TextStyle(
                                  fontSize: dialogButtonSize,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(viewcontext);
                              },
                            ),
                            FlatButton(
                              child: Text(
                                S.of(context).yes,
                                style: TextStyle(
                                  fontSize: dialogButtonSize,
                                ),
                              ),
                              onPressed: () {
                                deleteRequest(requestModel: widget.requestItem);
                                Navigator.pop(viewcontext);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              : Offstage()
        ],
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.requestItem.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Object>(
          future: FirestoreManager.getUserForId(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                S.of(context).general_stream_error,
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            UserModel userModel = snapshot.data;
            String usertimezone = userModel.timezone;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    color: widget.requestItem.color,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            widget.requestItem.title,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: RichTextView(
                              text: widget.requestItem.description),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            '${S.of(context).from}:  ' +
                                DateFormat(
                                  'MMMM dd, yyyy @ h:mm a',
                                  Locale(AppConfig.prefs
                                          .getString('language_code'))
                                      .toLanguageTag(),
                                ).format(
                                  getDateTimeAccToUserTimezone(
                                      dateTime:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              widget.requestItem.requestStart),
                                      timezoneAbb: usertimezone),
                                ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            '${S.of(context).until}:  ' +
                                DateFormat(
                                        'MMMM dd, yyyy @ h:mm a',
                                        Locale(AppConfig.prefs
                                                .getString('language_code'))
                                            .toLanguageTag())
                                    .format(
                                  getDateTimeAccToUserTimezone(
                                      dateTime:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              widget.requestItem.requestEnd),
                                      timezoneAbb: usertimezone),
                                ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text('${S.of(context).posted_by}:' +
                              widget.requestItem.fullName),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            '${S.of(context).posted_date}:  ' +
                                DateFormat(
                                        'MMMM dd, yyyy @ h:mm a',
                                        Locale(AppConfig.prefs
                                                .getString('language_code'))
                                            .toLanguageTag())
                                    .format(
                                  getDateTimeAccToUserTimezone(
                                      dateTime:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              widget.requestItem.postTimestamp),
                                      timezoneAbb: usertimezone),
                                ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            '${S.of(context).number_of_volunteers_required} ' +
                                '${widget.requestItem.numberOfApprovals}',
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(' '),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            onPressed: widget.requestItem.sevaUserId ==
                                    SevaCore.of(context).loggedInUser.sevaUserID
                                ? null
                                : () {
                                    widget.requestItem.acceptors.contains(
                                            SevaCore.of(context)
                                                .loggedInUser
                                                .email)
                                        ? _withdrawRequest()
                                        : _acceptRequest();
                                    Navigator.pop(context);
                                  },
                            child: Text(
                              widget.requestItem.acceptors.contains(
                                      SevaCore.of(context).loggedInUser.email)
                                  ? S.of(context).withdraw +
                                      ' ' +
                                      S.of(context).request
                                  : S.of(context).accept +
                                      ' ' +
                                      S.of(context).request,
                              style: TextStyle(
                                color: FlavorConfig.values.buttonTextColor,
                              ),
                            ),
                          ),
                        ),
                        widget.requestItem.sevaUserId !=
                                SevaCore.of(context).loggedInUser.sevaUserID
                            ? Offstage()
                            : Container(
                                padding: EdgeInsets.all(8.0),
                                child: RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  onPressed: widget.requestItem.approvedUsers
                                              .length <
                                          1
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        RequestStatusView(
                                                          requestId: widget
                                                              .requestItem.id,
                                                        ),
                                                fullscreenDialog: true),
                                          );
                                        },
                                  child: Text(
                                    widget.requestItem.approvedUsers.length < 1
                                        ? S.of(context).no_approved_members
                                        : S.of(context).view_approved_members,
                                    style: TextStyle(
                                      color:
                                          FlavorConfig.values.buttonTextColor,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Future<void> deleteRequest({
    @required RequestModel requestModel,
  }) async {
    return await Firestore.instance
        .collection('requests')
        .document(requestModel.id)
        .delete();
  }
}
