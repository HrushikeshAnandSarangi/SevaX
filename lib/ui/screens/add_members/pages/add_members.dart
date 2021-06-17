// import 'dart:collection';

// import 'package:flutter/material.dart';
// import 'package:sevaexchange/internationalization/app_localization.dart';
// import 'package:sevaexchange/models/user_model.dart';
// import 'package:sevaexchange/ui/screens/add_members/bloc/add_members_bloc.dart';
// import 'package:sevaexchange/ui/screens/add_members/widgets/add_member_card.dart';

// class AddMembers extends StatefulWidget {
//   static Route<dynamic> route(
//       {String communityId,
//       String timebankId,
//       HashSet<String> selectedMembers}) {
//     return MaterialPageRoute(
//       builder: (BuildContext context) => AddMembers(
//         communityId: communityId,
//         timebankId: timebankId,
//         selectedMembers: selectedMembers,
//       ),
//     );
//   }

//   final String communityId;
//   final String timebankId;
//   final HashSet<String> selectedMembers;

//   const AddMembers(
//       {Key key, this.communityId, this.timebankId, this.selectedMembers})
//       : super(key: key);
//   @override
//   _AddMembersState createState() => _AddMembersState();
// }

// class _AddMembersState extends State<AddMembers> {
//   final AddMembersBloc _bloc = AddMembersBloc();

//   @override
//   void initState() {
//     _bloc.selectedMembers = widget.selectedMembers ?? HashSet<String>();
//     if (widget.timebankId != null) {
//       _bloc.getCommunityMembersExcludingTimebankMembers(
//           widget.communityId, widget.timebankId);
//     } else {
//       _bloc.getCommunityMembers(widget.communityId);
//     }
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _bloc.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context).translate('members','select_volunteers'),
//           style: TextStyle(fontSize: 18),
//         ),
//         elevation: 0,
//         actions: <Widget>[
//           CustomTextButton(
//             child: Text(
//               AppLocalizations.of(context).translate('members','save'),
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             onPressed: () {
//               if (widget.timebankId != null)
//                 _bloc.addMemberToTimebank(
//                   widget.communityId,
//                   widget.timebankId,
//                 );
//               Navigator.of(context).pop(_bloc.selectedMembers);
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<List<UserModel>>(
//         stream: _bloc.members,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           if (snapshot.data == null || snapshot.data.isEmpty) {
//             return Center(
//               child: Text(AppLocalizations.of(context).translate('members','no_members_toadd')),
//             );
//           }
//           return ListView.builder(
//             itemCount: snapshot.data.length,
//             itemBuilder: (context, index) {
//               UserModel user = snapshot.data[index];
//               return AddMemberCard(
//                 photoUrl: user.photoURL,
//                 fullName: user.fullname,
//                 userId: user.sevaUserID,
//                 selectedMembers: _bloc.selectedMembers,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
