import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/faq/controller.dart';

class FaqPage extends GetView<FaqPageController> {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchFaqController = TextEditingController();
    return Obx(() => Scaffold(
          appBar: AppBar(
            elevation: 1,
            backgroundColor: AppColor.primaryColor,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: AppColor.primaryColor,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
            ),
            title: Text("FAQ's"),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Iconsax.arrow_left,
                color: Colors.white,
              ),
            ),
          ),
          body: controller.isLoadingPage.value
              ? const PageLoader()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          faqs(searchFaqController),
                          SizedBox(height: 15),
                          CustomTitle(
                            text: "How can\nwe help you?",
                            fontSize: 30,
                            maxlines: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10))),
                        child: !controller.isNetConn.value
                            ? NoInternetConnected(
                                onTap: controller.refresher,
                              )
                            : controller.faqsData.isEmpty
                                ? NoDataFound()
                                : ScrollConfiguration(
                                    behavior: ScrollBehavior()
                                        .copyWith(overscroll: false),
                                    child: StretchingOverscrollIndicator(
                                      axisDirection: AxisDirection.down,
                                      child: ListView.separated(
                                          itemCount:
                                              controller.filteredFaqs.length,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          separatorBuilder: (context, index) =>
                                              Divider(
                                                color: Colors.grey[800],
                                                height: 1,
                                              ),
                                          itemBuilder: (context, index) {
                                            var faq =
                                                controller.filteredFaqs[index];

                                            return ExpansionTile(
                                              title: CustomParagraph(
                                                text: faq['faq_text'] ??
                                                    'No text available',
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              trailing: Icon(
                                                controller.expandedIndexes
                                                        .contains(index)
                                                    ? Iconsax.minus
                                                    : Iconsax.add,
                                                color: AppColor.primaryColor,
                                              ),
                                              onExpansionChanged:
                                                  (onExpand) async {
                                                controller.onExpand(
                                                    onExpand, index, faq);
                                              },
                                              children: [
                                                if (controller.expandedIndexes
                                                    .contains(index))
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        15, 0, 15, 15),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (faq['answers'] ==
                                                                null ||
                                                            (faq['answers']
                                                                    as List)
                                                                .isEmpty)
                                                          const CustomParagraph(
                                                            text:
                                                                'No answers available',
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          )
                                                        else
                                                          ...((faq['answers']
                                                                  as List)
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                            int index =
                                                                entry.key;
                                                            var answer =
                                                                entry.value;
                                                            return CustomParagraph(
                                                              text:
                                                                  '${index + 1}. ${answer['faq_ans_text'] ?? 'No answer available'}',
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            );
                                                          }).toList()),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          'Updated on: ${faq['updated_on'] != null ? DateFormat('MMMM d, y').format(DateTime.parse(faq['updated_on'])) : 'N/A'}',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }),
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
        ));
  }

  TextField faqs(TextEditingController searchFaqController) {
    return TextField(
      autofocus: false,
      style: paragraphStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10),
        hintText: "Ask a question...",
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(54),
          borderSide: BorderSide(color: AppColor.primaryColor),
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(54),
          borderSide: BorderSide(width: 1, color: Color(0xFFCECECE)),
        ),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 15),
            Icon(LucideIcons.search),
            Container(width: 10),
          ],
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: searchFaqController.text.isNotEmpty,
              child: InkWell(
                onTap: () {
                  searchFaqController.clear();
                  controller.filteredFaq('');
                },
                child: Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey.shade300),
                  child: Icon(
                    LucideIcons.x,
                    color: AppColor.headerColor,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        hintStyle: paragraphStyle(
          color: Color(0xFF646263),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        labelStyle: paragraphStyle(
          fontWeight: FontWeight.w500,
          color: AppColor.hintColor,
        ),
      ),
      onChanged: (value) {
        controller.filteredFaq(value);
      },
    );
  }
}

class FaqsAppbar extends StatelessWidget {
  const FaqsAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.message_search, size: 20),
        ),
      ],
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: InkWell(
          onTap: () {
            Get.back();
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
              CustomParagraph(
                text: "Back",
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
      leadingWidth: 100,
      title: const CustomTitle(
        text: "FAQs",
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.41,
      ),
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/faq_frame.png"),
              ),
            ),
          ),
          Column(
            children: [
              const Expanded(
                flex: 7,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: CustomTitle(
                      text: "How can we help you?",
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColor.bodyColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
