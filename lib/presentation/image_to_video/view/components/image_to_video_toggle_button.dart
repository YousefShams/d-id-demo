// import 'package:d_id_task/shared/styles/app_sizing_values.dart';
// import 'package:flutter/material.dart';
//
// class ImageToVideoToggleButton extends StatelessWidget {
//   final bool? isPlaying;
//   const ImageToVideoToggleButton({Key? key, required this.isPlaying,}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final bgIconColor = isPlaying!=null ? Colors.teal : Colors.grey;
//     return GestureDetector(
//       onTap: isPlaying!=null ? togglePlayingVideo : null,
//       child: Container(
//         alignment: Alignment.center,
//         width: AppValues.toggleButtonSize,
//         height: AppValues.toggleButtonSize,
//         padding: const EdgeInsets.all(AppValues.smallPadding),
//         decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: bgIconColor,
//             border: Border.all(color: bgIconColor[200]!, width: 5)
//         ),
//         child: Visibility(
//           visible: isPlaying==true,
//           replacement: const Icon(Icons.play_arrow_rounded, color: Colors.white,),
//           child: const Icon(Icons.pause, color: Colors.white,),
//         ),
//       ),
//     );
//   }
// }
