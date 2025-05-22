import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_driver/common/app_style.dart';
import 'package:foodly_driver/common/back_ground_container.dart';
import 'package:foodly_driver/common/reusable_text.dart';
import 'package:foodly_driver/common/shimmers/foodlist_shimmer.dart';
import 'package:foodly_driver/constants/constants.dart';
import 'package:foodly_driver/hooks/fetchDriverAddress.dart';
import 'package:foodly_driver/models/driver_address_model.dart';
import 'package:foodly_driver/views/profile/widgets/add_address.dart';
import 'package:foodly_driver/views/profile/widgets/address_list.dart';
import 'package:get/get.dart';

class Addresses extends HookWidget {
  const Addresses({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchAdresses();
    final List<AddressesList> addresses = hookResult.data;
    final isLoading = hookResult.isLoading;
    final error = hookResult.error;
    final refetch = hookResult.refetch;

    return Scaffold(
        backgroundColor: kPrimary,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: kWhite
          ),
          backgroundColor: kPrimary,
          elevation: 0,
          leading: InkWell(
              onTap: () {
                Get.back();
              },
              child: const Icon(CupertinoIcons.back)),

          centerTitle: true,
          title: ReusableText(text:
          "Addresses",
            style: appStyle(kFontSizeBodyLarge, Colors.white, FontWeight.w600),
          ),
        ),
        body: BackGroundContainer(
            color: kLightWhite,
            child: Stack(
              children: [
                isLoading
                    ? const FoodsListShimmer()
                    : Container(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  width: width,
                  height: hieght,
                  child: AddressList(addresses: addresses),
                ),


                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: hieght * 0.08,
                    padding: EdgeInsets.only(bottom: 20.0.h),
                    width: width,
                    color: Colors.transparent,
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.to(() => const AddAddress());
                        },
                        style: OutlinedButton.styleFrom(
                          // visualDensity: VisualDensity.compact,
                          elevation: 0,
                          foregroundColor: kLightWhite,
                          backgroundColor: kPrimary,
                          fixedSize: Size(width * 0.9, 15),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                        ),
                        child: ReusableText(
                          text: "Add Address",
                          style: appStyle(kFontSizeBodyRegular, kLightWhite, FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )));
  }
}
