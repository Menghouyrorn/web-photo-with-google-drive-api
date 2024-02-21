// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:theringphoto/screens/navigation_bar/desktop_bar_responsive.dart';
import 'package:theringphoto/screens/navigation_bar/mobile_bar_responsive.dart';
import 'package:theringphoto/screens/navigation_bar/tablet_bar_responsive.dart';
import 'package:theringphoto/staff/screen/list_album_staff.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';
import 'package:theringphoto/screens/navigation_bar/drawerforallAppbar.dart';


class HomeScreenStaff extends StatelessWidget{
  @override
 Widget build(BuildContext context) {
    bool isMobile = false;
    bool isTablet = false;
    if (ResponsiveUtils.isMobile(context)) {
      isMobile = true;
    } else if (ResponsiveUtils.isTablet(context)) {
      isTablet = true;
    }

    if (isMobile) {
      return Scaffold(
        appBar: MobileBar(),
        endDrawer: DrawerTest(context,'staff'),
        body: const ListAlbumsStaff(),
      );
    }

    if (isTablet) {
      return Scaffold(
        appBar: TabletBar(),
        body: const ListAlbumsStaff(),
        endDrawer: DrawerTest(context,'staff'),
      );
    } else {
      return Scaffold(
        appBar: DeskTopBar(context,'staff'),
        body: const ListAlbumsStaff(),
      );
    }
  }

  
}
