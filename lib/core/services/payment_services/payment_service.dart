import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static Future<String> fetchClientSecretFromBackend(num amount) async {
    final response = await http.post(
      Uri.parse('https://groomer.nablean.com/api/v1/payment/create-payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': (amount * 100).toInt(),
        'currency': 'AED',
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['clientSecret'] ?? '';
    } else {
      throw Exception('Failed to fetch clientSecret');
    }
  }
}