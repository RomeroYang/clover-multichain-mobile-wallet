import 'package:app/pages/account/create/accountAdvanceOption.dart';
import 'package:app/service/index.dart';
import 'package:app/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polkawallet_sdk/api/apiKeyring.dart';
import 'package:app/utils/UI.dart';

class BackupAccountPage extends StatefulWidget {
  const BackupAccountPage(this.service);
  final AppService service;

  static final String route = '/account/backup';

  @override
  _BackupAccountPageState createState() => _BackupAccountPageState();
}

class _BackupAccountPageState extends State<BackupAccountPage> {
  AccountAdvanceOptionParams _advanceOptions = AccountAdvanceOptionParams();
  int _step = 0;
  bool showPhrase = false;

  List<String> _wordsSelected;
  List<String> _wordsLeft;

  @override
  void initState() {
    widget.service.account.generateAccount();
    super.initState();
  }

  Future<void> _importAccount() async {
    // setState(() {
    //   _submitting = true;
    // });
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
              I18n.of(context).getDic(i18n_full_dic_ui, 'common')['loading']),
          content: Container(height: 64, child: CupertinoActivityIndicator()),
        );
      },
    );

    try {
      final json = await widget.service.account.importAccount(
        cryptoType: _advanceOptions.type ?? CryptoType.sr25519,
        derivePath: _advanceOptions.path ?? '',
      );
      final acc = await widget.service.account.addAccount(
        json: json,
        cryptoType: _advanceOptions.type ?? CryptoType.sr25519,
        derivePath: _advanceOptions.path ?? '',
      );

      // setState(() {
      //   _submitting = false;
      // });
      // Use double pop to return value

      Navigator.of(context).pop();
      Navigator.of(context).pop(true);
    } catch (err) {
      Navigator.of(context).pop();
      AppUI.alertWASM(context, () {
        setState(() {
          // _submitting = false;
          // _step = 0;
        });
      });
    }
  }

  Widget _buildStep0(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_app, 'account');

    return Observer(
      builder: (_) => Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 92),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 22, right: 22),
                      child: Text(dic['create.warn3'], style: Theme.of(context).textTheme.headline1),
                    ),
                    Container(
                      padding: EdgeInsets.all(22),
                      child: Text(
                          dic['create.warn4'],
                          style: Theme.of(context).textTheme.subtitle1
                      ),
                    ),
                    showPhrase ? Container(
                      height: 135,
                      margin: EdgeInsets.all(22),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black12,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Text(
                        widget.service.store.account.newAccount.key ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                    ) : GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            showPhrase = true;
                          });
                        },
                        child: Container(
                          height: 135,
                          margin: EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage("assets/images/seed_blanket.png"),
                            ),
                          ),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: !showPhrase ? [
                        SvgPicture.asset('assets/images/unlock.svg'),
                        SizedBox(width: 5),
                        Text(
                          "Tap to reveal your seed phrase",
                          style: Theme.of(context).textTheme.subtitle2,
                        )
                      ] : [],
                    ),
                    // AccountAdvanceOption(
                    //   api: widget.service.plugin.sdk.api.keyring,
                    //   seed: widget.service.store.account.newAccount.key ?? '',
                    //   onChange: (data) {
                    //     setState(() {
                    //       _advanceOptions = data;
                    //     });
                    //   },
                    // ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context)
                      .getDic(i18n_full_dic_ui, 'common')['next'],
                  onPressed: () {
                    if (_advanceOptions.error ?? false) return;
                    setState(() {
                      _step = 1;
                      _wordsSelected = <String>[];
                      _wordsLeft = widget.service.store.account.newAccount.key
                          .split(' ');
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_app, 'account');

    return Scaffold(
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      setState(() {
                        _step = 0;
                      });
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
                      Text(
                        dic['backup'],
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                            dic['backup.confirm'],
                            style: Theme.of(context).textTheme.subtitle1
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                dic['backup.reset'],
                                style: TextStyle(fontSize: 14, color: Colors.pink),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _wordsLeft = widget
                                    .service.store.account.newAccount.key
                                    .split(' ');
                                _wordsSelected = [];
                              });
                            },
                          )
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black12,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(16))),
                        padding: EdgeInsets.all(16),
                        child: Text(
                          _wordsSelected.join(' ') ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'RobotoMono',
                          ),
                        ),
                      ),
                      _buildWordsButtons(),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: RoundedButton(
                    text:
                    I18n.of(context).getDic(i18n_full_dic_ui, 'common')['next'],
                    onPressed: _wordsSelected.join(' ') ==
                        widget.service.store.account.newAccount.key
                        ? () => _importAccount()
                        : null,
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget _buildWordsButtons() {
    if (_wordsLeft.length > 0) {
      _wordsLeft.sort();
    }

    List<Widget> rows = <Widget>[];
    for (var r = 0; r * 3 < _wordsLeft.length; r++) {
      if (_wordsLeft.length > r * 3) {
        rows.add(Row(
          children: _wordsLeft
              .getRange(
              r * 3,
              _wordsLeft.length > (r + 1) * 3
                  ? (r + 1) * 3
                  : _wordsLeft.length)
              .map(
                (i) => Container(
              padding: EdgeInsets.only(left: 4, right: 4),
              child: _wordsSelected.indexOf(i) >= 0 ? OutlinedButton(
                child: Text(
                  i,
                ),
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  primary: Colors.white,
                  side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                  backgroundColor: Theme.of(context).primaryColor,
                  onSurface: Colors.white,
                  textStyle: TextStyle(
                    fontFamily: "RobotoMono",
                    fontSize: 14
                  )
                ),
              ) :
              OutlinedButton(
                child: Text(
                  i,
                ),
                onPressed: () {
                  setState(() {
                    // _wordsLeft.remove(i);
                    _wordsSelected.add(i);
                  });
                },
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                    backgroundColor: Color.fromRGBO(241, 255, 250, 1),
                    textStyle: TextStyle(
                        fontFamily: "RobotoMono",
                        fontSize: 14
                    )
                ),
              ),
            ),
          )
              .toList(),
        ));
      }
    }
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        children: rows,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 0:
        return _buildStep0(context);
      case 1:
        return _buildStep1(context);
      default:
        return Container();
    }
  }
}
