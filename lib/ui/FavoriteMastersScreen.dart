import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:style_app/model/MasterShortData.dart';
import 'package:style_app/service/MastersRepository.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

import 'MasterProfileScreen.dart';

// class Masters extends StatefulWidget {
//   const Masters();
//
//   @override
//   State<StatefulWidget> createState() => MastersState();
//
// }
//
// class MastersState extends State<Masters> {
//
//   @override
//   Widget build(BuildContext context) {
//     var favorites = [];
// //    MasterService().findFavoritesShort();
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         Container(
//           height: Global.blockY * 4,
//           child: Text("Избранные мастера", style: titleStyle),
//         ).marginW(
//             left: Global.blockX * 5,
//             top: Global.blockY * 2,
//             right: Global.blockX * 5,
//             bottom: Global.blockY),
//         Expanded(
//           child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: favorites.length,
//               itemBuilder: (context, index) {
//                 return MasterPreview(favorites[index]).marginW(top: Global.blockY * (index == 0 ? 2 : 0));
//               }
//           ),
//         )
//       ],
//     ).background(Colors.white);
//   }
// }
//
// class MasterPreview extends StatelessWidget {
//   final ProfileShortData _masterData;
//   MasterPreview(this._masterData);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => MasterProfile(MastersRepository().findById(_masterData.id))),
//         );
//       },
//       child: Container(
//         width: Global.blockX * 80,
//         margin: EdgeInsets.only(left: Global.blockX * 5, right: Global.blockX * 5, bottom: Global.blockY * 1.5),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 spreadRadius: 2,
//                 blurRadius: 15,
//                 offset: Offset(0, 1))
//           ],
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: ListTile(
//             leading: Container(
//               width: Global.blockX * 15,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(Global.blockX * 50),
//               ),
//                 child: Text("${_masterData.name[0]}${_masterData.surname[0]}", style: titleBigBlueStyle).center()
//             ),
//             title: Text("${_masterData.name} ${_masterData.surname}", style: previewNameStyle),
//             subtitle: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 Text("${_masterData.averageRating.toStringAsFixed(1)}", style: previewRateStyle),
//                 RatingBar(
//                   itemSize: Global.blockY * 2,
//                   ignoreGestures: true,
//                   initialRating: _masterData.averageRating,
//                   minRating: 0,
//                   direction: Axis.horizontal,
//                   allowHalfRating: true,
//                   itemCount: 5,
//                   itemBuilder: (context, _) => Icon(
//                     Icons.star,
//                     color: Colors.blueAccent,
//                   ),
//                   onRatingUpdate: (rating) {
//                     print(rating);
//                   },
//                 )
//               ],
//             )
//         ),
//       ),
//     );
//   }
// }