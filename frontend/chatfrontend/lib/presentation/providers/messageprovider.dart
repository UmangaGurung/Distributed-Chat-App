import 'package:flutter_riverpod/legacy.dart';

// class MessageNotifier extends StateNotifier<List<String>>{
//   MessageNotifier() : super ([]);
//
//   void addMessage(String msg){
//     state= [...state, msg];
//   }
// }
//
// final messageProvider=
//     StateNotifierProvider<MessageNotifier, List<String>>((ref){
//       return MessageNotifier();
//     });