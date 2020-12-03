import 'package:flutter/material.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/ui/screens/add_manual_time/pages/add_manual_time_details_page.dart';

class AddManualTimeButton extends StatelessWidget {
  final ManualTimeType timeFor;
  final String typeId;
  final String timebankId;
  final UserRole userType;

  const AddManualTimeButton({
    Key key,
    @required this.timeFor,
    @required this.typeId,
    @required this.userType,
    @required this.timebankId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        child: Text('Add manual time'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddMnualTimeDetailsPage(
                typeId: typeId,
                type: timeFor,
                userType: userType,
                timebankId: timebankId,
              ),
            ),
          );
        },
      ),
    );
  }
}
