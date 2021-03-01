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
      appBar: AppBar(title: Text(dic['create']), centerTitle: true),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(dic['create.warn1'], style: theme.headline4),
                  ),
                  Text(dic['create.warn2']),
                  Container(
                    padding: EdgeInsets.only(bottom: 16, top: 32),
                    child: Text(dic['create.warn3'], style: theme.headline4),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(dic['create.warn4']),
                  ),
                  Text(dic['create.warn5']),
                  Container(
                    padding: EdgeInsets.only(bottom: 16, top: 32),
                    child: Text(dic['create.warn6'], style: theme.headline4),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(dic['create.warn7']),
                  ),
                  Text(dic['create.warn8']),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text:
                    I18n.of(context).getDic(i18n_full_dic_ui, 'common')['next'],
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
            // submitting: _submitting,
            onSubmit: _onNext,
          ),
        ),
      );
    }
    return _generateSeed(context);
  }
}
