import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';

String getRequestUserStatus(
    {RequestModel requestModel, String userId, String email, context}) {
  if (requestModel.acceptors.contains(email) ||
      requestModel.invitedUsers.contains(userId)) {
    return S.of(context).invited;
  } else if (requestModel.approvedUsers.contains(email)) {
    return S.of(context).approved;
  } else {
    return S.of(context).invite;
  }
}
