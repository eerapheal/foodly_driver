import 'package:flutter/material.dart';
import 'package:foodly_driver/common/app_style.dart';
import 'package:foodly_driver/common/reusable_text.dart';
import 'package:foodly_driver/constants/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.text, this.color, this.onTap, this.btnWidth, this.radius, this.btnHieght});

  final String text;
  final Color? color;
  final double? btnWidth;
  final double? btnHieght;
  final double? radius;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: btnWidth ?? width,
        height: btnHieght??28,
        decoration:  BoxDecoration(
            color: color?? kSecondary,
            borderRadius:  BorderRadius.all(Radius.circular(radius??12))),
        child: Center(
          child: ReusableText(
              text: text,
              style: appStyle(kFontSizeButton,  kLightWhite, FontWeight.w500)),
        ),
      )
    );
  }
}
