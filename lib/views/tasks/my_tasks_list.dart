import 'dart:async';
import 'dart:math';

import 'package:doseform/doseform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/request/pages/oneToManySpeakerTimeEntryComplete_page.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/to_do.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/tasks_card_wrapper.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/tasks/completed_list.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:shimmer/shimmer.dart';

import '../../flavor_config.dart';
import 'completed_list.dart';
import 'notAccepted_tasks.dart';

class MyTaskPage extends StatefulWidget {
  final TabController controller;

  MyTaskPage(this.controller);

  @override
  MyTaskPageState createState() => MyTaskPageState();
}

class MyTaskPageState extends State<MyTaskPage> {
  @override
  Widget build(BuildContext context) {
    UserModel model = SevaCore.of(context).loggedInUser;
    ;
    return TabBarView(
      controller: widget.controller,
      children: [
        MyTaskList(
          email: model.email,
          sevaUserId: model.sevaUserID,
        ),
        NotAcceptedTaskList(),
        CompletedList()
      ],
    );
  }
}

class MyTaskList extends StatefulWidget {
  final String email;
  final String sevaUserId;

  MyTaskList({this.email, this.sevaUserId});

  @override
  State<StatefulWidget> createState() => MyTasksListState();
}

class MyTasksListState extends State<MyTaskList> {
  final subjectBorrow = ReplaySubject<int>();

  RequestModel requestModelNew;
  Stream<dynamic> myTasksStream;

  List<TasksCardWrapper> toDoItems = [];

  @override
  void initState() {
    super.initState();
    myTasksStream = ToDo.getToDoList(widget.email, widget.sevaUserId);
    subjectBorrow
        .transform(ThrottleStreamTransformer((_) => TimerStream(true, const Duration(seconds: 1))))
        .listen((data) {
      logger.e('COMES BACK HERE 1');
      checkForReviewBorrowRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: myTasksStream,
      builder: (streamContext, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: LoadingIndicator(),
          );
        }

        toDoItems = ToDo.classifyToDos(
            context: context,
            toDoSink: snapshot.data,
            requestCallback: (requestModel) {
              requestModelNew = requestModel;
            },
            feedbackCallback: (int value) {
              subjectBorrow.add(value);
            },
            email: widget.email);

        if (toDoItems.length == 0)
          return Center(
            child: Text(
              'No To Do\'s',
            ),
          );

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: toDoItems.length,
          itemBuilder: (listContext, index) {
            return toDoItems[index];
          },
        );
      },
    );
  }

  void checkForReviewBorrowRequests() async {
    logger.e('COMES BACK HERE 2');

    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return BorrowRequestFeedBackView(requestModel: requestModelNew);
        },
      ),
    );

    if (results != null && results.containsKey('selection')) {
      showProgressForCreditRetrieval();
      onActivityResult(results, SevaCore.of(context).loggedInUser);
    } else {}
  }

  Future<void> onActivityResult(Map results, UserModel loggedInUser) async {
    // adds review to firestore
    try {
      logger.i('here 1');
      await CollectionRef.reviews.add({
        "reviewer": SevaCore.of(context).loggedInUser.email,
        "reviewed": requestModelNew.email,
        "ratings": results['selection'],
        "device_info": results['device_info'],
        "requestId": requestModelNew.id,
        "comments": (results['didComment'] ? results['comment'] : "No comments"),
        "liveMode": !AppConfig.isTestCommunity,
      });
      logger.i('here 2');
      await sendMessageToMember(
          message: results['didComment'] ? results['comment'] : "No comments",
          loggedInUser: loggedInUser);
      logger.i('here 3');
      startTransaction();
    } on Exception catch (e) {
      // TODO
    }
  }

  Future<void> sendMessageToMember({
    UserModel loggedInUser,
    String message,
  }) async {
    TimebankModel timebankModel = await getTimeBankForId(timebankId: requestModelNew.timebankId);
    UserModel userModel =
        await FirestoreManager.getUserForId(sevaUserId: requestModelNew.sevaUserId);
    if (userModel != null && timebankModel != null) {
      ParticipantInfo receiver = ParticipantInfo(
        id: requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
            ? userModel.sevaUserID
            : requestModelNew.timebankId,
        photoUrl: requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
            ? userModel.photoURL
            : timebankModel.photoUrl,
        name: requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
            ? userModel.fullname
            : timebankModel.name,
        type: requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
            ? ChatType.TYPE_PERSONAL
            : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                ? ChatType.TYPE_TIMEBANK
                : ChatType.TYPE_GROUP,
      );

      ParticipantInfo sender = ParticipantInfo(
        id: loggedInUser.sevaUserID,
        photoUrl: loggedInUser.photoURL,
        name: loggedInUser.fullname,
        type: requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
            ? ChatType.TYPE_PERSONAL
            : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                ? ChatType.TYPE_TIMEBANK
                : ChatType.TYPE_GROUP,
      );
      await sendBackgroundMessage(
          messageContent: utils.getReviewMessage(
            requestTitle: requestModelNew.title,
            context: context,
            userName: loggedInUser.fullname,
            isForCreator: true,
            reviewMessage: message,
          ),
          reciever: receiver,
          isTimebankMessage:
              requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST ? false : true,
          timebankId: requestModelNew.timebankId,
          communityId: loggedInUser.currentCommunity,
          sender: sender);
    }
  }

  void startTransaction() async {
    // TODO needs flow correction to tasks model (currently reliying on requests collection for changes which will be huge instead tasks have to be individual to users)
    // logger.e('comes here 1');

    //doing below since in RequestModel if != null nothing happens
    //so manually removing user from task
    requestModelNew.approvedUsers = [];
    requestModelNew.acceptors = [];

    if (requestModelNew.requestType == RequestType.BORROW) {
      if (SevaCore.of(context).loggedInUser.sevaUserID == requestModelNew.sevaUserId) {
        requestModelNew.borrowerReviewed = true;
      } else {
        requestModelNew.lenderReviewed = true;
      }
    }

    FirestoreManager.requestComplete(model: requestModelNew);

    FirestoreManager.createTaskCompletedNotification(
      model: NotificationsModel(
        id: utils.Utils.getUuid(),
        data: requestModelNew.toMap(),
        type: NotificationType.RequestCompleted,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: requestModelNew.sevaUserId,
        communityId: requestModelNew.communityId,
        timebankId: requestModelNew.timebankId,
        isTimebankNotification: requestModelNew.requestMode == RequestMode.TIMEBANK_REQUEST,
        isRead: false,
      ),
    );

    Navigator.of(creditRequestDialogContext).pop();
    //Navigator.of(context).pop();
  }

  BuildContext creditRequestDialogContext;

  void showProgressForCreditRetrieval() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          creditRequestDialogContext = context;
          return AlertDialog(
            title: Text(S.of(context).please_wait),
            content: LinearProgressIndicator(
 backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
),
          );
        });
  }

  Widget getOneToManyTaskWidget(
    RequestModel model,
    String userTimezone,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          shadows: shadowList,
        ),
        child: InkWell(
          onTap: () {
            return null;
          },
          child: ListTile(
            title: Text(
              model.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(model.fullName),
                // SizedBox(height: 4),
                // Text(
                //   timeAgo.format(
                //     DateTime.fromMillisecondsSinceEpoch(
                //       model.requestStart,
                //     ),
                //     locale: S.of(context).localeName == 'sn'
                //         ? 'en'
                //         : S.of(context).localeName,
                //   ),
                // ),
                SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  //runAlignment: WrapAlignment.center,
                  spacing: 8,
                  children: <Widget>[
                    model.isSpeakerCompleted
                        ? Text(S.of(context).requested_for_completion)
                        : Container(
                            height: 35,
                            child: CustomElevatedButton(
                              padding: EdgeInsets.zero,
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                S.of(context).speaker_claim_credits,
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'Europa', fontSize: 12),
                              ),
                              onPressed: () async {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return OneToManySpeakerTimeEntryComplete(
                                        requestModel: model,
                                        onFinish: () async {
                                          await oneToManySpeakerCompletesRequest(context, model);
                                        },
                                        isFromtasks: true,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                    SizedBox(height: 4),
                  ],
                ),
                SizedBox(height: 5),
              ],
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(model.photoUrl ?? defaultUserImageURL),
            ),
            onTap: () {
              return null;
            },
          ),
        ),
      ),
    );
  }

  String getTime(int timeInMilliseconds, String timezoneAbb) {
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    DateTime localtime = getDateTimeAccToUserTimezone(dateTime: datetime, timezoneAbb: timezoneAbb);
    String from = DateFormat.jm().format(
      localtime,
    );
    return from;
  }

  String getTimeFormattedString(int timeInMilliseconds, String timezoneAbb) {
    DateFormat dateFormat = DateFormat('d MMM hh:mm a ', Locale(getLangTag()).toLanguageTag());
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    DateTime localtime = getDateTimeAccToUserTimezone(dateTime: datetime, timezoneAbb: timezoneAbb);
    String from = dateFormat.format(
      localtime,
    );
    return from;
  }

  Widget get taskShimmer {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white.withAlpha(80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: ListTile(
            title: Container(height: 10, color: Colors.white),
            subtitle: Container(height: 10, color: Colors.white),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
        ),
        baseColor: Colors.black.withAlpha(50),
        highlightColor: Colors.white.withAlpha(50),
      ),
    );
  }

  List<BoxShadow> get shadowList => [shadow];

  BoxShadow get shadow {
    return BoxShadow(
      color: Colors.black.withAlpha(10),
      spreadRadius: 2,
      blurRadius: 3,
    );
  }

  String _getPostItColor(RequestModel model) {
    final _random = Random();
    int next(int min, int max) => min + _random.nextInt(max - min);

    switch (next(1, 4)) {
      case 1:
        model.color = Color.fromRGBO(237, 230, 110, 1.0);
        return 'lib/assets/images/yellow.png';
        break;
      case 2:
        model.color = Color.fromRGBO(170, 204, 105, 1.0);
        return 'lib/assets/images/green.png';
        break;
      case 3:
        model.color = Color.fromRGBO(112, 198, 233, 1.0);
        return 'lib/assets/images/blue.png';
        break;
      case 4:
        model.color = Color.fromRGBO(213, 106, 162, 1.0);
        return 'lib/assets/images/pink.png';
        break;
      case 5:
        model.color = Color.fromRGBO(160, 107, 166, 1.0);
        return 'lib/assets/images/violet.png';
        break;
      default:
        model.color = Color.fromRGBO(237, 230, 110, 1.0);
        return 'lib/assets/images/yellow.png';
    }
  }

  Future oneToManySpeakerCompletesRequest(BuildContext context, RequestModel requestModel) async {
    NotificationsModel notificationModel = NotificationsModel(
        timebankId: requestModel.timebankId,
        targetUserId: requestModel.sevaUserId,
        data: requestModel.toMap(),
        type: NotificationType.OneToManyRequestCompleted,
        id: utils.Utils.getUuid(),
        isRead: false,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        communityId: requestModel.communityId,
        isTimebankNotification: true);

    await CollectionRef.timebank
        .doc(notificationModel.timebankId)
        .collection('notifications')
        .doc(notificationModel.id)
        .set(notificationModel.toMap());

    await CollectionRef.requests.doc(requestModel.id).update({
      'isSpeakerCompleted': true,
    });

    await FirestoreManager.readUserNotificationOneToManyWhenSpeakerIsRejectedCompletion(
        requestModel: requestModel,
        userEmail: SevaCore.of(context).loggedInUser.email,
        fromNotification: false);
  }
}

class TaskCardView extends StatefulWidget {
  final RequestModel requestModel;
  final String userTimezone;

  // TODO needs flow correction to tasks model
  TaskCardView({@required this.requestModel, this.userTimezone});

  @override
  TaskCardViewState createState() => TaskCardViewState();
}

class TaskCardViewState extends State<TaskCardView> {
  String selectedMinuteValue = "0";
  String selectedHourValue;

//One To Many Request Variables
  String selectedMinutesPrepTime = "0";
  String selectedHoursPrepTime;
  String selectedMinutesDeliveryTime = "0";
  String selectedHoursDeliveryTime;

  RequestModel requestModel;
  final subject = ReplaySubject<int>();

  @override
  void initState() {
    super.initState();
    this.requestModel = widget.requestModel;
    subject
        .transform(ThrottleStreamTransformer((_) => TimerStream(true, const Duration(seconds: 1))))
        .listen((data) {
      checkForReview();
    });
  }

  final _formKey = GlobalKey<DoseFormState>();

  TextEditingController hoursController = TextEditingController();
  TextEditingController selectedHoursPrepTimeController = TextEditingController();
  TextEditingController selectedHoursDeliveryTimeController = TextEditingController();
  List<FocusNode> focusNodeList = List.generate(3, (_) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          requestModel.title,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Container(
                padding: EdgeInsets.all(10.0),
                color: requestModel.color,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment(-1.0, 0.0),
                      child: Text(
                        requestModel.title,
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: RichTextView(text: requestModel.description),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment(-1.0, 0.0),
                      child: Text(
                        '${S.of(context).from}  ' +
                            DateFormat(
                                    'MMMM dd, yyyy @ h:mm a',
                                    Locale(AppConfig.prefs.getString('language_code'))
                                        .toLanguageTag())
                                .format(
                              getDateTimeAccToUserTimezone(
                                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                                      requestModel.requestStart),
                                  timezoneAbb: widget.userTimezone),
                            ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment(-1.0, 0.0),
                      child: Text(
                        '${S.of(context).until}  ' +
                            DateFormat(
                                    'MMMM dd, yyyy @ h:mm a',
                                    Locale(AppConfig.prefs.getString('language_code'))
                                        .toLanguageTag())
                                .format(
                              getDateTimeAccToUserTimezone(
                                  dateTime:
                                      DateTime.fromMillisecondsSinceEpoch(requestModel.requestEnd),
                                  timezoneAbb: widget.userTimezone),
                            ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment(-1.0, 0.0),
                      child: Text('${S.of(context).posted_by} ' + requestModel.fullName),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment(-1.0, 0.0),
                      child: Text(
                        '${S.of(context).posted_date}  ' +
                            DateFormat(
                                    'MMMM dd, yyyy @ h:mm a',
                                    Locale(AppConfig.prefs.getString('language_code'))
                                        .toLanguageTag())
                                .format(
                              getDateTimeAccToUserTimezone(
                                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                                      requestModel.postTimestamp),
                                  timezoneAbb: widget.userTimezone),
                            ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(' '),
                    ),
                    (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
                            requestModel.selectedInstructor.sevaUserID ==
                                SevaCore.of(context).loggedInUser.sevaUserID)
                        ? DoseForm(
                      formKey: _formKey,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      S.of(context).enter_prep_time,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          DoseTextField(
                                            controller: selectedHoursPrepTimeController,
                                            currentNode: focusNodeList[0],
                                            keyboardType: TextInputType.number,
                                            formatters: [
                                              BlacklistingTextInputFormatter(
                                                RegExp('[\\.|\\,|\\ |\\-]'),
                                              ),
                                            ],
                                            decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(bottom: 20)),
                                            validator: (value) {
                                              if (value == null) {
                                                return S.of(context).enter_hours;
                                              }
                                              if (value.isEmpty) {
                                                S.of(context).select_hours;
                                              }
                                              this.selectedHoursPrepTime = value;
                                              return null;
                                            },
                                          ),
                                          Text(S.of(context).hours),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 48,
                                      ),
                                      child: Text(
                                        ' : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          DropdownButtonFormField<String>(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return S.of(context).validation_error_invalid_hours;
                                              }

                                              selectedMinutesPrepTime = value;
                                              return null;
                                            },
                                            items: minuteList.map((value) {
                                              return DropdownMenuItem(
                                                  child: Text(value), value: value);
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedMinutesPrepTime = value;
                                              });
                                            },
                                            value: selectedMinutesPrepTime,
                                          ),
                                          Text(S.of(context).minutes),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 25),
                                Row(
                                  children: [
                                    Text(
                                      S.of(context).enter_delivery_time,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          DoseTextField(
                                            controller:
                                                selectedHoursDeliveryTimeController,
                                            currentNode: focusNodeList[1],
                                            keyboardType: TextInputType.number,
                                            formatters: [
                                              BlacklistingTextInputFormatter(
                                                RegExp('[\\.|\\,|\\ |\\-]'),
                                              ),
                                            ],
                                            decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(bottom: 20)),
                                            validator: (value) {
                                              if (value == null) {
                                                return S.of(context).enter_hours;
                                              }
                                              if (value.isEmpty) {
                                                S.of(context).select_hours;
                                              }
                                              this.selectedHoursDeliveryTime = value;
                                              return null;
                                            },
                                          ),
                                          Text(S.of(context).hours),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 48,
                                      ),
                                      child: Text(
                                        ' : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          DropdownButtonFormField<String>(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return S.of(context).validation_error_invalid_hours;
                                              }

                                              selectedMinutesDeliveryTime = value;
                                              return null;
                                            },
                                            items: minuteList.map((value) {
                                              return DropdownMenuItem(
                                                  child: Text(value), value: value);
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedMinutesDeliveryTime = value;
                                              });
                                            },
                                            value: selectedMinutesDeliveryTime,
                                          ),
                                          Text(S.of(context).minutes),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : DoseForm(
                      formKey: _formKey,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      DoseTextField(
                                        isRequired: true,
                                        controller: hoursController,
                                        currentNode: focusNodeList[2],
                                        keyboardType: TextInputType.number,
                                        formatters: [
                                          BlacklistingTextInputFormatter(
                                            RegExp('[\\.|\\,|\\ |\\-]'),
                                          ),
                                        ],
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(bottom: 20)),
                                        validator: (value) {
                                          if (value == null) {
                                            return S.of(context).enter_hours;
                                          }
                                          if (value.isEmpty) {
                                            S.of(context).select_hours;
                                          }
                                          this.selectedHourValue = value;
                                          return null;
                                        },
                                      ),
                                      Text(S.of(context).hours),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 48,
                                  ),
                                  child: Text(
                                    ' : ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      DropdownButtonFormField<String>(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return S.of(context).validation_error_invalid_hours;
                                          }

                                          selectedMinuteValue = value;
                                          return null;
                                        },
                                        items: minuteList.map((value) {
                                          return DropdownMenuItem(child: Text(value), value: value);
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedMinuteValue = value;
                                          });
                                        },
                                        value: selectedMinuteValue,
                                      ),
                                      Text(S.of(context).minutes),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: 20),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(8.0),
                      child: CustomElevatedButton(
                        onPressed: () {
                          subject.add(0);
                        },
                        child: Text(
                          S.of(context).completed,
                          style: Theme.of(context).primaryTextTheme.button,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showDialogFoInfo({String title, String content}) {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              CustomTextButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text(S.of(context).close),
                onPressed: () {
                  Navigator.of(buildContext).pop();
                },
              )
            ],
          );
        });
  }

  void checkForReview() async {
    int totalMinutes = 0;
    var maxClaim;
    double creditRequest = 0.0;
    logger.i('This 1');
    logger.i('TYPE:  ' + requestModel.requestType.toString());

    if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
        requestModel.selectedInstructor.sevaUserID ==
            SevaCore.of(context).loggedInUser.sevaUserID) {
      if (selectedHoursPrepTimeController.text == null ||
          selectedHoursPrepTimeController.text.length == 0 ||
          selectedHoursDeliveryTimeController.text == null ||
          selectedHoursDeliveryTimeController.text.length == 0) {
        return;
      }

      totalMinutes = int.parse(selectedMinutesPrepTime) +
          int.parse(selectedMinutesDeliveryTime) +
          (int.parse(selectedHoursPrepTimeController.text) * 60) +
          (int.parse(selectedHoursDeliveryTimeController.text) * 60);
    } else if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
        requestModel.selectedInstructor.sevaUserID !=
            SevaCore.of(context).loggedInUser.sevaUserID) {
      logger.i('This 2');

      if (hoursController.text == null || hoursController.text.length == 0) {
        return;
      }

      totalMinutes = int.parse(selectedMinuteValue) + (int.parse(hoursController.text) * 60);
    } else {
      logger.i('This 3');

      if (hoursController.text == null || hoursController.text.length == 0) {
        return;
      }
    }

    totalMinutes = int.parse(selectedMinuteValue) + (int.parse(hoursController.text) * 60);
    creditRequest = totalMinutes / 60;
    //Just keeping 20 hours limit for previous versions of app whih did not had number of hours
    maxClaim = (requestModel.numberOfHours ?? 20) / requestModel.numberOfApprovals;

    if (requestModel.isFromOfferRequest && creditRequest < requestModel.minimumCredits ?? 0) {
      showDialogFoInfo(
        title: S.of(context).enter_hours,
        content: S.of(context).minimum_credits_offer,
      );
      return;
    }

    if (!requestModel.isFromOfferRequest && creditRequest > maxClaim) {
      showDialogFoInfo(
        title: S.of(context).limit_exceeded,
        content:
            "${S.of(context).task_max_request_message} $maxClaim ${S.of(context).task_max_hours_of_credit}",
      );
      return;
      //show dialog
    } else if (creditRequest == 0 && requestModel.requestType != RequestType.BORROW) {
      showDialogFoInfo(
        title: S.of(context).enter_hours,
        content: S.of(context).validation_error_invalid_hours,
      );
      return;
    }

    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ReviewFeedback(
            feedbackType: FeedbackType.FOR_REQUEST_CREATOR,
            // requestModel: requestModel,
          );
        },
      ),
    );

    if (results != null && results.containsKey('selection')) {
      showProgressForCreditRetrieval();
      onActivityResult(results, SevaCore.of(context).loggedInUser);
    } else {}
  }

  BuildContext creditRequestDialogContext;

  void showProgressForCreditRetrieval() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          creditRequestDialogContext = context;
          return AlertDialog(
            title: Text(S.of(context).please_wait),
            content: LinearProgressIndicator(
 backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
),
          );
        });
  }

  Future<void> onActivityResult(Map results, UserModel loggedInUser) async {
    // adds review to firestore
    try {
      logger.i('here 1');
      await CollectionRef.reviews.add({
        "reviewer": SevaCore.of(context).loggedInUser.email,
        "reviewed": requestModel.email,
        "ratings": results['selection'],
        "device_info": results['device_info'],
        "requestId": requestModel.id,
        "comments": (results['didComment'] ? results['comment'] : "No comments"),
        'liveMode': !AppConfig.isTestCommunity,
      });
      logger.i('here 2');
      await sendMessageToMember(
          message: results['didComment'] ? results['comment'] : "No comments",
          requestModel: requestModel,
          loggedInUser: loggedInUser);
      logger.i('here 3');
      startTransaction();
    } on Exception catch (e) {
      // TODO
    }
  }

  Future<void> sendMessageToMember({
    UserModel loggedInUser,
    RequestModel requestModel,
    String message,
  }) async {
    TimebankModel timebankModel = await getTimeBankForId(timebankId: requestModel.timebankId);
    UserModel userModel = await FirestoreManager.getUserForId(sevaUserId: requestModel.sevaUserId);
    if (userModel != null && timebankModel != null) {
      ParticipantInfo receiver = ParticipantInfo(
        id: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? userModel.sevaUserID
            : requestModel.timebankId,
        photoUrl: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? userModel.photoURL
            : timebankModel.photoUrl,
        name: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? userModel.fullname
            : timebankModel.name,
        type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? ChatType.TYPE_PERSONAL
            : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                ? ChatType.TYPE_TIMEBANK
                : ChatType.TYPE_GROUP,
      );

      ParticipantInfo sender = ParticipantInfo(
        id: loggedInUser.sevaUserID,
        photoUrl: loggedInUser.photoURL,
        name: loggedInUser.fullname,
        type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? ChatType.TYPE_PERSONAL
            : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                ? ChatType.TYPE_TIMEBANK
                : ChatType.TYPE_GROUP,
      );
      await sendBackgroundMessage(
          messageContent: utils.getReviewMessage(
            requestTitle: requestModel.title,
            context: context,
            userName: loggedInUser.fullname,
            isForCreator: true,
            reviewMessage: message,
          ),
          reciever: receiver,
          isTimebankMessage:
              requestModel.requestMode == RequestMode.PERSONAL_REQUEST ? false : true,
          timebankId: requestModel.timebankId,
          communityId: loggedInUser.currentCommunity,
          sender: sender);
    }
  }

  void startTransaction() async {
    if (_formKey.currentState.validate()) {
      // TODO needs flow correction to tasks model (currently reliying on requests collection for changes which will be huge instead tasks have to be individual to users)
      int totalMinutes = 0;

      if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          requestModel.selectedInstructor.sevaUserID ==
              SevaCore.of(context).loggedInUser.sevaUserID) {
        totalMinutes = int.parse(selectedMinutesPrepTime) +
            int.parse(selectedMinutesDeliveryTime) +
            (int.parse(selectedHoursPrepTimeController.text) * 60) +
            (int.parse(selectedHoursDeliveryTimeController.text) * 60);
      } else {
        totalMinutes = int.parse(selectedMinuteValue) + (int.parse(selectedHourValue) * 60);
        // TODO needs flow correction need to be removed when tasks introduced- Eswar
      }

      this.requestModel.durationOfRequest = totalMinutes;

      TransactionModel transactionModel = TransactionModel(
        from: requestModel.sevaUserId,
        to: SevaCore.of(context).loggedInUser.sevaUserID,
        credits: totalMinutes / 60,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        communityId: requestModel.communityId,
        fromEmail_Id: requestModel.email,
        toEmail_Id: SevaCore.of(context).loggedInUser.email,
      );

      if (requestModel.transactions == null) {
        requestModel.transactions = [transactionModel];
      } else if (!requestModel.transactions.any((model) => model.to == transactionModel.to)) {
        requestModel.transactions.add(transactionModel);
      }

      FirestoreManager.requestComplete(model: requestModel);
      // END OF CODE correction mentioned above
      // await transactionBloc.createNewTransaction(
      //   requestModel.requestMode == RequestMode.PERSONAL_REQUEST
      //       ? requestModel.sevaUserId
      //       : requestModel.timebankId,
      //   SevaCore.of(context).loggedInUser.sevaUserID,
      //   DateTime.now().millisecondsSinceEpoch,
      //   totalMinutes / 60,
      //   false,
      //   this.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
      //       ? RequestMode.TIMEBANK_REQUEST.toString()
      //       : RequestMode.PERSONAL_REQUEST.toString(),
      //   this.requestModel.id,
      //   this.requestModel.timebankId,
      //   communityId: requestModel.communityId,
      //   toEmailORId: SevaCore.of(context).loggedInUser.email,
      //   fromEmailORId: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
      //       ? requestModel.email
      //       : requestModel.timebankId,
      // );

      FirestoreManager.createTaskCompletedNotification(
        model: NotificationsModel(
          id: utils.Utils.getUuid(),
          data: requestModel.toMap(),
          type: NotificationType.RequestCompleted,
          senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
          targetUserId: requestModel.sevaUserId,
          communityId: requestModel.communityId,
          timebankId: requestModel.timebankId,
          isTimebankNotification: requestModel.requestMode == RequestMode.TIMEBANK_REQUEST,
          isRead: false,
        ),
      );
      Navigator.of(creditRequestDialogContext).pop();
      Navigator.of(context).pop();
    }
  }

  List<String> get minuteList {
    List<String> data = [];
    for (int i = 0; i < 60; i += 5) {
      data.add('$i');
    }
    return data;
  }
}

class BorrowRequestFeedBackView extends StatefulWidget {
  final RequestModel requestModel;

  // TODO needs flow correction to tasks model
  BorrowRequestFeedBackView({@required this.requestModel});

  @override
  BorrowRequestFeedBackViewState createState() => BorrowRequestFeedBackViewState();
}

class BorrowRequestFeedBackViewState extends State<BorrowRequestFeedBackView> {
  RequestModel requestModel;

  @override
  void initState() {
    super.initState();
    this.requestModel = widget.requestModel;
  }

  TextEditingController hoursController = TextEditingController();
  TextEditingController selectedHoursPrepTimeController = TextEditingController();
  TextEditingController selectedHoursDeliveryTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          requestModel.title,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: ReviewFeedback(
        feedbackType: (requestModel.requestType == RequestType.BORROW &&
                SevaCore.of(context).loggedInUser.sevaUserID == requestModel.sevaUserId)
            ? FeedbackType.FOR_BORROW_REQUEST_BORROWER
            : FeedbackType.FOR_BORROW_REQUEST_LENDER,
        //FeedbackType.FOR_REQUEST_CREATOR
        // requestModel: requestModel,
      ),
    );
  }
}
