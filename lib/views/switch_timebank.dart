import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class SwitchTimebank extends StatelessWidget {
  final String content;

  SwitchTimebank({required this.content});

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(milliseconds: 500),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePageRouter(),
        ),
      ),
    );
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LoadingIndicator(),
            SizedBox(height: 20),
            Text(
              content ?? S.of(context).switching_timebank,
              style: TextStyle(
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
