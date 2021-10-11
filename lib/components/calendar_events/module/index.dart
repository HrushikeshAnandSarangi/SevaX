import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:sevaexchange/components/calendar_events/models/calendar_response.dart';
import 'package:sevaexchange/components/calendar_events/models/kloudless_models.dart';
import 'package:sevaexchange/components/calendar_events/repo/calendar_repo.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class KloudlessWidgetManager<M extends Mode, T extends DataModel> {
  syncCalendar({
    KloudlessWidgetBuilder builder,
    @required BuildContext context,
  }) {
    return builder.attendeeDetails.calendar.defined
        ? _existingMember(
            context,
            builder: builder,
          )
        : _newMember(
            context,
            builder: builder,
          );
  }

  Future<dynamic> _newMember(
    BuildContext context, {
    @required KloudlessWidgetBuilder builder,
  }) {
    return showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text('Add your calendar'),
          content: NewCalendarRegisteration(
            builder: builder,
            dialogContext: _,
          ),
        );
      },
    );
  }

  Future<dynamic> _existingMember(
    BuildContext context, {
    @required KloudlessWidgetBuilder builder,
  }) {
    return showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Do you want to add this to your Calender?"),
          actions: [
            ElevatedButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(_).pop();
              },
            ),
            TransactionsMatrixCheck(
              onNavigationStart: () {
                Navigator.of(_).pop();
              },
              upgradeDetails: AppConfig.upgradePlanBannerModel.calendar_sync,
              transaction_matrix_type: "calendar_sync",
              child: GestureDetector(
                child: ElevatedButton(
                  child: Text('Yes'),
                  onPressed: () async {
                    Navigator.of(_).pop();
                    addEventToExistingCalendar(builder);
                  },
                ),
                onTap: () async {},
              ),
            ),
          ],
        );
      },
    );
  }

  void addEventToExistingCalendar(KloudlessWidgetBuilder builder) async {
    CollectionReference collectionReferenece;
    KloudlessCalendarEvent canendarEvent;
    switch (T) {
      case ProjectModel:
        collectionReferenece = CollectionRef.projects;

        ProjectModel model = builder.stateOfCalendarCallback.model;
        //hit the create event API from calandar
        canendarEvent = KloudlessCalendarEvent(
          eventTitle: model.name,
          eventDescription: model.description,
          eventLocation: model.address ?? 'Location not added',
          eventStart: DateTime.fromMillisecondsSinceEpoch(model.startTime)
              .toIso8601String(),
          eventEnd: DateTime.fromMillisecondsSinceEpoch(
            model.endTime,
          ).toIso8601String(),
        );

        break;

      case OfferModel:
        collectionReferenece = CollectionRef.offers;

        OfferModel model = builder.stateOfCalendarCallback.model;
        canendarEvent = KloudlessCalendarEvent(
          eventTitle: model.groupOfferDataModel.classTitle,
          eventDescription: model.groupOfferDataModel.classDescription,
          eventLocation: model.selectedAdrress ?? 'Location not added',
          eventStart: DateTime.fromMillisecondsSinceEpoch(
                  model.groupOfferDataModel.startDate)
              .toIso8601String(),
          eventEnd: DateTime.fromMillisecondsSinceEpoch(
                  model.groupOfferDataModel.endDate)
              .toIso8601String(),
        );

        break;

      case RequestModel:
        collectionReferenece = CollectionRef.requests;

        RequestModel model = builder.stateOfCalendarCallback.model;
        canendarEvent = KloudlessCalendarEvent(
          eventTitle: model.title,
          eventDescription: model.description,
          eventLocation: model.address ?? 'Location not added',
          eventStart: DateTime.fromMillisecondsSinceEpoch(model.requestStart)
              .toIso8601String(),
          eventEnd: DateTime.fromMillisecondsSinceEpoch(model.requestEnd)
              .toIso8601String(),
        );
        break;

      default:
        throw Exception("Please specify the details of model");
    }

    //Check Mode of Opertion
    switch (M) {
      case CreateMode:
        await CalendarAPIRepo.createEventInCalendar(
          calendarAccountId: builder.attendeeDetails.calendar.calendarAccId,
          calendarId: builder.attendeeDetails.calendar.calendarId,
          event: canendarEvent,
        ).then((eventId) {
          if (eventId != null) {
            logger.d("Event Successfully created");
            collectionReferenece
                .doc(builder.stateOfCalendarCallback.model.id)
                .update({
                  "eventMetaData": EventMetaData(
                    calendar: builder.attendeeDetails.calendar,
                    eventId: eventId,
                  ).toMap(),
                })
                .then((value) => logger.d("Value Completed!"))
                .catchError((onError) {
                  logger.d("On Error : " + onError);
                });
          } else {
            logger.d("Failed to create event created");
          }
        }).catchError((e) {
          logger.d("ERROR : " + e.toString());
        });
        break;

      case ApplyMode:
        await CalendarAPIRepo.updateAttendiesInCalendarEvent(
          eventMetaData: builder.stateOfCalendarCallback.model.eventMetaData
              as EventMetaData,
          event: canendarEvent,
          attendeDetails: builder.attendeeDetails,
        )
            .then((value) => logger.i(
                  "updateAttendiesInCalendarEvent Completed without any errors",
                ))
            .catchError((onError) => logger.i(
                "updateAttendiesInCalendarEvent finished with an error! $onError"));
        break;
    }
  }
}

class NewCalendarRegisteration extends StatelessWidget {
  final KloudlessWidgetBuilder builder;
  final BuildContext dialogContext;

  NewCalendarRegisteration({
    this.builder,
    this.dialogContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      child: Column(
        children: [
          CalendarListAdapter(
            builder: builder,
            url: "lib/assets/images/googlecal.png",
            onNavigationStart: () {
              logger.d("Navigator.of(dialogContext).pop()");
              Navigator.of(dialogContext).pop();
            },
            title: "Google Calendar",
            typeId: 'google_calendar',
          ),
          CalendarListAdapter(
            builder: builder,
            url: "lib/assets/images/outlookcal.png",
            onNavigationStart: () {
              logger.d("Navigator.of(dialogContext).pop()");
              Navigator.of(dialogContext).pop();
            },
            title: "Outlook Calendar",
            typeId: 'outlook_calendar',
          ),
          CalendarListAdapter(
            builder: builder,
            url: "lib/assets/images/ical.png",
            onNavigationStart: () {
              logger.d("Navigator.of(dialogContext).pop()");
              Navigator.of(dialogContext).pop();
            },
            title: "iCalendar",
            typeId: 'icloud_calendar',
          ),
          CustomTextButton(
            shape: StadiumBorder(),
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            color:  Theme.of(context).primaryColor,
            child: Text(
              S.of(context).skip_for_now,
              style: TextStyle(color: Colors.white, fontFamily: 'Europa'),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }
}

class CalendarListAdapter extends StatelessWidget {
  final String title;
  final Function onNavigationStart;
  final String typeId;
  final KloudlessWidgetBuilder builder;
  final String url;

  CalendarListAdapter({
    this.onNavigationStart,
    this.typeId,
    this.title,
    this.builder,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(url),
      title: TransactionsMatrixCheck(
        onNavigationStart: onNavigationStart,
        upgradeDetails: AppConfig.upgradePlanBannerModel.calendar_sync,
        transaction_matrix_type: "calendar_sync",
        child: GestureDetector(
          child: Text(title),
          onTap: () async {
            try {
              onNavigationStart();
            } catch (e) {
              logger.d("Failed to launch");
            }
            String authURL =
                "${builder.authorizationUrl}?client_id=${builder.clienId}&response_type=code&scope=${typeId}&redirect_uri=${builder.redirectUrl}&state=${builder.stateOfCalendarCallback.toJson()}";
            //LAUNCH URL
            canLaunch(Uri.parse(authURL).toString()).then((value) {
              if (value) {
                launch(Uri.parse(authURL).toString());
              }
            });
            logger.d(Uri.parse(authURL).toString());
          },
        ),
      ),
    );
  }
}
