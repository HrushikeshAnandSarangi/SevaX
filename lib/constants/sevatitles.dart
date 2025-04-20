// import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:sevaexchange/utils/app_config.dart';

final String newsCreateTitle = "Add News Post";
final String feedTitle = "News Feed";
final String defaultUserImageURL =
    "https://firebasestorage.googleapis.com/v0/b/sevaxproject4sevax.appspot.com/o/static_images%2Fdefault_user_image.jpg?alt=media&token=5f35ee87-78b1-4d04-9c4a-967a03dde926";
final String defaultUsername = "Anonymous";
final double dialogButtonSize = 16;
final String addImageIcon =
    "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/icons%2Fadd_photo_icon.PNG?alt=media&token=54ddd35a-545b-429e-be3e-06528d64225b";

final String defaultCameraImageURL =
    "https://firebasestorage.googleapis.com/v0/b/sevaxproject4sevax.appspot.com/o/static_images%2Fimageedit_1_8210492120.png?alt=media&token=082173b7-843f-4a14-b837-e40ca32a863b";

final String defaultProjectImageURL =
    "https://firebasestorage.googleapis.com/v0/b/sevaxproject4sevax.appspot.com/o/timebanklogos%2Fproject_default.jpg?alt=media&token=a2cd81e3-c90f-4d04-ae14-6cfaa42d4e90";

final String defaultGroupImageURL =
    "https://firebasestorage.googleapis.com/v0/b/sevaxproject4sevax.appspot.com/o/timebanklogos%2Fgroup_default.jpg?alt=media&token=206f56eb-d575-4ae8-ac55-34aef5f3958a";

List<dynamic> currencyItems =
    jsonDecode(AppConfig.remoteConfig!.getString("currency_code_name_flag"));
