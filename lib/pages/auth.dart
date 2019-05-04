import 'package:flutter/material.dart';
import 'package:product_manager/model/auth.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';

typedef _AuthFunction = Future<Map<String, dynamic>> Function(
    {String email, String password, AuthMode authMode});

class AuthPage extends StatefulWidget {
  //
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  //
  String _email;
  String _password;
  bool _termsAccepted = false;
  AuthMode _authMode = AuthMode.Login;

  final _formKey = GlobalKey<_CenteredFormState>();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          decoration: BoxDecoration(image: _backgroundImage()),
          padding: const EdgeInsets.all(16.0),
          child: _CenteredForm(
            key: _formKey,
            children: <Widget>[
              _EmailTextField(onSaved: (value) => _email = value),
              const SizedBox(height: 8.0),
              _PasswordTextField(
                  controller: _passwordController,
                  onSaved: (value) => _password = value),
              const SizedBox(height: 8.0),
              if (_authMode == AuthMode.Signup)
                _ConfirmPasswordTextField(
                    validatedController: _passwordController),
              const SizedBox(height: 20),
              _buildTermsSwitch(),
              const SizedBox(height: 8.0),
              _buildAuthModeButton(),
              SizedBox(child: _buildLoginButton(), height: 50.0, width: 160.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final loginButtonText = _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP';

    return ScopedModelDescendant<MainModel>(builder: (_, __, MainModel model) {
      return model.isLoading
          ? Center(child: CircularProgressIndicator())
          : RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              textColor: Colors.white,
              child: Text('$loginButtonText'),
              onPressed: _termsAccepted
                  ? () => _onLoginTapped(auth: model.authenticate)
                  : null,
            );
    });
  }

  FlatButton _buildAuthModeButton() {
    final authModeText = _authMode == AuthMode.Login
        ? 'Create account'
        : 'Already have an account';

    return FlatButton(
      child: Text('$authModeText'),
      onPressed: () {
        setState(() {
          _authMode =
              _authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
        });
      },
    );
  }

  SwitchListTile _buildTermsSwitch() {
    return SwitchListTile(
      title: const Text(
        'Accept Terms and conditions',
        style: TextStyle(fontSize: 12.0),
      ),
      value: _termsAccepted,
      onChanged: (value) {
        setState(() {
          _termsAccepted = value;
        });
      },
    );
  }

  DecorationImage _backgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.3),
        BlendMode.dstATop,
      ),
      image: const AssetImage('assets/background.jpg'),
    );
  }

  void _onLoginTapped({_AuthFunction auth}) async {
    //
    if (_formKey.currentState.validate() && _termsAccepted) {
      _formKey.currentState.save();

      final result =
          await auth(email: _email, password: _password, authMode: _authMode);
      final success = result['success'];
      final errorMessage = result['message'];
      if (success)
        Navigator.pushReplacementNamed(context, '/');
      else
        showDialog(
          context: context,
          builder: (context) => _buildFailedLoginDialog(context, errorMessage),
        );
    }
  }

  Widget _buildFailedLoginDialog(context, message) {
    final title = _authMode == AuthMode.Login
        ? 'Failed logging in'
        : 'Failed creating account';
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: const Text('Ok'),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }
}

class _PasswordTextField extends StatelessWidget {
  final void Function(String value) onSaved;
  final TextEditingController controller;

  const _PasswordTextField({Key key, this.onSaved, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: true,
      controller: controller,
      validator: (value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password has to contain 6 characters.';
        }
      },
      onSaved: onSaved,
    );
  }
}

class _ConfirmPasswordTextField extends StatelessWidget {
  final void Function(String value) onSaved;
  final TextEditingController controller;
  final TextEditingController validatedController;

  const _ConfirmPasswordTextField({
    Key key,
    this.onSaved,
    this.controller,
    this.validatedController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: true,
      controller: controller,
      validator: (value) {
        if (value != validatedController.text) {
          return 'Passwords do not match';
        }
      },
      onSaved: onSaved,
    );
  }
}

class _EmailTextField extends StatelessWidget {
  final void Function(String value) onSaved;
  final TextEditingController controller;

  const _EmailTextField({Key key, this.onSaved, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
          labelText: 'Email or username',
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      controller: controller,
      validator: (value) {
        if (value.isEmpty || !_isValidEmail(value)) {
          return 'Invalid email address.';
        }
      },
      onSaved: onSaved,
    );
  }

  bool _isValidEmail(String value) {
    return RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
            "*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
            "\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
        .hasMatch(value);
  }
}

class _CenteredForm extends StatefulWidget {
  final List<Widget> children;

  _CenteredForm({Key key, this.children}) : super(key: key);

  @override
  _CenteredFormState createState() => _CenteredFormState();
}

class _CenteredFormState extends State<_CenteredForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return Form(
      key: _formKey,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: targetWidth,
            child: Column(children: widget.children),
          ),
        ),
      ),
    );
  }

  bool validate() => _formKey.currentState.validate();

  void save() => _formKey.currentState.save();
}
