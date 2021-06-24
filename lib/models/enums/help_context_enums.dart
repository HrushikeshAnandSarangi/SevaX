import 'package:sevaexchange/utils/log_printer/log_printer.dart';

enum HelpContextMemberType {
  seva_community,
  groups,
  events,
  requests,
  time_requests,
  one_to_many_requests,
  money_requests,
  goods_requests,
  offers,
  time_offers,
  money_offers,
  goods_offers,
  one_to_many_offers,
  lending_offers,
}

enum HelpContextAdminType {
  seva_community,
  groups,
  events,
  requests,
  time_requests,
  one_to_many_requests,
  money_requests,
  goods_requests,
  offers,
  time_offers,
  money_offers,
  goods_offers,
  one_to_many_offers,
  lending_offers,
}

extension MemberValues on HelpContextMemberType {
  String getValue() {
    try {
      return this.toString().split('.')[1];
    } catch (e) {
      logger.e(e);
      return HelpContextMemberType.seva_community.toString().split('.')[1];
    }
  }
}

extension AdminValues on HelpContextAdminType {
  String getValue() {
    try {
      return this.toString().split('.')[1];
    } catch (e) {
      logger.e(e);
      return HelpContextAdminType.seva_community.toString().split('.')[1];
    }
  }
}
