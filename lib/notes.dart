//IMPORTANT NOTICE
// 1.Need to clear Authentication().getUserLogin() every logout

//header
// CustomTitle(text: "Header"),
//Sub Header
// CustomParagraph(
//   text: 'Sub Header',
//   color: Colors.black,
//   fontWeight: FontWeight.w500,
// ),
// //Sub Title
// CustomParagraph(
//   text:
//       'Paragraph',
//   fontWeight: FontWeight.normal,
//   color: Colors.black,
// ),

//submit to playstore or appstore notice
//1. Inform sir bernard for version
//2. Change app version to notify user for new update

// Fri, jan 3, 1:40 PM changes
// 1. '/ords/$luvApi/fav/addVehicle' to '/ords/$luvApi/fav/veh' > for get add and delete vehicle
// 2. if zero succeeding rate make it per entry as per sir bernard.

//Changes i made
// API : https://gce81b2a8b40195-gccdb.adb.ap-singapore-1.oraclecloudapps.com/ords/luv/base/userinfo
// 1. Reason: get only important user info for wallet send rather than all data.
// API : https://gce81b2a8b40195-gccdb.adb.ap-singapore-1.oraclecloudapps.com/ords/luv/auth/login
// 2. Reason:  added is_verified column for user login get

// APP secure command
//1. flutter build apk --release --no-tree-shake-icons --obfuscate --split-debug-info=debug_info


// returnPost["user_id"] == 0 &&
//                 returnPost["session_id"] != null &&
//                 returnPost["device_valid"] == 'N'
// I changed the message of this 



// Bernard Durango, [Feb 25, 2025 at 4:00:24 PM]:
// updates on verify_otp API parameter
// 1. change from new_acct = 'Y' to req_type : "NA"
// 2. for forgot password, change password, reset password use req_type : "UP"
// 3. for others use req_type : "SR"


// req_type means "request type"


// Parameters for the Request OTP when

// 1. Forgot Password -- not verified account
//    {"mobile_no": "639661432144", "new_pwd":"Test123"}

// 2. Forgot Password -- verified account
//    {"mobile_no": "639661432144", "secq_no": "3",  "secq_id": "2", "seca": "MISYUBIBI", "new_pwd":"Test123"}

// 3. Change Password -- not verified
//    {"mobile_no": "639661432144", "new_pwd":"Test123", "old_pwd":"Test000"}

// 4. Change Password Request OTP -- verified account
//    {"mobile_no": "639661432144", "secq_no": "3",  "secq_id": "2", "seca": "MISYUBIBI", "new_pwd":"Test123", "old_pwd":"Test000"}


// Parameters for the login PUT API when

// 1. Forgot Password / Change Password
//    {"mobile_no": "639661432144", "new_pwd":"Test123"}

//    if there is otp then
//    {"mobile_no": "639661432144", "new_pwd":"Test123", "otp":"0000"}

// 2. Extend Password validity
//    {"mobile_no": "639661432144", "extend":"Y"}

//    if there is otp then
//    {"mobile_no": "639661432144", "extend":"Y", "otp":"0000"}



// USER CREATION/REGISTRATION
// 1. Enter user info
// 2. submit data - call POST API /wv2/login/
// 3. request otp => /wv2/otp/ POST API 
//        {"mobile_no": "639661432144", "pwd":"Test000"}  
// 4. verify otp => /wv2/otp/PUT
//        {"mobile_no": "639661432144", "otp":"12345", "req_type":"NA"}
// 5. ask user to re-login