import 'dart:convert';

UpgradePlanBannerModel upgradePlanBannerModelFromJson(String str) =>
    UpgradePlanBannerModel.fromJson(json.decode(str));

class UpgradePlanBannerModel {
  UpgradePlanBannerModel(
      {this.pin_feeds,
      this.multi_lang,
      this.single_member_messaging,
      this.recurring_schedules,
      this.email_notifications,
      this.push_notifications,
      this.stock_images,
      this.user_defined_skills_interests,
      this.images_msgs_propriety,
      this.onetomany_offers,
      this.calendar_sync,
      this.multi_member_messaging,
      this.project_templates,
      this.invoice_generation,
      this.analytics_generation,
      this.upload_cv,
      this.csv_import_users,
      this.private_groups,
      this.parent_timebanks,
      this.cash_donation,
      this.goods_donation,
      this.admins_child_timebanks_messaging,
      this.cash_request,
      this.goods_request,
      this.sponsored_groups,
      this.add_manual_time,
      this.onetomany_requests,
      this.borrow_requests,
      this.multiple_super_admins,
      this.public_to_sevax_global,
      this.community_sponsors,
      this.admin_role_customization,
      this.cash_goods_offers,
      this.lending_offers});
  BannerDetails? pin_feeds;
  BannerDetails? multi_lang;
  BannerDetails? single_member_messaging;
  BannerDetails? recurring_schedules;
  BannerDetails? email_notifications;
  BannerDetails? push_notifications;
  BannerDetails? stock_images;
  BannerDetails? user_defined_skills_interests;
  BannerDetails? images_msgs_propriety;
  BannerDetails? onetomany_offers;
  BannerDetails? calendar_sync;
  BannerDetails? multi_member_messaging;
  BannerDetails? project_templates;
  BannerDetails? invoice_generation;
  BannerDetails? analytics_generation;
  BannerDetails? upload_cv;
  BannerDetails? csv_import_users;
  BannerDetails? private_groups;
  BannerDetails? parent_timebanks;
  BannerDetails? cash_donation;
  BannerDetails? goods_donation;
  BannerDetails? admins_child_timebanks_messaging;
  BannerDetails? cash_request;
  BannerDetails? goods_request;
  BannerDetails? multiple_super_admins;
  BannerDetails? sponsored_groups;
  BannerDetails? add_manual_time;
  BannerDetails? onetomany_requests;
  BannerDetails? borrow_requests;
  BannerDetails? public_to_sevax_global;
  BannerDetails? community_sponsors;
  BannerDetails? admin_role_customization;
  BannerDetails? cash_goods_offers;
  BannerDetails? lending_offers;

  factory UpgradePlanBannerModel.fromJson(Map<String, dynamic> json) =>
      UpgradePlanBannerModel(
        pin_feeds: json.containsKey("pin_feeds")
            ? BannerDetails.fromJson(json["pin_feeds"])
            : null,
        multi_lang: json.containsKey("multi_lang")
            ? BannerDetails.fromJson(json["multi_lang"])
            : null,
        single_member_messaging: json.containsKey("single_member_messaging")
            ? BannerDetails.fromJson(json["single_member_messaging"])
            : null,
        recurring_schedules: json.containsKey("recurring_schedules")
            ? BannerDetails.fromJson(json["recurring_schedules"])
            : null,
        email_notifications: json.containsKey("email_notifications")
            ? BannerDetails.fromJson(json["email_notifications"])
            : null,
        push_notifications: json.containsKey("push_notifications")
            ? BannerDetails.fromJson(json["push_notifications"])
            : null,
        stock_images: json.containsKey("stock_images")
            ? BannerDetails.fromJson(json["stock_images"])
            : null,
        user_defined_skills_interests:
            json.containsKey("user_defined_skills_interests")
                ? BannerDetails.fromJson(json["user_defined_skills_interests"])
                : null,
        images_msgs_propriety: json.containsKey("images_msgs_propriety")
            ? BannerDetails.fromJson(json["images_msgs_propriety"])
            : null,
        onetomany_offers: json.containsKey("onetomany_offers")
            ? BannerDetails.fromJson(json["onetomany_offers"])
            : null,
        calendar_sync: json.containsKey("calendar_sync")
            ? BannerDetails.fromJson(json["calendar_sync"])
            : null,
        multi_member_messaging: json.containsKey("multi_member_messaging")
            ? BannerDetails.fromJson(json["multi_member_messaging"])
            : null,
        project_templates: json.containsKey("project_templates")
            ? BannerDetails.fromJson(json["project_templates"])
            : null,
        invoice_generation: json.containsKey("invoice_generation")
            ? BannerDetails.fromJson(json["invoice_generation"])
            : null,
        analytics_generation: json.containsKey("analytics_generation")
            ? BannerDetails.fromJson(json["analytics_generation"])
            : null,
        upload_cv: json.containsKey("upload_cv")
            ? BannerDetails.fromJson(json["upload_cv"])
            : null,
        csv_import_users: json.containsKey("csv_import_users")
            ? BannerDetails.fromJson(json["csv_import_users"])
            : null,
        private_groups: json.containsKey("private_groups")
            ? BannerDetails.fromJson(json["private_groups"])
            : null,
        parent_timebanks: json.containsKey("parent_timebanks")
            ? BannerDetails.fromJson(json["parent_timebanks"])
            : null,
        cash_donation: json.containsKey("cash_donation")
            ? BannerDetails.fromJson(json["cash_donation"])
            : null,
        goods_donation: json.containsKey("goods_donation")
            ? BannerDetails.fromJson(json["goods_donation"])
            : null,
        admins_child_timebanks_messaging: json
                .containsKey("admins_child_timebanks_messaging")
            ? BannerDetails.fromJson(json["admins_child_timebanks_messaging"])
            : null,
        cash_request: json.containsKey("cash_request")
            ? BannerDetails.fromJson(json["cash_request"])
            : null,
        goods_request: json.containsKey("goods_request")
            ? BannerDetails.fromJson(json["goods_request"])
            : null,
        sponsored_groups: json.containsKey("sponsored_groups")
            ? BannerDetails.fromJson(json["sponsored_groups"])
            : null,
        add_manual_time: json.containsKey("add_manual_time")
            ? BannerDetails.fromJson(json["add_manual_time"])
            : null,
        onetomany_requests: json.containsKey("onetomany_requests")
            ? BannerDetails.fromJson(json["onetomany_requests"])
            : null,
        borrow_requests: json.containsKey("borrow_requests")
            ? BannerDetails.fromJson(json["borrow_requests"])
            : null,
        multiple_super_admins: json.containsKey("multiple_super_admins")
            ? BannerDetails.fromJson(json["multiple_super_admins"])
            : null,
        public_to_sevax_global: json.containsKey("public_to_sevax_global")
            ? BannerDetails.fromJson(json["public_to_sevax_global"])
            : null,
        community_sponsors: json.containsKey("community_sponsors")
            ? BannerDetails.fromJson(json["community_sponsors"])
            : null,
        admin_role_customization: json.containsKey("admin_role_customization")
            ? BannerDetails.fromJson(json["admin_role_customization"])
            : null,
        cash_goods_offers: json.containsKey("cash_goods_offers")
            ? BannerDetails.fromJson(json["cash_goods_offers"])
            : null,
        lending_offers: json.containsKey("lending_offers")
            ? BannerDetails.fromJson(json["lending_offers"])
            : null,
      );
}

class BannerDetails {
  BannerDetails({
    this.name,
    this.message,
    this.images,
  });

  String? name;
  String? message;
  List<String>? images;

  factory BannerDetails.fromJson(Map<String, dynamic> json) => BannerDetails(
        name: json["name"],
        message: json["message"],
        images: List<String>.from(json["images"].map((x) => x)),
      );
}
