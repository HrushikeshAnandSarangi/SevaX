import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_list_data_manager.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';

class RecurringRequestList extends StatefulWidget {
  final RequestModel model;
  final TimebankModel timebankModel;

  RecurringRequestList({Key key, @required this.model,this.timebankModel}) : super(key: key);

  getRequestModel() {
//    print("model url is == ${model.id}");
    return model;
  }

  @override
  _RecurringRequestListState createState() => _RecurringRequestListState();
}

class _RecurringRequestListState extends State<RecurringRequestList> {
  @override
  Widget build(BuildContext context) {
    print("model id is == ${widget.model.id}");
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Recurring list",
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: Container(
          child: StreamBuilder(
              stream: RecurringListDataManager.getRecurringRequestListStream(
                parentRequestId: widget.model.parent_request_id,
              ),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data != null) {
                  List<RequestModel> requestModelList = snapshot.data;
                    print("snapshot data is ==== ${snapshot.data.length}");
                  requestModelList.forEach((k) => print('snapshot id is ==> ${k.id}'));
                  return RecurringList(requestModelList,widget.timebankModel);
                } else {
                  return Center(child: CircularProgressIndicator());

                }
              }),
        ));
  }
}

class RecurringList extends StatefulWidget {
  List<RequestModel> model;
  TimebankModel timebankModel;

  RecurringList(this.model,this.timebankModel);

  @override
  _RecurringListState createState() => _RecurringListState();
}

class _RecurringListState extends State<RecurringList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        itemCount: widget.model.length,
        itemBuilder: (BuildContext context, int index){
          print("occurenceCounttt===>${widget.model[index].occurenceCount} ${widget.model[index].requestStart}");
          return Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              child: Card(
                color: Colors.white,
                elevation: 2,
                child: InkWell(
                  onTap: () =>editRequest(model: widget.model[index],timebankModel: widget.timebankModel),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipOval(
                          child: SizedBox(
                            height: 45,
                            width: 45,
                            child: FadeInImage.assetNetwork(
                              fit: BoxFit.cover,
                              placeholder: 'lib/assets/images/profile.png',
                              image: widget.model[index].photoUrl == null
                                  ? defaultUserImageURL
                                  : widget.model[index].photoUrl,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(widget.model[index].title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.subhead,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  widget.model[index].description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.subtitle,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Text(
                                    getTimeFormattedString(
                                        widget.model[index].requestStart)
                                    ,
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.arrow_forward, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    getTimeFormattedString(
                                        widget.model[index].requestEnd

                                    )
                                    ,
                                  ),
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
            );});
  }

  void editRequest({RequestModel model,TimebankModel timebankModel}) {
    timeBankBloc.setSelectedRequest(model);
    if (model.sevaUserId == SevaCore.of(context).loggedInUser.sevaUserID ||
        widget.timebankModel.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestTabHolder(
            isAdmin: true,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestDetailsAboutPage(
            requestItem: model,
            timebankModel: widget.timebankModel,
            isAdmin: false,
          ),
        ),
      );
    }
     /* Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestDetailsAboutPage(
            requestItem: model,
            timebankModel: timebankModel,
            isAdmin: false,
          ),
        ),
      );*/

  }

  String getTimeFormattedString(int timeInMilliseconds) {
    String timezoneAbb = SevaCore.of(context).loggedInUser.timezone;
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
}
