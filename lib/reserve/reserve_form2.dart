import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/reserve/booking_notice.dart';
import 'package:luvpark/reserve/receiptV2.dart';
import 'package:luvpark/reserve/time_list.dart';
import 'package:luvpark/reserve/vehicle_list_modal.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ReserveForm2 extends StatefulWidget {
  final List areaData;
  final List queueChkIn;
  final int pId;
  final List userBal;
  final bool isCheckIn;
  final LatLng? currentLocation;
  const ReserveForm2({
    super.key,
    required this.queueChkIn,
    required this.areaData,
    required this.userBal,
    required this.pId,
    required this.isCheckIn,
    this.currentLocation,
  });

  @override
  State<ReserveForm2> createState() => _ReserveForm2State();
}

class _ReserveForm2State extends State<ReserveForm2> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController timeInParam = TextEditingController();
  final TextEditingController plateNo = TextEditingController();

  bool _isRewardchecked = false;
  bool _isExtendchecked = false;
  DateTime? inDate;
  DateTime? dateTimmmee;
  DateTime? outDate;
  TimeOfDay? selectedTime;
  TextEditingController _rewardpoints = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController startTime = TextEditingController();
  TextEditingController endTime = TextEditingController();
  int numberOfhours = 1;
  String hoursLabel = "1 Hour";
  bool isLoadingPage = true;
  bool isSubmit = false;
  bool isSelectedVehicle = false;
  bool isHide = true;
  List vehicleTypeData = [];
  String? vehicleTypeValue;
  List<dynamic> data = [];
  bool isValidDate = true;
  bool hasInternet = true;
  LatLng? startLocation;
  String myAddress = "";
  int ctr = 0;
  String vehicleIdx = "0";
  String hintTextLabel = "Plate No.";
  // ignore: prefer_typing_uninitialized_variables
  var akongP;
  BuildContext? myContext;
  List<Map<String, dynamic>> myVehicles = [];
  List vehicleData = [];
  final Map<String, RegExp> _filter = {
    'A': RegExp(r'[A-Za-z0-9]'),
    '#': RegExp(r'[A-Za-z0-9]')
  };
  MaskTextInputFormatter? maskFormatter;
  double ptsBal = 0.0;
  List distanceData = [];
  List callBackData = [];
  String vehicleText = "Tap to add vehicle";
  List<int> numbersList = [];
  String totalAmount = "0.0";
  bool isLoadingBtn = false;
  bool allowAutoExtend = false;
  bool hasInternetBal = true;
  bool loadingBal = true;
  String inputTimeLabel = 'Input a Duration'; // Define initial label'
  double subtractedToken = 0;

  var myData;
  @override
  void initState() {
    super.initState();
    _updateMaskFormatter("");
    int endNumber = int.parse(widget.areaData[0]["res_max_hours"].toString());

    // Generate a list of numbers within the specified range
    numbersList = List.generate(
        endNumber - numberOfhours + 1, (index) => numberOfhours + index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserData();
    });
  }

  void _toggleRewardChecked() {
    setState(() {
      _isRewardchecked = !_isRewardchecked;
    });
  }

  void _toggleExtendChecked() {
    setState(() {
      _isExtendchecked = !_isExtendchecked;
      allowAutoExtend = !allowAutoExtend;
    });
  }

  void _RewardSubtract() {
    setState(() {
      // Ensure _rewardpoints.text is parsed correctly
      double rewardPoints = double.tryParse(_rewardpoints.text) ?? 0.0;

      // Ensure totalAmount is parsed correctly
      double parsedTotalAmount = double.tryParse(totalAmount) ?? 0.0;

      // Perform subtraction only when both values are non-null
      subtractedToken = parsedTotalAmount - rewardPoints;
    });
  }

  //totalamount

  void _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    myData = prefs.getString(
      'userData',
    );
    _timeComputation();
    _getCurrentLocation();
  }

  void _timeComputation() {
    DateTime now = DateTime.now();
    setState(() {
      startDate.text = DateTime.now().toString().split(" ")[0].toString();
      startTime.text = DateFormat('h:mm a').format(now).toString();
      DateTime parsedTime = DateFormat('hh:mm a').parse(startTime.text);
      timeInParam.text = DateFormat('HH:mm').format(parsedTime);
      endTime.text = DateFormat('h:mm a')
          .format(parsedTime.add(Duration(hours: numberOfhours)))
          .toString();
    });
  }

  @override
  void dispose() {
    _rewardpoints.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showRewardDialog() {
    showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomDisplayText(
            label: "Reward Points",
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
          content: RewardDialog(
            controller: _rewardpoints,
            points: widget.userBal[0]["rewards"].toString(),
            totalAmount: totalAmount,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                _rewardpoints.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (int.parse(_rewardpoints.text) >
                    int.parse(totalAmount.toString().split(".")[0])) {
                  showAlertDialog(context, "LuvPark", "Limit exceeds", () {
                    Navigator.of(context).pop();
                  });
                } else {
                  Navigator.of(context).pop(double.parse(_rewardpoints.text));
                }
                _RewardSubtract();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    myContext = context;
    return CustomParentWidgetV2(
      appBarHeaderText: "Back",
      hasPadding: false,
      canPop: true,
      appBarIconClick: () {
        Navigator.pop(context);
      },
      bodyColor: Color.fromARGB(255, 249, 248, 248),
      child: isLoadingPage
          ? const Center(
              child: SizedBox(
                  height: 40, width: 40, child: CircularProgressIndicator()),
            )
          : !hasInternet
              ? NoInternetConnected(onTap: () {
                  setState(() {
                    //   hasInternet = true;
                    isLoadingPage = true;
                  });
                  refresh();
                })
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 20),
                              CustomTitle(text: "You are parking at"),
                              Container(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Container(
                                        height: 71,
                                        decoration: BoxDecoration(
                                          color: Color(0xff1F313F),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(7),
                                            bottomLeft: Radius.circular(7),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              isLoadingPage
                                                  ? Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey.shade300,
                                                      highlightColor:
                                                          const Color(
                                                              0xFFe6faff),
                                                      child: const SizedBox(
                                                        width: 30,
                                                        height: 10,
                                                      ))
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: CustomTitle(
                                                        text: widget.areaData[0]
                                                            ["park_area_name"],
                                                        maxlines: 1,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                              isLoadingPage
                                                  ? Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey.shade300,
                                                      highlightColor:
                                                          const Color(
                                                              0xFFe6faff),
                                                      child: const SizedBox(
                                                        width: 30,
                                                        height: 10,
                                                      ),
                                                    )
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: CustomParagraph(
                                                        text: widget.areaData[0]
                                                            ["address"],
                                                        fontSize: 12,
                                                        color: Colors.white70,
                                                        maxlines: 2,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      )),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: 71,
                                      decoration: BoxDecoration(
                                        color: Color(0xff243a4b),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(7),
                                          bottomRight: Radius.circular(7),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.black.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            isLoadingPage
                                                ? Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        const Color(0xFFe6faff),
                                                    child: const SizedBox(
                                                      width: 30,
                                                      height: 10,
                                                    ),
                                                  )
                                                : CustomTitle(
                                                    text: distanceData.isEmpty
                                                        ? ""
                                                        : distanceData[0]
                                                                ["distance"]
                                                            .toString(),
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    letterSpacing: -0.41,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Container(height: 20),
                              CustomTitle(
                                  text: "How long do you want to park?"),
                              Container(height: 10),
                              InkWell(
                                onTap: () async {
                                  Variables.customBottomSheet(
                                    context,
                                    TimeList(
                                      numbersList: numbersList,
                                      maxHours: widget.areaData[0]
                                              ["res_max_hours"]
                                          .toString(),
                                      onTap: (dataHours) async {
                                        setState(() {
                                          inputTimeLabel =
                                              "$dataHours ${dataHours > 1 ? "Hours" : "Hour"}";
                                          numberOfhours = dataHours;
                                          isLoadingBtn = true;
                                          isHide = false;
                                        });
                                        _timeComputation();
                                        if (callBackData.isNotEmpty) {
                                          routeToComputation();
                                        }
                                        setState(() {
                                          isLoadingBtn = false;
                                        });
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 71,
                                  width: Variables.screenSize.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Color(0xFFFFFFFF),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: inputTimeLabel == 'Input a Duration'
                                        ? Center(
                                            child: RichText(
                                              text: TextSpan(
                                                children: <InlineSpan>[
                                                  WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: CustomParagraph(
                                                      text: "$inputTimeLabel ",
                                                      color:
                                                          AppColor.primaryColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: -0.41,
                                                    ),
                                                  ),
                                                  const WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 3),
                                                      child: FaIcon(
                                                        FontAwesomeIcons
                                                            .chevronDown,
                                                        color:
                                                            Color(0xFF0078FF),
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CustomTitle(
                                                      text: inputTimeLabel,
                                                      fontSize: 14,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                    CustomParagraph(
                                                      text:
                                                          "Start Booking: ${startTime.text} - ${endTime.text}",
                                                      color: inputTimeLabel ==
                                                              'Input a Duration'
                                                          ? Colors.white
                                                          : Colors.grey,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: -0.41,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              FaIcon(
                                                FontAwesomeIcons.chevronDown,
                                                color: Color(0xFF0078FF),
                                                size: 15,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              if (!isHide)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height: 20),
                                    CustomTitle(text: "Vehicle Details"),
                                    Container(height: 10),
                                    Container(
                                      height: 71,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.black.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (vehicleTypeData.isEmpty) {
                                            showAlertDialog(context, "LuvPark",
                                                "No vehicle data.", () {
                                              Navigator.of(context).pop();
                                            });
                                            return;
                                          }
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            CustomModal(context: context)
                                                .loader();
                                            Functions.getVehicleTypesData(
                                                context,
                                                widget.areaData[0]
                                                    ["park_area_id"],
                                                (objData) {
                                              if (objData["msg"] == "Success") {
                                                Variables.customBottomSheet(
                                                  context,
                                                  VehicleOption(
                                                      vhTypesId: widget
                                                              .areaData[0][
                                                          "vehicle_types_id_list"],
                                                      vehicleData:
                                                          objData["data"],
                                                      vehicleTypeId:
                                                          vehicleTypeValue ??
                                                              "",
                                                      onTap: (cbData) {
                                                        setState(() {
                                                          isLoadingBtn = true;
                                                        });
                                                        Variables
                                                            .hasInternetConnection(
                                                                (hasNet) {
                                                          if (hasNet) {
                                                            setState(() {
                                                              callBackData =
                                                                  cbData;
                                                              vehicleText =
                                                                  callBackData[
                                                                          0][
                                                                      "vehicle_plate_no"];
                                                            });
                                                            routeToComputation();
                                                          } else {
                                                            showAlertDialog(
                                                                myContext!,
                                                                "Error",
                                                                "Please check your internet connection and try again.",
                                                                () {
                                                              Navigator.of(
                                                                      myContext!)
                                                                  .pop();
                                                              setState(() {
                                                                callBackData =
                                                                    [];
                                                                vehicleText =
                                                                    "Tap to add vehicle";
                                                              });
                                                            });
                                                          }
                                                        });
                                                      }),
                                                );
                                              }
                                            });
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                ),
                                                child: callBackData.isEmpty
                                                    ? CustomParagraph(
                                                        text: vehicleText,
                                                        color:
                                                            callBackData.isEmpty
                                                                ? AppColor
                                                                    .primaryColor
                                                                : Colors.grey,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: -0.41,
                                                      )
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CustomTitle(
                                                            text: vehicleText,
                                                            fontSize: 14,
                                                          ),
                                                          CustomParagraph(
                                                            text: callBackData[
                                                                    0][
                                                                "vehicle_brand_name"],
                                                            color: Colors.grey,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            letterSpacing:
                                                                -0.41,
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15),
                                              child: callBackData.isNotEmpty
                                                  ? Icon(
                                                      Icons
                                                          .check_circle_outline_outlined,
                                                      color:
                                                          AppColor.primaryColor,
                                                      size: 20,
                                                      weight: 5,
                                                    )
                                                  : Icon(
                                                      Icons.add,
                                                      color:
                                                          AppColor.primaryColor,
                                                      size: 20,
                                                    ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (vehicleText != "Tap to add vehicle")
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(height: 20),
                                          CustomTitle(text: "Payment Details"),
                                          Container(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        spreadRadius: 1,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CustomParagraph(
                                                        text: "Wallet Balance",
                                                        color:
                                                            callBackData.isEmpty
                                                                ? AppColor
                                                                    .primaryColor
                                                                : Colors.grey,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: -0.41,
                                                      ),
                                                      Container(height: 5),
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: CustomParagraph(
                                                          text: toCurrencyString(widget
                                                                  .userBal[0][
                                                                      "user_bal"]
                                                                  .toString())
                                                              .toString(),
                                                          fontSize: 16,
                                                          maxlines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        spreadRadius: 1,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CustomParagraph(
                                                        text: "Rewards",
                                                        color: Colors.grey,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: -0.41,
                                                      ),
                                                      Container(height: 5),
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: CustomParagraph(
                                                          text: toCurrencyString(widget
                                                                  .userBal[0][
                                                                      "rewards"]
                                                                  .toString())
                                                              .toString(),
                                                          fontSize: 16,
                                                          maxlines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 10,
                                          ),
                                          GestureDetector(
                                            onTap: _toggleRewardChecked,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 15),
                                              width: Variables.screenSize.width,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20.0,
                                                  right: 20,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          _isRewardchecked
                                                              ? Icons
                                                                  .check_circle_outline
                                                              : Icons
                                                                  .circle_outlined,
                                                          color: _isRewardchecked
                                                              ? AppColor
                                                                  .primaryColor
                                                              : Colors.grey,
                                                        ),
                                                        Container(width: 5),
                                                        Expanded(
                                                          child: CustomTitle(
                                                            text:
                                                                "Use Reward Points",
                                                            fontSize: 14,
                                                            letterSpacing:
                                                                -0.41,
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                        Container(width: 5),
                                                        if (_isRewardchecked)
                                                          GestureDetector(
                                                            onTap:
                                                                _showRewardDialog,
                                                            child: Icon(
                                                              Icons.edit_note,
                                                              color: AppColor
                                                                  .primaryColor,
                                                            ),
                                                          )
                                                      ],
                                                    ),
                                                    if (_isRewardchecked)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Column(
                                                          children: [
                                                            Divider(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                CustomParagraph(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    text:
                                                                        ' Reward Points :',
                                                                    letterSpacing:
                                                                        -0.41),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20),
                                                                  child:
                                                                      CustomParagraph(
                                                                    text: () {
                                                                      try {
                                                                        double
                                                                            points =
                                                                            double.parse(_rewardpoints.text);
                                                                        return points
                                                                            .toStringAsFixed(2); // Formats the number to 2 decimal places
                                                                      } catch (e) {
                                                                        return '0.00'; // Handle parsing error
                                                                      }
                                                                    }(),
                                                                    color: AppColor
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                                height: 5),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                CustomParagraph(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  text:
                                                                      ' Token :',
                                                                  letterSpacing:
                                                                      -0.41,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20),
                                                                  child:
                                                                      CustomParagraph(
                                                                    text: subtractedToken.toStringAsFixed(2) ==
                                                                            "0.00"
                                                                        ? toCurrencyString(
                                                                            totalAmount)
                                                                        : subtractedToken
                                                                            .toStringAsFixed(2),
                                                                    color: AppColor
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                                height: 10),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                CustomParagraph(
                                                                    text:
                                                                        ' total ',
                                                                    letterSpacing:
                                                                        -0.41),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20),
                                                                  child:
                                                                      CustomParagraph(
                                                                    text: toCurrencyString(
                                                                        totalAmount),
                                                                    color: AppColor
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(height: 20),
                                          CustomParagraph(
                                              text:
                                                  "Tap below to use the auto-extend function",
                                              color: Colors.grey,
                                              fontSize: 12,
                                              letterSpacing: -0.41),
                                          Container(
                                            height: 5,
                                          ),
                                          GestureDetector(
                                            onTap: _toggleExtendChecked,
                                            child: Container(
                                              height: 51,
                                              width: Variables.screenSize.width,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20.0,
                                                  right: 20,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Icon(
                                                      _isExtendchecked
                                                          ? Icons
                                                              .check_circle_outline
                                                          : Icons
                                                              .circle_outlined,
                                                      color: _isExtendchecked
                                                          ? AppColor
                                                              .primaryColor
                                                          : Colors.grey,
                                                    ),
                                                    Container(width: 5),
                                                    Expanded(
                                                      child: CustomTitle(
                                                        text: "Auto extend",
                                                        fontSize: 14,
                                                        letterSpacing: -0.41,
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade100)),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(7),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 20.0, right: 20.0, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: CustomTitle(
                                    text: "Total",
                                  ),
                                ),
                                CustomTitle(
                                  text: toCurrencyString(totalAmount),
                                ),
                              ],
                            ),
                            Container(height: 20),
                            if (isLoadingBtn)
                              Row(
                                children: [
                                  Expanded(
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: const Color(0xFFe6faff),
                                      child: CustomButton(
                                        label: "",
                                        onTap: () {},
                                      ),
                                    ),
                                  ),
                                  if (widget.isCheckIn)
                                    Container(
                                      width: 10,
                                    ),
                                  if (widget.isCheckIn)
                                    Expanded(
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: const Color(0xFFe6faff),
                                        child: CustomButton(
                                          label: "",
                                          onTap: () {},
                                        ),
                                      ),
                                    )
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                        label: widget.queueChkIn[0]["is_queue"]
                                            ? "Confirm this Queue"
                                            : "Confirm this booking",
                                        color: callBackData.isEmpty
                                            ? Color(0xFF6C7075).withOpacity(.6)
                                            : AppColor.primaryColor,
                                        textColor: Colors.white,
                                        onTap: callBackData.isEmpty
                                            ? () {}
                                            : () {
                                                var dateIn = DateTime.parse(
                                                    "${startDate.text} ${timeInParam.text}");

                                                var dateOut = dateIn.add(
                                                    Duration(
                                                        hours: numberOfhours));

                                                void bongGo() {
                                                  Map<String, dynamic>
                                                      parameters = {
                                                    "client_id":
                                                        widget.areaData[0]
                                                            ["client_id"],
                                                    "park_area_id":
                                                        widget.areaData[0]
                                                            ["park_area_id"],
                                                    "vehicle_plate_no":
                                                        callBackData[0][
                                                            "vehicle_plate_no"],
                                                    "vehicle_type_id":
                                                        callBackData[0][
                                                                "vehicle_type_id"]
                                                            .toString(),
                                                    "dt_in": dateIn
                                                        .toString()
                                                        .toString()
                                                        .split(".")[0],
                                                    "dt_out": dateOut
                                                        .toString()
                                                        .split(".")[0],
                                                    "no_hours": numberOfhours,
                                                    "tran_type": "R",
                                                  };

                                                  submitReservation(
                                                      parameters,
                                                      isSelectedVehicle,
                                                      context,
                                                      false);
                                                }

                                                if (allowAutoExtend) {
                                                  bongGo();
                                                } else {
                                                  showModalConfirmation(
                                                      context,
                                                      "Enable Auto Extend",
                                                      "Your parking duration will be automatically extended using your available balance if it is enabled.\n\Would you like to enable it?",
                                                      "",
                                                      "Yes", () {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      allowAutoExtend = false;
                                                    });
                                                    bongGo();
                                                  }, () async {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      allowAutoExtend = true;
                                                    });
                                                    bongGo();
                                                  });
                                                }
                                              }),
                                  ),
                                  if (widget.isCheckIn)
                                    Container(
                                      width: 10,
                                    ),
                                  if (isLoadingBtn)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                const Color(0xFFe6faff),
                                            child: CustomButton(
                                              label: "",
                                              onTap: () {},
                                            ),
                                          ),
                                        ),
                                        if (widget.isCheckIn)
                                          Container(
                                            width: 10,
                                          ),
                                        if (widget.isCheckIn)
                                          Expanded(
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  const Color(0xFFe6faff),
                                              child: CustomButton(
                                                label: "",
                                                onTap: () {},
                                              ),
                                            ),
                                          )
                                      ],
                                    )
                                  else if (widget.isCheckIn &&
                                      !widget.queueChkIn[0]["is_queue"])
                                    Expanded(
                                      child: CustomButton(
                                          label: "Check In",
                                          color: callBackData.isEmpty
                                              ? AppColor.primaryColor
                                                  .withOpacity(.6)
                                              : AppColor.primaryColor,
                                          textColor: Colors.white,
                                          onTap: callBackData.isEmpty
                                              ? () {}
                                              : () {
                                                  var dateIn = DateTime.parse(
                                                      "${startDate.text} ${timeInParam.text}");

                                                  var dateOut = dateIn.add(
                                                      Duration(
                                                          hours:
                                                              numberOfhours));
                                                  // routeToComputation();
                                                  void bongGo() {
                                                    Map<String, dynamic>
                                                        parameters = {
                                                      "client_id":
                                                          widget.areaData[0]
                                                              ["client_id"],
                                                      "park_area_id":
                                                          widget.areaData[0]
                                                              ["park_area_id"],
                                                      "vehicle_plate_no":
                                                          callBackData[0][
                                                              "vehicle_plate_no"],
                                                      "vehicle_type_id":
                                                          callBackData[0][
                                                                  "vehicle_type_id"]
                                                              .toString(),
                                                      "dt_in": dateIn
                                                          .toString()
                                                          .toString()
                                                          .split(".")[0],
                                                      "dt_out": dateOut
                                                          .toString()
                                                          .split(".")[0],
                                                      "no_hours": numberOfhours,
                                                      "tran_type": "R",
                                                    };

                                                    submitReservation(
                                                        parameters,
                                                        isSelectedVehicle,
                                                        context,
                                                        false);
                                                  }

                                                  if (allowAutoExtend) {
                                                    bongGo();
                                                  } else {
                                                    showModalConfirmation(
                                                        context,
                                                        "Confirmation",
                                                        "Your parking duration will be automatically extended using your available balance if it is enabled.\n\nWould you like to proceed?",
                                                        "",
                                                        "Cancel", () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {
                                                        allowAutoExtend = false;
                                                      });
                                                      bongGo();
                                                    }, () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {
                                                        allowAutoExtend = true;
                                                      });
                                                      bongGo();
                                                    });
                                                  }
                                                }),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> refresh() async {
    getVehicleTypeData();
  }

  void _getCurrentLocation() async {
    LatLng destLocation = LatLng(
        double.parse(widget.areaData[0]["pa_latitude"].toString()),
        double.parse(widget.areaData[0]["pa_longitude"].toString()));
    LatLng origin = LatLng(
        double.parse(widget.currentLocation!.latitude.toString()),
        double.parse(widget.currentLocation!.longitude.toString()));

    Variables.hasInternetConnection((hasInternetMe) async {
      if (hasInternetMe) {
        DashboardComponent.fetchETA(origin, destLocation,
            (estimatedData) async {
          if (estimatedData == "No Internet") {
            setState(() {
              isLoadingPage = false;
              distanceData = [];
              hasInternet = false;
            });
            showAlertDialog(context, "Attention",
                "Please check your internet connection and try again.", () {
              Navigator.of(context).pop();
            });
            return;
          }
          if (estimatedData.isEmpty) {
            setState(() {
              isLoadingPage = false;
              hasInternet = false;
              distanceData = [];
            });
            showAlertDialog(
                context, "LuvPark", Variables.popUpMessageOutsideArea, () {
              Navigator.of(context).pop();
            });
            return;
          } else {
            setState(() {
              distanceData = estimatedData;
            });
            refresh();
          }
        });
        return;
      } else {
        setState(() {
          isLoadingPage = false;
          hasInternet = false;
        });
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
    });
  }

  void _updateMaskFormatter(mask) {
    if (mask != null) {
      setState(() {
        hintTextLabel = mask.toString();
      });
    } else {
      setState(() {
        hintTextLabel = "Plate No.";
      });
    }
    maskFormatter = MaskTextInputFormatter(
      mask: mask,
      filter: _filter,
    );
  }

  void getVehicleTypeData() async {
    var dataVehicle = [];

    HttpRequest(
            api:
                "${ApiKeys.gApiSubFolderGetVehicleType}?park_area_id=${widget.pId}")
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        setState(() {
          isLoadingPage = false;
          hasInternet = false;
        });

        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (returnData == null) {
        setState(() {
          isLoadingPage = false;
          hasInternet = true;
        });

        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }

      if (returnData["items"].length > 0) {
        for (var items in returnData["items"]) {
          dataVehicle.add({
            "vehicle_id": items["vehicle_type_id"],
            "vehicle_desc": items["vehicle_type_desc"],
            "format": items["input_format"],
          });
        }
        setState(() {
          vehicleTypeData = dataVehicle;
          vehicleTypeValue =
              "${vehicleTypeData.length > 1 ? 0 : vehicleTypeData[0]["vehicle_id"].toString()}";
          isLoadingPage = false;
          hasInternet = true;
          _updateMaskFormatter(vehicleTypeData[0]["format"]);
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                content: BookingNotice(callBack: () {}),
              ),
            );
          },
        );
      } else {
        setState(() {
          isLoadingPage = false;
          hasInternet = true;
        });
        showAlertDialog(context, "LuvPark", "No vehicle data.", () {
          Navigator.of(context).pop();
        });
        return;
      }
    });
  }

  void routeToComputation() async {
    if (callBackData.isEmpty) {
      showAlertDialog(context, "Attention", "Vehicle is required", () {
        Navigator.of(context).pop();
      });

      return;
    }

    var dateIn = DateTime.parse("${startDate.text} ${timeInParam.text}");

    var dateOut = dateIn.add(Duration(hours: numberOfhours));

    FocusManager.instance.primaryFocus!.unfocus();

    Map<String, dynamic> parameters = {
      "client_id": widget.areaData[0]["client_id"],
      "park_area_id": widget.areaData[0]["park_area_id"],
      "vehicle_plate_no": callBackData[0]["vehicle_plate_no"],
      "vehicle_type_id": callBackData[0]["vehicle_type_id"].toString(),
      "dt_in": dateIn.toString().toString().split(".")[0],
      "dt_out": dateOut.toString().split(".")[0],
      "no_hours": numberOfhours,
      "tran_type": "R",
    };

    HttpRequest(
            api: ApiKeys.gApiSubFolderPostReserveCalc, parameters: parameters)
        .post()
        .then((returnPost) async {
      if (returnPost == "No Internet") {
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.pop(context);
          setState(() {
            isLoadingBtn = false;
            hasInternet = false;
          });
        });
        return;
      }
      if (returnPost == null) {
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
          setState(() {
            isLoadingBtn = false;
            hasInternet = true;
          });
        });
      } else {
        if (returnPost["success"] == 'Y') {
          if (mounted) {
            setState(() {
              hasInternet = true;
              isLoadingBtn = false;
              totalAmount = returnPost["amount"].toString();
            });
          }
        } else {
          showAlertDialog(context, "LuvPark", returnPost['msg'], () {
            Navigator.of(context).pop();
            setState(() {
              hasInternet = true;
              isLoadingBtn = false;
              callBackData = [];
              vehicleText = "Tap to add vehicle";
            });
          });
        }
      }
    });
  }

  //Reservation Submit
  void submitReservation(params, isVsel, context, isCheckIn) async {
    CustomModal(context: context).loader();

    FocusManager.instance.primaryFocus!.unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongP = prefs.getString(
      'userData',
    );
    HttpRequest(
            api: ApiKeys.gApiLuvParkGetResPayKey,
            parameters: {"user_id": jsonDecode(akongP!)['user_id'].toString()})
        .post()
        .then((dataRefNo) async {
      if (dataRefNo == "No Internet") {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });

        return;
      }
      if (dataRefNo == null) {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      }
      if (dataRefNo["success"] == "Y") {
        Map<String, dynamic> postParameters = {
          "client_id": params["client_id"].toString(),
          "park_area_id": widget.areaData[0]["park_area_id"].toString(),
          "vehicle_plate_no":
              params["vehicle_plate_no"].toString().replaceAll(" ", "").trim(),
          "vehicle_type_id": params["vehicle_type_id"].toString(),
          "dt_in": params["dt_in"].toString(),
          "dt_out": params["dt_out"].toString(),
          "no_hours": params["no_hours"].toString(),
          "luvpay_id": jsonDecode(akongP)['user_id'].toString(),
          "luvpark_balance": widget.userBal.toString(),
          "lp_ref_no": dataRefNo["ref_no"],
          "payment_hk": dataRefNo["payment_hk"],
          "auto_extend": allowAutoExtend ? "Y" : "N"
        };

        HttpRequest(
                api: ApiKeys.gApiSubFolderPostReserveParking,
                parameters: postParameters)
            .post()
            .then((returnPost) async {
          if (returnPost == "No Internet") {
            Navigator.of(context).pop();
            showAlertDialog(context, "Error",
                "Please check your internet connection and try again.", () {
              Navigator.of(context).pop();
            });
            return;
          }
          if (returnPost == null) {
            Navigator.pop(context);
            showAlertDialog(context, "Error",
                "Error while connecting to server, Please try again.", () {
              Navigator.of(context).pop();
            });
          }
          if (returnPost["success"] == 'Y') {
            Map<String, dynamic> payParameters = {
              "luvpay_id": jsonDecode(akongP)['user_id'].toString(),
              "lp_ref_no": dataRefNo["ref_no"].toString(),
              "no_hours": params["no_hours"].toString(),
              "ps_ref_no": returnPost["ps_ref_no"].toString(),
              "payment_hk": dataRefNo["payment_hk".toString()],
              "ticket_amount": returnPost["ticket_amount"].toString(),
              "dt_in": params["dt_in"].toString(),
              "dt_out": params["dt_out"].toString(),
              "park_area_name": returnPost["park_area_name"].toString(),
              "pa_longitude": returnPost["pa_longitude"].toString(),
              "pa_latitude": returnPost["pa_latitude"].toString(),
              "auto_extend": allowAutoExtend ? "Y" : "N"
            };

            HttpRequest(
                    api: ApiKeys.gApiSubFolderPostReservePay,
                    parameters: payParameters)
                .post()
                .then((returnPay) async {
              if (returnPay == "No Internet") {
                Navigator.of(context).pop();
                showAlertDialog(context, "Error",
                    "Please check your internet connection and try again.", () {
                  Navigator.of(context).pop();
                });

                return;
              }
              if (returnPay == null) {
                Navigator.pop(context);
                showAlertDialog(context, "Error",
                    "Error while connecting to server, Please contact administrator.",
                    () {
                  Navigator.of(context).pop();
                });
              } else {
                if (returnPay["success"] == 'Y') {
                  // if (widget.isCheckIn && isCheckIn) {
                  //   LocationService.grantPermission(context, (isGranted) {
                  //     if (isGranted) {
                  //     } else {
                  //       showAlertDialog(
                  //           context, "LuvPark", "No permissions granted.", () {
                  //         Navigator.of(context).pop();
                  //       });
                  //     }
                  //   });
                  //   return;
                  // } else {

                  // }

                  Navigator.of(context).pop();
                  Navigator.pop(context);

                  Variables.pageTrans(
                      ReserveReceipt(
                          spaceName: returnPost['park_space_name'],
                          parkArea: widget.areaData[0]["park_area_name"],
                          startDate: Variables.formatDate(
                              params["dt_in"].toString().split(" ")[0]),
                          //      params["dt_in"].toString().split(" ")[0] ==
                          //     params["dt_out"].toString().split(" ")[0]
                          // ? Variables.formatDate(
                          //     params["dt_in"].toString().split(" ")[0])
                          // : "${Variables.formatDate(params["dt_in"].toString().split(" ")[0])} - ${Variables.formatDate(params["dt_out"].toString().split(" ")[0])}",
                          endDate: Variables.formatDate(
                              params["dt_out"].toString().split(" ")[0]),
                          startTime: params["dt_in"]
                              .toString()
                              .split(" ")[1]
                              .toString(),
                          endTime: params["dt_out"]
                              .toString()
                              .split(" ")[1]
                              .toString(),
                          plateNo: params["vehicle_plate_no"].toString(),
                          hours: params["no_hours"].toString(),
                          amount: returnPay['applied_amt'].toString(),
                          refno: returnPost["ps_ref_no"].toString(),
                          lat: double.parse(
                              returnPost['ps_latitude'].toString()),
                          long: double.parse(
                              returnPost['ps_longitude'].toString()),
                          canReserved: false,
                          isReserved: false,
                          isVehicleSelected: isVsel,
                          tab: 2,
                          isShowRate: true,
                          reservationId: int.parse(returnPay["reservation_id"]),
                          address: "",
                          isAutoExtend: "",
                          paramsCalc: params),
                      context

                      ///
                      );
                  return;
                } else {
                  Navigator.pop(context);
                  showAlertDialog(context, "Error", returnPay['msg'], () {
                    Navigator.of(context).pop();
                  });
                }
              }
            });
          }
          if (returnPost["success"] == "Q") {
            Navigator.of(context).pop();
            showModalConfirmation(
                context, "Confirmation", returnPost["msg"], "", "Yes", () {
              Navigator.of(context).pop();
            }, () async {
              String userId = await Variables.getUserId();
              Map<String, dynamic> queueParam = {
                'luvpay_id': userId,
                'park_area_id': widget.areaData[0]["park_area_id"],
                'vehicle_type_id':
                    callBackData[0]["vehicle_type_id"].toString(),
                'vehicle_plate_no': callBackData[0]["vehicle_plate_no"]
              };

              CustomModal(context: context).loader();
              HttpRequest(
                      api: ApiKeys.gApiLuvParkResQueue, parameters: queueParam)
                  .post()
                  .then((queParamData) {
                if (queParamData == "No Internet") {
                  Navigator.pop(context);

                  showAlertDialog(context, "Error",
                      "Please check your internet connection and try again.",
                      () {
                    Navigator.of(context).pop();
                  });
                  return;
                }
                if (queParamData == null) {
                  Navigator.of(context).pop();
                  showAlertDialog(context, "Error",
                      "Error while connecting to server, Please try again.",
                      () {
                    Navigator.of(context).pop();
                  });

                  return;
                } else {
                  Navigator.of(context).pop();
                  if (queParamData["success"] == 'Y') {
                    showAlertDialog(context, "Success", queParamData["msg"],
                        () {
                      Navigator.of(context).pop();
                      Variables.pageTrans(MainLandingScreen(), context);
                    });
                  } else {
                    showAlertDialog(context, "LuvPark", queParamData["msg"],
                        () {
                      Navigator.of(context).pop();
                    });
                  }
                }
              });
            });
          }
          //error
          if (returnPost["success"] == 'N') {
            Navigator.of(context).pop();
            showAlertDialog(context, "Error", returnPost["msg"], () {
              Navigator.of(context).pop();
            });
          }
        });
      } else {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error", "No data found.", () {
          Navigator.of(context).pop();
        });

        return;
      }
    });
  }
}

class RewardDialog extends StatefulWidget {
  final TextEditingController controller;
  final String points, totalAmount;
  RewardDialog(
      {super.key,
      required this.controller,
      required this.points,
      required this.totalAmount});

  @override
  State<RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> {
  bool isExceed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomParagraph(text: "Enter desired amount to be used"),
          CustomTextField(
            labelText: toCurrencyString(widget.points.toString()).toString(),
            controller: widget.controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              //LengthLimitingTextInputFormatter(int.parse(totalAmount)),
              FilteringTextInputFormatter.digitsOnly
            ],
            onChange: (value) {
              if (int.parse(value) >
                  int.parse(widget.totalAmount.toString().split(".")[0])) {
                setState(() {
                  isExceed = true;
                });
              } else {
                setState(() {
                  isExceed = false;
                });
              }
            },
          ),
          if (isExceed)
            CustomParagraph(
              text:
                  "Reward points inputted should not be greater than the total bill for parking",
              maxlines: 2,
              fontSize: 10,
              color: Colors.red,
            ),
        ],
      ),
    );
  }
}
