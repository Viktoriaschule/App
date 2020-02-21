import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/custom_button.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';

//TODO: Check what happens when offline
/// Cafetoria login data
class CafetoriaLogin extends StatefulWidget {
  // ignore: public_member_api_docs
  const CafetoriaLogin({this.onFinished});

  /// Finish callback
  final VoidCallback onFinished;

  @override
  State<StatefulWidget> createState() => CafetoriaLoginState();
}

// ignore: public_member_api_docs
class CafetoriaLoginState extends State<CafetoriaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _focus = FocusNode();
  bool _credentialsCorrect = true;

  /// The reason why the login failed
  String failMsg;

  /// Text editing controller for the keyfob id
  TextEditingController idController;

  /// Text editing controller for the keyfob password
  TextEditingController passwordController;

  /// The current keyfob id
  String id;

  /// The current keyfob password
  String password;

  /// Checks if the user is currently logged in
  bool get loggedIn => id != null && password != null;

  /// Check the login
  Future<void> checkForm() async {
    final loginStatus =
        await Static.cafetoria.checkLogin(id, password, context);
    failMsg = loginStatus == StatusCodes.success
        ? null
        : (loginStatus == StatusCodes.failed
            ? 'Serverfehler - Versuchen Sie es später nochmal'
            : 'Login-Daten nicht korrekt');
    _credentialsCorrect = loginStatus == StatusCodes.success;
    if (_formKey.currentState.validate()) {
      // Save correct credentials
      Static.storage
          .setString(Keys.cafetoriaModified, DateTime.now().toIso8601String());
      Static.storage.setString(Keys.cafetoriaId, idController.text);
      Static.storage.setString(Keys.cafetoriaPassword, passwordController.text);
      await Static.tags
          .syncTags(context, syncExams: false, syncSelections: false);
      Navigator.pop(context);
      // Update UI
      widget.onFinished();
    } else {
      passwordController.clear();
    }
  }

  @override
  void initState() {
    id = Static.storage.getString(Keys.cafetoriaId);
    password = Static.storage.getString(Keys.cafetoriaPassword);
    super.initState();
  }

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: Text(
          'Cafétoria Login',
          style: TextStyle(fontWeight: FontWeight.w100),
        ),
        children: [
          Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: idController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Id muss angegeben sein';
                    }
                    if (!_credentialsCorrect) {
                      return 'Login-Daten falsch';
                    }
                    return null;
                  },
                  decoration: InputDecoration(hintText: 'Keyfob-ID'),
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_focus);
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password kann nicht leer sein';
                    }
                    if (!_credentialsCorrect) {
                      return 'Login-Daten falsch';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Keyfob-Pin',
                  ),
                  onFieldSubmitted: (value) {
                    checkForm();
                  },
                  obscureText: true,
                  focusNode: _focus,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: CustomButton(
                          onPressed: () => null,
                          child: Text(
                            'Anmelden',
                            style: TextStyle(
                              color: darkColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (loggedIn)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: CustomButton(
                            onPressed: () => null,
                            child: Text(
                              'Abmelden',
                              style: TextStyle(
                                color: darkColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          )
        ],
      );
}
