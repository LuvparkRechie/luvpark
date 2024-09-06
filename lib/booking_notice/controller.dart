import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';

class BookingNoticeController extends GetxController {
  BookingNoticeController();
  RxBool isAgree = false.obs;
  RxBool isInternetConn = true.obs;
  RxBool isLoadingPage = true.obs;

  RxList noticeData = [].obs;

  void onPageChanged(bool agree) {
    isAgree.value = agree;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    getNotice();
  }

  void isReadAgree(bool agree) {
    isAgree.value = agree;
  }

  Future<void> getNotice() async {
    isInternetConn.value = true;
    isLoadingPage.value = true;
    String subApi = "${ApiKeys.gApiLuvParkGetNotice}?msg_code=PREBOOKMSG";

    HttpRequest(api: subApi).get().then((retDataNotice) async {
      if (retDataNotice == "No Internet") {
        isLoadingPage.value = false;
        isInternetConn.value = false;
        noticeData.value = [];
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (retDataNotice == null) {
        isInternetConn.value = true;
        isLoadingPage.value = true;
        noticeData.value = [];
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }
      if (retDataNotice["items"].length > 0) {
        isInternetConn.value = true;
        isLoadingPage.value = false;
        noticeData.value = retDataNotice["items"];
      } else {
        isInternetConn.value = true;
        isLoadingPage.value = false;
        noticeData.value = [];
        CustomDialog().errorDialog(Get.context!, "luvpark", "No data found",
            () {
          Get.back();
        });
      }
    });
  }
}
