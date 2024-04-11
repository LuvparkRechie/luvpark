// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirebaseService {
//   static Future<void> updateDocumentData(
//       String documentId, Map<String, dynamic> updatedData) async {
//     try {
//       // Create a reference to the document using its ID
//       DocumentReference documentReference = FirebaseFirestore.instance
//           .collection('live_tracking')
//           .doc(documentId);

//       // Update the document data
//       await documentReference.update(updatedData);

//       print("Document updated successfully");
//     } catch (e) {
//       print("Error updating document: $e");
//     }
//   }

//   static Stream<List<SharingData>> fetchData() {
//     return FirebaseFirestore.instance
//         .collection('live_tracking')
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => SharingData.fromMap(doc.data()))
//           .toList();
//     });
//   }
// }

// class SharingData {
//   String lat;
//   String long;
//   String from;
//   String to;
//   String isAccepted;

//   // Constructor
//   SharingData(
//       {required this.lat,
//       required this.long,
//       required this.from,
//       required this.isAccepted,
//       required this.to});

//   // Factory method to create a User instance from a map
//   factory SharingData.fromMap(Map<String, dynamic> map) {
//     return SharingData(
//       lat: map['lat'] ?? '',
//       long: map['long'] ?? '',
//       from: map['from'] ?? '',
//       to: map['to'] ?? '',
//       isAccepted: map['to'] ?? '',
//     );
//   }
// }
