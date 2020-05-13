import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';

class SwitchTimebank extends StatelessWidget {
  final String content;

  SwitchTimebank({this.content});

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
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              content ?? 'Switching Timebank',
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
