import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:foodly_driver/common/show_snack_bar.dart';
import 'package:foodly_driver/constants/constants.dart';
import 'package:foodly_driver/controllers/location_controller.dart';
import 'package:foodly_driver/models/api_error.dart';
import 'package:foodly_driver/models/ready_orders.dart';
import 'package:foodly_driver/views/order/active_page.dart';
import 'package:foodly_driver/views/order/delivered.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OrdersController extends GetxController {
  final box = GetStorage();
  final userController = Get.put(UserLocationController);
  ReadyOrders? order;

  double _tripDistance = 0;
  double _restaurantToClient=0;
  RxBool _activeOrders = false.obs;
  RxBool _validOrder = true.obs;
  RxBool get activeOrder => _activeOrders;
  set setActiveOrder(bool order){
    _activeOrders.value=order;
  }
  RxBool get validOrder => _validOrder;
  // Getter
  double get tripDistance => _tripDistance;

  //getter
  double get restaurantToClient => _restaurantToClient;
  // Setter
  set setTotalDistance(double newValue) {
    _tripDistance = newValue;
    if(_tripDistance>20){
      _validOrder.value=false;
    }

  }

  set setTotalDistanceFromRestaurantToClient(double newValue) {
    _restaurantToClient = newValue;
  }

  // Reactive state
  var _count = 0.obs;

  // Getter
  int get count => _count.value;

  // Setter
  set setCount(int newValue) {
    _count.value = newValue;
  }

  var _setLoading = false.obs;

  // Getter
  bool get setLoading => _setLoading.value;

  // Setter
  set setLoading(bool newValue) {
    _setLoading.value = newValue;
  }

  void pickOrder(String orderId) async {
    String driverId = box.read('driverId');
    String accessToken = box.read('token');

    setLoading = true;
    var url =
        Uri.parse('$appBaseUrl/api/orders/picked-orders/$orderId/$driverId');

    try {
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        setLoading = false;
        showCustomSnackBar("Order picked successfully", title:  "To view the order, go to the active tab",);

        Map<String, dynamic> data = jsonDecode(response.body);
        order = ReadyOrders.fromJson(data);

        Get.off(() => const ActivePage(),
            transition: Transition.fadeIn,
            duration: const Duration(seconds: 2));
      } else {
        var data = apiErrorFromJson(response.body);


        showCustomSnackBar(data.message.toString(), title: "Failed order picking");

      }
    } catch (e) {
      setLoading = false;
      showCustomSnackBar(e.toString(), title: "Failed order picking");
    } finally {
      setLoading = false;
    }
  }

  void markOrderAsDelivered(String orderId) async {
    String accessToken = box.read('token');
    setLoading = true;
    var url = Uri.parse('$appBaseUrl/api/orders/delivered/$orderId');
    try {
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );

      if (response.statusCode == 200) {
        setLoading = false;

        Get.snackbar("Order delivered successfully",
            "Thank you for your service, please continue awesome work",
            colorText: kLightWhite,
            backgroundColor: kTertiary,
            icon: const Icon(FontAwesome5Solid.shipping_fast));

        Map<String, dynamic> data = jsonDecode(response.body);
        order = ReadyOrders.fromJson(data);

        Get.off(() => const DeliveredPage(),
            transition: Transition.fadeIn,
            duration: const Duration(seconds: 2));
      } else {
        var data = apiErrorFromJson(response.body);
        print(data.message);
        showCustomSnackBar(data.message,
            title: "Failed to mark as delivered, please try again or contact support",
        );
      }
    } catch (e) {
      setLoading = false;

      showCustomSnackBar(
          e.toString(), title: "Failed to mark order as delivered please try again",
          );
    } finally {
      setLoading = false;
    }
  }
}
