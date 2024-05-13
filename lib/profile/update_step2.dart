// ignore: must_be_immutable
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class UpdateProfStep2 extends StatefulWidget {
  final TextEditingController address1,
      address2,
      zipCode,
      provinceId,
      regionId,
      cityId,
      brgyId,
      searchAddress;

  final GlobalKey<FormState> formKey;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;
  String? ddParamProvince;
  LatLng? location;
  UpdateProfStep2(
      {super.key,
      this.ddParamProvince,
      this.location,
      required this.searchAddress,
      required this.onPreviousPage,
      required this.onNextPage,
      required this.provinceId,
      required this.regionId,
      required this.cityId,
      required this.brgyId,
      required this.address1,
      required this.address2,
      required this.zipCode,
      required this.formKey});

  @override
  State<UpdateProfStep2> createState() => _RegistrationPage1State();
}

class _RegistrationPage1State extends State<UpdateProfStep2> {
  bool loading = true;
  var akongP;
  TextEditingController searchPlaceController = TextEditingController();
  List regionDatas = [];
  List cityData = [];
  List provinceData = [];
  List brgyData = [];
  String? ddProvice;
  String? ddRegion;
  String? ddCity;
  String? ddBrgy;
  String provinceName = "";
  String regionName = "";
  String cityName = "";
  String brgyName = "";
  String searchAdd = "";
  bool loadingOnChange = true;

  @override
  void initState() {
    super.initState();
    getAccountData();
  }

  void getAccountData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    akongP = prefs.getString(
      'userData',
    );
    akongP = jsonDecode(akongP!);
    var myProvinceData = prefs.getString(
      'provinceData',
    );
    var myCityData = prefs.getString(
      'cityData',
    );
    var myBrgyData = prefs.getString(
      'brgyData',
    );
    print("myProvinceData ${myProvinceData != 'null'}");

    if (myProvinceData != null) {
      print("waa bay");
      setState(() {
        ddRegion = widget.regionId.text.isEmpty ? null : widget.regionId.text;
      });
    }

    if (myProvinceData != null) {
      print("ne lpaos dre if");
      provinceData = jsonDecode(myProvinceData);
      setState(() {
        ddProvice =
            widget.provinceId.text.isEmpty ? null : widget.provinceId.text;
        provinceName = provinceData.where((element) {
          return int.parse(element["value"].toString()) ==
              int.parse(ddProvice.toString());
        }).toList()[0]["province"];
      });
    } else {
      print("ne lpaos dre ellse");
      setState(() {
        ddProvice = null;
      });
    }

    if (myCityData != null) {
      cityData = jsonDecode(myCityData);
      setState(() {
        ddCity = widget.cityId.text.isEmpty ? null : widget.cityId.text;
        cityName = cityData.where((element) {
          return int.parse(element["value"].toString()) ==
              int.parse(ddCity.toString());
        }).toList()[0]["city"];
      });
    } else {
      setState(() {
        ddCity = null;
      });
    }

    if (myBrgyData != null) {
      brgyData = jsonDecode(myBrgyData);
      setState(() {
        ddBrgy = widget.brgyId.text.isEmpty ? null : widget.brgyId.text;
        brgyName = brgyData.where((element) {
          return int.parse(element["value"].toString()) ==
              int.parse(ddBrgy.toString());
        }).toList()[0]["brgy"];
      });
    } else {
      setState(() {
        ddBrgy = null;
      });
    }

    if (mounted) {
      setState(() {
        widget.searchAddress.text = "$provinceName $cityName $brgyName";
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRegionData();
    });
  }

  void getRegionData() async {
    print("ne sulod sa get region data");
    FocusManager.instance.primaryFocus!.unfocus();
    CustomModal(context: context).loader();
    const HttpRequest(api: ApiKeys.gApiSubFolderGetRegion)
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            'Please check your internet connection and try again.', () {
          Navigator.pop(context);
          widget.onPreviousPage();
        });

        return;
      }
      if (returnData == null) {
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Navigator.of(context).pop();
          widget.onPreviousPage();
        });

        return;
      } else {
        if (returnData["items"].length == 0) {
          Navigator.pop(context);
          showAlertDialog(
              context, "Error", 'No data found, Please contact admin.', () {
            Navigator.pop(context);
            widget.onPreviousPage();
          });
        } else {
          for (var regionRows in returnData["items"]) {
            regionDatas.add({
              'value': regionRows["region_id"],
              "region": regionRows["region_name"]
            });
          }
          setState(() {
            loading = false;
          });
          Navigator.pop(context);
        }
      }
    });
  }

//ONCHANGE FUNCTION
  void getProvinceData(id, folder) {
    // ignore: prefer_typing_uninitialized_variables
    String subApi = "";

    if (folder == ApiKeys.gApiSubFolderGetProvince) {
      setState(() {
        provinceData = [];
        subApi = "$folder?p_region_id=$id";
      });
    } else if (folder == ApiKeys.gApiSubFolderGetCity) {
      setState(() {
        cityData = [];
        subApi = "$folder?p_province_id=$id";
      });
    } else {
      setState(() {
        //  baranggayData = [];
        subApi = "$folder?p_city_id=$id";
      });
    }
    // ignore: prefer_typing_uninitialized_variables

    FocusManager.instance.primaryFocus!.unfocus();
    CustomModal(context: context).loader();
    HttpRequest(api: subApi).get().then((returnData) async {
      if (returnData == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.pop(context);
          widget.onPreviousPage();
        });
        return;
      }
      if (returnData == null) {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Navigator.of(context).pop();
          widget.onPreviousPage();
        });

        return;
      } else {
        if (returnData["items"].length == 0) {
          Navigator.pop(context);
          showAlertDialog(
              context, "Error", 'No data found, Please contact admin.', () {
            Navigator.pop(context);
            widget.onPreviousPage();
          });
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          if (folder == ApiKeys.gApiSubFolderGetProvince) {
            setState(() {
              provinceData = [];
            });
            for (var provRow in returnData["items"]) {
              provinceData.add(
                  {'value': provRow["value"], 'province': provRow["text"]});
            }

            setState(() {
              prefs.setString('provinceData', jsonEncode(provinceData));
            });
          }
          if (folder == ApiKeys.gApiSubFolderGetCity) {
            setState(() {
              cityData = [];
            });
            for (var provRow in returnData["items"]) {
              cityData
                  .add({'value': provRow["value"], 'city': provRow["text"]});
            }
            setState(() {
              prefs.setString('cityData', jsonEncode(cityData));
            });
          }
          if (folder == ApiKeys.gApiSubFolderGetBrgy) {
            setState(() {
              brgyData = [];
            });
            for (var provRow in returnData["items"]) {
              brgyData
                  .add({'value': provRow["value"], 'brgy': provRow["text"]});
            }

            setState(() {
              prefs.setString('brgyData', jsonEncode(brgyData));
            });
          }

          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const HeaderLabel(
              title: "What is your address?",
              subTitle:
                  "To ensure your security, kindly provide your accurate address.",
            ),
            loading ? Container() : cardAddress(),
          ],
        ),
      ),
    );
  }

  Widget cardAddress() {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelText(text: "Region"),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: DropdownButtonFormField(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                //   constraints: BoxConstraints.tightFor(height: 60),

                // filled: true,
                // fillColor: Colors.white,
                hintText: "",
                hintStyle: Platform.isAndroid
                    ? GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9C9C9C),
                        fontSize: 14,
                      )
                    : TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9C9C9C),
                        fontSize: 14,
                        fontFamily: "SFProTextReg",
                      ),
                contentPadding: const EdgeInsets.all(10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
              ),
              value: ddRegion,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null; // Return null to indicate no validation errors
              },
              onChanged: (String? newValue) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  ddRegion = newValue!;
                  widget.regionId.text = newValue.toString();
                  ddProvice = null;
                  widget.provinceId.text = "";
                  widget.cityId.text = "";
                  widget.brgyId.text = "";
                  ddCity = null;
                  ddBrgy = null;

                  getProvinceData(int.parse(ddRegion.toString()),
                      ApiKeys.gApiSubFolderGetProvince);
                  regionName = regionDatas.where((element) {
                    return int.parse(element["value"].toString()) ==
                        int.parse(ddRegion.toString());
                  }).toList()[0]["region"];
                });

                setState(() {
                  prefs.remove('provinceData');
                  prefs.remove('cityData');
                  prefs.remove('brgyData');

                  provinceData = [];
                  cityData = [];
                  brgyData = [];
                });
              },
              isExpanded: true,
              items: regionDatas.map((item) {
                return DropdownMenuItem(
                    value: item['value'].toString(),
                    child: AutoSizeText(
                      item['region'],
                      style: GoogleFonts.varela(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxFontSize: 15,
                      maxLines: 2,
                    ));
              }).toList(),
            ),
          ),
          LabelText(text: "Province"),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: DropdownButtonFormField(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                //   constraints: BoxConstraints.tightFor(height: 60),

                // filled: true,
                // fillColor: Colors.white,
                hintText: "",
                hintStyle: Platform.isAndroid
                    ? GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9C9C9C),
                        fontSize: 14,
                      )
                    : TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9C9C9C),
                        fontSize: 14,
                        fontFamily: "SFProTextReg",
                      ),
                contentPadding: const EdgeInsets.all(10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
              ),
              value: ddProvice,
              isExpanded: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null; // Return null to indicate no validation errors
              },
              onChanged: (String? newValue) async {
                setState(() {
                  ddProvice = newValue!;
                  widget.provinceId.text = ddProvice!;
                  ddCity = null;
                  ddBrgy = null;

                  widget.cityId.text = "";
                  widget.brgyId.text = "";
                  getProvinceData(int.parse(ddProvice.toString()),
                      ApiKeys.gApiSubFolderGetCity);
                  provinceName = provinceData.where((element) {
                    return int.parse(element["value"].toString()) ==
                        int.parse(ddProvice.toString());
                  }).toList()[0]["province"];
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  widget.searchAddress.text = provinceName;
                  prefs.remove('cityData');
                  prefs.remove('brgyData');
                  cityData = [];
                  brgyData = [];
                  prefs.setString('ddProvinceChangeVal', jsonEncode(ddProvice));
                });
              },
              items: provinceData.map((item) {
                return DropdownMenuItem(
                    value: item['value'].toString(),
                    child: AutoSizeText(
                      item['province'],
                      style: GoogleFonts.varela(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxFontSize: 15,
                      maxLines: 2,
                    ));
              }).toList(),
            ),
          ),
          LabelText(text: "City"),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: DropdownButtonFormField(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                //   constraints: BoxConstraints.tightFor(height: 60),

                // filled: true,
                // fillColor: Colors.white,
                hintText: "",
                hintStyle: Platform.isAndroid
                    ? GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9C9C9C),
                        fontSize: 14,
                      )
                    : TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9C9C9C),
                        fontSize: 14,
                        fontFamily: "SFProTextReg",
                      ),
                contentPadding: const EdgeInsets.all(10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
              ),
              value: ddCity,
              isExpanded: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null; // Return null to indicate no validation errors
              },
              onChanged: (String? newValue) async {
                setState(() {
                  ddCity = newValue!;
                  widget.cityId.text = ddCity!;
                  ddBrgy = null;
                  widget.brgyId.text = "";
                  getProvinceData(int.parse(newValue.toString()),
                      ApiKeys.gApiSubFolderGetBrgy);
                  cityName = cityData.where((element) {
                    return int.parse(element["value"].toString()) ==
                        int.parse(ddCity.toString());
                  }).toList()[0]["city"];
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  widget.searchAddress.text = "$provinceName $cityName";
                  prefs.remove('brgyData');
                  brgyData = [];
                });
              },
              items: cityData.map((item) {
                return DropdownMenuItem(
                    value: item['value'].toString(),
                    child: AutoSizeText(
                      item['city'],
                      style: GoogleFonts.varela(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxFontSize: 15,
                      maxLines: 2,
                    ));
              }).toList(),
            ),
          ),
          LabelText(text: "Barangay"),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: DropdownButtonFormField(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                hintText: "",
                hintStyle: Platform.isAndroid
                    ? GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9C9C9C),
                        fontSize: 14,
                      )
                    : TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9C9C9C),
                        fontSize: 14,
                        fontFamily: "SFProTextReg",
                      ),
                contentPadding: const EdgeInsets.all(10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.15000000596046448),
                  ),
                ),
              ),
              value: ddBrgy,
              isExpanded: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null; // Return null to indicate no validation errors
              },
              onChanged: (String? newValue) {
                setState(() {
                  ddBrgy = newValue!;
                  widget.brgyId.text = ddBrgy!;
                  searchAdd = "";
                  brgyName = brgyData.where((element) {
                    return int.parse(element["value"].toString()) ==
                        int.parse(ddBrgy.toString());
                  }).toList()[0]["brgy"];
                  widget.searchAddress.text =
                      "$provinceName $cityName $brgyName";
                });
              },
              items: brgyData.map((item) {
                return DropdownMenuItem(
                    value: item['value'].toString(),
                    child: AutoSizeText(
                      item['brgy'],
                      style: GoogleFonts.varela(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxFontSize: 15,
                      maxLines: 2,
                    ));
              }).toList(),
            ),
          ),
          LabelText(text: "Address1"),
          CustomTextField(
            labelText: 'House No./Bldg (optional)',
            controller: widget.address1,
            onChange: (value) {
              if (value.isNotEmpty) {
                widget.address1.value = TextEditingValue(
                    text: Variables.capitalizeAllWord(value),
                    selection: widget.address1.selection);
              }
              setState(() {});
            },
          ),
          LabelText(text: "Address2"),
          CustomTextField(
            labelText: 'Street Name (optional)',
            controller: widget.address2,
            onChange: (value) {
              if (value.isNotEmpty) {
                widget.address2.value = TextEditingValue(
                    text: Variables.capitalizeAllWord(value),
                    selection: widget.address2.selection);
              }
              setState(() {});
            },
          ),
          LabelText(text: "Zip Code"),
          CustomTextField(
            labelText: 'Zip Code',
            controller: widget.zipCode,
            keyboardType: TextInputType.number,
            onChange: (value) {},
          ),
        ],
      ),
    );
  }
}
