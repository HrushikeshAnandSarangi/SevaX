import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/components/calendar_events/models/calendar_response.dart';
import 'package:sevaexchange/views/core.dart';

class Mode {}

class CreateMode extends Mode {}

class ApplyMode extends Mode {}

enum ENVIRONMENT {
  PRODUCTION,
  DEVELOPMENT,
}

extension ReadableEnvironment on ENVIRONMENT {
  String get readable {
    switch (this) {
      case ENVIRONMENT.PRODUCTION:
        return "PRODUCTION";

      case ENVIRONMENT.DEVELOPMENT:
        return "DEVELOPMENT";

      default:
        return "DEVELOPMENT";
    }
  }
}

class AttendeDetails {
  final Attendee attendee;
  final CalanderBuilder calendar;

  AttendeDetails({
    this.attendee,
    this.calendar,
  });
}

class KloudlessCalendarEvent {
  final String eventTitle;
  final String eventDescription;
  final String eventStart;
  final String eventEnd;
  final String eventLocation;

  KloudlessCalendarEvent({
    this.eventTitle,
    this.eventDescription,
    this.eventStart,
    this.eventEnd,
    this.eventLocation,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};
    object["name"] = this.eventTitle;
    object["description"] = this.eventDescription;
    object["location"] = this.eventLocation;
    object["start"] = this.eventStart;
    object["end"] = this.eventEnd;

    return object;
  }
}

class EventMetaData {
  String eventId;
  CalanderBuilder calendar;

  EventMetaData({this.eventId, this.calendar});

  EventMetaData.fromMap(Map<String, dynamic> map) {
    this.calendar = CalanderBuilder.fromMap(map['calendar']);
    this.eventId = map['eventId'];
  }

  Map<String, dynamic> toMap() => {
        "calendar": this.calendar.toMap(),
        "eventId": this.eventId,
      };
}

class KloudlessWidgetBuilder {
  String authorizationUrl;
  String clienId;
  String redirectUrl;
  CalStateBuilder stateOfCalendarCallback;
  AttendeDetails attendeeDetails;
  EventMetaData initialEventDetails;

  Function onPressed;

  KloudlessWidgetBuilder({
    this.clienId = "B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh",
    this.redirectUrl =
        "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth",
    this.authorizationUrl = "https://api.kloudless.com/v1/oauth",
    this.onPressed,
    this.stateOfCalendarCallback,
    this.attendeeDetails,
    this.initialEventDetails,
  });

  KloudlessWidgetBuilder fromContext<T>({
    BuildContext context,
    String stateId,
    T model,
  }) {
    stateOfCalendarCallback = CalStateBuilder<T>(
      stateId: stateId,
      memberEmailAddress: SevaCore.of(context).loggedInUser.email,
      environment: ENVIRONMENT.DEVELOPMENT,
      model: model,
    );

    attendeeDetails = AttendeDetails(
      attendee: Attendee(
        email: SevaCore.of(context).loggedInUser.email,
        name: SevaCore.of(context).loggedInUser.fullname,
      ),
      calendar: CalanderBuilder(
        caledarScope: SevaCore.of(context).loggedInUser.calendarScope,
        calendarAccId: SevaCore.of(context).loggedInUser.calendarAccId,
        calendarAccessToken:
            SevaCore.of(context).loggedInUser.calendarAccessToken,
        calendarEmail: SevaCore.of(context).loggedInUser.calendarEmail,
        calendarId: SevaCore.of(context).loggedInUser.calendarId,
      ),
    );
    return this;
  }
}

class CalanderBuilder {
  int calendarAccId;
  String calendarAccessToken;
  String calendarEmail;
  String caledarScope;
  String calendarId;

  CalanderBuilder({
    this.calendarAccId,
    this.calendarAccessToken,
    this.calendarEmail,
    this.caledarScope,
    this.calendarId,
  });

  Map<String, dynamic> toMap() => {
        "calendarAccId": this.calendarAccId,
        "calendarAccessToken": this.calendarAccessToken,
        "calendarEmail": this.calendarEmail,
        "caledarScope": this.caledarScope,
        "calendarId": this.calendarId,
      };

  CalanderBuilder.fromMap(Map<String, dynamic> map) {
    this.caledarScope = map['caledarScope'];
    this.calendarAccId = map['calendarAccId'];
    this.calendarAccessToken = map['calendarAccessToken'];
    this.calendarEmail = map['calendarEmail'];
    this.calendarId = map['calendarId'];
  }

  bool get defined {
    return calendarAccId != null;
  }
}

class CalStateBuilder<T> {
  final String stateId;
  final String memberEmailAddress;
  final ENVIRONMENT environment;
  final T model;

  String stateType;

  CalStateBuilder({
    @required this.stateId,
    this.environment,
    this.memberEmailAddress,
    this.model,
  }) {
    stateType = T.toString();
  }

  Map<String, dynamic> toMap() => {
        'stateId': this.stateId,
        'environment': this.environment.readable,
        'memberEmailAddress': this.memberEmailAddress,
        'stateType': this.stateType,
      };

  String get state {
    return this.toMap.toString();
  }
}
