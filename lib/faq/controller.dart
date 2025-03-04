import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';

class FaqPageController extends GetxController {
  FaqPageController();
  RxList<Map<String, dynamic>> faqsData = <Map<String, dynamic>>[].obs;
  RxBool isLoadingPage = true.obs;
  RxBool isNetConn = true.obs;
  RxBool isExpanded = false.obs;
  RxSet<int> expandedIndexes = <int>{}.obs;
  RxList filteredFaqs = [].obs;
  RxList faqs = [].obs;
  @override
  void onInit() {
    super.onInit();
    getFaq();
  }

  Future<void> refresher() async {
    isNetConn.value = true;
    getFaq();
  }

  Future<void> getFaq() async {
    isLoadingPage.value = true;
    var returnData = await HttpRequest(
      api: ApiKeys.getFAQ,
    ).get();

    if (returnData == "No Internet") {
      isNetConn.value = false;
      isLoadingPage.value = false;
      return;
    }
    if (returnData == null) {
      isNetConn.value = true;
      isLoadingPage.value = false;
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }

    faqsData.value = List<Map<String, dynamic>>.from(returnData["items"]);

    filteredFaqs.assignAll(faqsData);

    isLoadingPage.value = false;
  }

  Future<void> getFaqAnswers(String id, int index) async {
    CustomDialog().loadingDialog(Get.context!);
    var returnData = await HttpRequest(
      api: '${ApiKeys.getFAQsAnswer}?faq_id=$id',
    ).get();
    Get.back();
    if (returnData == "No Internet") {
      isNetConn.value = false;
      isLoadingPage.value = false;
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (returnData == null) {
      isNetConn.value = true;
      isLoadingPage.value = false;
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }

    if (returnData["items"].length > 0) {
      expandedIndexes.clear();
      faqsData[index]['answers'] = returnData["items"];

      expandedIndexes.add(index);
    } else {
      CustomDialog().errorDialog(Get.context!, "Luvpark", "No data found", () {
        Get.back();
      });
    }
  }

  void onExpand(bool onExpand, int index, item) async {
    if (onExpand) {
      if (!expandedIndexes.contains(index)) {
        await getFaqAnswers(item['faq_id'].toString(), index);
      }
    } else {
      expandedIndexes.clear();
    }

    update();
  }

  void filteredFaq(String query) {
    if (query.isEmpty) {
      filteredFaqs.assignAll(faqsData);
    } else {
      filteredFaqs.assignAll(faqsData.where((faq) {
        return faq['faq_text'].toLowerCase().contains(query.toLowerCase());
      }).toList());
    }
  }
}
