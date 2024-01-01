import 'package:flutter/material.dart';

const destinations = <Widget>[
  NavigationDestination(
    selectedIcon: Icon(Icons.home),
    icon: Icon(Icons.home_outlined),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(
      Icons.book,
    ),
    label: 'Common Pinoy Food',
  ),
  NavigationDestination(
    icon: Icon(
      Icons.settings,
    ),
    label: 'Settings',
  ),
];
