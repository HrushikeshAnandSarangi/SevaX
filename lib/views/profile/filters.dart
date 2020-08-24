import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/neayby_setting/nearby_setting.dart';

import '../core.dart';

class NearByFiltersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filters'),
      ),
      body: SafeArea(
        child: NearbySettingsWidget(
          SevaCore.of(context).loggedInUser,
        ),
      ),
    );
  }
}
