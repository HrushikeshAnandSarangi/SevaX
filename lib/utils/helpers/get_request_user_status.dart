import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/request_model.dart';

String getRequestUserStatus(
    {RequestModel requestModel, String userId, String email, context}) {
  if (requestModel.acceptors.contains(email) ||
      requestModel.invitedUsers.contains(userId)) {
    return AppLocalizations.of(context).translate('requests', 'invited');
  } else if (requestModel.approvedUsers.contains(email)) {
    return AppLocalizations.of(context).translate('requests', 'approved');
  } else {
    return AppLocalizations.of(context).translate('members', 'invite');
  }
}
