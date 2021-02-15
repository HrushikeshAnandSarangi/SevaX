
enum ExitJoinType {
  JOIN,
  EXIT,
}

extension ExitJoinLabel on ExitJoinType {
  String get readable {
    switch (this) {
      case ExitJoinType.JOIN:
        return 'JOIN';
      case ExitJoinType.EXIT:
        return 'EXIT';
      default:
        return 'DEFAULT_CASE_TYPE';
    }
  }
}


enum JoinMode {
  ADDED_MANUALLY_BY_ADMIN,
  APPROVED_BY_ADMIN,
  JOINED_VIA_CODE,
  JOINED_VIA_LINK,
  REJECTED_BY_ADMIN,
}

extension JoinModeLabel on JoinMode {
  String get readable {
    switch (this) {
      case JoinMode.ADDED_MANUALLY_BY_ADMIN:
        return 'ADDED_MANUALLY_BY_ADMIN';  //done
      case JoinMode.APPROVED_BY_ADMIN:
        return 'APPROVED_BY_ADMIN';        
      case JoinMode.REJECTED_BY_ADMIN:
        return 'REJECTED_BY_ADMIN';
      case JoinMode.JOINED_VIA_CODE:
        return 'JOINED_VIA_CODE';
      case JoinMode.JOINED_VIA_LINK:
        return 'JOINED_VIA_LINK';
      default:
        return 'DEFAULT_CASE_JOIN_MODE';
    }
  }
}


enum ExitMode {
  REMOVED_BY_ADMIN,
  LEFT_THE_COMMUNITY,
  REPORTED_IN_COMMUNITY,
}

extension ExitModeLabel on ExitMode {
  String get readable {
    switch (this) {
      case ExitMode.REMOVED_BY_ADMIN:
        return 'REMOVED_BY_ADMIN';
      case ExitMode.LEFT_THE_COMMUNITY:
        return 'LEFT_THE_COMMUNITY';
      case ExitMode.REPORTED_IN_COMMUNITY:
        return 'REPORTED_IN_COMMUNITY';
      default:
        return 'DEFAULT_CASE_EXIT_MODE';
    }
  }
}