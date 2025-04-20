// To parse this JSON data, do
//
//     final calendarEventDetailsResponse = calendarEventDetailsResponseFromJson(jsonString);

import 'dart:convert';

CalendarEventDetailsResponse calendarEventDetailsResponseFromJson(String str) =>
    CalendarEventDetailsResponse.fromJson(json.decode(str));

String calendarEventDetailsResponseToJson(CalendarEventDetailsResponse data) =>
    json.encode(data.toJson());

class CalendarEventDetailsResponse {
  CalendarEventDetailsResponse({
    this.api,
    this.type,
    this.id,
    this.accountId,
    this.calendarId,
    this.icalUid,
    this.recurrenceType,
    this.creator,
    this.organizer,
    this.onOrganizerCalendar,
    this.attendees,
    this.created,
    this.modified,
    this.allDay,
    this.start,
    this.startTimeZone,
    this.end,
    this.endTimeZone,
    this.name,
    this.description,
    this.location,
    this.status,
    this.visibility,
    this.attachments,
    this.useDefaultReminder,
    this.reminders,
    this.reminder,
    this.href,
  });

  String? api;
  String? type;
  String? id;
  String? accountId;
  String? calendarId;
  String? icalUid;
  String? recurrenceType;
  Creator? creator;
  Creator? organizer;
  bool? onOrganizerCalendar;
  List<Attendee>? attendees;
  DateTime? created;
  DateTime? modified;
  bool? allDay;
  DateTime? start;
  String? startTimeZone;
  DateTime? end;
  String? endTimeZone;
  String? name;
  String? description;
  String? location;
  String? status;
  dynamic visibility;
  List<dynamic>? attachments;
  bool? useDefaultReminder;
  List<dynamic>? reminders;
  dynamic reminder;
  String? href;

  factory CalendarEventDetailsResponse.fromJson(Map<String, dynamic> json) =>
      CalendarEventDetailsResponse(
        api: json["api"],
        type: json["type"],
        id: json["id"],
        accountId: json["account_id"],
        calendarId: json["calendar_id"],
        icalUid: json["ical_uid"],
        recurrenceType: json["recurrence_type"],
        creator: Creator.fromJson(json["creator"]),
        organizer: Creator.fromJson(json["organizer"]),
        onOrganizerCalendar: json["on_organizer_calendar"],
        attendees: List<Attendee>.from(
            json["attendees"].map((x) => Attendee.fromJson(x))),
        created: DateTime.parse(json["created"]),
        modified: DateTime.parse(json["modified"]),
        allDay: json["all_day"],
        start: DateTime.parse(json["start"]),
        startTimeZone: json["start_time_zone"],
        end: DateTime.parse(json["end"]),
        endTimeZone: json["end_time_zone"],
        name: json["name"],
        description: json["description"],
        location: json["location"],
        status: json["status"],
        visibility: json["visibility"],
        attachments: List<dynamic>.from(json["attachments"].map((x) => x)),
        useDefaultReminder: json["use_default_reminder"],
        reminders: List<dynamic>.from(json["reminders"].map((x) => x)),
        reminder: json["reminder"],
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "api": api,
        "type": type,
        "id": id,
        "account_id": accountId,
        "calendar_id": calendarId,
        "ical_uid": icalUid,
        "recurrence_type": recurrenceType,
        "creator": creator?.toJson(),
        "organizer": organizer?.toJson(),
        "on_organizer_calendar": onOrganizerCalendar,
        "attendees": attendees?.map((x) => x.toJson()).toList() ?? [],
        "created": created?.toIso8601String(),
        "modified": modified?.toIso8601String(),
        "all_day": allDay,
        "start": start?.toIso8601String(),
        "start_time_zone": startTimeZone,
        "end": end?.toIso8601String(),
        "end_time_zone": endTimeZone,
        "name": name,
        "description": description,
        "location": location,
        "status": status,
        "visibility": visibility,
        "attachments": List<dynamic>.from(attachments?.map((x) => x) ?? []),
        "use_default_reminder": useDefaultReminder,
        "reminders": List<dynamic>.from(reminders?.map((x) => x) ?? []),
        "reminder": reminder,
        "href": href,
      };
}

class Attendee {
  Attendee({
    this.name,
    this.email,
  });

  dynamic? id;
  String? name;
  String? email;
  String? status;
  bool? resource;

  factory Attendee.fromJson(Map<String, dynamic> json) => Attendee(
        name: json["name"] == null ? null : json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "email": email,
      };
}

class Creator {
  Creator({
    this.id,
    this.name,
    this.email,
  });

  dynamic? id;
  String? name;
  String? email;

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        id: json["id"],
        name: json["name"] == null ? null : json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name == null ? null : name,
        "email": email,
      };
}
