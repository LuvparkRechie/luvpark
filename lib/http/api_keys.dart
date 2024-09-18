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
  static const gApiSubFolderPutChangeQR = '/ords/$luvApi/base/newqr/'; //put
  //terms & conditions
  static const gApiSubFolderPolicy = '/ords/$luvApi/base/policy';
  //Privacy policy
  static const gApiSubFolderPrivacyPolicy = '/ords/$luvApi/base/privacypolicy/';

  // static const gApiSubFolderPostReg = '/ords/$luvApi/base/reg/'; //post
//Change password
  static const gApiSubFolderChangePass = '/ords/$luvApi/auth/chgpwd/';
  //reset pasword random question
  static const gApiSubFolderGetDropdownSeq = '/ords/$luvApi/auth/resetpwd/';
  //sercurity question registration
  static const gApiSubFolderGetDD = '/ords/$luvApi/base/reg/';
  //get account balance
  static const gApiSubFolderGetBalance = '/ords/$luvApi/acct/balance';
//get notification
  static const gApiSubFolderGetNotification =
      '/ords/$luvApi/base/notification/';

//send otp forgot pass
  static const gApiSubFolderPutForgotPass =
      '/ords/$luvApi/auth/resetpwd-reqotp/';
//Request Otp
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
//Reservation history
  static const gApiSubFolderGetReservationHistory =
      '/ords/$luvApi/tnx/reslist/';
// //GEt REservation
//   static const gApiSubFolderGetReservations = '/ords/$luvApi/ps/reservations';
//replaced with
  static const gApiSubFolderGetReservations =
      '/ords/$parkSpaceApi/pm/getAdvancedParking';
  static const gApiSubFolderGetActiveParking =
      '/ords/$parkSpaceApi/pm/getAdvancedParkingLogs';

//Login API
//Get user data
  static const gApiSubFolderLogin = '/ords/$luvApi/auth/login/';
//wala gi gamit
  static const gApiSubFolderGetIdleTime = '/ords/$luvApi/base/userpref/';
//Post Login
  static const gApiSubFolderPostLogin = '/ords/$luvApi/auth/login/'; //post

//$parkSpaceApi api
  //get vehicles
  static const gApiSubFolderGetVehicleType =
      '/ords/$parkSpaceApi/base/vehicletypes';

//get neareast space data sa mapa

  static const gApiSubFolderGetNearestSpace =
      '/ords/$parkSpaceApi/zone/nearestParking';
  static const gApiSubGetNearybyParkings =
      '/ords/$parkSpaceApi/zone/nearbyParkings';

  //get parking type filter dropdown dashboard
  static const gApiSubFolderGetParkingTypes =
      '/ords/$parkSpaceApi/base/parkingtypes';
//get parking type filter dropdown radius
  static const gApiSubFolderGetDDNearest =
      '/ords/$parkSpaceApi/park/dd_nearest';

//get Direction view payment details
  static const gApiSubFolderGetDirection = '/ords/$parkSpaceApi/park/res/';

// Get Address registration
  static const gApiSubFolderGetRegion = 'ords/$luvApi/base/region/';
  static const gApiSubFolderGetProvince = 'ords/$luvApi/base/prov/';
  static const gApiSubFolderGetCity = 'ords/$luvApi/base/city/';
  static const gApiSubFolderGetBrgy = 'ords/$luvApi/base/brgy/';

//Extend API
  static const gApiSubFolderPutExtendPay = '/ords/$luvApi/ps/payext'; //put
  static const gApiSubFolderPutExtend = '/ords/$parkSpaceApi/park/extend'; //put

//Get User Info connect with union bank
  static const gApiSubFolderGetUserInfo = '/ords/$luvApi/base/userinfo';
//UB CONNECT API
  static const gApiSubFolderPostUbTrans = '/ords/$luvApi/topup/ub/'; //post

//Check account Lock or unlock
  static const gApiSubFolderGetLoginAttemptRecord =
      '/ords/$luvApi/auth/chklogin/';
//15 minuntes account activation
  static const gApiSubFolderPutClearLockTimer =
      'ords/$luvApi/auth/unlock/'; //put

//UNIion bank apis
  static const gApiSubFolderGetUbDetails = '/ords/$luvApi/3pa/hdr/';
  static const gApiSubFolderGetBankParam = '/ords/$luvApi/3pa/dtl/';
  static const gApiSubFolderGetTopUp = '/ords/$luvApi/topup/TPA';

//Share or transfer token
  static const gApiSubFolderPutShareLuv = '/ords/$luvApi/acct/st';
// Share token get otp
  static const gApiSubFolderPostReqOtpShare = '/ords/$luvApi/auth/get-otp/';

//Update profile
  static const gApiSubFolderPutUpdateProf = '/ords/$luvApi/base/userinfo';

//$parkSpaceApi API
  static const gApiSubFolderGetRates = '/ords/$parkSpaceApi/park/rates/';

//MPIN
  static const gApiSubFolderGetPutPostMpin = '/ords/$luvApi/auth/mpin';
//MPIN SWitch button
  static const gApiSubFolderPutSwitch = '/ords/$luvApi/base/mpin';

  //LUVPARK REGISTRATION
  static const gApiLuvParkPostReg = '/ords/$luvApi/user/reg/';
  //LUVPARK REGISTRATION vehicle
  static const gApiLuvParkPostGetVehicleReg = '/ords/$luvApi/fav/veh';
  //LUVPARK Get Brand vehicle
  //static const gApiLuvParkPostGetVehicleBrand = '/ords/$luvApi/ps/vb';
  static const gApiLuvParkGetVehicleBrand =
      '/ords/$parkSpaceApi/base/vehiclebrands';
  //Track location to reserve
  static const gApiLuvParkGetResLoc = '/ords/$parkSpaceApi/park/chkpsr';
  //Change Pass
  static const gApiLuvParkPostForgetPassNotVerified =
      '/ords/$luvApi/auth/rpsf/';

  //Add vehicle
  static const gApiLuvParkAddVehicle = '/ords/$luvApi/fav/addVehicle';
  //Delete vehicle\
  static const gApiLuvParkDeleteVehicle = '/ords/$luvApi/fav/delVehicle';

  //Get Parkspace app notice
  static const gApiLuvParkGetNotice = '/ords/$parkSpaceApi/notify/pbm/';

  //Rating Question
  static const gApiLuvParkGetRatingQuestions =
      '/ords/$parkSpaceApi/rating/questions/';
  //Check direct in reservation
  static const gApiLuvParkPutChkIn = '/ords/$parkSpaceApi/park/check_in/';
  // Check in Luvpay
  static const gApiLuvParkPutLPChkIn = '/ords/$luvApi/ps/check_in';
  //Compute Distance
  static const gApiLuvParkGetComputeDistance = '/ords/$parkSpaceApi/conf/psrc/';
//Verify User
  static const gApiLuvParkGetAcctStat = '/ords/$luvApi/user/verify';
  //Rate Us
  static const gApiLuvParkPostRating = '/ords/$luvApi/user/uxr';

  //dd vehicle types
  static const gApiLuvParkDDVehicleTypes =
      '/ords/$parkSpaceApi/park/dd_vehicletypes';
  //Changed to zvt
  static const gApiLuvParkDDVehicleTypes2 =
      '/ords/$parkSpaceApi/zone/vehicleTypes';

  //Sharing Location API's
  static const gApiLuvParkPostShareLoc = '/ords/$luvApi/geo/gpsShare';
  //GETSHARE
  ///Get pending  user in map share

  //Invite friend
  static const gApiLuvParkPutShareLoc = '/ords/$luvApi/geo/gpsShare';

  static const gApiLuvParkPutAcceptShareLoc = '/ords/$luvApi/geo/acceptShare';
  //End Share Location
  static const gApiLuvParkPutCloseShareLoc = '/ords/$luvApi/geo/closeShare';
  //Get active sharing
  static const gApiLuvParkGetActiveShareLoc = '/ords/$luvApi/geo/activeShare';

  // Invite map
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
  //Faqs answer
  static const gAPISubFolderFaqAnswer = '/ords/$parkSpaceApi/faqs/ans';

  //POST mobile_no DELETE
  static const gApiLuvPayPostDeleteAccount = '/ords/$luvApi/user/del';

  //Cancel Auto Extend  POSt  parameter: reservation_id
  // static const gApiCancelAutoExtend = '/ords/$parkSpaceApi/pm/cancelAutoExtend';
  //GET amenities by park_area
  static const gApiSubFolderGetAmenities =
      '/ords/$parkSpaceApi/zone/parkingAmenities';
  //Get all amenities
  static const gApiSubFolderGetAllAmenities =
      '/ords/$parkSpaceApi/rf/amenities';
  static const gApiSubFolderGetAverage =
      '/ords/$luvApi/feedback/getAverageRatingOnBooking';

  //NEW BOOKING API added august 19
  static const gApiBooking = '/ords/$luvApi/token/luvpark/booking';
  static const gApiPostSelfCheckIn =
      '/ords/$parkSpaceApi/pm/checkInAdvancedParking';
  //Delete advance parking
  static const gApiPostCancelParking =
      '/ords/$parkSpaceApi/pm/cancelAdvancedParking';
  //  extendPost param reservation_id, no_hours
  static const gApiExtendParking =
      '/ords/$parkSpaceApi/pm/extendAdvancedParking';
  //Cancel Auto Extend  POSt  parameter: reservation_id
  static const gApiCancelAutoExtend = '/ords/$parkSpaceApi/pm/cancelAutoExtend';

  //REMOVED API
  // //Reserve payment key
  // static const gApiLuvParkGetResPayKey =
  //     '/ords/$luvApi/base/paymentkey'; ////  removed

// //Reserve API with auto extend parameter
//   static const gApiSubFolderPostReserveParking =
//       '/ords/$parkSpaceApi/park/reserve'; //removed
// //Reservation pay
//   static const gApiSubFolderPostReservePay =
//       '/ords/$luvApi/ps/payres'; //removed
//   //getComputation
//   static const gApiSubFolderPostReserveCalc =
//       '/ords/$parkSpaceApi/park/calcfee'; //removed
}
