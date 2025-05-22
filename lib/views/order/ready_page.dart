// ignore_for_file: unrelated_type_equality_checks, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:foodly_driver/common/app_style.dart';
import 'package:foodly_driver/common/contact_controller.dart';
import 'package:foodly_driver/common/custom_btn.dart';
import 'package:foodly_driver/common/divida.dart';
import 'package:foodly_driver/common/reusable_text.dart';
import 'package:foodly_driver/common/row_text.dart';
import 'package:foodly_driver/common/show_snack_bar.dart';

import 'package:foodly_driver/constants/constants.dart';
import 'package:foodly_driver/controllers/location_controller.dart';
import 'package:foodly_driver/controllers/order_controller.dart';
import 'package:foodly_driver/hooks/fetchRestaurantData.dart';
import 'package:foodly_driver/models/distance_time.dart';
import 'package:foodly_driver/models/response_model.dart';
import 'package:foodly_driver/services/distance.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReadyPage extends StatefulHookWidget {
  const ReadyPage({super.key});

  @override
  State<ReadyPage> createState() => _ReadyPageState();
}

class _ReadyPageState extends State<ReadyPage> {
  PolylinePoints polylinePoints = PolylinePoints();
  final controller = Get.find<OrdersController>();
  final userController = Get.find<UserLocationController>();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Placemark? place;

  late GoogleMapController mapController;

  Map<MarkerId, Marker> markers = {};

  String image =
      "https://d326fntlu7tb1e.cloudfront.net/uploads/5c2a9ca8-eb07-400b-b8a6-2acfab2a9ee2-image001.webp";

  late LatLng _restaurant;
  late LatLng _client;
  late LatLng _user;
  var restaurantData ;
  @override
  void initState() {
    super.initState();
    _initializeCoordinates();
    _determinePosition();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _initializeCoordinates() {
    if (controller.order != null) {
      var coordsRes = controller.order!.restaurantCoords;
      _restaurant = LatLng(coordsRes[0], coordsRes[1]);
      var coordsClient = controller.order!.recipientCoords;
      _client = LatLng(coordsClient[0], coordsClient[1]);
      var coordsDriverLat = userController.currentLocation.latitude;
      var coordsDriverLng = userController.currentLocation.longitude;
      _user = LatLng(coordsDriverLat, coordsDriverLng);
      print("_restaurant coordinates are ${_restaurant}");
      print("_client coordinates are ${_client}");
    } else {
      _restaurant = const LatLng(37.7786, -122.4181);
      print("_restaurant coordinates are ${_restaurant}");// Default coordinates
    }
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    var currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      //_center = LatLng(currentLocation.latitude, currentLocation.longitude);

      // Adding markers
      _addMarker(_client, "client_location");
      _addMarker(_restaurant, "restaurant_location");

      // Calculate the bounds to include both markers
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          min(_client.latitude, _restaurant.latitude),
          min(_client.longitude, _restaurant.longitude),
        ),
        northeast: LatLng(
          max(_client.latitude, _restaurant.latitude),
          max(_client.longitude, _restaurant.longitude),
        ),
      );

      // Adjust the camera to cover both markers
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 150);
      mapController.animateCamera(cameraUpdate);

      if(controller.validOrder==false){
        showCustomSnackBar("Location validity", title: "You are too far to receive the order. Won't show poly lines");
      }else{
        _getPolyline();
      }
    });
  }

  void _addMarker(LatLng position, String id) {
    setState(() {
      final markerId = MarkerId(id);
      final marker = Marker(
        markerId: markerId,
        position: position,
        infoWindow:  InfoWindow(title: id),
      );
      markers[markerId] = marker;
    });
  }

  void _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(_client.latitude, _client.longitude),
      PointLatLng(_restaurant.latitude, _restaurant.longitude),
      travelMode: TravelMode.driving,
      optimizeWaypoints: true,
    );

    if (result.status == 'OK') {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      print('Polyline points: $polylineCoordinates');
      _addPolyLine();
    } else {
      debugPrint('Polyline error: ${result.errorMessage}');
    }
  }

  void _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: kPrimary, // Your desired polyline color
      points: polylineCoordinates,
      width: 6,
    );
    polylines[id] = polyline;

    setState(() {}); // Ensure the map updates with the new polyline
  }

  void loadRestaurant(String restaurantId){
    final hookResult = useFetchRestaurant(restaurantId);
    //= hookResult.data;
    final load = hookResult.isLoading;

    if (load == false) {
      restaurantData = hookResult.data;

      if (restaurantData != null) {
        // Encoding to JSON string
        String jsonString = jsonEncode(restaurantData);


        // Decoding the JSON string back to Map
        Map<String, dynamic> resData = jsonDecode(jsonString);

        // Assigning the restaurant ID to the controller state
        Get.find<ContactController>().state.restaurantId.value = resData["owner"];

        // Load chat data
        //loadChatData();
      } else {
        print("restaurantData is null");
      }
    }
  }

  Future<ResponseModel> loadData() async {

    //prepare the contact list for this user.
    //get the restaurant info from the firebase
    //get only one restaurant info
    return   Get.find<ContactController>().asyncLoadSingleRestaurant();
  }

  void loadChatData ()async{
    ResponseModel response = await  loadData();
    if(response.isSuccess==false){
      showCustomSnackBar(response.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderController = Get.put(OrdersController());
    if (orderController.order!.orderStatus == 'Ready') {
      _restaurant = LatLng(orderController.order!.restaurantCoords[0],
          orderController.order!.restaurantCoords[1]);
    } else if (orderController.order!.orderStatus == 'Active') {
      _restaurant = LatLng(orderController.order!.recipientCoords[0],
          orderController.order!.recipientCoords[1]);
    }
    if(orderController.order!.orderStatus ==
        'Out_for_Delivery'){
      Get.put(ContactController());
      Get.find<ContactController>().state.restaurantId.value = orderController.order!.restaurantId.id;

      loadChatData();
      loadRestaurant(orderController.order!.restaurantId.id);
    }

    LatLng restaurant = LatLng(_restaurant.latitude, _restaurant.longitude);

    final location = Get.put(UserLocationController());
    DistanceTime distanceTime = Distance().calculateDistanceTimePrice(
        _user.latitude,
        _user.longitude,
        _restaurant.latitude,
        _restaurant.longitude,
        10,
        2.00);
    String numberString =
        orderController.order!.orderItems[0].foodId.time.substring(0, 2);

    double tripTime = double.parse(numberString);

    return Scaffold(

      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: restaurant,
              bearing: 50,
              zoom: 40.0,
            ),
            markers: Set<Marker>.of(markers.values),
            polylines: Set<Polyline>.of(polylines.values),
              padding: const EdgeInsets.only(bottom: 150)
          ),

          Positioned(
            bottom: 0.h,
            left: 0,
            right: 0,
            child: Container(
              width: width,
              height: hieght / 2.5,
              decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r))),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                margin: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 12.h),

                decoration: BoxDecoration(
                    color: kLightWhite,
                    borderRadius: BorderRadius.circular(20.r)),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ReusableText(
                            text: orderController.order!.restaurantId.title,
                            style: appStyle(20, kGray, FontWeight.bold)),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: kTertiary,
                          backgroundImage: NetworkImage(
                              orderController.order!.restaurantId.logoUrl),
                        ),
                      ],
                    ),
                    const Divida(),
                    RowText(
                        first: "Total Distance",
                        second:
                        "${orderController.tripDistance.toStringAsFixed(3)} km"),
                    SizedBox(
                      height: 5.h,
                    ),
                    RowText(
                        first: "Distance from Restaurant to Client",
                        second:
                        "${orderController.restaurantToClient.toStringAsFixed(3)} km"),
                    SizedBox(
                      height: 5.h,
                    ),
                    RowText(
                        first: "Delivery Free",
                        second:
                        "\$ ${orderController.order!.deliveryFee.toStringAsFixed(2)}"),
                    SizedBox(
                      height: 5.h,
                    ),
                    RowText(
                        first: "Estimated Delivery Time From Restaurant",
                        second: "${tripTime.toStringAsFixed(0)} mins"),
                    SizedBox(
                      height: 5.h,
                    ),
                    RowText(
                        first: "Business Hours",
                        second: orderController.order!.restaurantId.time),
                    SizedBox(
                      height: 10.h,
                    ),
                    const Divida(),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child:RowText(
                            first: "Restaurant    ",
                            second:
                            orderController.order!.restaurantId.coords.address)),
                    SizedBox(
                      height: 10.h,
                    ),
                    orderController.order!.orderStatus == 'Out_for_Delivery'
                        ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child:RowText(
                            color: kSecondary,
                            first: "Recipient    ",
                            second:
                            orderController.order!.deliveryAddress.addressLine1))
                        : const SizedBox.shrink(),

                    orderController.order!.orderStatus == 'Ready'
                        ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child:RowText(
                            first: "Recipient    ",
                            second:
                            orderController.order!.deliveryAddress.addressLine1))
                        : const SizedBox.shrink(),


                    SizedBox(
                      height: 10.h,
                    ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       orderController.order!.orderStatus ==
                           'Out_for_Delivery'?Container(
                         child: GestureDetector(
                           onTap: () async {
                             if(restaurantData==null){
                               print("you are null");
                             }
                             ResponseModel status = await Get.find<ContactController>().goChat(restaurantData);
                             if(status.isSuccess==false){
                               showCustomSnackBar(status.message!, title: status.title!);
                             }
                           },
                           child: ReusableText(
                             text: "Chat",
                             style: appStyle(12, kPrimary, FontWeight.bold),
                           ),
                         ),
                       ):Container(),
                       orderController.order!.orderStatus ==
                           'Out_for_Delivery'?Container(
                         child: Text("Chat"),
                       ):Container(),
                     ],
                   ),
                    orderController.order!.orderStatus == 'Ready'
                        ? CustomButton(
                      onTap: () {
                        if(orderController.tripDistance>50){
                          showCustomSnackBar("It's too far for you deliver the order", title: "Distance alert");
                        }else{
                          orderController
                              .pickOrder(orderController.order!.id);
                        }
                      },
                      color: kPrimary,
                      btnHieght: kCustomButtonHeight,
                      radius: kCustomButtonRadius,
                      text: "Pick up",
                    )
                        : orderController.order!.orderStatus ==
                        'Out_for_Delivery'
                        ?  CustomButton(
                      onTap: () {
                        orderController.markOrderAsDelivered(orderController.order!.id);
                      },
                      color: kPrimary,
                      btnHieght: kCustomButtonHeight,
                      radius: kCustomButtonRadius,
                      text: "M A R K  A S  D E L I V E R E D",
                    )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 50.h,
            left: 12.w,
            right: 12.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    AntDesign.closecircle,
                    color: Colors.red,
                    size: 28.w,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  width: width * 0.8,
                  height: 30.h,
                  decoration: BoxDecoration(
                      color: kOffWhite,
                      border: Border.all(color: kPrimary, width: 1),
                      borderRadius: BorderRadius.circular(20.r)),
                  child: RowText(
                      color: kPrimary,
                      first: "Order Number",
                      second: orderController.order!.id),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}
