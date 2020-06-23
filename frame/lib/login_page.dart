import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode _passwordFieldFocus = FocusNode();
  final FocusNode _submitButtonFocus = FocusNode();
  final TextEditingController _usernameFieldController =
      TextEditingController();
  final TextEditingController _passwordFieldController =
      TextEditingController();

  bool _checkingLogin = false;

  Future _submitLogin() async {
    if (_usernameFieldController.text.isEmpty ||
        _passwordFieldController.text.isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.usernamePasswordRequired),
      ));
      return;
    }
    setState(() {
      _checkingLogin = true;
    });
    final result = await Static.updates.loadOnline(
      context,
      force: true,
      showLoginOnWrongCredentials: false,
      username: _usernameFieldController.text,
      password: _passwordFieldController.text,
    );
    if (mounted) {
      setState(() {
        _checkingLogin = false;
      });
    }
    if (result == StatusCode.success) {
      Static.user.username = _usernameFieldController.text;
      Static.user.password = _passwordFieldController.text;
      await Navigator.of(context).pushReplacementNamed('/');
      return;
    } else {
      String msg;
      switch (result) {
        case StatusCode.unauthorized:
          msg = AppLocalizations.credentialsWrong;
          _passwordFieldController.clear();
          FocusScope.of(context).requestFocus(_passwordFieldFocus);
          break;
        case StatusCode.offline:
          msg = AppLocalizations.needsToBeOnline;
          break;
        default:
          msg = AppLocalizations.errorWhileLoggingIn;
      }
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(msg),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final usernameField = TextField(
      obscureText: false,
      enabled: !_checkingLogin,
      autofocus: !Platform().isMobile,
      style: TextStyle(
        color: ThemeWidget.of(context).textColor,
      ),
      decoration: InputDecoration(
        hintText: AppLocalizations.username,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: darkColor,
            width: 2,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).accentColor,
            width: 2,
          ),
        ),
      ),
      controller: _usernameFieldController,
      onSubmitted: (_) {
        FocusScope.of(context).requestFocus(_passwordFieldFocus);
      },
    );
    final passwordField = TextField(
      obscureText: true,
      enabled: !_checkingLogin,
      style: TextStyle(
        color: ThemeWidget.of(context).textColor,
      ),
      decoration: InputDecoration(
        hintText: AppLocalizations.password,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: darkColor,
            width: 2,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).accentColor,
            width: 2,
          ),
        ),
      ),
      controller: _passwordFieldController,
      focusNode: _passwordFieldFocus,
      onSubmitted: (_) {
        FocusScope.of(context).requestFocus(_submitButtonFocus);
        _submitLogin();
      },
    );
    final submitButton = Container(
      margin: EdgeInsets.only(top: 10),
      width: double.infinity,
      child: CustomButton(
        focusNode: _submitButtonFocus,
        onPressed: _submitLogin,
        child: _checkingLogin
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
    );
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Center(
        child: Scrollbar(
          child: Scrollbar(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(10),
              children: [
                SizeLimit(
                  child: Column(
                    children: [
                      usernameField,
                      passwordField,
                      submitButton,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
