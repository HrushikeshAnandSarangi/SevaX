enum PlanIds {
  neighbourhood_plan,
  friends_and_families_plan,
  community_plan,
  community_plus_plan,
  non_profit_plan,
  enterprise_plan,
}

extension Label on PlanIds {
  String get label => this.toString().split('.')[1];

  String get name {
    String name = '';
    switch (this) {
      case PlanIds.neighbourhood_plan:
        name = 'Neighborhood Plan';
        break;
      case PlanIds.friends_and_families_plan:
        name = 'Private Friends and Family Plan';
        break;
      case PlanIds.community_plan:
        name = 'Community Plan';
        break;
      case PlanIds.community_plus_plan:
        name = 'Community Plus Plan';
        break;
      case PlanIds.non_profit_plan:
        name = 'Non-Profit Plan';
        break;
      case PlanIds.enterprise_plan:
        name = 'Enterprise Plan';
        break;
    }
    return name;
  }

  bool canChangePlan(PlanIds activePlanId) {
    var planIds = PlanIds.values;
    return planIds.indexOf(activePlanId) < planIds.indexOf(this);
  }
}

// Map<String, PlanIds> stringToPlanIds = {
//   "neighbourhood_plan": PlanIds.neighbourhood_plan,
//   "friends_and_families_plan": PlanIds.friends_and_families_plan,
//   "community_plan": PlanIds.community_plan,
//   "community_plus_plan": PlanIds.community_plus_plan,
//   "non_profit_plan": PlanIds.non_profit_plan,
//   "enterprise_plan": PlanIds.enterprise_plan,
// };
Map<String, PlanIds> stringToPlanIds = {
  "neighbourhood_plan": PlanIds.neighbourhood_plan,
  "family_plan": PlanIds.friends_and_families_plan,
  "tall_plan": PlanIds.community_plan,
  "community_plus_plan": PlanIds.community_plus_plan,
  "grande_plan": PlanIds.non_profit_plan,
  "venti_plan": PlanIds.enterprise_plan,
  "friends_and_families_plan": PlanIds.friends_and_families_plan,
  "community_plan": PlanIds.community_plan,
  "non_profit_plan": PlanIds.non_profit_plan,
  "enterprise_plan": PlanIds.enterprise_plan,
};
