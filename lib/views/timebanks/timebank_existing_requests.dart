import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../flavor_config.dart';
import '../core.dart';

class TimeBankExistingRequests extends StatefulWidget {
  final String? timebankId;
  final UserModel? userModel;
  final bool? isAdmin;

  TimeBankExistingRequests(
      {Key? key, this.timebankId, this.isAdmin, this.userModel});

  @override
  _TimeBankExistingRequestsState createState() =>
      _TimeBankExistingRequestsState();
}

class _TimeBankExistingRequestsState extends State<TimeBankExistingRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<RequestModel>>(
        stream: FirestoreManager.getTimebankExistingRequestListStream(
            timebankId: widget.timebankId!),
        builder: (BuildContext context,
            AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
          if (requestListSnapshot.hasError) {
            return Text('Error: ${requestListSnapshot.error}');
          }
          switch (requestListSnapshot.connectionState) {
            case ConnectionState.waiting:
              return LoadingIndicator();
            default:
              List<RequestModel> requestModelList = requestListSnapshot.data!;
              requestModelList = filterRequests(
                  context: context, requestModelList: requestModelList);
              requestModelList = filterBlockedRequestsContent(
                  context: context, requestModelList: requestModelList);

              if (requestModelList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text(S.of(context).no_requests)),
                );
              }
              var consolidatedList =
                  GroupRequestCommons.groupAndConsolidateRequests(
                      requestModelList,
                      SevaCore.of(context).loggedInUser.sevaUserID!);
              return formatListFrom(consolidatedList: consolidatedList);
          }
        },
      ),
    );
  }

  List<RequestModel> filterRequests({
    List<RequestModel>? requestModelList,
    BuildContext? context,
  }) {
    List<RequestModel> filteredList = [];

    requestModelList!.forEach((request) =>
        request.requestEnd! > DateTime.now().millisecondsSinceEpoch
            ? filteredList.add(request)
            : S.of(context!).filtering_past_requests_content);

    return filteredList;
  }

  List<RequestModel> filterBlockedRequestsContent({
    List<RequestModel>? requestModelList,
    BuildContext? context,
  }) {
    List<RequestModel> filteredList = [];

    requestModelList!.forEach((request) => SevaCore.of(context!)
                .loggedInUser
                .blockedMembers!
                .contains(request.sevaUserId) ||
            SevaCore.of(context)
                .loggedInUser
                .blockedBy!
                .contains(request.sevaUserId)
        ? S.of(context).filtering_blocked_content
        : filteredList.add(request));

    return filteredList;
  }

  Widget formatListFrom(
      {List<RequestModelList>? consolidatedList,
      String? loggedintimezone,
      String? userEmail}) {
    return Container(
        child: ListView.builder(
      shrinkWrap: true,
      itemCount: consolidatedList!.length + 1,
      itemBuilder: (context, index) {
        if (index >= consolidatedList.length) {
          return Container(
            width: double.infinity,
            height: 65,
          );
        }
        return getRequestView(
          consolidatedList[index],
          loggedintimezone!,
          userEmail!,
        );
      },
    ));
  }

  Widget getRequestView(
      RequestModelList model, String loggedintimezone, String userEmail) {
    return FutureBuilder<TimebankModel>(
        future: utils
            .getTimeBankForId(timebankId: widget.timebankId!)
            .then((value) {
          if (value == null) {
            throw Exception('TimebankModel is null');
          }
          return value;
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (model.getType()) {
              case RequestModelList.TITLE:
                var isMyContent =
                    (model as GroupTitle).groupTitle!.contains("My");

                return Container(
                  height: !isMyContent ? 18 : 0,
                  margin: !isMyContent ? EdgeInsets.all(12) : EdgeInsets.all(0),
                  child: Text(
                    GroupRequestCommons.getGroupTitle(
                      groupKey: (model as GroupTitle).groupTitle,
                      context: context,
                      isGroup: isPrimaryTimebank(
                        parentTimebankId: snapshot.data!.parentTimebankId,
                      ),
                    ),
                  ),
                );

              case RequestModelList.REQUEST:
                return getRequestListViewHolder(
                  model: (model as RequestItem).requestModel,
                  loggedintimezone: loggedintimezone,
                  userEmail: userEmail,
                );

              default:
                return Text(S.of(context).default_text);
            }
          } else {
            return Container();
          }
        });
  }

  Widget getRequestListViewHolder(
      {RequestModel? model, String? loggedintimezone, String? userEmail}) {
    return Container(
      decoration: containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: () {
            if (model!.acceptors!.contains(widget.userModel!.email) ||
                model.approvedUsers!.contains(widget.userModel!.email) ||
                model.invitedUsers!.contains(widget.userModel!.sevaUserID)) {
              showDialog(
                context: context,
                builder: (BuildContext viewContextS) {
                  // return object of type Dialog
                  return AlertDialog(
                    title: Text(S.of(context).already_exists),
                    content: Text(
                        '${widget.userModel!.fullname} ${S.of(context).already_added}'),
                    actions: <Widget>[
                      CustomTextButton(
                        child: Text(
                          S.of(context).ok,
                          style: TextStyle(
                            fontSize: dialogButtonSize,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(viewContextS).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext viewContext) {
                  // return object of type Dialog
                  return AlertDialog(
                    title: Text(S.of(context).add_to_request),
                    content: Text(
                        '${S.of(context).are_you_sure} add ${widget.userModel!.fullname} to ${S.of(context).request}'),
                    actions: <Widget>[
                      CustomTextButton(
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        color: Theme.of(context).colorScheme.secondary,
                        textColor: FlavorConfig.values.buttonTextColor,
                        child: Text(
                          S.of(context).add,
                          style: TextStyle(
                            fontSize: dialogButtonSize,
                          ),
                        ),
                        onPressed: () async {
                          await timeBankBloc.updateInvitedUsersForRequest(
                            model.id,
                            widget.userModel!.sevaUserID,
                            widget.userModel!.email,
                          );

                          var timebankModel = await utils.getTimeBankForId(
                              timebankId: widget.timebankId!);

                          sendNotification(
                            requestModel: model,
                            userModel: widget.userModel!,
                            timebankModel: timebankModel,
                            currentCommunity: model.communityId!,
                            sevaUserID:
                                SevaCore.of(context).loggedInUser.sevaUserID!,
                          );
                          Navigator.of(viewContext).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                      CustomTextButton(
                        child: Text(
                          S.of(context).cancel,
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          Navigator.of(viewContext).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipOval(
                  child: SizedBox(
                    height: 45,
                    width: 45,
                    child: FadeInImage.assetNetwork(
                      placeholder: defaultUserImageURL,
                      //  placeholder: 'lib/assets/images/profile.png',
                      image: model!.photoUrl == null
                          ? defaultUserImageURL
                          : model.photoUrl!,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        model.title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          model.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            getTimeFormattedString(
                                model.requestStart!, loggedintimezone!),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.arrow_forward, size: 14),
                          SizedBox(width: 4),
                          Text(
                            getTimeFormattedString(
                              model.requestEnd!,
                              loggedintimezone,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          model.acceptors!.contains(userEmail) ||
                                  model.approvedUsers!.contains(userEmail)
                              ?
//                          || model.invitedUsers.contains(userEmail) ?
                              Container(
                                  margin: EdgeInsets.all(10),
                                  width: 100,
                                  height: 32,
                                  child: CustomTextButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.all(0),
                                    color: Colors.green,
                                    child: Text(
                                      S.of(context).applied,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {},
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getTimeFormattedString(int timeInMilliseconds, String timezoneAbb) {
    DateFormat dateFormat =
        DateFormat('d MMM hh:mm a ', Locale(getLangTag()).toLanguageTag());
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    DateTime localtime = getDateTimeAccToUserTimezone(
        dateTime: datetime, timezoneAbb: timezoneAbb);
    String from = dateFormat.format(
      localtime,
    );
    return from;
  }

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(2),
          spreadRadius: 6,
          offset: Offset(0, 3),
          blurRadius: 6,
        )
      ],
      color: Colors.white,
    );
  }

  Future<void> sendNotification({
    RequestModel? requestModel,
    UserModel? userModel,
    String? currentCommunity,
    String? sevaUserID,
    TimebankModel? timebankModel,
  }) async {
    RequestInvitationModel requestInvitationModel = RequestInvitationModel(
      requestModel: requestModel,
      timebankModel: timebankModel,
    );

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: FlavorConfig.values.timebankId,
        data: requestInvitationModel.toMap(),
        isRead: false,
        type: NotificationType.RequestInvite,
        communityId: currentCommunity,
        senderUserId: sevaUserID,
        targetUserId: userModel!.sevaUserID!);

    await CollectionRef.users
        .doc(userModel.email)
        .collection("notifications")
        .doc(notification.id)
        .set(notification.toMap());
  }

  BoxDecoration get containerDecorationR {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(2),
            spreadRadius: 6,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: Colors.white,
    );
  }
}
