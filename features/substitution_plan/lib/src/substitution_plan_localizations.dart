/// All localizations for the cafetoria feature
class SubstitutionPlanLocalizations {
  // ignore: public_member_api_docs
  static const noSubstitutions = 'Keine Änderung';

  // ignore: public_member_api_docs
  static const noSubstitutionPlan = 'Kein Vertretungsplan';

  // ignore: public_member_api_docs
  static const substitutions = 'Vertretungen';

  // ignore: public_member_api_docs
  static const mySubstitutions = 'Meine $substitutions';

  // ignore: public_member_api_docs
  static const otherSubstitutions = 'Weitere $substitutions';

  // ignore: public_member_api_docs
  static const newSubstitutionPlans = 'Neue Vertretungspläne';

  // ignore: public_member_api_docs
  static String newSubstitutionPlanFor(String weekday) =>
      'Neuer Vertretungsplan${weekday != null ? ' für $weekday' : ''}';
}
