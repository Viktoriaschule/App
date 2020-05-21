import 'package:utils/utils.dart';

import 'subjects_events.dart';
import 'subjects_keys.dart';
import 'subjects_model.dart';

/// SubjectsLoader class
class SubjectsLoader extends Loader<Subjects> {
  // ignore: public_member_api_docs
  SubjectsLoader() : super(SubjectsKeys.subjects, SubjectsUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Subjects.fromJSON(json);
}
