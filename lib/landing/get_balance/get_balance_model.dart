import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:luvpark/classess/api_keys.dart';

Future<SecurityQuestion?> getConsumerBalance(userId) async {
  String subApi = "${ApiKeys.gApiSubFolderGetBalance}?user_id=$userId";
  final response = await http.get(
      Uri.parse(Uri.decodeFull(Uri.https(ApiKeys.gApiURL, subApi).toString())),
      headers: {"Content-Type": "application/json"});

  try {
    if (response.statusCode == 200) {
      return SecurityQuestion.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

class SecurityQuestion {
  SecurityQuestion({
    required this.items,
  });

  List<SecurityQuestionRow> items;

  factory SecurityQuestion.fromJson(Map<String, dynamic> json) =>
      SecurityQuestion(
        items: List<SecurityQuestionRow>.from(
            json["items"].map((x) => SecurityQuestionRow.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class SecurityQuestionRow {
  SecurityQuestionRow(
      {required this.userId, required this.amountBal, required this.pointsBal});
  int userId;
  String amountBal;
  String pointsBal;

  factory SecurityQuestionRow.fromJson(Map<String, dynamic> json) =>
      SecurityQuestionRow(
          userId: json["user_id"],
          amountBal: json["amount_bal"],
          pointsBal: json["points_bal"]);

  Map<String, dynamic> toJson() =>
      {"user_id": userId, "token_bal": amountBal, "points_bal": pointsBal};
}
