import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:foodly_driver/common/entities/user.dart';
import 'package:foodly_driver/constants/constants.dart';
import 'package:foodly_driver/main.dart';
import 'package:foodly_driver/models/api_error.dart';
import 'package:foodly_driver/models/driver_response.dart';
import 'package:foodly_driver/models/login_request.dart';
import 'package:foodly_driver/models/login_response.dart';
import 'package:foodly_driver/views/auth/driver_registration.dart';
import 'package:foodly_driver/views/auth/login_page.dart';
import 'package:foodly_driver/views/auth/waiting_page.dart';
import 'package:foodly_driver/views/entrypoint.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  final box = GetStorage();
  RxBool _isLoading = false.obs;
  final db = FirebaseFirestore.instance;
  bool get isLoading => _isLoading.value;

  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  LoginResponse? _loginResponse;
  LoginResponse? get loginResponse => _loginResponse;

  void loginFunc(String model, LoginRequest login) async {
    setLoading = true;

    var url = Uri.parse('$appBaseUrl/login');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: model,
      );

      print(response.body);

      if (response.statusCode == 200) {
        LoginResponse data = loginResponseFromJson(response.body);
        String userId = data.id;
        String userData = json.encode(data);
        print("getting data ${userData}");
        box.write(userId, userData);
        box.write("token", data.userToken);
        box.write("userId", data.id);
        box.write("user", userData);
        if (data.userType == "Driver") {
          getDriver(data.userToken);
        } else {
          Get.snackbar("Opps Error ",
              "You are not a driver, please register as a driver",
              colorText: Colors.red,
              backgroundColor: kPrimary,
              icon: const Icon(Ionicons.fast_food_outline));

          defaultHome = const Login();
          Get.offAll(() => const DriverRegistration(),
              transition: Transition.fade,
              duration: const Duration(seconds: 2));

          defaultHome = const Login();
        }

        setLoading = false;

        Get.snackbar("Successfully logged in ", "Enjoy your awesome experience",
            colorText: kLightWhite,
            backgroundColor: kPrimary,
            icon: const Icon(Ionicons.fast_food_outline));
        var userbase = await db.collection("users").withConverter(
          fromFirestore: UserData.fromFirestore,
          toFirestore: (UserData userdata, options)=>userdata.toFirestore(),
        ).where("id", isEqualTo: userId).get();

        if(userbase.docs.isEmpty){
          print("docs---empty");
          final data = UserData(
              id:userId,
              name: "",
              email: login.email,
              photourl: "",
              location: "",
              fcmtoken: "",
              addtime: Timestamp.now()

          );
          try {
            await db.collection("users").withConverter(
              fromFirestore: UserData.fromFirestore,
              toFirestore: (UserData userdata, options) => userdata.toFirestore(),
            ).add(data);

            print("docs---updated");
          } catch (e) {
            print("Error adding document: $e");
          }
          print("docs---updated");
        }else{
          print("docs---exist");
        }

      } else {
        var data = apiErrorFromJson(response.body);

        Get.snackbar(data.message, "Failed to login, please try again",
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      print(e);
      setLoading = false;

      Get.snackbar(e.toString(), "Failed to login, please try again",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error));
    } finally {
      setLoading = false;
    }
  }

  void logout() {
    box.erase();
    defaultHome = const Login();
    Get.offAll(() => defaultHome,
        transition: Transition.fade, duration: const Duration(seconds: 2));
  }

  LoginResponse? getUserData() {
    String? userId = box.read("userId");
    String? data = box.read(userId.toString());
    if (data != null) {
      return loginResponseFromJson(data);
    }
    return null;
  }

  void getDriver(String token) async {
    var url = Uri.parse('$appBaseUrl/api/driver');

    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Driver driver = driverFromJson(response.body);
        box.write("driverId", driver.id);
        box.write(driver.id, json.encode(driver));

        box.write("verification", driver.verification);

        if (driver.verification != "Verified") {
          Get.offAll(() => const WaitingPage(),
              transition: Transition.fade,
              duration: const Duration(seconds: 2));
        } else {
          Get.to(() => MainScreen(),
              transition: Transition.fade,
              duration: const Duration(seconds: 2));
        }
      } else {
        var error = apiErrorFromJson(response.body);

        Get.snackbar("Opps Error ", error.message,
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Ionicons.fast_food_outline));

        Get.offAll(() => MainScreen(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      }
    } catch (e) {
      Get.snackbar(e.toString(), "Failed to login, please try again",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error));
    }
  }

  Driver? getDriverData() {
    String? driverId = box.read("driverId");
    String? data = box.read(driverId!);
    if (data != null) {
      return driverFromJson(data);
    }
    return null;
  }
}
