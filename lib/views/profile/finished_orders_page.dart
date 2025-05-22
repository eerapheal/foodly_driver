import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_driver/common/app_style.dart';
import 'package:foodly_driver/common/custom_app_bar.dart';
import 'package:foodly_driver/common/custom_container.dart';
import 'package:foodly_driver/common/reusable_text.dart';
import 'package:foodly_driver/common/row_text.dart';
import 'package:foodly_driver/common/shimmers/foodlist_shimmer.dart';
import 'package:foodly_driver/constants/constants.dart';
import 'package:foodly_driver/controllers/order_controller.dart';
import 'package:foodly_driver/hooks/fetchFinishedOrders.dart';
import 'package:foodly_driver/models/ready_orders.dart';
import 'package:foodly_driver/views/entrypoint.dart';
import 'package:foodly_driver/views/home/widgets/order_tile.dart';
import 'package:get/get.dart';

class FinishedOrdersPage extends HookWidget {
  const FinishedOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchClientFinishedOrders();
    List<ReadyOrders>? orders = hookResult.data ?? [];
    final isLoading = hookResult.isLoading;

    return Scaffold(
      appBar: CommonAppBar(
        titleText: "My orders"
      ),
      body: Container(
        height: hieght / 1.3,
        width: width,
        color: kLightWhite,
        child: isLoading
            ? const FoodsListShimmer()
            : ListView.builder(
            padding: EdgeInsets.only(top: 10.h, left: 12.w, right: 12.w),
            itemCount: orders!.length,
            itemBuilder: (context, i) {
              ReadyOrders order = orders[i];
              return OrderTile(order: order, active: null,);
            }),
      ),
    );
  }
}
