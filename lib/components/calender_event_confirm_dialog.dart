import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';

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
      title: Text(L.of(context).add_to_calender),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(L.of(context).do_you_want_to_add + '$title ${isrequest ? 'request' : 'offer'}'+ L.of(context).event_to_calender),
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
                  S.of(context).no,
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
