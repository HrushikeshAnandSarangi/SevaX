import 'package:sevaexchange/models/models.dart';

class BillingAddress extends DataModel {
  String companyname;
  String street_address1;
  String street_address2;
  String city;
  String state;
  String country;
  int pincode;
  String additionalnotes;
  BillingAddress({
    this.companyname,
    this.street_address1,
    this.street_address2,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.additionalnotes
  });

  BillingAddress.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('companyname')) {
      this.companyname = map['companyname'];
    }
    if (map.containsKey('street_address1')) {
      this.street_address1 = map['street_address1'];
    }
    if (map.containsKey('street_address2')) {
      this.street_address2 = map['street_address2'];
    }
    if (map.containsKey('city')) {
      this.city = map['city'];
    }
    if (map.containsKey('state')) {
      this.state = map['state'];
    }
    if (map.containsKey('country')) {
      this.country = map['country'];
    }
    if (map.containsKey('pincode')) {
      this.pincode = map['pincode'];
    }
    if (map.containsKey('additionalnotes')) {
      this.additionalnotes = map['additionalnotes'];
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
}

class PaymentRecord extends DataModel {
  String payment_created_on;
  String type;
  PaymentRecord({
    this.payment_created_on,
    this.type
  });

  PaymentRecord.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('payment_created_on')) {
      this.payment_created_on = map['payment_created_on'];
    }
    if (map.containsKey('type')) {
      this.type = map['type'];
    }
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
  String primaryEmail;
  BillingAddress billing_address;
  List<PaymentRecord> payment_records;
  String logo_url;
  String cover_url;
  String creatorEmail;
  String created_at;
  List<String> timebanks;
  List<String> admins;
  List<String> coordinators;
  List<String> members;

  CommunityModel({
    this.id,
    this.name,
    this.primaryEmail,
    this.billing_address,
    this.payment_records,
    this.logo_url,
    this.cover_url,
    this.creatorEmail,
    this.created_at,
    this.timebanks = const <String>[],
    this.admins = const <String>[],
    this.coordinators = const <String>[],
    this.members = const <String>[],
  });

  CommunityModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('id')) {
      this.id = map['id'];
    }
    if (map.containsKey('name')) {
      this.name = map['name'];
    }
    if (map.containsKey('primaryEmail')) {
      this.primaryEmail = map['primaryEmail'];
    }
    if (map.containsKey('billing_address')) {
      this.billing_address = new BillingAddress.fromMap(map['billing_address'].cast<String, dynamic>());
    }
    if (map.containsKey('payment_records')) {
      this.payment_records = [];
    }
    if (map.containsKey('logo_url')) {
      this.logo_url = map['logo_url'];
    }
    if (map.containsKey('cover_url')) {
      this.cover_url = map['cover_url'];
    }
    if (map.containsKey('creatorEmail')) {
      this.creatorEmail = map['creatorEmail'];
    }
    if (map.containsKey('created_at')) {
      this.created_at = map['created_at'];
    }
    if (map.containsKey('timebanks')) {
      List timeBanks = map['timebanks'];
      this.timebanks = List.castFrom(timeBanks);
    }
    if (map.containsKey('admins')) {
      List admins = map['admins'];
      this.admins = List.castFrom(admins);
    }

    if (map.containsKey('coordinators')) {
      List coordinatorList = map['coordinators'];
      this.coordinators = List.castFrom(coordinatorList);
    }

    if (map.containsKey('members')) {
      List memberList = map['members'];
      this.members = List.castFrom(memberList);
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.id != null && this.id.isNotEmpty) {
      object['id'] = this.id;
    }
    if (this.name != null && this.name.isNotEmpty) {
      object['name'] = this.name;
    }
    if (this.primaryEmail != null && this.primaryEmail.isNotEmpty) {
      object['primaryEmail'] = this.primaryEmail;
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
    if (this.creatorEmail != null && this.creatorEmail.isNotEmpty) {
      object['creatorEmail'] = this.creatorEmail;
    }
    if (this.created_at != null) {
      object['created_at'] = this.created_at;
    }
    if (this.timebanks != null) {
      object['timebanks '] = this.timebanks;
    }
    if (this.admins != null) {
      object['admins'] = this.admins;
    }
    if (this.coordinators != null) {
      object['coordinators'] = this.coordinators;
    }
    if (this.members != null) {
      object['members'] = this.members;
    }
    return object;
  }
}


class CommunityListModel {
  List<CommunityModel> communities = [];
  CommunityListModel();

  add(community) {
    this.communities.add(community);
  }
  List<CommunityModel> get getCommunities => communities;
}
