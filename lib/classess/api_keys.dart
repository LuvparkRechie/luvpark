const String luvApi = "luv";
const String parkSpaceApi = "parkspace";

class ApiKeys {
  //Prod Path
  static const gApiURLProd = 'dddijnzn.adb.ap-singapore-1.oraclecloudapps.com';
  //Testing Path
  static const gApiURL =
      'gce81b2a8b40195-gccdb.adb.ap-singapore-1.oraclecloudapps.com';
  //get Payment key
  static const gApiSubFolderPayments = '/ords/$luvApi/ps/qr/';
  //Get luv ReferenceNo
  static const gApiSubFolderGetRefNo = '/ords/$luvApi/base/refno/';
  static const gApiSubFolderPutChangeQR = '/ords/$luvApi/base/newqr/'; //put
  static const gApiSubFolderPolicy = '/ords/$luvApi/base/policy';
  static const gApiSubFolderPrivacyPolicy = '/ords/$luvApi/base/privacypolicy/';
  static const gApiSubFolderPostReg = '/ords/$luvApi/base/reg/'; //post

  static const gApiSubFolderChangePass = '/ords/$luvApi/auth/chgpwd/';
  static const gApiSubFolderGetDropdownSeq = '/ords/$luvApi/auth/resetpwd/';
  static const gApiSubFolderGetDD = '/ords/$luvApi/base/reg/';
  static const gApiSubFolderGetBalance = '/ords/$luvApi/acct/balance';
//get notification
  static const gApiSubFolderGetNotification =
      '/ords/$luvApi/base/notification/';

//send otp forgot pass
  static const gApiSubFolderPutForgotPass =
      '/ords/$luvApi/auth/resetpwd-reqotp/';
  static const gApiSubFolderPutOTP = '/ords/$luvApi/base/reg/'; //put

//verify mobile no
  static const gApiSubFolderVerifyNumber = '/ords/$luvApi/acct/verify'; //get

//Forgot password first
  static const gApiSubFolderPostPutGetResetPass =
      '/ords/$luvApi/auth/resetpwd/'; //put//post

//privacy policy
  static const gApiSubFolderGetPrivacyPolicy =
      '/ords/$luvApi/base/privacypolicy/';

//Idle
  static const gApiSubFolderIdle = '/ords/$luvApi/base/userpref/';
//All Transaction Api
// const gApiSubFolderGetPaymentTrans = '/ords/$luvApi/tnx/out/';
//Ge ilisan ug ords/$luvApi/tnx/logs/
  static const gApiSubFolderGetTransactionLogs = '/ords/$luvApi/tnx/logs/';
//Reserved api
  static const gApiSubFolderGetReservationHistory =
      '/ords/$luvApi/tnx/reslist/';
  static const gApiSubFolderGetReservations = '/ords/$luvApi/ps/reservations';

//Login API
  static const gApiSubFolderLogin = '/ords/$luvApi/auth/login/';
  static const gApiSubFolderGetIdleTime = '/ords/$luvApi/base/userpref/';
  static const gApiSubFolderPostLogin = '/ords/$luvApi/auth/login/'; //post

//$parkSpaceApi api
  static const gApiSubFolderGetCities =
      '/ords/$parkSpaceApi/base/client_cities';
  static const gApiSubFolderGetArea = '/ords/$parkSpaceApi/park/vacant_areas';
  static const gApiSubFolderGetSpaces =
      '/ords/$parkSpaceApi/park/vacant_spaces'; //display marker on map
  static const gApiSubFolderGetVehicleType =
      '/ords/$parkSpaceApi/base/vehicletypes';
  static const gApiSubFolderGetParkingTime = '/ords/$parkSpaceApi/park/sched/';
  static const gApiSubFolderGetParkingTypes =
      '/ords/$parkSpaceApi/base/parkingtypes';

//get neareast space
  static const gApiSubFolderGetNearestSpace =
      '/ords/$parkSpaceApi/park/nearest';
  static const gApiSubFolderGetDDNearest =
      '/ords/$parkSpaceApi/park/dd_nearest';

//get Direction view payment details
  static const gApiSubFolderGetDirection = '/ords/$parkSpaceApi/park/res/';

// Get Address
  static const gApiSubFolderGetRegion = 'ords/$luvApi/base/region/';
  static const gApiSubFolderGetProvince = 'ords/$luvApi/base/prov/';
  static const gApiSubFolderGetCity = 'ords/$luvApi/base/city/';
  static const gApiSubFolderGetBrgy = 'ords/$luvApi/base/brgy/';

//Extend API
  static const gApiSubFolderPutExtendPay = '/ords/$luvApi/ps/payext'; //put
  static const gApiSubFolderPutExtend = '/ords/$parkSpaceApi/park/extend'; //put

//Reserve API
  static const gApiSubFolderPostReserveParking =
      '/ords/$parkSpaceApi/park/reserve'; //post
  static const gApiSubFolderPostReservePay = '/ords/$luvApi/ps/payres'; //post

//Get User Info
  static const gApiSubFolderGetUserInfo = '/ords/$luvApi/base/userinfo';

//Payment Bills
  static const gApiSubFolderGetBillers = '/ords/$luvApi/bs/billers';
  static const gApiSubFolderGetBillersForm = '/ords/$luvApi/bs/templ/';

//UB CONNECT API
  static const gApiSubFolderPostUbTrans = '/ords/$luvApi/topup/ub/'; //post

//Check login Lock unlock
  static const gApiSubFolderGetLoginAttemptRecord =
      '/ords/$luvApi/auth/chklogin/';
  static const gApiSubFolderPutClearLockTimer =
      'ords/$luvApi/auth/unlock/'; //put

//UNIion bank apis
  static const gApiSubFolderGetUbDetails = '/ords/$luvApi/3pa/hdr/';
  static const gApiSubFolderGetBankParam = '/ords/$luvApi/3pa/dtl/';
  static const gApiSubFolderGetTopUp = '/ords/$luvApi/topup/TPA';

//Share luv
  static const gApiSubFolderPutShareLuv = '/ords/$luvApi/acct/st';
  static const gApiSubFolderPostReqOtpShare = '/ords/$luvApi/auth/get-otp/';

//Update profile
  static const gApiSubFolderPutUpdateProf = '/ords/$luvApi/base/userinfo';

//Withdraw
  static const gApiSubFolderGetWithdrawBanks = '/ords/$luvApi/base/banks';
  static const gApiSubFolderPostWithdraw = '/ords/$luvApi/acct/ft';

//$parkSpaceApi API
  static const gApiSubFolderGetRates = '/ords/$parkSpaceApi/park/rates/';

//getComputation
  static const gApiSubFolderPostReserveCalc =
      '/ords/$parkSpaceApi/park/calcfee';
//MPIN
  static const gApiSubFolderGetPutPostMpin = '/ords/$luvApi/auth/mpin';
//MPIN SWitch button
  static const gApiSubFolderPutSwitch = '/ords/$luvApi/base/mpin';

  //LUVPARK REGISTRATION
  static const gApiLuvParkPostReg = '/ords/$luvApi/user/reg/';
  //LUVPARK REGISTRATION vehicle
  static const gApiLuvParkPostGetVehicleReg = '/ords/$luvApi/mfav/vehicles';
  //LUVPARK Get Brand vehicle
  //static const gApiLuvParkPostGetVehicleBrand = '/ords/$luvApi/ps/vb';
  static const gApiLuvParkGetVehicleBrand =
      '/ords/$parkSpaceApi/base/vehiclebrands';
  //Track location to reserve
  static const gApiLuvParkGetResLoc = '/ords/$parkSpaceApi/park/chkpsr';
  //Change Pass
  static const gApiLuvParkPostForgetPassNotVerified =
      '/ords/$luvApi/auth/rpsf/';
  //Delete vehicle
  static const gApiLuvParkDeleteVehicle = '/ords/$luvApi/mfav/vehicles';
  //Get Parkspace app notice
  static const gApiLuvParkGetNotice = '/ords/$parkSpaceApi/notify/pbm/';
  //Reserve payment key
  static const gApiLuvParkGetResPayKey = '/ords/$luvApi/base/paymentkey';
  //Rating Question
  static const gApiLuvParkGetRatingQuestions =
      '/ords/$parkSpaceApi/rating/questions/';
  //Check direct in reservation
  static const gApiLuvParkPutChkIn = '/ords/$parkSpaceApi/park/check_in/';
  // Check in Luvpay
  static const gApiLuvParkPutLPChkIn = '/ords/$luvApi/ps/check_in';
  //Compute Distance
  static const gApiLuvParkGetComputeDistance = '/ords/$parkSpaceApi/conf/psrc/';
//Compute Distance
  static const gApiLuvParkGetAcctStat = '/ords/$luvApi/user/verify';
  //Rate Us
  static const gApiLuvParkPostRating = '/ords/$luvApi/user/uxr';

  //dd vehicle types
  static const gApiLuvParkDDVehicleTypes =
      '/ords/$parkSpaceApi/park/dd_vehicletypes';

  //Sharing Location API's
  static const gApiLuvParkPostShareLoc = '/ords/$luvApi/geo/gpsShare';
  //GETSHARE
  static const gApiLuvParkGetShareLoc = '/ords/$luvApi/geo/gpsShare';
  static const gApiLuvParkPutShareLoc = '/ords/$luvApi/geo/gpsShare';

  static const gApiLuvParkPutAcceptShareLoc = '/ords/$luvApi/geo/acceptShare';
  static const gApiLuvParkPutCloseShareLoc = '/ords/$luvApi/geo/closeShare';
  static const gApiLuvParkGetActiveShareLoc = '/ords/$luvApi/geo/activeShare';

  //INVITE FRIENDS IN CURRENT SHARING
  static const gApiLuvParkPostAddUserMapSharing = '/ords/$luvApi/geo/addUser';
  //NOTIFY/INVITE FRIENDS for the second time
  // static const gApiLuvParkPostAddUserMapSharing = '/ords/$luvApi/geo/gpsShare';

  //UPDATE LOCATION
  static const gApiLuvParkPutUpdateUsersLoc = "/ords/$luvApi/geo/updateUserGPS";
  //static const gApiLuvParkPutUpdateLoc = '/ords/$luvApi/geo/getUpdates';

  //END SHARING
  static const gApiLuvParkPutEndSharing = '/ords/$luvApi/geo/closeShare';

  //Reservation Queue PUT&GET
  static const gApiLuvParkResQueue = '/ords/$parkSpaceApi/park/queue';

  //GET MESSAGE NOTIF
  static const gApiLuvParkMessageNotif = '/ords/$luvApi/push/messages';
  static const gApiLuvParkPutUpdMessageNotif = '/ords/$luvApi/push/updMessages';
  //FAQ APIS
  static const gAPISubFolderFaqList = '/ords/$parkSpaceApi/faqs/list';
  static const gAPISubFolderFaqAnswer = '/ords/$parkSpaceApi/faqs/ans';
  //POST mobile_no DELETE
  static const gApiLuvPayPostDeleteAccount = '/ords/$luvApi/user/del';
  //Cancel Auto Extend   parameter: reservation_id
  static const gApiLuvPayPutCancelAutoExtend =
      '/ords/$luvApi/ps/stopAutoExtend';
}
