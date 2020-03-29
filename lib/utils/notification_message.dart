import 'package:sevaexchange/models/notifications_model.dart';

String getNotificationMessage(NotificationType type) {
  switch (type) {
    case NotificationType.RequestAccept:
      return "Request accepted by *name, waiting for your approval";
      break;
    case NotificationType.RequestApprove:
      return "Request approved by *name";
      break;
    case NotificationType.RequestInvite:
      return "Request ";
      break;
    case NotificationType.RequestReject:
      return "Task completion rejected by *name ";
      break;
    case NotificationType.RequestCompleted:
      return "*name completed the task in *credits hours, waiting for your approval.";
      break;
    case NotificationType.RequestCompletedApproved:
      return "*name approved the task completion for *credits hours ";
      break;
    case NotificationType.RequestCompletedRejected:
      return "Task completion rejected by *name ";
      break;
    case NotificationType.TransactionCredit:
      return "Congrats, *credits Seva Credits have been credited to your account.";
      break;
    case NotificationType.TransactionDebit:
      return "Request ";
      break;
    case NotificationType.OfferAccept:
      return "*name sent request for your offer: *title";
      break;
    case NotificationType.OfferReject:
      return "Request ";
      break;
    case NotificationType.JoinRequest:
      return "*name has requested to join *title, Tap to view all join requests";
      break;
    case NotificationType.AcceptedOffer:
      return "Request ";
      break;
    default:
      return '';
  }
}

String getAdminNotificationMessage(NotificationType type) {
  switch (type) {
    case NotificationType.JoinRequest:
      return "Join Request";
      break;
    case NotificationType.RequestAccept:
      return "Request Accept";
      break;
    case NotificationType.RequestApprove:
      return "Request Approve";
      break;
    case NotificationType.TransactionCredit:
      return "Transaction Credit";
      break;
    default:
      return "Error";
  }
}
