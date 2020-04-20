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

class ValidationErrors {
  static const String titleError = 'Please enter the subject of your offer';
  static const String genericError = 'Please enter some text';
  static const String classHours =
      'Please enter the hours required for the class';
  static const String hoursNotInt = 'Entered number of hours is not valid';
  static const String preprationTimeError =
      'Please enter your preperation time';
  static const String locationError = 'Please select location';
  static const String sizeOfClassIsNotInt = "Size of class can't be in decimal";
  static const String sizeOfClassError = "Please enter valid size of class";
  static const String offerProfitError = "We cannot publish this Class. There are insufficient credits from the class. Please revise the Prep time or the number of students and submit the offer again";

  // static const String titleError = 'Please enter the subject of your offer';
}
