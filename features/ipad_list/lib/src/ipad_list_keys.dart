import 'package:utils/utils.dart';

/// All keys for the iPad list feature
class IPadListKeys extends FeatureKeys {
  // ignore: public_member_api_docs
  static const iPadList = 'ipad_list';

  // ignore: public_member_api_docs
  static const iPadHistoryEntries = 'history';

  /// The sort method is an index starting by one
  ///
  /// If the index is negative, the sort direction is inversed
  static const iPadSortMethod = 'ipad_sort_method';

  // ignore: public_member_api_docs
  static const chartType = 'ipad_list_chart_type';

  // ignore: public_member_api_docs
  static const chartTimespan = 'ipad_list_timespan';
}
