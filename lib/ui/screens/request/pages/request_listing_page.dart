import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_listing.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart'; // Add this import
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/request/bloc/request_bloc.dart';
import 'package:sevaexchange/ui/screens/request/widgets/cutom_chip.dart';
import 'package:sevaexchange/ui/screens/request/widgets/request_card.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/location_helper.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/create_request/createrequest.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_dialogs/custom_dialog.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/empty_widget.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/tag_view.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class RequestListingPage extends StatefulWidget {
  final TimebankModel? timebankModel;
  final bool? isFromSettings;

  const RequestListingPage({
    Key? key,
    this.isFromSettings = false,
    this.timebankModel,
  }) : super(key: key);
  @override
  _RequestListingPageState createState() => _RequestListingPageState();
}

class _RequestListingPageState extends State<RequestListingPage> {
  late Future<GeoPoint> currentCoords;
  final RequestBloc _bloc = RequestBloc();

  Future<GeoPoint> _getGeoPoint() async {
    final latLng = SevaCore.of(context).loggedInUser.lat_lng;
    if (latLng != null && latLng.isNotEmpty) {
      final latLngList = latLng.split(',');
      if (latLngList.length == 2) {
        final latitude = double.tryParse(latLngList[0]) ?? 0.0;
        final longitude = double.tryParse(latLngList[1]) ?? 0.0;
        return GeoPoint(latitude, longitude);
      }
    }
    return GeoPoint(0.0, 0.0);
  }

  @override
  void initState() {
    currentCoords = _getGeoPoint();
    Future.delayed(Duration.zero, () {
      _bloc.init(
        widget.timebankModel!.id!,
        SevaCore.of(context).loggedInUser.sevaUserID!,
      );
    });
    super.initState();
  }

  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isFromSettings! ? AppBar() : null,
      body: Provider<RequestBloc>(
        create: (context) => _bloc,
        dispose: (c, b) => b.dispose(),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    S.of(context).requests,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                infoButton(
                  context: context,
                  key: GlobalKey(),
                  type: InfoType.REQUESTS,
                ),
                HideWidget(
                  hide: widget.isFromSettings!,
                  child: TransactionLimitCheck(
                    comingFrom: ComingFrom.Requests,
                    timebankId: widget.timebankModel!.id,
                    isSoftDeleteRequested:
                        widget.timebankModel!.requestedSoftDelete,
                    child: GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(left: 0),
                        child: Icon(
                          Icons.add_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onTap: () => onCreateButtonTap(widget.timebankModel!),
                    ),
                  ),
                  secondChild: SizedBox.shrink(),
                ),
              ],
            ),
            buildFilterView(),
            SizedBox(height: 8),
            FutureBuilder<GeoPoint>(
              future: currentCoords,
              builder: (context, AsyncSnapshot<GeoPoint> currentLocation) {
                if (currentLocation.connectionState ==
                    ConnectionState.waiting) {
                  return LoadingIndicator();
                }

                if (!widget.isFromSettings!) {
                  return Expanded(
                    child: SingleChildScrollView(
                      child: RequestListBuilder(
                        coords: currentLocation.data,
                        timebankModel: widget.timebankModel!,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<RequestFilter> buildFilterView() {
    return StreamBuilder<RequestFilter>(
      initialData: RequestFilter(),
      stream: _bloc.filter,
      builder: (context, snapshot) {
        var filter = snapshot.data;
        return Container(
          height: 50,
          child: ListView(
            // crossAxisAlignment: WrapCrossAlignment.start,
            // spacing: 4.0,
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(width: 10),
              CustomChip(
                label: 'Time',
                isSelected: filter!.timeRequest!,
                onTap: () {
                  _bloc.onFilterChange(
                    snapshot.data!.copyWith(
                      timeRequest: !snapshot.data!.timeRequest,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: 'Money',
                isSelected: filter.cashRequest,
                onTap: () {
                  _bloc.onFilterChange(
                    snapshot.data!.copyWith(
                      cashRequest: !snapshot.data!.cashRequest,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: 'Goods',
                isSelected: filter.goodsRequest,
                onTap: () {
                  _bloc.onFilterChange(
                    snapshot.data!.copyWith(
                      goodsRequest: !snapshot.data!.goodsRequest,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: S.of(context).one_to_many.sentenceCase(),
                isSelected: filter.oneToManyRequest,
                onTap: () {
                  _bloc.onFilterChange(
                    snapshot.data!.copyWith(
                      oneToManyRequest: !snapshot.data!.oneToManyRequest,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: S.of(context).borrow,
                isSelected: filter.borrowRequest,
                onTap: () {
                  _bloc.onFilterChange(
                    snapshot.data!.copyWith(
                      borrowRequest: !snapshot.data!.borrowRequest,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: 'Public',
                isSelected: filter.publicRequest,
                onTap: () {
                  _bloc.onFilterChange(
                    snapshot.data!.copyWith(
                      publicRequest: !snapshot.data!.publicRequest,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: S.of(context).virtual,
                isSelected: filter.virtualRequest,
                onTap: () {
                  _bloc.onFilterChange(
                    snapshot.data!.copyWith(
                      virtualRequest: !snapshot.data!.virtualRequest,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }

  void onCreateButtonTap(TimebankModel timebankModel) {
    bool _isAccessAvailable = isAccessAvailable(
      timebankModel,
      SevaCore.of(context).loggedInUser.sevaUserID!,
    );
    if (timebankModel.protected) {
      if (_isAccessAvailable) {
        _navigateToCreateRequest(timebankModel.id);
        return;
      }
      CustomDialogs.generalDialogWithCloseButton(
        context,
        S.of(context).protected_timebank_request_creation_error,
      );
    } else {
      if (timebankModel.id == FlavorConfig.values.timebankId &&
          !_isAccessAvailable) {
        showAdminAccessMessage(context: context);
      } else {
        _navigateToCreateRequest(timebankModel.id);
      }
    }
  }

  void _navigateToCreateRequest(String timebankId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRequest(
          comingFrom: ComingFrom.Requests,
          userModel: UserModel(),
          projectModel: ProjectModel(),
          requestModel: RequestModel(communityId: timebankId),
          timebankId: timebankId,
          projectId: '', // Provide the appropriate projectId here
        ),
      ),
    );
  }
}

class RequestListBuilder extends StatelessWidget {
  final Coordinates coords;
  final TimebankModel timebankModel;

  const RequestListBuilder({Key key, this.coords, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RequestLists>(
      stream: Provider.of<RequestBloc>(context).requests,
      builder: (context, AsyncSnapshot<RequestLists> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('${S.of(context).general_stream_error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingIndicator(),
          );
        }

        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Center(
            child: EmptyWidget(
              sub_title: S.of(context).no_content_common_description,
              title: S.of(context).no_requests_title,
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HideWidget(
                hide: snapshot.data.myRequests.isEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        S.of(context).my_requests,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ...snapshot.data.myRequests
                        .map(
                          (model) => RequestCard(
                            model: model,
                            coords: coords,
                            onTap: () => editRequest(
                              model: model,
                              context: context,
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
              HideWidget(
                hide: snapshot.data.communityRequests.isEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8),
                      child: Text(
                        S.of(context).seva_community_requests,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ...snapshot.data.communityRequests
                        .map(
                          (model) => RequestCard(
                            model: model,
                            coords: coords,
                            onTap: () => editRequest(
                              model: model,
                              context: context,
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void editRequest({BuildContext context, RequestModel model}) {
    bool isAdmin = false;
    timeBankBloc.setSelectedRequest(model);
    timeBankBloc.setSelectedTimeBankDetails(timebankModel);
    if (model.requestMode == RequestMode.PERSONAL_REQUEST) {
      isAdmin = model.sevaUserId == SevaCore.of(context).loggedInUser.sevaUserID
          ? true
          : false;
    } else {
      isAdmin = isAccessAvailable(
        timebankModel,
        SevaCore.of(context).loggedInUser.sevaUserID,
      );
    }
    timeBankBloc.setIsAdmin(isAdmin);

    if (model.isRecurring) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_context) => BlocProvider(
                    bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                    child: RecurringListing(
                      comingFrom: ComingFrom.Requests,
                      requestModel: model,
                      timebankModel: timebankModel,
                      offerModel: null,
                    ),
                  )));
    } else if (model.sevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID ||
        isAccessAvailable(
            timebankModel, SevaCore.of(context).loggedInUser.sevaUserID)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_context) => BlocProvider(
            bloc: BlocProvider.of<HomeDashBoardBloc>(context),
            child: RequestTabHolder(
              //communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
              isAdmin: true,
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_context) => BlocProvider(
            bloc: BlocProvider.of<HomeDashBoardBloc>(context),
            child: RequestDetailsAboutPage(
              requestItem: model,
              timebankModel: timebankModel,
              isAdmin: false,
              //communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
            ),
          ),
        ),
      );
    }
  }
}

Widget getAppropriateTag(BuildContext context, RequestType requestType) {
  switch (requestType) {
    case RequestType.CASH:
      return getTagMainFrame(S.of(context).cash);

    case RequestType.GOODS:
      return getTagMainFrame(S.of(context).goods);

    case RequestType.TIME:
      return getTagMainFrame(S.of(context).time);

    case RequestType.ONE_TO_MANY_REQUEST:
      return getTagMainFrame(S.of(context).one_to_many.sentenceCase());

    case RequestType.BORROW:
      return getTagMainFrame('Borrow'); //Label to be created

    default:
      return Container();
  }
}

Widget getTagMainFrame(String tagTitle) {
  return Container(
    margin: EdgeInsets.only(right: 10),
    child: TagView(tagTitle: tagTitle),
  );
}

class RequestViewClassifer {
  static String getTimeFormattedString(
    int timeInMilliseconds,
    String timezoneAbb,
  ) {
    DateFormat dateFormat =
        DateFormat('d MMM hh:mm a ', Locale(getLangTag()).toLanguageTag());
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    DateTime localtime = getDateTimeAccToUserTimezone(
        dateTime: datetime, timezoneAbb: timezoneAbb);
    String from = dateFormat.format(
      localtime,
    );
    return from;
  }

  static String getLocation(String location) {
    if (location != null && location.length > 1) {
      List<String> l = location.split(',');
      l = l.reversed.toList();
      if (l.length >= 2) {
        return "${l[1]},${l[0]}";
      } else if (l.length >= 1) {
        return "${l[0]}";
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static String getTimeInText({int postTimeStamp}) {
    return timeAgo
        .format(
            DateTime.fromMillisecondsSinceEpoch(
              postTimeStamp,
            ),
            locale: Locale(AppConfig.prefs.getString('language_code'))
                .toLanguageTag())
        .replaceAll('hours ago', 'hr');
  }

  static BoxDecoration get containerDecorationR {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    );
  }
}
