import 'package:app/pages/account/create/createAccountPage.dart';
import 'package:app/pages/account/import/importAccountPage.dart';
import 'package:app/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';

class CreateAccountEntryPage extends StatelessWidget {
  static final String route = '/account/entry';

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_app, 'account');
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/welcome_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.asset(
                              'assets/images/logo.svg'
                          ),
                          SizedBox(height: 20),
                          Text(dic['welcome'], style: Theme.of(context).textTheme.headline1)
                        ]
                    )
                ),
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
                        color: Colors.white,
                        border: Border.all(width: 1, color: Colors.black.withOpacity(0.2)),
                        backgroundBlendMode: BlendMode.multiply
                    ),
                    child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, CreateAccountPage.route);
                        },
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 42, vertical: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                    'assets/images/create.svg'
                                ),
                                SizedBox(width: 12),
                                Expanded(child: Text(dic['welcome.nowallet'], style: Theme.of(context).textTheme.headline3))
                              ],
                            )
                        ))
                ),
                Container(
                    child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, ImportAccountPage.route);
                        },
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 42, vertical: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                    'assets/images/import.svg'
                                ),
                                SizedBox(width: 12),
                                Expanded(child: Text(dic['welcome.havewallet'], style: Theme.of(context).textTheme.headline3))
                              ],
                            )
                        ))
                ),
              ],
            ),
          ),
        )
    );
  }
}
