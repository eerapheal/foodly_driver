import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_driver/common/shimmers/foodlist_shimmer.dart';
import 'package:foodly_driver/constants/constants.dart';
import 'package:foodly_driver/hooks/fetchDriverOrders.dart';
import 'package:foodly_driver/models/ready_orders.dart';
import 'package:foodly_driver/views/home/widgets/order_tile.dart';

class ActiveOrders extends HookWidget {
   const ActiveOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchPicked("Out_for_Delivery");
    List<ReadyOrders>? orders = hookResult.data ?? [];
    final isLoading = hookResult.isLoading;

    return Container(
      height: hieght ,
      width: width,
      color: kLightWhite,
      child: isLoading
          ? const FoodsListShimmer()
          : ListView.builder(
              padding: EdgeInsets.only(top: 10.h, left: 12.w, right: 12.w),
              itemCount: orders!.length,
              itemBuilder: (context, i) {
                ReadyOrders order = orders[i];
                return OrderTile(order: order, active: 'active');
              }),
    );
  }
}
