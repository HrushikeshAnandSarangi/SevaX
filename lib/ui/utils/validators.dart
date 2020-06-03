import 'dart:async';

class Validators {
  var titleValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (title, sink) {
      if (title != null && title.length > 0) {
        sink.add(title);
        print("no error");
      } else {
        sink.addError('Please enter the subject of your offer');
        print(" error");
      }
    },
  );
  var preperationValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (title, sink) {
      if (title != null) {
        sink.add(title);
      } else {
        sink.addError('Please enter your preperation time');
      }
    },
  );
  var classHoursValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (title, sink) {
      if (title != null) {
        sink.add(title);
      } else {
        sink.addError('Please enter the hours required for the class');
      }
    },
  );

  var genericValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (text, sink) {
      if (text != null && text.length > 0) {
        sink.add(text);
        print("no error");
      } else {
        print("error");
        sink.addError('Please enter some text');
      }
    },
  );
}

//keys for localisation
class ValidationErrors {
  static const String titleError = 'title_error';
  static const String genericError = 'generic_error';
  static const String classHours = 'class_hours';
  static const String hoursNotInt = 'hours_not_int';
  static const String preprationTimeError = 'prepration_time_error';
  static const String locationError = 'location_error';
  static const String sizeOfClassIsNotInt = "size_of_class_not_int";
  static const String sizeOfClassError = "size_of_class_error";
  static const String offerCreditError = "offer_credit_error";

  // static const String titleError = 'Please enter the subject of your offer';
}
