import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/tasks/completed_list.dart';
import 'package:intl/intl.dart';

import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import '../../flavor_config.dart';
import 'completed_list.dart';
import 'notAccepted_tasks.dart';

class MyTaskPage extends StatefulWidget {
  final TabController controller;

  MyTaskPage(this.controller);

  @override
  MyTaskPageState createState() => MyTaskPageState();
}

class MyTaskPageState extends State<MyTaskPage> with TickerProviderStateMixin {
  TabController controller;
  final TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.addListener(() {
      setState(() {});
    });
    searchTextController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TabBarView(
      controller: widget.controller,
      children: [MyTasksList(), NotAcceptedTaskList(), CompletedList()],
    );
    ;
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
            return new Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          UserModel userModel = snapshot.data;
          String usertimezone = userModel.timezone;
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
                return Center(child: Text('No Pending Tasks'));
              }
              return ListView.builder(
                itemCount: requestModelList.length,
                itemBuilder: (listContext, index) {
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

          DateFormat format = DateFormat('dd/MM/yy hh:mm a');
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
              child: ListTile(
                  title: Text(model.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(user.email),
                      SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runAlignment: WrapAlignment.center,
                        spacing: 8,
                        children: <Widget>[
                          Text(
                            format.format(
                              getDateTimeAccToUserTimezone(
                                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                                      model.requestStart),
                                  timezoneAbb: userTimezone),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 14,
                          ),
                          Text(
                            format.format(
                              getDateTimeAccToUserTimezone(
                                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                                      model.requestEnd),
                                  timezoneAbb: userTimezone),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.photoURL),
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
                  }),
            ),
          );
        });
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

  TaskCardView({@required this.requestModel, this.userTimezone});

  @override
  TaskCardViewState createState() => TaskCardViewState();
}

class TaskCardViewState extends State<TaskCardView> {
  String selectedMinuteValue = "0";
  String selectedHourValue;

  RequestModel requestModel;

  @override
  void initState() {
    super.initState();
    this.requestModel = widget.requestModel;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          requestModel.title,
          style: TextStyle(color: Colors.white),
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
                        'From:  ' +
                            DateFormat('MMMM dd, yyyy @ h:mm a').format(
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
                        'Until:  ' +
                            DateFormat('MMMM dd, yyyy @ h:mm a').format(
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
                      child: Text('Posted By: ' + requestModel.fullName),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment(-1.0, 0.0),
                      child: Text(
                        'PostDate:  ' +
                            DateFormat('MMMM dd, yyyy @ h:mm a').format(
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
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                BlacklistingTextInputFormatter(
                                  new RegExp('[\\.|\\,|\\ |\\-]'),
                                ),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Hours',
                                border: UnderlineInputBorder(),
                                hasFloatingPlaceholder: true,
                                labelText: 'Hours',
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'Select hours';
                                }
                                if (value.isEmpty) {
                                  return 'Select hours';
                                }
                                this.selectedHourValue = value;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            child: Text(
                              ' : ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hasFloatingPlaceholder: true,
                                labelText: 'Minutes',
                                hintText: 'Minutes',
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'Minutes cannot be null';
                                }
                                if (value.isEmpty) {
                                  return 'Minutes cannot be Empty';
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
                              hint: Text('Minutes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: RaisedButton(
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            int totalMinutes = int.parse(selectedMinuteValue) +
                                (int.parse(selectedHourValue) * 60);

                            this.requestModel.durationOfRequest = totalMinutes;

                            TransactionModel transactionModel =
                                TransactionModel(
                              from: requestModel.sevaUserId,
                              to: SevaCore.of(context).loggedInUser.sevaUserID,
                              credits: totalMinutes / 60,
                              timestamp: DateTime.now().millisecondsSinceEpoch,
                            );

                            if (requestModel.transactions == null) {
                              requestModel.transactions = [transactionModel];
                            } else if (!requestModel.transactions.any(
                                (model) => model.to == transactionModel.to)) {
                              requestModel.transactions.add(transactionModel);
                            }

                            FirestoreManager.requestComplete(
                                model: requestModel);

                            FirestoreManager.createTaskCompletedNotification(
                              model: NotificationsModel(
                                id: utils.Utils.getUuid(),
                                data: requestModel.toMap(),
                                type: NotificationType.RequestCompleted,
                                senderUserId: SevaCore.of(context)
                                    .loggedInUser
                                    .sevaUserID,
                                targetUserId: requestModel.sevaUserId,
                              ),
                            );

                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          'Completed',
                          style: TextStyle(color: FlavorConfig.values.buttonTextColor,),
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

  List<String> get minuteList {
    List<String> data = [];
    for (int i = 0; i < 60; i += 15) {
      data.add('$i');
    }
    return data;
  }
}
