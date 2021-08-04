// One to many offer notifications
// --DEBIT_FROM_OFFER,
// CREDIT_FROM_OFFER_ON_HOLD,//timebank notification
// CREDIT_FROM_OFFER_APPROVED,//timebank notification
// --CREDIT_FROM_OFFER,//user notification
// DEBIT_FULFILMENT_FROM_TIMEBANK,//timebank notification
// --NEW_MEMBER_SIGNUP_OFFER,//user notification
// --OFFER_FULFILMENT_ACHIEVED,// user notification
// --OFFER_SUBSCRIPTION_COMPLETED,//user ///successfully signed up
// --FEEDBACK_FROM_SIGNUP_MEMBER,//feedback user

///Replace the string accordingly [*n -> Seva Credits] [*class -> class name] [*name -> name]
class UserNotificationMessage {
  static const String CREDIT_FROM_OFFER =
      "You have been credited *n Seva Credits for the *class that you hosted";
  static const String DEBIT_FROM_OFFER =
      "*n Seva Credits have been debited from your account";
  static const String NEW_MEMBER_SIGNUP_OFFER =
      "*name has signed up for your class \"*class\"";
  static const String OFFER_SUBSCRIPTION_COMPLETED =
      "You have successfully signed up for the *class";
  static const String OFFER_FULFILMENT_ACHIEVED =
      "You have received *n Seva Credits for the *class that you recently hosted";
  static const String FEEDBACK_FROM_SIGNUP_MEMBER =
      "Please provide feedback for the *class that you recently attended";
}

class TimebankNotificationMessage {
  static const String DEBIT_FULFILMENT_FROM_TIMEBANK =
      "*n Seva Credits have been sent to *name from the credits received for *class ";
  static const String CREDIT_FROM_OFFER_APPROVED =
      "Received *n Seva Credits from the the offer *class";

  static const String MEMBER_REPORT = "*name has been reported";
}
