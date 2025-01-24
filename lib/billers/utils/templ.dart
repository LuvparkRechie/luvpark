// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../custom_widgets/alert_dialog.dart';
import '../../custom_widgets/app_color.dart';
import '../../custom_widgets/custom_appbar.dart';
import '../../custom_widgets/custom_text.dart';
import '../../http/thirdparty.dart';
import '../controller.dart';

class Templ extends StatefulWidget {
  const Templ({super.key});

  @override
  State<Templ> createState() => _TemplState();
}

class _TemplState extends State<Templ> {
  Map<String, TextEditingController> controllers2 = {};
  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(BillersController());
  final args = Get.arguments;
  final Map<String, RegExp> _filter = {
    'A': RegExp(r'[A-Za-z0-9]'),
    '0': RegExp(r'[0-9]'),
    'N': RegExp(r'[0-9]'),
  };
  List dataBiller = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    setState(() {
      dataBiller = args["field"];
      controllers2.clear();
    });

    for (var field in dataBiller) {
      controllers2[field['key']] = TextEditingController(text: field['value']);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {};
      for (var field in dataBiller) {
        formData[field['key']] = controllers2[field['key']]!.text;
      }

      String paramUrl = args["details"]["full_url"];
      List dataMap = args["field"];
      List redundant = dataMap.where((e) {
        return e["is_validation"] == "Y";
      }).toList();

      Map<String, dynamic> validateParam = {};
      for (var field in redundant) {
        String key = field["key"];
        if (formData.containsKey(key)) {
          field["value"] = formData[key];
        }
      }

      for (var field in redundant) {
        String key = field["key"];
        String value = field["value"];
        validateParam[key] = value;
      }

      Uri fullUri = Uri.parse(paramUrl).replace(queryParameters: validateParam);
      String fullUrl = fullUri.toString();

      CustomDialog().loadingDialog(Get.context!);
      final inatay = await Http3rdPartyRequest(url: fullUrl).getBiller();
      Get.back();

      if (inatay == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
      } else if (inatay["result"] == "true") {
        print("success");
        postData();
      } else if (inatay == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      } else {
        CustomDialog().infoDialog("Invalid request",
            "Please provide the required information or ensure the data entered is valid.",
            () {
          Get.back();
        });
      }
    }
  }

  // Future<void> luvparkPayment() async {
  //   FocusManager.instance.primaryFocus?.unfocus();

  //   CustomDialog().loadingDialog(Get.context!);
  //   final response = await Functions.generateQr();

  //   if (response["response"] == "Success") {
  //     double serviceFee =
  //         double.tryParse(args['service_fee'].toString()) ?? 0.0;
  //     double userAmount = double.tryParse(amount.text) ?? 0.0;
  //     double addedAmount = serviceFee + userAmount;
  //     String totalAmount = addedAmount.toStringAsFixed(2);
  //     int userId = await Authentication().getUserId();
  //     CustomDialog().confirmationDialog(Get.context!, "Pay Bills",
  //         "Are you sure you want to continue?", "No", "Okay", () {
  //       Get.back();
  //     }, () async {
  //       Get.back();
  //       var parameter = {
  //         "luvpay_id": userId.toString(),
  //         "biller_id": args["biller_id"].toString(),
  //         "bill_acct_no": billAccNo.text,
  //         "amount": totalAmount,
  //         "payment_hk": response["data"],
  //         "bill_no": billNo.text,
  //         "account_name": billerAccountName.text,
  //         'original_amount': amount.text
  //       };

  //       CustomDialog().loadingDialog(Get.context!);

  //       HttpRequest(api: ApiKeys.gApiPostPayBills, parameters: parameter)
  //           .postBody()
  //           .then((returnPost) async {
  //         Get.back();
  //         if (returnPost == "No Internet") {
  //           CustomDialog().internetErrorDialog(Get.context!, () {
  //             Get.back();
  //           });
  //         } else if (returnPost == null) {
  //           CustomDialog().serverErrorDialog(Get.context!, () {
  //             Get.back();
  //           });
  //         } else {
  //           if (returnPost["success"] == 'Y') {
  //             var params = {
  //               "user_id": userId,
  //               "biller_id": args["biller_id"].toString(),
  //               "account_no": billAccNo.text,
  //               "biller_name": args["biller_name"],
  //               "biller_address": args["biller_address"],
  //               'user_biller_id': args['user_biller_id'],
  //               'amount': totalAmount.toString(),
  //               "account_name": billerAccountName.text,
  //               "service_fee": args['service_fee'].toString(),
  //               "original_amount": amount.text
  //             };
  //             Get.to(TicketUI(), arguments: params);
  //           } else {
  //             CustomDialog()
  //                 .errorDialog(Get.context!, "Error", returnPost["msg"], () {
  //               Get.back();
  //             });
  //           }
  //         }
  //         isNetConn.value = true;
  //       });
  //     });
  //   }
  // }

  Future<void> postData() async {
    Map<String, dynamic> validateParam = {
      "accountno": "2021-0323-2",
      "bill_ref_no": "BHBR25-01-0001",
      "luvpark_trans_ref": "LPP-123456",
      "received_amount": "629"
    };
    String paramUrl = "http://192.168.7.78/web/eforms/hydracore/add_payment";
    Uri fullUri = Uri.parse(paramUrl).replace(queryParameters: validateParam);
    String fullUrl = fullUri.toString();

    print("fullUrl $fullUrl");

    CustomDialog().loadingDialog(Get.context!);
    final inatay = await Http3rdPartyRequest(url: fullUrl).postBiller();
    Get.back();

    if (inatay == "No Internet") {
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
    } else if (inatay["result"] == "true") {
      CustomDialog().successDialog(
          context, "Payment Successfull", inatay["msg"], "Return to billers",
          () {
        Get.back();
      });
    } else if (inatay == null) {
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
    } else {
      CustomDialog().infoDialog("Invalid request",
          "Please provide the required information or ensure the data entered is valid.",
          () {
        Get.back();
      });
    }
  }

  Future<void> _selectDate(BuildContext context, String key) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controllers2[key]!.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Pay Biller",
        onTap: () {
          Get.back();
        },
      ),
      body: Container(
        child: dataBiller.isEmpty
            ? Container()
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: CustomTitle(
                        text: args["details"]["biller_name"],
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: CustomParagraph(
                        text: args["details"]["biller_address"],
                        fontSize: 10,
                        maxlines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Divider(
                      color: AppColor.linkLabel,
                    ),
                    Expanded(
                        child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(15, 20, 15, 10),
                            itemCount: dataBiller.length,
                            itemBuilder: (context, i) {
                              final field = dataBiller[i];
                              List<TextInputFormatter> inputFormatters = [];
                              if (field['input_formatter'] != null &&
                                  field['input_formatter'].isNotEmpty) {
                                String mask = field['input_formatter'];
                                inputFormatters = [
                                  MaskTextInputFormatter(
                                      mask: mask, filter: _filter)
                                ];
                              }
                              if (field['type'] == 'date') {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTitle(
                                        fontSize: 14, text: field['label']),
                                    CustomTextField(
                                      controller: controllers2[field['key']]!,
                                      isReadOnly: true,
                                      isFilled: false,
                                      suffixIcon: Icons.calendar_today,
                                      onTap: () =>
                                          _selectDate(context, field['key']),
                                      validator: (value) {
                                        if (field['required'] &&
                                            (value == null || value.isEmpty)) {
                                          return '${field['label']} is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                );
                              } else if (field['type'] == 'number') {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTitle(
                                        fontSize: 14, text: field['label']),
                                    CustomTextField(
                                      controller: controllers2[field['key']]!,
                                      maxLength: field['maxLength'],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: inputFormatters,
                                      validator: (value) {
                                        if (field['required'] &&
                                            (value == null || value.isEmpty)) {
                                          return '${field['label']} is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTitle(
                                        fontSize: 14, text: field['label']),
                                    CustomTextField(
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      controller: controllers2[field['key']]!,
                                      maxLength: field['maxLength'],
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (field['required'] &&
                                            (value == null || value.isEmpty)) {
                                          return '${field['label']} is required';
                                        }
                                        return null;
                                      },
                                      inputFormatters: inputFormatters,
                                    ),
                                  ],
                                );
                              }
                            })),
                    if (MediaQuery.of(context).viewInsets.bottom == 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: CustomButton(
                            text: "Submit", onPressed: _submitForm),
                      ),
                    Container(
                      height: 20,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class AutoDecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final numericValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final value = double.tryParse(numericValue) ?? 0.0;
    final formattedValue = (value / 100).toStringAsFixed(2);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
