import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/sqlite/vehicle_brands_model.dart';
import 'package:luvpark/sqlite/vehicle_brands_table.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

enum AppState {
  free,
  picked,
  cropped,
}

class VehicleRegDialog extends StatefulWidget {
  final Function callback;
  final String userId;
  final String plateNo;
  final List? paramDataReg;

  const VehicleRegDialog(
      {super.key,
      required this.callback,
      required this.userId,
      this.paramDataReg,
      required this.plateNo});

  @override
  State<VehicleRegDialog> createState() => _VehicleRegDialogState();
}

class _VehicleRegDialogState extends State<VehicleRegDialog> {
  List vehicleTypeData = [];
  List vehicleBrandData = [];
  final TextEditingController plateNo = TextEditingController();
  final TextEditingController vehicleBrand = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? vehicleTypeValue;
  String? vehicleBrandValue;
  bool isLoading = true;
  bool isReadOnly = false;
  bool isLoadingBrand = false;
  bool hasInternet = true;
  final ImagePicker _picker = ImagePicker();
  String? orImageBase64;
  String? crImageBase64;
  AppState? state;
  File? imageFile;
  String hintTextLabel = "Plate No.";
  final Map<String, RegExp> _filter = {
    'A': RegExp(r'[A-Za-z0-9]'),
    '#': RegExp(r'[A-Za-z0-9]')
  };
  MaskTextInputFormatter? _maskFormatter;
  BuildContext? mainCtxt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getVehicleData();
      _updateMaskFormatter("");
    });
    if (widget.plateNo.isNotEmpty) {
      plateNo.text = widget.plateNo;
      isReadOnly = true;
      vehicleTypeValue = widget.paramDataReg![0]["vehicle_type_id"];
    }
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
    _maskFormatter = MaskTextInputFormatter(
      mask: mask,
      filter: _filter,
    );
  }

  void getVehicleData() {
    CustomModal(context: context).loader();
    const HttpRequest(api: ApiKeys.gApiLuvParkDDVehicleTypes)
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        setState(() {
          hasInternet = false;
          isLoading = false;
        });
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return;
      }
      if (returnData == null) {
        Navigator.of(context).pop();
        setState(() {
          isLoading = false;
          hasInternet = true;
        });
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
      }

      if (returnData["items"].length > 0) {
        for (var items in returnData["items"]) {
          vehicleTypeData.add({
            "vehicle_id": items["value"],
            "vehicle_desc": items["text"],
            "format": items["input_format"],
          });
        }
        setState(() {
          isLoading = false;
          hasInternet = true;
        });

        Navigator.of(context).pop();
        // if (widget.plateNo.isNotEmpty) {
        getVehicleBrand();
        //}
      } else {
        Navigator.of(context).pop();
        setState(() {
          isLoading = true;
        });
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return;
      }
    });
  }

  void getVehicleBrand() {
    CustomModal(context: context).loader();

    String apiParam = "${ApiKeys.gApiLuvParkGetVehicleBrand}";
    HttpRequest(api: apiParam).get().then((returnBrandData) async {
      if (returnBrandData == "No Internet") {
        setState(() {
          isLoadingBrand = false;
          vehicleBrandData = [];
          hasInternet = false;
        });
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (returnBrandData == null) {
        Navigator.of(context).pop();
        setState(() {
          isLoadingBrand = false;
          hasInternet = true;
          vehicleBrandData = [];
        });
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      }

      if (returnBrandData["items"].length > 0) {
        VehicleBrandsTable.instance.deleteAll();
        for (var dataRow in returnBrandData["items"]) {
          var vbData = {
            VHBrandsDataFields.vhTypeId:
                int.parse(dataRow["vehicle_type_id"].toString()),
            VHBrandsDataFields.vhBrandId:
                int.parse(dataRow["vehicle_brand_id"].toString()),
            VHBrandsDataFields.vhBrandName:
                dataRow["vehicle_brand_name"].toString(),
          };
          await VehicleBrandsTable.instance.insertUpdate(vbData);
        }

        setState(() {
          isLoadingBrand = false;
          hasInternet = true;
        });

        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        setState(() {
          isLoadingBrand = false;
          vehicleBrandData = [];
          hasInternet = true;
        });
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
    });
  }

  void getFilteredBrand(vtId) async {
    print("maeMaevtId $vtId");
    await VehicleBrandsTable.instance.readAllVHBrands().then((maeMae) {
      print("maeMae $maeMae");

      if (maeMae.isNotEmpty) {
        vehicleBrandData = maeMae.where((e) {
          print("eeee ${e["vehicle_type_id"].toString()}");
          return int.parse(e["vehicle_type_id"].toString()) ==
              int.parse(vtId.toString());
        }).toList();

        setState(() {});
      }
    });
  }

  void showBottomSheetCamera(isOr) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext cont) {
          return CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  takePhoto(ImageSource.camera, isOr);
                },
                child: const Text('Use Camera'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  takePhoto(ImageSource.gallery, isOr);
                },
                child: const Text('Upload from files'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                // ignore: unnecessary_statements
                Navigator.pop(mainCtxt!);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          );
        });
  }

  void takePhoto(ImageSource source, bool isOr) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 25,
      maxHeight: 480,
      maxWidth: 640,
    );

    setState(() {
      imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
        imageFile!.readAsBytes().then((data) {
          if (isOr) {
            orImageBase64 = base64.encode(data);
          } else {
            crImageBase64 = base64.encode(data);
          }
        });
      });
    } else {
      if (isOr) {
        orImageBase64 = null;
      } else {
        crImageBase64 = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    mainCtxt = context;
    return CustomParent1Widget(
      appBarheaderText: "Add Vehicle",
      canPop: true,
      appBarIconClick: () {
        Navigator.of(context).pop();
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
              ),
              LabelText(text: "Vehicle Type"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DropdownButtonFormField(
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  menuMaxHeight: 200,
                  decoration: InputDecoration(
                    // filled: true,
                    // fillColor: Colors.white,
                    hintText: "Select Vehicle",
                    // constraints:
                    //     const BoxConstraints.tightFor(height: 50),
                    contentPadding: const EdgeInsets.all(10),
                    hintStyle: GoogleFonts.varela(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 223, 223, 223)),
                    ),
                  ),
                  style: Platform.isAndroid
                      ? GoogleFonts.dmSans(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        )
                      : TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          fontFamily: "SFProTextReg",
                        ),
                  value: vehicleTypeValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      vehicleTypeValue = newValue;
                      vehicleBrandData = [];
                      vehicleBrandValue = null;
                      plateNo.clear();
                    });
                    var dataList = vehicleTypeData.where((e) {
                      return int.parse(e["vehicle_id"].toString()) ==
                          int.parse(vehicleTypeValue.toString());
                    }).toList()[0];
                    _updateMaskFormatter(dataList["format"]);
                    //  getVehicleBrand(vehicleTypeValue);
                    print("vehicleTypeValue $vehicleTypeValue");
                    getFilteredBrand(vehicleTypeValue);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vehicle is required';
                    }
                    return null;
                  },
                  items: vehicleTypeData.map((item) {
                    return DropdownMenuItem(
                        value: item['vehicle_id'].toString(),
                        child: AutoSizeText(
                          item['vehicle_desc'],
                          style: GoogleFonts.varela(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                          maxFontSize: 15,
                          maxLines: 2,
                        ));
                  }).toList(),
                ),
              ),
              LabelText(text: "Brand"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DropdownButtonFormField(
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  menuMaxHeight: 200,
                  decoration: InputDecoration(
                    hintText: "Brand",
                    contentPadding: const EdgeInsets.all(10),
                    hintStyle: GoogleFonts.varela(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 223, 223, 223)),
                    ),
                  ),
                  style: Platform.isAndroid
                      ? GoogleFonts.dmSans(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        )
                      : TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          fontFamily: "SFProTextReg",
                        ),
                  value: vehicleBrandValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      vehicleBrandValue = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vehicle brand is required';
                    }
                    return null;
                  },
                  items: vehicleBrandData.map((item) {
                    return DropdownMenuItem(
                        value: item['vehicle_brand_id'].toString(),
                        child: AutoSizeText(
                          item['vehicle_brand_name'],
                          style: GoogleFonts.varela(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                          maxFontSize: 15,
                          maxLines: 2,
                        ));
                  }).toList(),
                ),
              ),
              LabelText(text: "Plate No"),
              CustomTextField(
                labelText: hintTextLabel,
                inputFormatters: [_maskFormatter!],
                controller: plateNo,
                isReadOnly: isReadOnly,
                maxLength: 15,

                // inputFormatters: [Variables.regExpRestrictFormatter],
                onTap: () async {},
                onChange: (value) {
                  plateNo.value = TextEditingValue(
                      text: value.toUpperCase(), selection: plateNo.selection);
                  if (value.length > 15) {
                    plateNo.text = value.substring(0, 15);
                  }
                },
              ),
              LabelText(text: "Original Receipt (OR)"),
              Container(
                height: 10,
              ),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: orImageBase64 != null
                                ? MemoryImage(
                                    const Base64Decoder()
                                        .convert(orImageBase64!.toString()),
                                  )
                                : const AssetImage("assets/images/no_orcr.png")
                                    as ImageProvider)),
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                    top: 0,
                    right: 10,
                    child: InkWell(
                      onTap: () {
                        showBottomSheetCamera(true);
                      },
                      child: Center(
                        child: Icon(
                          CupertinoIcons.camera,
                          size: 30,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                height: 10,
              ),
              LabelText(text: "Certificate of Registration (CR)"),
              Container(
                height: 10,
              ),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: crImageBase64 != null
                                ? MemoryImage(
                                    const Base64Decoder()
                                        .convert(crImageBase64!.toString()),
                                  )
                                : const AssetImage("assets/images/no_orcr.png")
                                    as ImageProvider)),
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                    top: 0,
                    right: 10,
                    child: InkWell(
                      onTap: () {
                        showBottomSheetCamera(false);
                      },
                      child: Center(
                        child: Icon(
                          CupertinoIcons.camera,
                          size: 30,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                height: 30,
              ),
              CustomButton(
                  label: "Register",
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      CustomModal(context: context).loader();
                      var parameter = {
                        "user_id": widget.userId,
                        "vehicle_plate_no": plateNo.text,
                        "vehicle_type_id": vehicleTypeValue,
                        "vehicle_brand_id": vehicleBrandValue,
                        "vor_image_base64": orImageBase64,
                        "vcr_image_base64": crImageBase64,
                      };
                      print("parameter $parameter");

                      HttpRequest(
                              api: ApiKeys.gApiLuvParkPostGetVehicleReg,
                              parameters: parameter)
                          .post()
                          .then((returnPost) async {
                        if (returnPost == "No Internet") {
                          Navigator.of(context).pop();
                          showAlertDialog(context, "Error",
                              "Please check your internet connection and try again.",
                              () {
                            Navigator.of(context).pop();
                          });

                          return;
                        }
                        if (returnPost == null) {
                          Navigator.pop(context);
                          showAlertDialog(context, "Error",
                              "Error while connecting to server, Please try again.",
                              () {
                            Navigator.of(context).pop();
                          });
                        } else {
                          if (returnPost["success"] == 'Y') {
                            Navigator.of(context).pop();
                            showAlertDialog(context, "Success",
                                "Your vehicle with plate number \n${plateNo.text} has been successfully registered.",
                                () {
                              Navigator.of(context).pop();
                              if (Navigator.canPop(context)) {
                                Navigator.of(context).pop();
                              }
                              widget.callback();
                            });
                          } else {
                            Navigator.pop(context);
                            showAlertDialog(context, "Error", returnPost['msg'],
                                () {
                              Navigator.of(context).pop();
                            });
                          }
                        }
                      });
                    }
                  }),
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
