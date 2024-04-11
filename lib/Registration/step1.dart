// ignore: must_be_immutable
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/password_indicator.dart';

// ignore: must_be_immutable
class RegistrationPage1 extends StatefulWidget {
  final TextEditingController mobile, email, password, passText;

  final GlobalKey<FormState> formKey;
  final VoidCallback onNextPage;

  const RegistrationPage1(
      {super.key,
      required this.onNextPage,
      required this.mobile,
      required this.password,
      required this.email,
      required this.passText,
      required this.formKey});

  @override
  State<RegistrationPage1> createState() => _RegistrationPage1State();
}

class _RegistrationPage1State extends State<RegistrationPage1> {
  bool? has1Number = false;
  bool? hasUpperCase = false;
  bool? hasEightCharacters = false;
  bool? hasText = false;
  bool isObscure = true;
  bool isShowPass = false;
  final numericRegex = RegExp(r'[0-9]');
  final upperCaseRegex = RegExp(r'[A-Z]');
  bool isValidated = false;
  int passStrength = 0;

  onPasswordChange(String password) {
    setState(() {
      has1Number = false;
      hasEightCharacters = false;
      hasUpperCase = false;
      if (password.length >= 8) {
        setState(() {
          hasEightCharacters = true;
        });
      }
      if (numericRegex.hasMatch(password)) {
        setState(() {
          has1Number = true;
        });
      }
      if (upperCaseRegex.hasMatch(password)) {
        setState(() {
          hasUpperCase = true;
        });
      }
      if (password.length > 1) {
        setState(() {
          hasText = true;
        });
      }

      if (hasEightCharacters! && has1Number! && hasUpperCase!) {
        setState(() {
          isValidated = true;
        });
      } else {
        setState(() {
          isValidated = false;
        });
      }
    });
  }

  @override
  void initState() {
    passStrength =
        int.parse(widget.passText.text.isEmpty ? "0" : widget.passText.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isShowKeyboard = MediaQuery.of(context).viewInsets.bottom == 0;
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const HeaderLabel(
              title: "Account Registration",
              subTitle:
                  "Register your mobile number. We'll send you a code to help us secure your account.",
            ),
            LabelText(text: "Mobile Number"),
            CustomMobileNumber(
              labelText: 'Mobile No',
              inputFormatters: [Variables.maskFormatter],
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              controller: widget.mobile,
              onChange: (value) {},
            ),
            LabelText(text: "Email"),
            CustomTextField(
              labelText: "Email",
              controller: widget.email,
              onTap: () async {},
            ),
            LabelText(text: "Password"),
            CustomTextField(
              labelText: "Password",
              controller: widget.password,
              isObscure: isShowPass,
              suffixIcon: isShowPass ? Icons.visibility : Icons.visibility_off,
              onIconTap: () {
                setState(() {
                  isShowPass = !isShowPass;
                });
              },
              onChange: (value) async {
                //  onPasswordChange(value);

                setState(() {
                  passStrength = Variables.getPasswordStrength(value);
                  widget.passText.text = passStrength.toString();
                });
              },
            ),
            Container(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 239, 244, 248),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Password Strength",
                      style: GoogleFonts.varela(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      height: 15,
                    ),
                    Row(
                      children: [
                        PasswordStrengthIndicator(
                          strength: 1,
                          currentStrength: passStrength,
                        ),
                        Container(
                          width: 5,
                        ),
                        PasswordStrengthIndicator(
                          strength: 2,
                          currentStrength: passStrength,
                        ),
                        Container(
                          width: 5,
                        ),
                        PasswordStrengthIndicator(
                          strength: 3,
                          currentStrength: passStrength,
                        ),
                        Container(
                          width: 5,
                        ),
                        PasswordStrengthIndicator(
                          strength: 4,
                          currentStrength: passStrength,
                        ),
                      ],
                    ),
                    Container(
                      height: 15,
                    ),
                    if (Variables.getPasswordStrengthText(passStrength)
                        .isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_shield_fill,
                            color: AppColor.primaryColor,
                            size: 18,
                          ),
                          Container(
                            width: 6,
                          ),
                          CustomDisplayText(
                            label:
                                Variables.getPasswordStrengthText(passStrength),
                            fontWeight: FontWeight.w600,
                            color: Variables.getColorForPasswordStrength(
                                passStrength),
                            fontSize: 15,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    Container(
                      height: 10,
                    ),
                    CustomDisplayText(
                      label:
                          "The password should have a minimum of 8 characters, including at least one uppercase letter and a number.",
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 141, 140, 140),
                      fontSize: 14,
                    ),
                    if (isShowKeyboard)
                      Container(
                        height: 20,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
