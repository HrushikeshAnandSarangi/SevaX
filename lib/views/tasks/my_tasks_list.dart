import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/qna-module/ReviewLandingPage.dart';
import 'package:sevaexchange/views/tasks/completed_list.dart';
import 'package:shimmer/shimmer.dart';

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
    return TabBarView(
      controller: widget.controller,
      children: [MyTasksList(), NotAcceptedTaskList(), CompletedList()],
    );
  }
}

class MyTasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: FirestoreManager.getUserForId(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Text(
                '${AppLocalizations.of(context).translate('tasks', 'error')} ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          UserModel userModel = snapshot.data;
          String usertimezone = userModel.timezone;
          print(SevaCore.of(context).loggedInUser.sevaUserID);
          return StreamBuilder<List<RequestModel>>(
            stream: FirestoreManager.getTaskStreamForUserWithEmail(
                userEmail: SevaCore.of(context).loggedInUser.email,
                userId: SevaCore.of(context).loggedInUser.sevaUserID),
            builder: (streamContext, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              List<RequestModel> requestModelList = snapshot.data;
              if (requestModelList.length == 0) {
                // return ListView.builder(
                //   itemBuilder: (context, index) => Text(index.toString()),
                //   itemCount: 100,
                // );
                return Padding(
                  padding: const EdgeInsets.only(top: 58.0),
                  child: Text(
                    AppLocalizations.of(context)
                        .translate('tasks', 'no_pending'),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
                itemCount: requestModelList.length,
                // physics: NeverScrollableScrollPhysics(),
                itemBuilder: (listContext, index) {
                  // TODO needs flow correction to tasks model
                  RequestModel model = requestModelList[index];

                  return getTaskWidget(model, usertimezone);

                  return Container(
                    padding: EdgeInsets.only(
                      top: 5.0,
                      bottom: 5.0,
                      left: 30.0,
                      right: 15.0,
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage(_getPostItColor(model)),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        model.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(model.fullName),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return TaskCardView(
                                requestModel: model,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        });
  }

  Widget getTaskWidget(
    RequestModel model,
    String userTimezone,
  ) {
    return FutureBuilder<UserModel>(
        future: FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (snapshot.connectionState == ConnectionState.waiting) {
            return taskShimmer;
          }

          UserModel user = snapshot.data;

          DateFormat format = DateFormat(
              'dd/MM/yy hh:mm a',
              Locale(AppConfig.prefs.getString('language_code'))
                  .toLanguageTag());
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return TaskCardView(
                          requestModel: model,
                          userTimezone: userTimezone,
                        );
                      },
                    ),
                  );
                },
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       mainAxisSize: MainAxisSize.min,
                //       children: <Widget>[
                //         Text(
                //           getTime(
                //             model.requestStart,
                //             userTimezone,
                //           ),
                //           style: TextStyle(
                //             color: Color(0xFFFb57b59),
                //             fontSize: 14,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         SizedBox(height: 3),
                //         Text(
                //           model.title,
                //           style: TextStyle(
                //             fontSize: 16,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         SizedBox(height: 3),
                //         Text(
                //           user.fullname,
                //           style: TextStyle(fontSize: 14),
                //         ),
                //         SizedBox(height: 3),
                //         Text(
                //           getTimeFormattedString(
                //             model.requestStart,
                //             userTimezone,
                //           ),
                //           style: TextStyle(
                //             color: Color(0xFFFb57b59),
                //             fontSize: 14,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                child: ListTile(
                  title: Text(
                    model.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(user.fullname),
                      SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        //runAlignment: WrapAlignment.center,
                        spacing: 8,
                        children: <Widget>[
                          Text(
                            getTimeFormattedString(
                                model.requestStart, userTimezone),
                            style: TextStyle(color: Colors.black),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 14,
                          ),
                          Text(
                            getTimeFormattedString(
                                model.requestEnd, userTimezone),
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(user.photoURL ?? defaultUserImageURL),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return TaskCardView(
                            requestModel: model,
                            userTimezone: userTimezone,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        });
  }

  String getTime(int timeInMilliseconds, String timezoneAbb) {
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    DateTime localtime = getDateTimeAccToUserTimezone(
        dateTime: datetime, timezoneAbb: timezoneAbb);
    String from = DateFormat.jm().format(
      localtime,
    );
    return from;
  }

  String getTimeFormattedString(int timeInMilliseconds, String timezoneAbb) {
    DateFormat dateFormat = DateFormat('d MMM hh:mm a ',
        Locale(AppConfig.prefs.getString('language_code')).toLanguageTag());
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    DateTime localtime = getDateTimeAccToUserTimezone(
        dateTime: datetime, timezoneAbb: timezoneAbb);
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
    final _random = new Random();
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

  RequestModel requestModel;
  final subject = new ReplaySubject<int>();

  @override
  void initState() {
    super.initState();
    this.requestModel = widget.requestModel;
    subject
        .transform(ThrottleStreamTransformer(
            (_) => TimerStream(true, const Duration(seconds: 1))))
        .listen((data) {
      checkForReview();
    });
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController hoursController = TextEditingController();

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
          FocusScope.of(context).requestFocus(new FocusNode());
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
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
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
                        '${AppLocalizations.of(context).translate('tasks', 'from')}  ' +
                            DateFormat(
                                    'MMMM dd, yyyy @ h:mm a',
                                    Locale(AppConfig.prefs
                                            .getString('language_code'))
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
                        '${AppLocalizations.of(context).translate('tasks', 'untill')}  ' +
                            DateFormat(
                                    'MMMM dd, yyyy @ h:mm a',
                                    Locale(AppConfig.prefs
                                            .getString('language_code'))
                                        .toLanguageTag())
                                .format(
                              getDateTimeAccToUserTimezone(
                                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                                      requestModel.requestEnd),
                                  timezoneAbb: widget.userTimezone),
                            ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment(-1.0, 0.0),
                      child: Text(
                          '${AppLocalizations.of(context).translate('tasks', 'posted_by')} ' +
                              requestModel.fullName),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment(-1.0, 0.0),
                      child: Text(
                        '${AppLocalizations.of(context).translate('tasks', 'posted_date')}  ' +
                            DateFormat(
                                    'MMMM dd, yyyy @ h:mm a',
                                    Locale(AppConfig.prefs
                                            .getString('language_code'))
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
                    Form(
                      key: _formKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextFormField(
                                  controller: hoursController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    BlacklistingTextInputFormatter(
                                      new RegExp('[\\.|\\,|\\ |\\-]'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 20)),
                                  validator: (value) {
                                    if (value == null) {
                                      return AppLocalizations.of(context)
                                          .translate('tasks', 'enterhours');
                                    }
                                    if (value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .translate('tasks', 'selecthours');
                                    }
                                    this.selectedHourValue = value;
                                  },
                                ),
                                Text(AppLocalizations.of(context)
                                    .translate('tasks', 'hours')),
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
                                    if (value == null) {
                                      return AppLocalizations.of(context)
                                          .translate('tasks', 'minutes_null');
                                    }
                                    if (value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .translate('tasks', 'minutes_empty');
                                    }
                                    selectedMinuteValue = value;
                                  },
                                  items: minuteList.map((value) {
                                    return DropdownMenuItem(
                                        child: Text(value), value: value);
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedMinuteValue = value;
                                    });
                                  },
                                  value: selectedMinuteValue,
                                ),
                                Text(AppLocalizations.of(context)
                                    .translate('tasks', 'minutes')),
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
                      child: RaisedButton(
                        onPressed: () {
                          subject.add(0);
                        },
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('tasks', 'completed'),
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
              FlatButton(
                child: Text(AppLocalizations.of(context)
                    .translate('homepage', 'close')),
                onPressed: () {
                  Navigator.of(buildContext).pop();
                },
              )
            ],
          );
        });
  }

  void checkForReview() async {
    if (hoursController.text == null || hoursController.text.length == 0) {
      return;
    }
    int totalMinutes =
        int.parse(selectedMinuteValue) + (int.parse(hoursController.text) * 60);
    double creditRequest = totalMinutes / 60;
    //Just keeping 20 hours limit for previous versions of app whih did not had number of hours
    var maxClaim =
        (requestModel.numberOfHours ?? 20) / requestModel.numberOfApprovals;

    if (creditRequest > maxClaim) {
      showDialogFoInfo(
        title:
            AppLocalizations.of(context).translate('tasks', 'limit_exceeded'),
        content:
            "${AppLocalizations.of(context).translate('tasks', 'only_request')} $maxClaim ${AppLocalizations.of(context).translate('tasks', 'hours_of_credit')}",
      );
      return;
      //show dialog
    } else if (creditRequest == 0) {
      showDialogFoInfo(
        title: AppLocalizations.of(context).translate('tasks', 'enter_hours'),
        content: AppLocalizations.of(context)
            .translate('tasks', 'enter_valid_hours'),
      );
      return;
    }

    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return ReviewFeedback(
          feedbackType: FeedbackType.FOR_REQUEST_CREATOR,
        );
      },
    ));

    if (results != null && results.containsKey('selection')) {
      showProgressForCreditRetrieval();
      onActivityResult(results);
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
            title:
                Text(AppLocalizations.of(context).translate('tasks', 'wait')),
            content: LinearProgressIndicator(),
          );
        });
  }

  Future<void> onActivityResult(Map results) async {
    // adds review to firestore
    await Firestore.instance.collection("reviews").add({
      "reviewer": SevaCore.of(context).loggedInUser.email,
      "reviewed": requestModel.email,
      "ratings": results['selection'],
      "requestId": requestModel.id,
      "comments": (results['didComment'] ? results['comment'] : "No comments")
    });

    startTransaction();
  }

  void startTransaction() async {
    if (_formKey.currentState.validate()) {
      // TODO needs flow correction to tasks model (currently reliying on requests collection for changes which will be huge instead tasks have to be individual to users)
      int totalMinutes =
          int.parse(selectedMinuteValue) + (int.parse(selectedHourValue) * 60);
      // TODO needs flow correction need to be removed when tasks introduced- Eswar
      this.requestModel.durationOfRequest = totalMinutes;

      TransactionModel transactionModel = TransactionModel(
        from: requestModel.sevaUserId,
        to: SevaCore.of(context).loggedInUser.sevaUserID,
        credits: totalMinutes / 60,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      if (requestModel.transactions == null) {
        requestModel.transactions = [transactionModel];
      } else if (!requestModel.transactions
          .any((model) => model.to == transactionModel.to)) {
        requestModel.transactions.add(transactionModel);
      }

      FirestoreManager.requestComplete(model: requestModel);
      // END OF CODE correction mentioned above
      await transactionBloc.createNewTransaction(
          requestModel.requestMode == RequestMode.PERSONAL_REQUEST
              ? requestModel.sevaUserId
              : requestModel.timebankId,
          SevaCore.of(context).loggedInUser.sevaUserID,
          DateTime.now().millisecondsSinceEpoch,
          totalMinutes / 60,
          false,
          this.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
              ? RequestMode.TIMEBANK_REQUEST.toString()
              : RequestMode.PERSONAL_REQUEST.toString(),
          this.requestModel.id,
          this.requestModel.timebankId);
      FirestoreManager.createTaskCompletedNotification(
        model: NotificationsModel(
          id: utils.Utils.getUuid(),
          data: requestModel.toMap(),
          type: NotificationType.RequestCompleted,
          senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
          targetUserId: requestModel.sevaUserId,
          communityId: SevaCore.of(context).loggedInUser.currentCommunity,
          timebankId: requestModel.timebankId,
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
