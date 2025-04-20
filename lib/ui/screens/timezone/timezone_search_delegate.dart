import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/timezone/widgets/timezone_card.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/profile/timezone.dart';

class TimezoneSearchDelegate extends SearchDelegate<TimeZoneModel> {
  final List<TimeZoneModel>? timezoneList;
  final String? selectedTimezone;
  TimezoneSearchDelegate({
    textStyle,
    this.timezoneList,
    this.selectedTimezone,
  }) : super(searchFieldStyle: textStyle);

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    logger.e("#appTHEME ${theme.primaryColor}");
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      color: Colors.white,
      onPressed: () {
        close(context, null!);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResult();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResult();
  }

  Widget buildSearchResult() {
    var searchResult =
        TimezoneListData().searchTimebank(query, timezoneList ?? []);
    if (searchResult == null || searchResult.isEmpty) {
      return Center(child: Text('No Timezone found'));
    }
    return ListView.builder(
      itemCount: searchResult.length,
      itemBuilder: (context, index) {
        TimeZoneModel timeZoneModel = searchResult[index];
        DateTime timeInUtc = DateTime.now().toUtc();
        DateTime localtime = timeInUtc.add(Duration(
            hours: timeZoneModel.offsetFromUtc!,
            minutes: timeZoneModel.offsetFromUtcMin!));
        return TimezoneCard(
          title: timeZoneModel.timezoneName!,
          subTitle: DateFormat(
            'dd/MMM/yyyy HH:mm',
            S.of(context).localeName == 'sn' ? 'en' : S.of(context).localeName,
          ).format(localtime),
          onTap: () {
            close(context, timeZoneModel);
          },
          code: timeZoneModel.timezoneAbb!,
          isSelected: selectedTimezone == timeZoneModel.timezoneName,
        );
      },
    );
  }
}
