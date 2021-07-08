import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_listing.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_listing_page.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/distance_from_current_location.dart';
import 'package:sevaexchange/widgets/tag_view.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class RequestCard extends StatelessWidget {
  final RequestModel model;
  final Coordinates coords;
  final VoidCallback onTap;

  const RequestCard({Key key, this.model, this.coords, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = SevaCore.of(context).loggedInUser;
    var requestLocation = RequestViewClassifer.getLocation(model.address);
    return Container(
      decoration: RequestViewClassifer.containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                user.curatedRequestIds.contains(model.id)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          getTagMainFrame('recommended'),
                        ],
                      )
                    : Offstage(),
                Row(
                  children: <Widget>[
                    requestLocation != null
                        ? Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                          )
                        : Container(),
                    requestLocation != null
                        ? Expanded(
                            child: Text(
                              requestLocation,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : Container(),
                    SizedBox(width: 10),
                    model.location != null &&
                            model.sevaUserId !=
                                SevaCore.of(context).loggedInUser.sevaUserID
                        ? DistanceFromCurrentLocation(
                            currentLocation: coords,
                            coordinates: Coordinates(model.location.latitude,
                                model.location.longitude),
                            isKm: true,
                          )
                        : Container(),
                    Spacer(),
                    Text(
                      timeAgo
                          .format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  model.postTimestamp),
                              locale: Locale(
                                AppConfig.prefs.getString('language_code'),
                              ).toLanguageTag())
                          .replaceAll('hours ago', 'hr'),
                      style: TextStyle(
                        fontFamily: 'Europa',
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipOval(
                      child: SizedBox(
                        height: 45,
                        width: 45,
                        child: FadeInImage.assetNetwork(
                          fit: BoxFit.cover,
                          placeholder: 'lib/assets/images/profile.png',
                          image: model.photoUrl == null
                              ? defaultUserImageURL
                              : model.photoUrl,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.73,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            children: [
                              getAppropriateTag(context, model.requestType),
                              Visibility(
                                visible: model.virtualRequest ?? false,
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: TagView(
                                    tagTitle: S.of(context).virtual,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: model.public ?? false,
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: TagView(
                                    tagTitle: 'Public',
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: model.isRecurring ?? false,
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: TagView(
                                    tagTitle: 'Recurring',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  model.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                                child: Center(
                                  child: Visibility(
                                    visible: model.isRecurring ?? false,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_context) => BlocProvider(
                                              bloc: BlocProvider.of<
                                                  HomeDashBoardBloc>(context),
                                              child: RecurringListing(
                                                comingFrom: ComingFrom.Requests,
                                                requestModel: model,
                                                offerModel: null,
                                                timebankModel: null,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.navigate_next),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Visibility(
                            visible: !(model.isRecurring ?? false),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Text(
                                  DateFormat.MMMd(getLangTag()).add_jm().format(
                                        getDateTimeAccToUserTimezone(
                                          dateTime: DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  model.requestStart),
                                          timezoneAbb: SevaCore.of(context)
                                              .loggedInUser
                                              .timezone,
                                        ),
                                      ),
                                  // RequestViewClassifer.getTimeFormattedString(
                                  //   model.requestEnd,
                                  //   user.language,
                                  // ),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.remove,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  DateFormat.MMMd(getLangTag()).add_jm().format(
                                        getDateTimeAccToUserTimezone(
                                          dateTime: DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  model.requestEnd),
                                          timezoneAbb: SevaCore.of(context)
                                              .loggedInUser
                                              .timezone,
                                        ),
                                      ),
                                  // RequestViewClassifer.getTimeFormattedString(
                                  //   model.requestEnd,
                                  //   user.timezone,
                                  // ),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Text(
                              model.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                          // Visibility(
                          //   visible: model.isRecurring,
                          //   child: Wrap(
                          //     crossAxisAlignment: WrapCrossAlignment.center,
                          //     children: <Widget>[
                          //       Text(
                          //         S.of(context).recurring,
                          //         style: TextStyle(
                          //             fontSize: 16.0,
                          //             color: Theme.of(context).primaryColor,
                          //             fontWeight: FontWeight.bold),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              model.email != user.email &&
                                      (model.acceptors.contains(user.email) ||
                                          model.approvedUsers
                                              .contains(user.email) ||
                                          model.oneToManyRequestAttenders
                                              .contains(user.email))
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      width: 100,
                                      height: 32,
                                      child: CustomTextButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.all(0),
                                        color: Colors.green,
                                        child: (model.requestType ==
                                                    RequestType
                                                        .ONE_TO_MANY_REQUEST &&
                                                model.acceptors
                                                    .contains(user.email) &&
                                                !model.approvedUsers
                                                    .contains(user.email))
                                            ? Text(
                                                S.of(context).invited,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              )
                                            : (model.requestType ==
                                                        RequestType
                                                            .ONE_TO_MANY_REQUEST &&
                                                    model.approvedUsers
                                                        .contains(user.email))
                                                ? Text(
                                                    S.of(context).accepted,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(
                                                    S.of(context).applied,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                        onPressed: () {},
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
