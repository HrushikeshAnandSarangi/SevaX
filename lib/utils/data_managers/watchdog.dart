import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';

class WatchDog {
  static showDialogForUpdation({
    BuildContext context,
    Function updateSingleEvent,
    Function updateSubsequentEvents,
  }) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext viewContext) {
          return WillPopScope(
              onWillPop: () {},
              child: AlertDialog(
                  title: Text(S.of(context).this_is_repeating_event),
                  actions: [
                    FlatButton(
                      child: Text(
                        S.of(context).edit_this_event,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        //Update this event
                        await updateSingleEvent();
                        Navigator.pop(viewContext);
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        S.of(context).edit_subsequent_event,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        //Update subsquent events
                        await updateSubsequentEvents();
                        Navigator.pop(viewContext);
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        Navigator.pop(viewContext);
                      },
                    ),
                  ]));
        });
  }

  static Future<bool> updateSubsequentEvents(ProjectModel projectModel) async {
    var batch = Firestore.instance.batch();

    var eventList =
        await getEventAssociatedWithParentEvent(projectModel.parentEventId);

    var affectedEventIds = [];

    eventList.forEach((element) {
      if (element.occurenceCount >= projectModel.occurenceCount)
        affectedEventIds.add(element.id);
    });

    logger.d(affectedEventIds.length);

    affectedEventIds.forEach((element) {
      Map<String, dynamic> updatedDetails = {
        "name": projectModel.name,
        "description": projectModel.description,
        "public": projectModel.public,
        "virtualProject": projectModel.virtualProject,
        "email_id": projectModel.emailId,
        "address": projectModel.address,
        "registrationLink": projectModel.registrationLink,
        "timebanksPosted":
            List<dynamic>.from(projectModel.timebanksPosted.map((x) => x)),
      };
      if (projectModel.location != null)
        updatedDetails['location'] = projectModel.location?.data;

      batch.updateData(
        Firestore.instance.collection("projects").document(element),
        updatedDetails,
      );
    });
    return batch.commit().then((value) => true).catchError((onError) => false);
  }

  static Future<List<ProjectModel>> getEventAssociatedWithParentEvent(
    String parentEventId,
  ) {
    return Firestore.instance
        .collection("projects")
        .where("parentEventId", isEqualTo: parentEventId)
        .getDocuments()
        .then((value) {
      List<ProjectModel> eventList = [];
      value.documents.forEach((event) {
        eventList.add(ProjectModel.fromMap(event.data));
      });
      return eventList;
    });
  }

  static Future<bool> updateSingleEvent() {}

  static Future<List<String>> createRecurringEvents({
    @required ProjectModel projectModel,
  }) async {
    var batch = Firestore.instance.batch();
    var db = Firestore.instance;
    DateTime eventStartDate =
        DateTime.fromMillisecondsSinceEpoch(projectModel.startTime);
    DateTime eventEndDate =
        DateTime.fromMillisecondsSinceEpoch(projectModel.endTime);

    bool lastRound = false;
    List<Map<String, dynamic>> temparr = [];
    List<String> eventsIdsArr = [];
    batch.setData(db.collection("projects").document(projectModel.id),
        projectModel.toMap());

    if (projectModel.end.endType == "on") {
      //end type is on
      int occurenceCount = 2;
      var numTemp = 0;
      while (lastRound == false) {
        eventStartDate = DateTime(
            eventStartDate.year,
            eventStartDate.month,
            eventStartDate.day + 1,
            eventStartDate.hour,
            eventStartDate.minute,
            eventStartDate.second);
        eventEndDate = DateTime(
            eventEndDate.year,
            eventEndDate.month,
            eventEndDate.day + 1,
            eventEndDate.hour,
            eventEndDate.minute,
            eventEndDate.second);

        if (eventStartDate.millisecondsSinceEpoch <= projectModel.end.on) {
          numTemp = eventStartDate.weekday % 7;
          if (projectModel.recurringDays.contains(numTemp)) {
            ProjectModel temp = projectModel;
            temp.startTime = eventStartDate.millisecondsSinceEpoch;
            temp.endTime = eventEndDate.millisecondsSinceEpoch;
            temp.createdAt = DateTime.now().millisecondsSinceEpoch;
            temp.id = Utils.getUuid();
            temp.occurenceCount = occurenceCount;
            occurenceCount++;
            temp.softDelete = false;
            temp.isRecurring = false;
            temp.autoGenerated = true;
            temparr.add(temp.toMap());
          }
        } else {
          lastRound = true;
          break;
        }
      }
    } else {
      //end type is after
      var numTemp = 0;
      int occurenceCount = 2;
      while (occurenceCount <= projectModel.end.after) {
        eventStartDate = DateTime(
            eventStartDate.year,
            eventStartDate.month,
            eventStartDate.day + 1,
            eventStartDate.hour,
            eventStartDate.minute,
            eventStartDate.second);
        eventEndDate = DateTime(
          eventEndDate.year,
          eventEndDate.month,
          eventEndDate.day + 1,
          eventEndDate.hour,
          eventEndDate.minute,
          eventEndDate.second,
        );

        numTemp = eventStartDate.weekday % 7;
        if (projectModel.recurringDays.contains(numTemp)) {
          ProjectModel temp = projectModel;
          temp.startTime = eventStartDate.millisecondsSinceEpoch;
          temp.endTime = eventEndDate.millisecondsSinceEpoch;
          temp.createdAt = DateTime.now().millisecondsSinceEpoch;
          temp.id = Utils.getUuid();
          temp.occurenceCount = occurenceCount;
          occurenceCount++;
          temp.softDelete = false;
          temp.isRecurring = false;
          temp.autoGenerated = true;
          temparr.add(temp.toMap());
        }
        if (occurenceCount > projectModel.end.after) {
          break;
        }
      }
    }

    eventsIdsArr.add(projectModel.id);
    temparr.forEach((tempobj) {
      batch.setData(db.collection("projects").document(tempobj['id']), tempobj);
      eventsIdsArr.add(tempobj['id']);
    });

    await batch.commit();
    return eventsIdsArr;
  }
}
