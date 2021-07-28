import 'package:sevaexchange/new_baseline/models/configuration_model.dart';

class ConfigurationsList {
  ConfigurationsList();

  final List<ConfigurationModel> configurationsList = [
    ConfigurationModel(
        id: 'create_feeds', title_en: 'Create Feeds', type: 'general'),
    ConfigurationModel(
        id: 'accept_requests', title_en: 'Accept requests', type: 'request'),
    ConfigurationModel(
        id: 'billing_access', title_en: 'Billing Access', type: 'general'),
    ConfigurationModel(
        id: 'create_borrow_request',
        title_en: 'Create Borrow Request',
        type: 'request'),
    ConfigurationModel(
        id: 'create_events', title_en: 'Create Events', type: 'events'),
    ConfigurationModel(
        id: 'create_goods_offers',
        title_en: 'Create Goods Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_goods_request',
        title_en: 'Create Goods Requests',
        type: 'request'),
    ConfigurationModel(
        id: 'create_money_offers',
        title_en: 'Create Money Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_money_request',
        title_en: 'Create Money Requests',
        type: 'request'),
    ConfigurationModel(
        id: 'create_time_offers',
        title_en: 'Create Time Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_time_request',
        title_en: 'Create Time Requests',
        type: 'request'),
    ConfigurationModel(
        id: 'invite_bulk_members',
        title_en: 'Invite / Invite bulk members',
        type: 'general'),
    ConfigurationModel(
        id: 'create_group', title_en: 'Create Group', type: 'group'),
    ConfigurationModel(
        id: 'promote_user', title_en: 'Promote User', type: 'general'),
    ConfigurationModel(
        id: 'demote_user', title_en: 'Demote user', type: 'general'),
    ConfigurationModel(
        id: 'create_onetomany_request',
        title_en: 'Create One To Many Requests',
        type: 'request'),
    ConfigurationModel(
        id: 'create_virtual_request',
        title_en: 'Create virtual Request',
        type: 'request'),
    ConfigurationModel(
        id: 'create_public_request',
        title_en: 'Create public request',
        type: 'request'),
    ConfigurationModel(
        id: 'create_virtual_offer',
        title_en: 'Create Virtual offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_public_offer',
        title_en: 'Create public offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_virtual_event',
        title_en: 'Create virtual event',
        type: 'events'),
    ConfigurationModel(
        id: 'create_public_event',
        title_en: 'Create public event',
        type: 'events'),
    ConfigurationModel(
        id: 'create_endorsed_group',
        title_en: 'Create endorsed group',
        type: 'group'),
    ConfigurationModel(
        id: 'create_private_group',
        title_en: 'Create private group',
        type: 'group'),
    ConfigurationModel(
        id: 'one_to_many_offer',
        title_en: 'Create One To Many Offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'accept_time_offer', title_en: 'Accept Time Offer', type: 'offer'),
    ConfigurationModel(
        id: 'accept_money_offer',
        title_en: 'Accept Money Offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'accept_goods_offer',
        title_en: 'Accept Goods Offer',
        type: 'offer'),
  ];

  final List<ConfigurationModel> memberConfigurationsList = [
    ConfigurationModel(
        id: 'create_feeds', title_en: 'Create Feeds', type: 'general'),
    // ConfigurationModel(
    //     id: 'accept_offers', title_en: 'Accept Offers', type: 'offer'),
    ConfigurationModel(
        id: 'accept_requests', title_en: 'Accept requests', type: 'request'),
    ConfigurationModel(
        id: 'create_goods_offers',
        title_en: 'Create Goods Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_money_offers',
        title_en: 'Create Money Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_time_offers',
        title_en: 'Create Time Offers',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_time_request',
        title_en: 'Create Time Request',
        type: 'request'),
    ConfigurationModel(
        id: 'create_group', title_en: 'Create Group', type: 'group'),
    ConfigurationModel(
        id: 'create_virtual_request',
        title_en: 'Create virtual Request',
        type: 'request'),
    ConfigurationModel(
        id: 'create_virtual_offer',
        title_en: 'Create Virtual offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_public_offer',
        title_en: 'Create public offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'create_endorsed_group',
        title_en: 'Create endorsed group',
        type: 'group'),
    ConfigurationModel(
        id: 'create_private_group',
        title_en: 'Create private group',
        type: 'group'),
    ConfigurationModel(
        id: 'one_to_many_offer',
        title_en: 'Create One To Many Offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'accept_time_offer', title_en: 'Accept Time Offer', type: 'offer'),
    ConfigurationModel(
        id: 'accept_money_offer',
        title_en: 'Accept Money Offer',
        type: 'offer'),
    ConfigurationModel(
        id: 'accept_goods_offer',
        title_en: 'Accept Goods Offer',
        type: 'offer'),
  ];

  List<ConfigurationModel> getMemberData() {
    return memberConfigurationsList;
  }

  List<ConfigurationModel> getData() {
    return configurationsList;
  }
}
