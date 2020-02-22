import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/widgets/custom_button.dart';
import 'package:viktoriaapp/widgets/custom_circular_progress_indicator.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';

//TODO: Check what happens when offline
/// Cafetoria login data
class CafetoriaLogin extends StatefulWidget {
  // ignore: public_member_api_docs
  const CafetoriaLogin({@required this.onFinished});

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
  TextEditingController idController = TextEditingController();

  /// Text editing controller for the keyfob password
  TextEditingController passwordController = TextEditingController();

  /// The current keyfob id
  String id;

  /// The current keyfob password
  String password;

  /// Checks if the user is currently logged in
  bool get loggedIn => id != null && password != null;

  /// Sets if the cafetoria login is currently logging in
  bool loggingIn = false;

  /// Sets if the cafetoria login is currently logging out
  bool loggingOut = false;

  /// Checks the login
  Future<void> checkForm() async {
    if (!loggingIn) {
      setState(() => loggingIn = true);
      final loginStatus = await Static.cafetoria
          .checkLogin(idController.text, passwordController.text, context);
      failMsg = loginStatus == StatusCodes.success
          ? null
          : (loginStatus == StatusCodes.failed
              ? 'Serverfehler - Versuche es später nochmal'
              : 'Login-Daten nicht korrekt');
      _credentialsCorrect = loginStatus == StatusCodes.success;
      if (_formKey.currentState.validate()) {
        // Save correct credentials
        Static.storage.setString(
            Keys.cafetoriaModified, DateTime.now().toIso8601String());
        Static.storage.setString(Keys.cafetoriaId, idController.text);
        Static.storage
            .setString(Keys.cafetoriaPassword, passwordController.text);
        await Static.tags
            .syncTags(context, syncExams: false, syncSelections: false);
        await Static.cafetoria.loadOnline(context, force: true);
        setState(() => loggingIn = false);
        Navigator.pop(context);
        // Update UI
        widget.onFinished();
      } else {
        setState(() => loggingIn = false);
        passwordController.clear();
      }
    }
  }

  @override
  void initState() {
    id = Static.storage.getString(Keys.cafetoriaId);
    password = Static.storage.getString(Keys.cafetoriaPassword);
    idController.text = id ?? '';
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
        titlePadding: EdgeInsets.all(0),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Cafétoria Login',
              style: TextStyle(fontWeight: FontWeight.w100),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: idController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Id muss angegeben sein';
                      }
                      if (!_credentialsCorrect) {
                        return failMsg;
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
                        return failMsg;
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
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed: checkForm,
                            enabled: !loggingOut,
                            child: loggingIn
                                ? CustomCircularProgressIndicator(
                                    height: 25,
                                    width: 25,
                                    color: Theme.of(context).primaryColor,
                                  )
                                : Text(
                                    'Anmelden',
                                    style: TextStyle(
                                      color: darkColor,
                                    ),
                                  ),
                          ),
                        ),
                        if (loggedIn)
                          Padding(padding: EdgeInsets.only(right: 20)),
                        if (loggedIn)
                          Expanded(
                            child: CustomButton(
                              onPressed: () async {
                                if (!loggingOut) {
                                  setState(() => loggingOut = true);
                                  await Static.cafetoria.logout(context);
                                  setState(() => loggingOut = false);
                                  Navigator.pop(context);
                                  widget.onFinished();
                                }
                              },
                              enabled: !loggingIn,
                              child: loggingOut
                                  ? CustomCircularProgressIndicator(
                                      height: 25,
                                      width: 25,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : Text(
                                      'Abmelden',
                                      style: TextStyle(
                                        color: darkColor,
                                      ),
                                    ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      );
}