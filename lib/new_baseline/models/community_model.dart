import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/models/models.dart';

class BillingAddress {
  String companyname;
  String street_address1;
  String street_address2;
  String city;
  String state;
  String country;
  int pincode;
  String additionalnotes;

  BillingAddress(Map<String, dynamic> map) {
    this.companyname = map.containsKey('companyname') ? map['companyname'] : '';
    this.street_address1 =
        map.containsKey('street_address1') ? map['street_address1'] : '';
    this.street_address2 =
        map.containsKey('street_address2') ? map['street_address2'] : '';
    this.city = map.containsKey('city') ? map['city'] : '';
    this.state = map.containsKey('state') ? map['state'] : '';
    this.country = map.containsKey('country') ? map['country'] : '';
    this.pincode = map.containsKey('pincode') ? map['pincode'] : null;
    this.additionalnotes =
        map.containsKey('additionalnotes') ? map['additionalnotes'] : '';
  }
  updateValueByKey(String key, dynamic value) {
    if (key == 'companyname') {
      this.companyname = value;
    }
    if (key == 'street_address1') {
      this.street_address1 = value;
    }
    if (key == 'street_address2') {
      this.street_address2 = value;
    }
    if (key == 'city') {
      this.city = value;
    }
    if (key == 'state') {
      this.state = value;
    }
    if (key == 'country') {
      this.country = value;
    }
    if (key == 'pincode') {
      this.pincode = value;
    }
    if (key == 'additionalnotes') {
      this.additionalnotes = value;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};
    if (this.companyname != null) {
      object['companyname'] = this.companyname;
    }
    if (this.street_address1 != null) {
      object['street_address1'] = this.street_address1;
    }
    if (this.street_address2 != null) {
      object['street_address2'] = this.street_address2;
    }
    if (this.city != null) {
      object['city'] = this.city;
    }
    if (this.state != null) {
      object['state'] = this.state;
    }
    if (this.country != null) {
      object['country'] = this.country;
    }
    if (this.pincode != null) {
      object['pincode'] = this.pincode;
    }
    if (this.additionalnotes != null) {
      object['additionalnotes'] = this.additionalnotes;
    }
    return object;
  }

  @override
  String toString() {
    return 'BillingAddress{companyname: $companyname, street_address1: $street_address1, street_address2: $street_address2, city: $city, state: $state, country: $country, pincode: $pincode, additionalnotes: $additionalnotes}';
  }
}

class PaymentRecord extends DataModel {
  String payment_created_on;
  String type;
  PaymentRecord({this.payment_created_on, this.type});

  PaymentRecord.fromMap(Map<String, dynamic> map) {
    this.payment_created_on =
        map.containsKey('payment_created_on') ? map['payment_created_on'] : '';
    this.type = map.containsKey('type') ? map['type'] : '';
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};
    if (this.payment_created_on != null) {
      object['payment_created_on'] = this.payment_created_on;
    }
    if (this.type != null) {
      object['type'] = this.type;
    }
    return object;
  }
}

class CommunityModel extends DataModel {
  String id;
  String name;
  String primary_email;
  String about;
  BillingAddress billing_address;
  List<PaymentRecord> payment_records;
  String logo_url;
  String cover_url;
  String creator_email;
  String created_by;
  String created_at;
  String primary_timebank;
  double taxPercentage;
  List<String> timebanks;
  List<String> admins;
  List<String> coordinators;
  List<String> members;
  int transactionCount;
  GeoFirePoint location;
  bool softDelete;

  Map<String, dynamic> billingQuota;
  Map<String, dynamic> payment;

  CommunityModel(Map<String, dynamic> map) {
    this.transactionCount = map.containsKey('transactionCount')
        ? map['transactionCount'] ?? 0
        : null;
    this.taxPercentage =
        map["taxPercentage"] != null ? map["taxPercentage"].toDouble() : 0.0;
    this.payment = Map<String, dynamic>.from(map['payment'] ?? {});
    this.transactionCount = map['transactionCount'] ?? 0;
    this.billingQuota = Map<String, dynamic>.from(map['billing_quota'] ?? {});
    this.id = map != null ? map.containsKey('id') ? map['id'] : '' : '';
    this.name = map.containsKey('name') ? map['name'] : '';
    this.about = map.containsKey('about') ? map['about'] : '';
    this.primary_email =
        map.containsKey('primary_email') ? map['primary_email'] : '';
    this.billing_address = map.containsKey('billing_address')
        ? BillingAddress(map['billing_address'].cast<String, dynamic>())
        : BillingAddress({});
    this.payment_records = map.containsKey('payment_records')
        ? [PaymentRecord.fromMap(map['payment_records'])]
        : [PaymentRecord.fromMap({})];
    this.logo_url = map.containsKey('logo_url') ? map['logo_url'] : '';
    this.cover_url = map.containsKey('cover_url') ? map['cover_url'] : '';
    this.creator_email =
        map.containsKey('creator_email') ? map['creator_email'] : '';
    this.created_by = map.containsKey('created_by') ? map['created_by'] : '';
    this.created_at = map.containsKey('created_at') ? map['created_at'] : '';
    this.primary_timebank =
        map.containsKey('primary_timebank') ? map['primary_timebank'] : '';
    this.timebanks =
        map.containsKey('timebanks') ? List.castFrom(map['timebanks']) : [];
    this.admins = map.containsKey('admins') ? List.castFrom(map['admins']) : [];
    this.coordinators = map.containsKey('coordinators')
        ? List.castFrom(map['coordinators'])
        : [];
    this.members =
        map.containsKey('members') ? List.castFrom(map['members']) : [];
    this.location = getLocation(map);
    this.softDelete = map.containsKey('softDelete') ? map['softDelete'] : false;
  }
  GeoFirePoint getLocation(map) {
    GeoFirePoint geoFirePoint;
    if (map.containsKey("location") &&
        map["location"] != null &&
        map['location']['geopoint'] != null) {
      if (map['location']['geopoint'] is GeoPoint) {
        GeoPoint geoPoint = map['location']['geopoint'];
        geoFirePoint = Geoflutterfire()
            .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
      } else {
        geoFirePoint = GeoFirePoint(
          map["location"]["geopoint"]["_latitude"],
          map["location"]["geopoint"]["_longitude"],
        );
      }
    } else {
      geoFirePoint = GeoFirePoint(40.754387, -73.984291);
    }
    return geoFirePoint;
  }

  updateValueByKey(String key, dynamic value) {
    if (key == 'id') {
      this.id = value;
    }
    if (key == 'name') {
      this.name = value;
    }
    if (key == 'about') {
      this.about = value;
    }
    if (key == 'taxPercentage') {
      this.taxPercentage = value;
    }
    if (key == 'primary_email') {
      this.primary_email = value;
    }

    if (key == 'locar=tion') {
      this.location = value;
    }

    if (key == 'billing_address') {
      this.billing_address = new BillingAddress(value);
    }

    if (key == 'payment_records') {
      this.payment_records = [];
      ;
    }

    if (key == 'logo_url') {
      this.logo_url = value;
    }
    if (key == 'cover_url') {
      this.cover_url = value;
    }
    if (key == 'creator_email') {
      this.creator_email = value;
    }
    if (key == 'created_by') {
      this.created_by = value;
    }
    if (key == 'created_at') {
      this.created_at = value;
    }
    if (key == 'primary_timebank') {
      this.primary_timebank = value;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.taxPercentage != null) {
      object['taxPercentage'] = this.taxPercentage;
    }

    if (this.id != null && this.id.isNotEmpty) {
      object['id'] = this.id;
    }
    if (this.name != null && this.name.isNotEmpty) {
      object['name'] = this.name;
    }

    if (this.about != null && this.about.isNotEmpty) {
      object['about'] = this.about;
    }
    if (this.primary_email != null && this.primary_email.isNotEmpty) {
      object['primary_email'] = this.primary_email;
    }
    if (this.billing_address != null) {
      object['billing_address'] = this.billing_address.toMap();
    }

    if (this.logo_url != null && this.logo_url.isNotEmpty) {
      object['logo_url'] = this.logo_url;
    }
    if (this.cover_url != null && this.cover_url.isNotEmpty) {
      object['cover_url'] = this.cover_url;
    }
    if (this.creator_email != null && this.creator_email.isNotEmpty) {
      object['creator_email'] = this.creator_email;
    }
    if (this.created_at != null) {
      object['created_at'] = this.created_at;
    }
    if (this.created_by != null) {
      object['created_by'] = this.created_by;
    }
    if (this.timebanks != null) {
      object['timebanks'] = this.timebanks;
    }
    if (this.admins != null) {
      object['admins'] = this.admins;
    }
    if (this.coordinators != null) {
      object['coordinators'] = this.coordinators;
    }

    if (this.coordinators != null) {
      object['coordinators'] = this.coordinators;
    }
    if (this.members != null) {
      object['members'] = this.members;
    }
    if (this.primary_timebank != null) {
      object['primary_timebank'] = this.primary_timebank;
    }
    if (this.location != null) {
      object['location'] = this.location.data;
    }

    object['softDelete'] = false;
    return object;
  }

  @override
  String toString() {
    return 'CommunityModel{id: $id, '
        'name: $name, '
        'primary_email: $primary_email, '
        'about: $about, '
        'billing_address: $billing_address,'
        ' payment_records: $payment_records, '
        ' logo_url: $logo_url, '
        ' cover_url: $cover_url,'
        ' creator_email: $creator_email,'
        ' created_by: $created_by, '
        'created_at: $created_at, '
        'primary_timebank: $primary_timebank, '
        'timebanks: $timebanks, '
        'admins: $admins, '
        'location: $location, '
        'coordinators: $coordinators,'
        ' members: $members, '
//        'transactionCount: $transactionCount}'
        'taxPercentage: $taxPercentage}';
  }
}

class CommunityListModel {
  List<CommunityModel> communities = [];
  bool loading = false;
  CommunityListModel();

  add(community) {
    this.communities.add(community);
  }

  removeall() {
    this.communities = [];
  }

  List<CommunityModel> get getCommunities => communities;
}
