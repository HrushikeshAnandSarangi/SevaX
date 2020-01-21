import 'package:flutter/material.dart';
import 'package:sevaexchange/models/bottom_navigation_data.dart';

List<BottomNavigationData> bottomNavigationData = [
  BottomNavigationData(Icons.search, "Explore", Icons.search),
  BottomNavigationData(
    Icons.notifications,
    "Notifications",
    Icons.notifications_none,
  ),
  BottomNavigationData(
    Icons.home,
    "Home",
    Icons.home,
  ),
  BottomNavigationData(
    Icons.chat_bubble,
    "Messages",
    Icons.chat_bubble_outline,
  ),
  BottomNavigationData(
    Icons.settings,
    "Settings",
    Icons.settings,
  ),
];
