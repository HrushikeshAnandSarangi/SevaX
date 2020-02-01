import 'package:sevaexchange/models/request_model.dart';

String getRequestUserStatus(
    {RequestModel requestModel, String userId, String email}) {
  if (requestModel.acceptors.contains(email) ||
      requestModel.invitedUsers.contains(userId)) {
    return 'Invited';
  } else if (requestModel.approvedUsers.contains(email)) {
    return 'Approved';
  } else {
    return 'Invite';
  }
}
