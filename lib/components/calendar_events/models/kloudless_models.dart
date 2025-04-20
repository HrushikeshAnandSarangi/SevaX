import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/components/calendar_events/models/calendar_response.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/views/core.dart';

import '../../../flavor_config.dart';

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
  final Attendee? attendee;
  final CalanderBuilder? calendar;

  AttendeDetails({
    this.attendee,
    this.calendar,
  });
}

class KloudlessCalendarEvent {
  final String? eventTitle;
  final String? eventDescription;
  final String? eventStart;
  final String? eventEnd;
  final String? eventLocation;

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
  String? eventId;
  CalanderBuilder? calendar;

  EventMetaData({this.eventId, this.calendar});

  EventMetaData.fromMap(Map<String, dynamic> map) {
    this.calendar = CalanderBuilder.fromMap(map['calendar']);
    this.eventId = map['eventId'];
  }

  Map<String, dynamic> toMap() => {
        "calendar": this.calendar?.toMap(),
        "eventId": this.eventId,
      };
}

class KloudlessWidgetBuilder {
  String? authorizationUrl;
  String? clienId;
  String? redirectUrl;
  CalStateBuilder? stateOfCalendarCallback;
  AttendeDetails? attendeeDetails;
  EventMetaData? initialEventDetails;

  Function? onPressed;

  KloudlessWidgetBuilder({
    this.clienId = "B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh",
    this.authorizationUrl = "https://api.kloudless.com/v1/oauth",
    this.onPressed,
    this.stateOfCalendarCallback,
    this.attendeeDetails,
    this.initialEventDetails,
  }) {
    this.redirectUrl =
        FlavorConfig.values.cloudFunctionBaseURL + "/callbackurlforoauth";
  }

  KloudlessWidgetBuilder fromContext<M, T>({
    BuildContext? context,
    String id = '',
    required T model,
  }) {
    if (context == null) throw ArgumentError.notNull('context');
    final fullname = SevaCore.of(context).loggedInUser.fullname;
    if (fullname == null) throw StateError('User fullname is required');

    stateOfCalendarCallback = CalStateBuilder<M, T>(
      name: fullname,
      id: id,
      memberEmail: SevaCore.of(context).loggedInUser.email ?? '',
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
  int? calendarAccId;
  String? calendarAccessToken;
  String? calendarEmail;
  String? caledarScope;
  String? calendarId;

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
    this.calendarAccId = int.tryParse(map['calendarAccId'].toString());
    this.calendarAccessToken = map['calendarAccessToken'];
    this.calendarEmail = map['calendarEmail'];
    this.calendarId = map['calendarId'];
  }

  bool get defined {
    return calendarAccId != null;
  }
}

class CalStateBuilder<M, T> {
  final String? memberEmail;
  final String? id;
  final T? model;
  final String? name;

  String? stateType;

  CalStateBuilder({
    required this.id,
    required this.memberEmail,
    required this.model,
    required this.name,
  }) {
    stateType = T.toString();
  }

  Map<String, dynamic> toMap() => {
        'memberEmail': this.memberEmail,
        "name": "name",
        'type': this.stateType,
        'id': this.id,
        "mode": getModeFromType(M, T),
        "fromMobile": true,
      };

  String toJson() {
    var json = jsonEncode(toMap());
    return json;
  }

  String get state {
    return this.toMap.toString();
  }

  String getModeFromType(
    Type m,
    Type t,
  ) {
    const MODE_CREATE_MODE_EVENT = "MODE.CREATE_MODE.EVENT";
    const MODE_CREATE_MODE_REQUEST = "MODE.CREATE_MODE.REQUEST";
    const MODE_CREATE_MODE_OFFER = "MODE.CREATE_MODE.OFFER";

    const MODE_APPLY_MODE_REQUEST = "MODE.APPLY_MODE.REQUEST";
    const MODE_APPLY_MODE_OFFER = "MODE.APPLY_MODE.OFFER";

    const UNRESOLVED_MODE = "UNRESOLVED_MODE";

    switch (T) {
      case RequestModel:
        return M == CreateMode
            ? MODE_CREATE_MODE_REQUEST
            : MODE_APPLY_MODE_REQUEST;

      case OfferModel:
        return M == CreateMode ? MODE_CREATE_MODE_OFFER : MODE_APPLY_MODE_OFFER;

      case ProjectModel:
        return MODE_CREATE_MODE_EVENT;

      default:
        return UNRESOLVED_MODE;
    }
  }
}
