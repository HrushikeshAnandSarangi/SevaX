// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:flutter/material.dart';
// import 'package:sevaexchange/models/user_model.dart';
// import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';

// import 'package:sevaexchange/utils/app_config.dart';
// import 'package:sevaexchange/views/core.dart';
// import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
// import 'package:sevaexchange/views/onboarding/bio_page.dart';

// Future<void> customRouter({BuildContext context, UserModel user}) async {
//   print("handling route");
//   if (!user.acceptedEULA) {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (context) => EulaPage(user: user),
//       ),
//     );
//     return;
//   }
//   if (!(AppConfig.prefs.getBool(AppConfig.skip_skill) ?? false) &&
//       user.skills == null) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => SkillsPage(user: user),
//       ),
//     );
//     return;
//   }
//   if (!(AppConfig.prefs.getBool(AppConfig.skip_interest) ?? false) &&
//       user.interests == null) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => InterestPage(user: user),
//       ),
//     );
//     return;
//   }
//   if (user.bio == null &&
//       !(AppConfig.prefs.getBool(AppConfig.skip_bio) ?? false)) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => BioPage(user: user),
//       ),
//     );
//     return;
//   }

//   if (user.communities == null || user.communities.isEmpty) {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (context) => SevaCore(
//           loggedInUser: user,
//           child: FindCommunitiesView(
//             keepOnBackPress: false,
//             loggedInUser: user,
//             showBackBtn: false,
//           ),
//         ),
//       ),
//     );
//     return;
//   } else if (user.communities.length > 0 &&
//       (user.currentCommunity.isEmpty ||
//           user.currentCommunity == null ||
//           user.currentCommunity == " ")) {
//     await CollectionRef.users.doc(user.email).update({
//       'currentCommunity': user.communities[0],
//     }).then((_) {
//       UserModel newUser = user;
//       newUser.currentCommunity = user.communities[0];
//       customRouter(context: context, user: newUser);
//     });
//     return;
//   } else {
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(
//         builder: (context) => SevaCore(
//           loggedInUser: user,
//           child: HomePageRouter(),
//         ),
//       ),
//       (Route<dynamic> route) => false,
//     );
//     return;
//   }
// }
