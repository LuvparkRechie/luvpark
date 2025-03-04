import 'package:get/get.dart';
import 'package:luvpark/about_us/index.dart';
import 'package:luvpark/faq/index.dart';
import 'package:luvpark/forgot_password/utils/forgot_pass_success.dart';
import 'package:luvpark/forgot_password/utils/forgot_verified_acc/index.dart';
import 'package:luvpark/my_account/index.dart';
import 'package:luvpark/my_account/utils/index.dart';
import 'package:luvpark/otp_field/index.dart';
import 'package:luvpark/wallet_qr/index.dart';
import 'package:luvpark/wallet_qr/merchantreceipt/index.dart';
import 'package:luvpark/wallet_qr/myqr/bindings.dart';
import 'package:luvpark/wallet_qr/myqr/view.dart';
import 'package:luvpark/wallet_qr/paywithqr/bindings.dart';
import 'package:luvpark/wallet_qr/paywithqr/view.dart';
import 'package:luvpark/wallet_recharge_load/index.dart';

import '../billers/index.dart';
import '../booking/index.dart';
import '../booking/utils/booking_receipt/index.dart';
import '../forgot_password/index.dart';
import '../forgot_password/utils/create_new/index.dart';
import '../help_feedback/index.dart';
import '../landing/index.dart';
import '../lock_screen/index.dart';
import '../login/index.dart';
import '../mapa/index.dart';
import '../merchants/index.dart';
import '../message/index.dart';
import '../my_vehicles/index.dart';
import '../my_vehicles/utils/add_vehicle.dart';
import '../onboarding/index.dart';
import '../parking/index.dart';
import '../parking_areas/index.dart';
import '../permission/permission.dart';
import '../registration/index.dart';
import '../security_settings/index.dart';
import '../splash_screen/index.dart';
import '../wallet/index.dart';
import '../wallet_qr/paymerchant/utils/index.dart';
import '../wallet_send/index.dart';
import 'routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: Routes.onboarding,
      page: () => const MyOnboardingPage(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.landing,
      page: () => const LandingScreen(),
      binding: LandingBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: LoginScreenBinding(),
      preventDuplicates: true,
      transition: Transition.noTransition, // Custom transition
      transitionDuration: Duration(
          milliseconds: 300), // Speed of animation  preventDuplicates: true,
    ),
    // GetPage(
    //     name: Routes.dashboard,
    //     page: () => const DashboardScreen(),
    //     binding: DashboardBinding()),
    GetPage(
      name: Routes.registration,
      page: () => const RegistrationPage(),
      binding: RegistrationBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.permission,
      page: () => const PermissionHandlerScreen(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.parking,
      page: () => const ParkingScreen(),
      binding: ParkingBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.parkingAreas,
      page: () => const ParkingAreas(),
      binding: ParkingAreasBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.map,
      page: () => const DashboardMapScreen(),
      binding: DashboardMapBinding(),
    ),
    GetPage(
      name: Routes.wallet,
      page: () => const WalletScreen(),
      binding: WalletBinding(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 400),
    ),
    GetPage(
      name: Routes.qrwallet,
      page: () => const QrWallet(),
      binding: QrWalletBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.booking,
      page: () => const BookingPage(),
      binding: BookingBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.bookingReceipt,
      page: () => BookingReceipt(),
      binding: BookingReceiptBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.faqpage,
      page: () => const FaqPage(),
      binding: FaqPageBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.aboutus,
      page: () => const AboutUs(),
      binding: AboutUsBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    // GetPage(
    //   name: Routes.profile,
    //   page: () => const Profile(),
    //   binding: ProfileScreenBinding(),
    // ),
    GetPage(
      name: Routes.security,
      page: () => const Security(),
      binding: SecuritySettingsBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.walletrechargeload,
      page: () => const WalletRechargeLoadScreen(),
      binding: WalletRechargeLoadBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.forgotPass,
      page: () => const ForgotPassword(),
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.createNewPass,
      page: () => const CreateNewPassword(),
      binding: CreateNewPasswordBinding(),

      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.forgotPassSuccess,
      page: () => const ForgetPasswordSuccess(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.forgotVerifiedAcct,
      page: () => const ForgotVerifiedAcct(),
      binding: ForgotVerifiedAcctBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.myaccount,
      page: () => const MyAccount(),
      binding: MyAccountBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.myVehicles,
      page: () => const MyVehicles(),
      binding: MyVehiclesBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.addVehicle,
      page: () => const AddVehicles(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.updProfile,
      page: () => const UpdateProfile(),
      binding: UpdateProfileBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),

    GetPage(
      name: Routes.message,
      page: () => const MessageScreen(),
      binding: MessageScreenBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.helpfeedback,
      page: () => const HelpandFeedback(),
      binding: HelpandFeedbackBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.lockScreen,
      page: () => const LockScreen(),
      binding: LockScreenBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.send2,
      page: () => WalletSend(),
      binding: WalletSendBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.billers,
      page: () => Billers(),
      binding: BillersBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.myQR,
      page: () => myQR(),
      binding: myQRBindings(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    // GetPage(
    //   name: Routes.merchantQR,
    //   page: () => payMerchant(),
    //   binding: payMerchantBinding(),
    // ),
    GetPage(
      name: Routes.paywithQR,
      page: () => paywithQR(),
      binding: paywithQRBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.merchantQRverify,
      page: () => MerchantQRverify(),
      binding: MerchantQRverifyBindings(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.merchantReceipt,
      page: () => MerchantQRReceipt(),
      binding: merchantQRRBindings(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.merchant,
      page: () => MerchantBiller(),
      binding: MerchantBillerBindings(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
    GetPage(
      name: Routes.otpField,
      page: () => const OtpFieldScreen(),
      binding: OtpFieldScreenBinding(),
      transition: Transition.rightToLeftWithFade, // Smooth slide transition
      transitionDuration: Duration(milliseconds: 400), preventDuplicates: true,
    ),
  ];
}
