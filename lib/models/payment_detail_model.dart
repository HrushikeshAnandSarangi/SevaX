enum PaymentMode {
  ACH,
  ZELLEPAY,
  PAYPAL,
  VENMO,
  SWIFT,
  OTHER,
}

class PaymentDetailModel {
  PaymentEventType? paymentEventType;
  PaymentMode? paymentMode;

  PaymentDetailModel({this.paymentMode, this.paymentEventType});
}

abstract class PaymentEventType {}

class ACHPayment extends PaymentEventType {
  String? bank_name;
  String? bank_address;
  String? routing_number;
  String? account_number;

  ACHPayment({
    this.bank_name,
    this.bank_address,
    this.routing_number,
    this.account_number,
  });
}

class ZellePayment extends PaymentEventType {
  String zelleId;

  ZellePayment({required this.zelleId});
}

class PayPalPayment extends PaymentEventType {
  String paypalId;

  PayPalPayment({this.paypalId = ''});
}

class VenmoPayment extends PaymentEventType {
  String venmoId;

  VenmoPayment({this.venmoId = ''});
}

class SwiftPayment extends PaymentEventType {
  String swiftId;

  SwiftPayment({this.swiftId = ''});
}

class OtherPayment extends PaymentEventType {
  String others;
  String other_details;

  OtherPayment({this.others = '', this.other_details = ''});
}
