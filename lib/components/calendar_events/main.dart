import 'package:flutter/material.dart';
import 'package:sevaexchange/components/calendar_events/models/calendar_response.dart';
import 'package:sevaexchange/components/calendar_events/models/kloudless_models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';

import 'module/index.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: MyWidget()),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text("sync"),
      onPressed: () {
        ProjectModel eventModel = ProjectModel(
          id: "somesampleprojectdi",
          name: 'KloudLess Sample',
          address: 'Sample Address CA',
          description: 'THIS IS A SAMPLE DESCRIPTION',
          startTime: 1624876200000,
          endTime: 1624883400000,
          eventMetaData: EventMetaData(
              calendar: CalanderBuilder(
                caledarScope: "google_calendar",
                calendarAccId: 402655325,
                calendarAccessToken: "E0BgzLSL6p1tTEkDhsoERLS5eV7IQu",
                calendarEmail: "burhan@uipep.com",
                calendarId:
                    "calendar_Y19saXA0bm9xdXY1NG5nbDdvMWV2bG0yZ2Rwa0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t",
              ),
              eventId: 'SomeEventIdFromMetaData'),
        );

        KloudlessWidgetManager<CreateMode, ProjectModel>().syncCalendar(
          context: context,
          builder: KloudlessWidgetBuilder(
            clienId: "B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh",
            stateOfCalendarCallback: CalStateBuilder<CreateMode, ProjectModel>(
              memberEmail: 'example@email.com',
              id: 'someIdHere',
              name: 'Sample Name',
              model: eventModel,
            ),
            attendeeDetails: AttendeDetails(
              attendee: Attendee(
                email: 'attende@email.com',
                name: 'Attendee',
              ),
              calendar: CalanderBuilder(
                caledarScope: "google_calendar",
                calendarAccId: 402655325,
                calendarAccessToken: "E0BgzLSL6p1tTEkDhsoERLS5eV7IQu",
                calendarEmail: "burhan@uipep.com",
                calendarId:
                    "calendar_Y19saXA0bm9xdXY1NG5nbDdvMWV2bG0yZ2Rwa0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t",
              ),
            ),
          ),
        );
      },
    );
  }
}
