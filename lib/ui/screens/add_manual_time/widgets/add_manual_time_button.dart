import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/ui/screens/add_manual_time/pages/add_manual_time_details_page.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class AddManualTimeButton extends StatelessWidget {
  final ManualTimeType timeFor;
  final String typeId;
  final String timebankId;
  final String communityName;
  final UserRole userType;

  const AddManualTimeButton({
    Key? key,
    required this.timeFor,
    required this.typeId,
    required this.userType,
    required this.timebankId,
    required this.communityName,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      height: 45,
      child: CustomElevatedButton(
        color: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.all(10),
        elevation: 3,
        textColor: Colors.white,
        child: Text(S.of(context).manual_time_add),
        onPressed: () => onPressed(
          context: context,
          typeId: typeId,
          timeFor: timeFor,
          userType: userType,
          timebankId: timebankId,
          communityName: communityName,
        ),
      ),
    );
  }

  static void onPressed({
    required BuildContext context,
    required ManualTimeType timeFor,
    required String typeId,
    required String timebankId,
    required String communityName,
    required UserRole userType,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMnualTimeDetailsPage(
          typeId: typeId,
          type: timeFor,
          userType: userType,
          timebankId: timebankId,
          communityName: communityName,
        ),
      ),
    );
  }
}
