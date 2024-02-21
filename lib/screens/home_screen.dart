import 'package:flutter/material.dart';
import 'package:theringphoto/screens/listAlbum.dart';
import 'package:theringphoto/screens/navigation_bar/desktop_bar_responsive.dart';
import 'package:theringphoto/screens/navigation_bar/mobile_bar_responsive.dart';
import 'package:theringphoto/screens/navigation_bar/tablet_bar_responsive.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';
import 'package:theringphoto/screens/navigation_bar/drawerforallAppbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        endDrawer: DrawerTest(context,'customer'),
        body: const ListAlbums(),
      );
    }

    if (isTablet) {
      return Scaffold(
        appBar: TabletBar(),
        body: const ListAlbums(),
        endDrawer: DrawerTest(context,'customer'),
      );
    } else {
      return Scaffold(
        appBar: DeskTopBar(context, 'customer'),
        body: const ListAlbums(),
      );
    }
  }
}
