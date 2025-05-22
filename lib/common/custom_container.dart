import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_driver/constants/constants.dart';

// ignore: must_be_immutable
class CustomContainer extends StatelessWidget {
  CustomContainer({
    super.key,
    this.containerContent,
  });

  Widget? containerContent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: hieght ,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0.r),
              bottomRight: Radius.circular(0.r)),
          child: Container(
            width: width,
            color: kWhite,
            child: SingleChildScrollView(child: containerContent),
          ),
        ));
  }
}
