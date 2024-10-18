import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_textfield.dart';
import '../../custom_widgets/custom_text.dart';
import '../controller.dart';

class EmailSender extends StatelessWidget {
  final emailController = Get.put(AboutUsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        onTap: () {
          Get.back();
        },
        action: [
          IconButton(
            onPressed: emailController.send,
            icon: Icon(Icons.send, color: AppColor.primaryColor),
          )
        ],
        title: "Contact Us",
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                filledColor: Colors.grey.shade200,
                isReadOnly: true,
                isFilled: true,
                labelText: "Recipient",
                controller: emailController.recipientController,
              ),
              Obx(() => CustomTextField(
                    labelText: "Subject",
                    controller: emailController.subjectController,
                    errorText: emailController.isSubjectValid.value
                        ? null
                        : 'Subject cannot be empty',
                  )),
              Obx(() => Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: TextFormField(
                    maxLength: 400,
                    minLines: 1,
                    maxLines: 5,
                    autofocus: false,
                    inputFormatters: [LengthLimitingTextInputFormatter(400)],
                    controller: emailController.bodyController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.multiline,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      labelText: "Body",
                      errorText: emailController.isBodyValid.value
                          ? null
                          : 'Body cannot be empty',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF0078FF))),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFDF0000))),
                    ),
                    style: paragraphStyle(color: Colors.black),
                  ))),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Attachments"),
                  InkWell(
                    onTap: emailController.openImagePicker,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      height: 50,
                      width: 50,
                      child: Icon(Icons.attach_file_sharp),
                    ),
                  ),
                ],
              ),
              Divider(),
              Obx(() => Column(
                    children: emailController.attachments.map((attachment) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              attachment,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () => emailController.removeAttachment(
                                emailController.attachments
                                    .indexOf(attachment)),
                          )
                        ],
                      );
                    }).toList(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
