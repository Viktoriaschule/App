// ignore: public_member_api_docs
extension AssertReplace on String {
  // ignore: public_member_api_docs
  String assertReplaceAll(Pattern from, String replace) {
    final o = this;
    final n = replaceAll(from, replace);
    if (o == n) {
      throw Exception('\'$this\' doesn\'t match the pattern \'$from\'');
    }
    return n;
  }
}
