import 'package:flutter/material.dart';
import 'package:theringphoto/screens/navigation_bar/desktop_bar_responsive.dart';
import 'package:theringphoto/screens/navigation_bar/mobile_bar_responsive.dart';
import 'package:theringphoto/screens/navigation_bar/tablet_bar_responsive.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';

// ignore: must_be_immutable
class NavigationBarTheRing extends StatelessWidget {
  String byuser;
  NavigationBarTheRing({super.key,required this.byuser});

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return MobileBar();
    } else if (ResponsiveUtils.isDesktop(context)) {
      return DeskTopBar(context,byuser);
    }
    return TabletBar();
  }
}
