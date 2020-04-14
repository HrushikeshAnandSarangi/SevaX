import 'package:intl/intl.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';

String getOfferTitle({OfferModel offerDataModel}) {
  return offerDataModel.offerType == OfferType.INDIVIDUAL_OFFER
      ? offerDataModel.individualOfferDataModel.title
      : offerDataModel.groupOfferDataModel.classTitle;
}

String getOfferDescription({OfferModel offerDataModel}) {
  return offerDataModel.offerType == OfferType.INDIVIDUAL_OFFER
      ? offerDataModel.individualOfferDataModel.description
      : offerDataModel.groupOfferDataModel.classDescription;
}

List<String> getOfferParticipants({OfferModel offerDataModel}) {
  return offerDataModel.offerType == OfferType.INDIVIDUAL_OFFER
      ? offerDataModel.individualOfferDataModel.offerAcceptors
      : offerDataModel.groupOfferDataModel.signedUpMembers;
}

String getOfferLocation({OfferModel offerDataModel}) {
  if (offerDataModel.selectedAdrress != null) {
    if (offerDataModel.selectedAdrress.contains(',')) {
      var slices = offerDataModel.selectedAdrress.split(',');
      return offerDataModel.selectedAdrress.split(',')[slices.length - 1];
    } else {
      return offerDataModel.selectedAdrress;
    }
  }else{
    return "Anonymous";
  }
}

String getFormatedTimeFromTimeStamp({int timeStamp, String timeZone, String format = "EEEEEEE, MMMM dd"} ) {
  return DateFormat(format).format(
    getDateTimeAccToUserTimezone(
        dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
        timezoneAbb: timeZone),
  );
}

