import 'package:app/service/index.dart';
import 'package:app/utils/format.dart';
import 'package:app/utils/i18n/index.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateAccountForm extends StatefulWidget {
  CreateAccountForm(this.service, {this.submitting, this.onSubmit});

  final AppService service;
  final Future<void> Function() onSubmit;
  final bool submitting;

  @override
  _CreateAccountFormState createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passCtrl = new TextEditingController();
  final TextEditingController _pass2Ctrl = new TextEditingController();

  bool _supportBiometric = false;
  bool _enableBiometric = true; // if the biometric usage checkbox checked

  Future<void> _checkBiometricAuth() async {
    final response = await BiometricStorage().canAuthenticate();
    final supportBiometric = response == CanAuthenticateResponse.success;
    if (!supportBiometric) {
      return;
    }
    setState(() {
      _supportBiometric = supportBiometric;
    });
  }

  Future<void> _authBiometric() async {
    final pubKey = widget.service.keyring.current.pubKey;
    final storeFile = await widget.service.account.getBiometricPassStoreFile(
      context,
      pubKey,
    );

    try {
      await storeFile.write(widget.service.store.account.newAccount.password);
      widget.service.account.setBiometricEnabled(pubKey);
    } catch (err) {
      // ignore
    }
  }

  Future<void> _onSubmit() async {
    // if (_formKey.currentState.validate()) {
    //   widget.service.store.account
    //       .setNewAccount(_nameCtrl.text, _passCtrl.text);
    //   final success = await widget.onSubmit();
    //
    //   if (success) {
    //     /// save password with biometrics after import success
    //     if (_supportBiometric && _enableBiometric) {
    //       await _authBiometric();
    //     }
    //
    //     widget.service.plugin.changeAccount(widget.service.keyring.current);
    //     widget.service.store.account.resetNewAccount();
    //     Navigator.popUntil(context, ModalRoute.withName('/'));
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometricAuth();
  }

  bool _isObscure = true;
  bool _isObscure2 = true;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_app, 'account');

    return Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SvgPicture.asset(
                            'assets/images/back.svg'
                        ),
                        SizedBox(width: 8),
                        Text(dic['back'], style: Theme.of(context).textTheme.headline4)
                      ],
                    ),
                  )
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 40),
                    Text(dic['create'], style: Theme.of(context).textTheme.headline1),
                    SizedBox(height: 12),
                    Text(dic['create.desc'], style: Theme.of(context).textTheme.subtitle1),
                    SizedBox(height: 60),
                    TextFormField(
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: SvgPicture.asset(
                            _isObscure ? 'assets/images/show.svg' : 'assets/images/hide.svg',
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                        hintText: dic['create.password'],
                        labelText: dic['create.password'],
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      controller: _passCtrl,
                      validator: (v) {
                        return AppFmt.checkPassword(v.trim())
                            ? null
                            : dic['create.password.error'];
                      },
                      obscureText: _isObscure,
                    ),
                    SizedBox(height: 70),
                    TextFormField(
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: SvgPicture.asset(
                            _isObscure2 ? 'assets/images/show.svg' : 'assets/images/hide.svg',
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure2 = !_isObscure2;
                            });
                          },
                        ),
                        hintText: dic['create.password2'],
                        labelText: dic['create.password2'],
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      controller: _pass2Ctrl,
                      obscureText: _isObscure2,
                      validator: (v) {
                        return _passCtrl.text != v
                            ? dic['create.password2.error']
                            : null;
                      },
                    ),
                    _supportBiometric
                        ? Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _enableBiometric,
                              onChanged: (v) {
                                setState(() {
                                  _enableBiometric = v;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(dic['unlock.bio.enable']),
                          )
                        ],
                      ),
                    )
                        : Container(),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).getDic(i18n_full_dic_ui, 'common')['next'],
                  onPressed: widget.submitting ? null : () => _onSubmit(),
                ),
              ),
            ],
          ),
        )
    );
  }
}
