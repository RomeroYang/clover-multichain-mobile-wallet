import 'package:app/pages/account/create/accountAdvanceOption.dart';
import 'package:app/pages/account/create/backupAccountPage.dart';
import 'package:app/pages/account/create/createAccountForm.dart';
import 'package:app/service/index.dart';
import 'package:app/utils/UI.dart';
import 'package:app/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:polkawallet_sdk/api/apiKeyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateAccountPage extends StatefulWidget {
  CreateAccountPage(this.service);
  final AppService service;

  static final String route = '/account/create';

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {

  int _step = 0;
  bool _submitting = false;

  Future<void> _onNext() async {
      final advancedOptions =
          await Navigator.pushNamed(context, BackupAccountPage.route);
      if (advancedOptions != null) {
        setState(() {
          _step = 1;
        });
      }
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

  Future<void> _onFinish() async {
    /// save password with biometrics after import success
    // if (_supportBiometric && _enableBiometric) {
    // await _authBiometric();
    // }

    widget.service.plugin.changeAccount(widget.service.keyring.current);
    widget.service.store.account.resetNewAccount();
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  Widget _generateSeed(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final dic = I18n.of(context).getDic(i18n_full_dic_app, 'account');

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                        'assets/images/logo.svg'
                    ),
                    SizedBox(height: 32),
                    Text(dic['create.warn1'], style: theme.headline1),
                    SizedBox(height: 10),
                    Text(dic['create.warn2'], style: theme.subtitle1, textAlign: TextAlign.center)
                  ],
              ),
            )),
            Container(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text: dic['done'],
                onPressed: () => _onFinish(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 0) {
      return Scaffold(
        body: SafeArea(
          child: CreateAccountForm(
            widget.service,
            onSubmit: _onNext,
          ),
        ),
      );
    }
    return _generateSeed(context);
  }
}
