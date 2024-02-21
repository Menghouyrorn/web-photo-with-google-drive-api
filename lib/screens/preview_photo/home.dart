import 'package:flutter/material.dart';
import 'package:theringphoto/screens/preview_photo/preview_photo_desktop.dart';
import 'package:theringphoto/screens/preview_photo/preview_photo_mobile.dart';
import 'package:theringphoto/screens/preview_photo/preview_photo_tablet.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';


// ignore: camel_case_types
class Preview_Photo extends StatelessWidget{
  const Preview_Photo({super.key});

  @override
  Widget build  (BuildContext context){
    if (ResponsiveUtils.isMobile(context)) {
      return const Preview_Photo_Mobile();
    } else if (ResponsiveUtils.isDesktop(context)) {
      return const Preview_Photo_Desktop();
    }
    return const Preview_Photo_Tablet();
  }
}

