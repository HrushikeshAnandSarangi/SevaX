import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class CalenderEventConfirmationDialog extends StatelessWidget {
  final String? title;
  final bool? isrequest;
  final VoidCallback? addToCalender;
  final VoidCallback? cancelled;

  CalenderEventConfirmationDialog(
      {this.title, this.isrequest, this.addToCalender, this.cancelled});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).add_to_calender),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(S.of(context).do_you_want_to_add +
              ' ' +
              '$title ${isrequest == true ? 'request ' : 'offer '}' +
              S.of(context).event_to_calender),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Spacer(),
              CustomTextButton(
                shape: StadiumBorder(),
                color: HexColor("#d2d2d2"),
                child: Text(
                  S.of(context).no,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Europa',
                    fontSize: 16,
                  ),
                ),
                onPressed: cancelled!,
              ),
              SizedBox(
                width: 10,
              ),
              CustomTextButton(
                shape: StadiumBorder(),
                // padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                color: Theme.of(context).colorScheme.secondary,
                // textColor: FlavorConfig.values.buttonTextColor,
                child: Text(
                  S.of(context).yes,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Europa',
                    fontSize: 16,
                  ),
                ),
                onPressed: addToCalender!,
              ),
            ],
          )
        ],
      ),
    );
  }
}
