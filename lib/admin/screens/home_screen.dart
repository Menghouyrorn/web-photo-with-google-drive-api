import 'package:flutter/material.dart';
import 'package:theringphoto/admin/screens/list_album_admin.dart';
import 'package:theringphoto/screens/navigation_bar/desktop_bar_responsive.dart';
import 'package:theringphoto/screens/navigation_bar/mobile_bar_responsive.dart';
import 'package:theringphoto/screens/navigation_bar/tablet_bar_responsive.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';
import 'package:theringphoto/screens/navigation_bar/drawerforallAppbar.dart';

class MyHomeAdmin extends StatelessWidget {
  const MyHomeAdmin({super.key});

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
        endDrawer: DrawerTest(context, 'admin'),
        appBar: MobileBar(),
        body: const ListAlbumsAdmin(),
      );
    }

    if (isTablet) {
      return Scaffold(
        appBar: TabletBar(),
        body: const ListAlbumsAdmin(),
        endDrawer: DrawerTest(context, 'admin'),
      );
    } else {
      return Scaffold(
        appBar: DeskTopBar(context, 'admin'),
        body: const ListAlbumsAdmin(),
      );
    }
  }
}
