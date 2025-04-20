import 'package:sevaexchange/new_baseline/models/configuration_model.dart';

class ConfigurationsList {
  ConfigurationsList();

  final List<ConfigurationModel> configurationsList = [
    ConfigurationModel(
        id: 'create_feeds', titleEn: 'Create Feeds', type: 'general'),
    /*ConfigurationModel(
        id: 'accept_requests', titleEn: 'Accept requests', type: 'request'),*/
    ConfigurationModel(
        id: 'billing_access', titleEn: 'Billing Access', type: 'general'),
    ConfigurationModel(
        id: 'create_borrow_request',
        titleEn: 'Create Borrow Request',
        type: 'request'),
    ConfigurationModel(
        id: 'create_events', titleEn: 'Create Events', type: 'events'),
    ConfigurationModel(
        id: 'create_goods_offers',
        titleEn: 'Create Goods Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_goods_request',
        titleEn: 'Create Goods Requests',
        type: 'request'),
    ConfigurationModel(
        id: 'create_money_offers',
        titleEn: 'Create Money Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_money_request',
        titleEn: 'Create Money Requests',
        type: 'request'),
    ConfigurationModel(
        id: 'invite_bulk_members',
        titleEn: 'Invite / Invite bulk members',
        type: 'general'),
    ConfigurationModel(
        id: 'create_group', titleEn: 'Create Group', type: 'group'),
    ConfigurationModel(
        id: 'promote_user', titleEn: 'Promote User', type: 'general'),
    ConfigurationModel(
        id: 'demote_user', titleEn: 'Demote user', type: 'general'),
    ConfigurationModel(
        id: 'create_onetomany_request',
        titleEn: 'Create One To Many Requests',
        type: 'request'),
    ConfigurationModel(
        id: 'create_virtual_request',
        titleEn: 'Create virtual Request',
        type: 'request'),
    ConfigurationModel(
        id: 'create_public_request',
        titleEn: 'Create public request',
        type: 'request'),
    ConfigurationModel(
        id: 'create_virtual_offer',
        titleEn: 'Create Virtual offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_public_offer',
        titleEn: 'Create public offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_virtual_event',
        titleEn: 'Create virtual event',
        type: 'events'),
    ConfigurationModel(
        id: 'create_public_event',
        titleEn: 'Create public event',
        type: 'events'),
    ConfigurationModel(
        id: 'create_endorsed_group',
        titleEn: 'Create endorsed group',
        type: 'group'),
    ConfigurationModel(
        id: 'create_private_group',
        titleEn: 'Create private group',
        type: 'group'),
    ConfigurationModel(
        id: 'one_to_many_offer',
        titleEn: 'Create One To Many Offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'accept_time_offer', titleEn: 'Accept Time Offer', type: 'offer'),
    ConfigurationModel(
        id: 'accept_money_offer', titleEn: 'Accept Money Offer', type: 'offer'),
    ConfigurationModel(
        id: 'accept_goods_offer', titleEn: 'Accept Goods Offer', type: 'offer'),
    ConfigurationModel(
        id: 'accept_one_to_many_offer',
        titleEn: 'Accept One To Many Offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_lending_offers',
        titleEn: 'Create Lending Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'accept_lending_offers',
        titleEn: 'Accept Lending Offers',
        type: 'offer'),
  ];

  final List<ConfigurationModel> memberConfigurationsList = [
    ConfigurationModel(
        id: 'create_feeds', titleEn: 'Create Feeds', type: 'general'),
    /*  ConfigurationModel(
        id: 'accept_requests', titleEn: 'Accept requests', type: 'request'),*/
    ConfigurationModel(
        id: 'create_goods_offers',
        titleEn: 'Create Goods Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_borrow_request',
        titleEn: 'Create Borrow Request',
        type: 'request'),
    ConfigurationModel(
        id: 'create_money_offers',
        titleEn: 'Create Money Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_group', titleEn: 'Create Group', type: 'group'),
    ConfigurationModel(
        id: 'create_virtual_request',
        titleEn: 'Create virtual Request',
        type: 'request'),
    ConfigurationModel(
        id: 'create_virtual_offer',
        titleEn: 'Create Virtual offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_public_offer',
        titleEn: 'Create public offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_endorsed_group',
        titleEn: 'Create endorsed group',
        type: 'group'),
    ConfigurationModel(
        id: 'create_private_group',
        titleEn: 'Create private group',
        type: 'group'),
    ConfigurationModel(
        id: 'one_to_many_offer',
        titleEn: 'Create One To Many Offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'accept_time_offer', titleEn: 'Accept Time Offer', type: 'offer'),
/*    ConfigurationModel(
        id: 'accept_money_offer',
        titleEn: 'Accept Money Offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'accept_goods_offer',
        titleEn: 'Accept Goods Offer',
        type: 'offer'),*/
    ConfigurationModel(
        id: 'accept_one_to_many_offer',
        titleEn: 'Accept One To Many Offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_lending_offers',
        titleEn: 'Create Lending Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'accept_lending_offers',
        titleEn: 'Accept Lending Offers',
        type: 'offer'),
  ];

  List<ConfigurationModel> getMemberData() {
    return memberConfigurationsList;
  }

  List<ConfigurationModel> getData() {
    return configurationsList;
  }
}
