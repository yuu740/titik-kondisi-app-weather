import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PaymentService {
  
  Future<String?> createDonation(String amount) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.donationEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "amount": amount, 
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['redirect_url']; 
      } else {
        throw Exception('Donation Failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> createSubscription() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.paymentEndpoint),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['redirect_url'];
      } else {
        throw Exception('Payment Failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}