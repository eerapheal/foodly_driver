import 'dart:convert';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:foodly_driver/common/contact_controller.dart';
import 'package:foodly_driver/constants/constants.dart';
import 'package:foodly_driver/models/hook_models/hook_result.dart';
import 'package:foodly_driver/models/restaurants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

FetchHook useFetchRestaurant(id) {
  final restaurant = useState<Restaurants?>(null);
  final isLoading = useState(false);
  final error = useState<Exception?>(null);
  final controller = Get.find<ContactController>();
  // Fetch Data Function
  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final response =
      await http.get(Uri.parse('${appBaseUrl}/api/restaurant/byId/$id'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Restaurants fetchedRestaurant = Restaurants.fromJson(data);
        restaurant.value = fetchedRestaurant;
        controller.state.restaurant.value = fetchedRestaurant;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e.toString());
      error.value = e as Exception?;
    } finally {
      isLoading.value = false;
    }
  }

  // Side Effect
  useEffect(() {
    fetchData();
    return null;
  }, const []);

  // Refetch Function
  void refetch() {
    isLoading.value = true;
    fetchData();
  }

  // Return values
  return FetchHook(
    data: restaurant.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}
