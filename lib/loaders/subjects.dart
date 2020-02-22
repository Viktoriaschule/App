import 'package:viktoriaapp/loaders/loader.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/models/subjects.dart';
import 'package:viktoriaapp/utils/events.dart';

/// SubjectsLoader class
class SubjectsLoader extends Loader<Subjects> {
  // ignore: public_member_api_docs
  SubjectsLoader() : super(Keys.subjects, SubjectsUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Subjects(
      subjects: json.map<String, String>(
          (key, value) => MapEntry<String, String>(key, value)));
}
