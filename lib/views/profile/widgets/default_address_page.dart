
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_driver/common/app_style.dart';
import 'package:foodly_driver/common/back_ground_container.dart';
import 'package:foodly_driver/common/custom_app_bar.dart';
import 'package:foodly_driver/common/custom_btn.dart';
import 'package:foodly_driver/common/reusable_text.dart';
import 'package:foodly_driver/constants/constants.dart';
import 'package:foodly_driver/controllers/address_controller.dart';
import 'package:foodly_driver/models/driver_address_model.dart';
import 'package:get/get.dart';
class SetDefaultAddressPage extends StatelessWidget {
  const SetDefaultAddressPage({super.key, required this.address});

  final AddressesList address;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());
    return Scaffold(
      backgroundColor: kPrimary,
      appBar: CommonAppBar(
        titleText:  "Change Default Address"
      ) ,
      body: BackGroundContainer(
        color: kLightWhite,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          children: [
            SizedBox(
              height: 35.h,
            ),

            ReusableText(
                text: address.addressLine1,
                style: appStyle(kFontSizeBodyRegular, kGray, FontWeight.normal)),


            SizedBox(
              height: 15.h,
            ),
            CustomButton(
              onTap: () {
                controller.setDefaultAddress(address.id);
              },
              radius: 9,
              color: kPrimary,
              btnWidth: width * 0.95,
              btnHieght: 34.h,
              text: "CLICK TO SET AS DEFAULT",
            ),


          ],
        ),
      ),
    );
  }
}
