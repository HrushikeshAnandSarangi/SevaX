import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/components/calendar_events/models/calendar_response.dart';
import 'package:sevaexchange/components/calendar_events/models/kloudless_models.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:http/http.dart' as http;

class CalendarAPIRepo {
  static Future<String> createEventInCalendar({
    KloudlessCalendarEvent event,
    int calendarAccountId,
    String calendarId,
  }) async {
    //EVENT META DATA

    String url =
        "https://api.kloudless.com/v1/accounts/${calendarAccountId.toString()}/cal/calendars/$calendarId/events";
    return await http.post(
      url,
      body: jsonEncode(event.toMap()),
      headers: {
        'Authorization': 'Bearer E0BgzLSL6p1tTEkDhsoERLS5eV7IQu',
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
    ).then((value) {
      logger.d(url + " VALUE FROM SERVER  " + value.body);
      Map<String, dynamic> map = json.decode(value.body);
      if (map.containsKey('id'))
        return map['id'];
      else
        return Future.error("Could not find id in response!");
    }).onError((error, stackTrace) {
      return Future.error(error);
    });
  }

  static Future<CalendarEventDetailsResponse> getEventDetailsFromId({
    @required int calendarAccountId,
    @required String calendarId,
    @required String eventId,
  }) async {
    return await http.get(
      "https://api.kloudless.com/v1/accounts/${calendarAccountId.toString()}/cal/calendars/$calendarId/events/$eventId",
      headers: {
        'Authorization': 'Bearer E0BgzLSL6p1tTEkDhsoERLS5eV7IQu',
        "Accept": "application/json",
      },
    ).then((value) {
      if (value.statusCode == 200) {
        CalendarEventDetailsResponse calendarDetails =
            CalendarEventDetailsResponse.fromJson(json.decode(value.body));
        return calendarDetails;
      }
      return Future.error("Couldn't parse the model!");
    }).onError((error, stackTrace) {
      return Future.error(error);
    });
  }

  static Future<bool> updateCalendarEventWithAttendies({
    List<Attendee> previousAttendies,
    EventMetaData eventMetaData,
    AttendeDetails attendeDetails,
    KloudlessCalendarEvent event,
  }) async {
    //
    String url =
        "https://api.kloudless.com/v1/accounts/${eventMetaData.calendar.calendarAccId}/cal/calendars/${eventMetaData.calendar.calendarId}/events/${eventMetaData.eventId}";
    //hit the URL and wait for response;

// attendeDetails.attendee.toJson()

    List<Attendee> updatedAttendies = [];

    updatedAttendies.add(attendeDetails.attendee);
    previousAttendies.forEach((element) {
      updatedAttendies.add(element);
    });

    var map = updatedAttendies.map((e) => e.toJson()).toList();

    Map<String, dynamic> body = {
      "attendees": map,
    };

    // logger.d("_______" + json.encode(body));

    return await http.patch(
      url,
      body: json.encode(body),
      headers: {
        'Authorization': 'Bearer E0BgzLSL6p1tTEkDhsoERLS5eV7IQu',
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
    ).then((value) {
      // logger.d("Response from update " + value.body.toString());
      return true;
    }).onError((error, stackTrace) {
      return Future.error(error);
    });
  }

  static Future<bool> updateAttendiesInCalendarEvent({
    AttendeDetails attendeDetails,
    EventMetaData eventMetaData,
    KloudlessCalendarEvent event,
  }) async {
    //Event doesn't have an associated link
    if (eventMetaData.eventId != null &&
        !(eventMetaData.eventId.isEmpty) &&
        eventMetaData.calendar.caledarScope ==
            attendeDetails.calendar.caledarScope) {
      //Get applicants
      return await getEventDetailsFromId(
        calendarAccountId: eventMetaData.calendar.calendarAccId,
        calendarId: eventMetaData.calendar.calendarId,
        eventId: eventMetaData.eventId,
      )
          .then(
        (value) => updateCalendarEventWithAttendies(
          eventMetaData: eventMetaData,
          attendeDetails: attendeDetails,
          event: event,
          previousAttendies: value.attendees,
        ),
      )
          .then((value) {
        // logger.i("Completed Updation!!");
        return true;
      }).catchError((onError) {
        logger.i("Failed Updation due to " + onError);
        return false;
      });
    } else {
      return await createEventInCalendar(
        calendarAccountId: attendeDetails.calendar.calendarAccId,
        calendarId: attendeDetails.calendar.calendarId,
        event: event,
      ).then((value) => value != null);
    }
  }
}
