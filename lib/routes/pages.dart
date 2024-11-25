import 'package:get/get.dart';
import 'package:luvpark/about_us/index.dart';
import 'package:luvpark/change_pass/index.dart';
import 'package:luvpark/faq/index.dart';
import 'package:luvpark/forgot_password/utils/forgot_otp/index.dart';
import 'package:luvpark/forgot_password/utils/forgot_verified_acc/index.dart';
import 'package:luvpark/my_account/index.dart';
import 'package:luvpark/my_account/utils/index.dart';
import 'package:luvpark/my_account/utils/otp_update/index.dart';
import 'package:luvpark/profile/index.dart';
import 'package:luvpark/wallet_qr/index.dart';
import 'package:luvpark/wallet_recharge_load/index.dart';

import '../activate_acc/index.dart';
import '../booking/index.dart';
import '../booking/utils/booking_receipt/index.dart';
import '../forgot_password/index.dart';
import '../forgot_password/utils/create_new/index.dart';
import '../forgot_password/utils/forgot_otp/utils/forgot_pass_success.dart';
import '../help_feedback/index.dart';
import '../landing/index.dart';
import '../lock_screen/index.dart';
import '../login/index.dart';
import '../mapa/index.dart';
import '../message/index.dart';
import '../my_vehicles/index.dart';
import '../my_vehicles/utils/add_vehicle.dart';
import '../onboarding/index.dart';
import '../parking/index.dart';
import '../parking_areas/index.dart';
import '../permission/permission.dart';
import '../registration/index.dart';
import '../registration/utils/otp_screen/index.dart';
import '../security_settings/index.dart';
import '../splash_screen/index.dart';
import '../wallet/index.dart';
import '../wallet_send/index.dart';
import '../wallet_send/send_otp/index.dart';
import 'routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
        name: Routes.onboarding,
        page: () => const MyOnboardingPage(),
        binding: OnboardingBinding()),
    GetPage(
        name: Routes.landing,
        page: () => const LandingScreen(),
        binding: LandingBinding()),

    GetPage(
        name: Routes.login,
        page: () => const LoginScreen(),
        binding: LoginScreenBinding()),
    // GetPage(
    //     name: Routes.dashboard,
    //     page: () => const DashboardScreen(),
    //     binding: DashboardBinding()),
    GetPage(
        name: Routes.registration,
        page: () => const RegistrationPage(),
        binding: RegistrationBinding()),
    GetPage(
      name: Routes.otp,
      page: () => const OtpScreen(),
      binding: OtpBinding(),
    ),

    GetPage(
      name: Routes.activate,
      page: () => const ActivateAccount(),
      binding: ActivateAccBinding(),
    ),
    GetPage(
      name: Routes.permission,
      page: () => const PermissionHandlerScreen(),
    ),
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.parking,
      page: () => const ParkingScreen(),
      binding: ParkingBinding(),
    ),
    GetPage(
      name: Routes.parkingAreas,
      page: () => const ParkingAreas(),
      binding: ParkingAreasBinding(),
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
    ),
    GetPage(
      name: Routes.qrwallet,
      page: () => const QrWallet(),
      binding: QrWalletBinding(),
    ),
    GetPage(
      name: Routes.booking,
      page: () => const BookingPage(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.changepassword,
      page: () => const ChangePassword(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: Routes.bookingReceipt,
      page: () => BookingReceipt(),
      binding: BookingReceiptBinding(),
    ),

    GetPage(
      name: Routes.sendOtp,
      page: () => const SendOtp(),
      binding: SendOtpBinding(),
    ),
    GetPage(
      name: Routes.faqpage,
      page: () => const FaqPage(),
      binding: FaqPageBinding(),
    ),
    // GetPage(
    //   name: Routes.mapFilter,
    //   page: () => const FilterMap(),
    //   binding: FilterMapBinding(),
    // ),

    GetPage(
      name: Routes.aboutus,
      page: () => const AboutUs(),
      binding: AboutUsBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const Profile(),
      binding: ProfileScreenBinding(),
    ),
    GetPage(
      name: Routes.security,
      page: () => const Security(),
      binding: SecuritySettingsBinding(),
    ),

    GetPage(
      name: Routes.walletrechargeload,
      page: () => const WalletRechargeLoadScreen(),
      binding: WalletRechargeLoadBinding(),
    ),
    GetPage(
      name: Routes.forgotPass,
      page: () => const ForgotPassword(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.createNewPass,
      page: () => const CreateNewPassword(),
      binding: CreateNewPasswordBinding(),
    ),
    GetPage(
      name: Routes.forgotPassOtp,
      page: () => const ForgotPassOtp(),
      binding: ForgotPassOtpBinding(),
    ),
    GetPage(
      name: Routes.forgotPassSuccess,
      page: () => const ForgetPasswordSuccess(),
    ),
    GetPage(
      name: Routes.forgotVerifiedAcct,
      page: () => const ForgotVerifiedAcct(),
      binding: ForgotVerifiedAcctBinding(),
    ),

    GetPage(
      name: Routes.myaccount,
      page: () => const MyAccount(),
      binding: MyAccountBinding(),
    ),

    GetPage(
      name: Routes.myVehicles,
      page: () => const MyVehicles(),
      binding: MyVehiclesBinding(),
    ),
    GetPage(
      name: Routes.addVehicle,
      page: () => const AddVehicles(),
    ),
    GetPage(
      name: Routes.updProfile,
      page: () => const UpdateProfile(),
      binding: UpdateProfileBinding(),
    ),
    GetPage(
      name: Routes.otpUpdProfile,
      page: () => const OtpUpdate(),
      binding: OtpUpdateBinding(),
    ),
    GetPage(
      name: Routes.message,
      page: () => const MessageScreen(),
      binding: MessageScreenBinding(),
    ),
    GetPage(
      name: Routes.helpfeedback,
      page: () => const HelpandFeedback(),
      binding: HelpandFeedbackBinding(),
    ),
    GetPage(
      name: Routes.lockScreen,
      page: () => const LockScreen(),
      binding: LockScreenBinding(),
    ),
    GetPage(
      name: Routes.send2,
      page: () => WalletSend(),
      binding: WalletSendBinding(),
    ),
  ];
}
