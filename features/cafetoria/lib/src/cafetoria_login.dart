import 'package:cafetoria/cafetoria.dart';
import 'package:cafetoria/src/cafetoria_localizations.dart';
import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

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
  Future<void> checkForm(CafetoriaLoader loader) async {
    if (!loggingIn) {
      setState(() => loggingIn = true);
      final loginStatus = await loader.checkLogin(
          idController.text, passwordController.text, context);
      failMsg = loginStatus == StatusCode.success
          ? null
          : (loginStatus == StatusCode.failed
              ? AppLocalizations.serverError
              : getStatusCodeMsg(loginStatus));
      _credentialsCorrect = loginStatus == StatusCode.success;
      if (_formKey.currentState.validate()) {
        // Save correct credentials
        Static.storage.setString(
            CafetoriaKeys.cafetoriaModified, DateTime.now().toIso8601String());
        Static.storage.setString(CafetoriaKeys.cafetoriaId, idController.text);
        Static.storage.setString(
            CafetoriaKeys.cafetoriaPassword, passwordController.text);
        final status = reduceStatusCodes([
          await Static.tags.syncToServer(
            context,
            [CafetoriaWidget.of(context).feature],
          ),
          await loader.loadOnline(context, force: true),
        ]);
        if (status != StatusCode.success) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(getStatusCodeMsg(status)),
              action: SnackBarAction(
                label: AppLocalizations.ok,
                onPressed: () => null,
              ),
            ),
          );
        }
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
    id = Static.storage.getString(CafetoriaKeys.cafetoriaId);
    password = Static.storage.getString(CafetoriaKeys.cafetoriaPassword);
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
  Widget build(BuildContext context) {
    final loader = CafetoriaWidget.of(context).feature.loader;
    return SimpleDialog(
      titlePadding: EdgeInsets.all(0),
      title: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            CafetoriaLocalizations.cafetoriaLogin,
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
                      return CafetoriaLocalizations.idMustSet;
                    }
                    if (!_credentialsCorrect) {
                      return failMsg;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: CafetoriaLocalizations.keyfobId),
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_focus);
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return CafetoriaLocalizations.passwordMustSet;
                    }
                    if (!_credentialsCorrect) {
                      return failMsg;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: CafetoriaLocalizations.keyfobPin,
                  ),
                  onFieldSubmitted: (value) {
                    checkForm(loader);
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
                          onPressed: () => checkForm(loader),
                          enabled: !loggingOut,
                          child: loggingIn
                              ? CustomCircularProgressIndicator(
                                  height: 25,
                                  width: 25,
                                  color: Theme.of(context).primaryColor,
                                )
                              : Text(
                            AppLocalizations.login,
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
                                final status = await loader.logout(context);
                                setState(() => loggingOut = false);
                                switch (status) {
                                  case StatusCode.success:
                                    Navigator.pop(context);
                                    widget.onFinished();
                                    return;
                                  case StatusCode.offline:
                                    failMsg = AppLocalizations.offline;
                                    break;
                                  default:
                                    failMsg = AppLocalizations.serverError;
                                }
                                _credentialsCorrect = false;
                                _formKey.currentState.validate();
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
                              AppLocalizations.logout,
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
}
