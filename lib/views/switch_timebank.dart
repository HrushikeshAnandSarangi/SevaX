import 'package:flutter/material.dart';
import 'package:sevaexchange/views/home_dashboard.dart';
import 'package:sevaexchange/views/home_page_router.dart';

class SwitchTimebank extends StatelessWidget {
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
              'Switching Timebank',
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
