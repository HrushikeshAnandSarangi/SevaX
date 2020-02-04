import 'package:flutter/material.dart';

class NoGroupPlaceHolder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.search,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 5),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  text:
                      'Groups help you to organize your specific \n activities,you don\'t have any . try ',
                ),
                TextSpan(
                  text: 'creating one',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}