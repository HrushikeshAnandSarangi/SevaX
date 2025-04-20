import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/neayby_setting/nearby_setting.dart';

class NearByFiltersView extends StatelessWidget {
  final UserModel? userModel;

  NearByFiltersView({this.userModel});

  @override
  Widget build(BuildContext context) {
    return NearbySettingsWidget(
      userModel!,
    );
  }
}
