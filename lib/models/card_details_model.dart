import 'dart:convert';

CardDetails cardDetailsFromJson(String str) =>
    CardDetails.fromJson(json.decode(str));

String cardDetailsToJson(CardDetails data) => json.encode(data.toJson());

class CardDetails {
  String? object;
  List<Datum>? data;
  bool? hasMore;
  String? url;

  CardDetails({
    this.object,
    this.data,
    this.hasMore,
    this.url,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) => CardDetails(
        object: json["object"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        hasMore: json["has_more"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "object": object,
        "data": List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
        "has_more": hasMore,
        "url": url,
      };
}

class Datum {
  String? id;
  String? object;
  BillingDetails? billingDetails;
  Card? card;
  int? created;
  String? customer;
  bool? livemode;
  Metadata? metadata;
  String? type;

  Datum({
    this.id,
    this.object,
    this.billingDetails,
    this.card,
    this.created,
    this.customer,
    this.livemode,
    this.metadata,
    this.type,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        object: json["object"],
        billingDetails: BillingDetails.fromJson(json["billing_details"]),
        card: Card.fromJson(json["card"]),
        created: json["created"],
        customer: json["customer"],
        livemode: json["livemode"],
        metadata: Metadata.fromJson(json["metadata"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "billing_details": billingDetails?.toJson(),
        "card": card?.toJson(),
        "created": created,
        "customer": customer,
        "livemode": livemode,
        "metadata": metadata?.toJson(),
        "type": type,
      };
}

class BillingDetails {
  Address? address;
  dynamic? email;
  dynamic? name;
  dynamic? phone;

  BillingDetails({
    this.address,
    this.email,
    this.name,
    this.phone,
  });

  factory BillingDetails.fromJson(Map<String, dynamic> json) => BillingDetails(
        address: Address.fromJson(json["address"]),
        email: json["email"],
        name: json["name"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "address": address?.toJson(),
        "email": email,
        "name": name,
        "phone": phone,
      };
}

class Address {
  dynamic? city;
  dynamic? country;
  dynamic? line1;
  dynamic? line2;
  dynamic? postalCode;
  dynamic? state;

  Address({
    this.city,
    this.country,
    this.line1,
    this.line2,
    this.postalCode,
    this.state,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        city: json["city"],
        country: json["country"],
        line1: json["line1"],
        line2: json["line2"],
        postalCode: json["postal_code"],
        state: json["state"],
      );

  Map<String, dynamic> toJson() => {
        "city": city,
        "country": country,
        "line1": line1,
        "line2": line2,
        "postal_code": postalCode,
        "state": state,
      };
}

class Card {
  String? brand;
  Checks? checks;
  String? country;
  int? expMonth;
  int? expYear;
  String? fingerprint;
  String? funding;
  dynamic? generatedFrom;
  String? last4;
  ThreeDSecureUsage? threeDSecureUsage;
  dynamic? wallet;

  Card({
    this.brand,
    this.checks,
    this.country,
    this.expMonth,
    this.expYear,
    this.fingerprint,
    this.funding,
    this.generatedFrom,
    this.last4,
    this.threeDSecureUsage,
    this.wallet,
  });

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        brand: json["brand"],
        checks: Checks.fromJson(json["checks"]),
        country: json["country"],
        expMonth: json["exp_month"],
        expYear: json["exp_year"],
        fingerprint: json["fingerprint"],
        funding: json["funding"],
        generatedFrom: json["generated_from"],
        last4: json["last4"],
        threeDSecureUsage:
            ThreeDSecureUsage.fromJson(json["three_d_secure_usage"]),
        wallet: json["wallet"],
      );

  Map<String, dynamic> toJson() => {
        "brand": brand,
        "checks": checks?.toJson(),
        "country": country,
        "exp_month": expMonth,
        "exp_year": expYear,
        "fingerprint": fingerprint,
        "funding": funding,
        "generated_from": generatedFrom,
        "last4": last4,
        "three_d_secure_usage": threeDSecureUsage?.toJson(),
        "wallet": wallet,
      };
}

class Checks {
  dynamic? addressLine1Check;
  dynamic? addressPostalCodeCheck;
  String? cvcCheck;

  Checks({
    this.addressLine1Check,
    this.addressPostalCodeCheck,
    this.cvcCheck,
  });

  factory Checks.fromJson(Map<String, dynamic> json) => Checks(
        addressLine1Check: json["address_line1_check"],
        addressPostalCodeCheck: json["address_postal_code_check"],
        cvcCheck: json["cvc_check"],
      );

  Map<String, dynamic> toJson() => {
        "address_line1_check": addressLine1Check,
        "address_postal_code_check": addressPostalCodeCheck,
        "cvc_check": cvcCheck,
      };
}

class ThreeDSecureUsage {
  bool? supported;

  ThreeDSecureUsage({
    this.supported,
  });

  factory ThreeDSecureUsage.fromJson(Map<String, dynamic> json) =>
      ThreeDSecureUsage(
        supported: json["supported"],
      );

  Map<String, dynamic> toJson() => {
        "supported": supported,
      };
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata();

  Map<String, dynamic> toJson() => {};
}
