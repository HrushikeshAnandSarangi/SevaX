import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';

import '../flavor_config.dart';

class CalenderEventConfirmationDialog extends StatelessWidget {
  final String title;
  final bool isrequest;
  final VoidCallback addToCalender;
  final VoidCallback cancelled;

  CalenderEventConfirmationDialog(
      {this.title, this.isrequest, this.addToCalender, this.cancelled});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add to calender'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Do you want to add this $title ${isrequest ? 'request' : 'offer'} event to calender'),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Spacer(),
              FlatButton(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                color: Theme.of(context).accentColor,
                textColor: FlavorConfig.values.buttonTextColor,
                child: Text(
                  S.of(context).yes,
                  style: TextStyle(fontFamily: 'Europa'),
                ),
                onPressed: addToCalender,
              ),
              FlatButton(
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(color: Colors.red, fontFamily: 'Europa'),
                ),
                onPressed: cancelled,
              ),
            ],
          )
        ],
      ),
    );
  }
}
