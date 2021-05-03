enum FindCards {
  COMMUNITIES,
  EVENTS,
  REQUESTS,
  OFFERS,
  PEOPLE,
}

extension FindCardsLabel on FindCards {
  String get readable {
    switch (this) {
      case FindCards.COMMUNITIES:
        return 'Communities';
      case FindCards.EVENTS:
        return 'Events';
      case FindCards.REQUESTS:
        return 'Requests';
      case FindCards.OFFERS:
        return 'Offers';
      case FindCards.PEOPLE:
        return 'People';
      default:
        return 'No Title';
    }
  }
}
