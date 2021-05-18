import 'dart:collection';

import 'package:store/common/constants/model.dart';
import 'package:store/data_layer/netclient.dart';

class ConstantsRepository {
  final Net _net;

  ConstantsRepository(this._net);

  Future<ConstantData> fetch() async {
    return   ConstantData(227, 30, 36, 250, 20, 29, 100);
   /* return Future<ConstantData>.delayed(Duration(seconds: 1), () {

    });*/
    /* var res = await _net.post(EndPoint.GET_STRUCTURE);

    if (res is SuccessResponse) {
      List<Map<String, dynamic>> list =
      new List<Map<String, dynamic>>.from(res.data);

      List<StructPet> pets = list.map((p) => StructPet.fromJson(p)).toList();
      pets.forEach((pet) {
        _cache.putIfAbsent(pet.id, () => pet);
      });

      return pets;
    } else {
      return [];
    }*/
  }

// StructPet getPet(int id) {
//   return fetch().firstWhere((p) => p.id == id);
// }
//
// StructCategory getCat(int catId) {
//   StructCategory result;
//   fetch().forEach((pet) {
//     if (pet.categories.map((cat) => cat.id).contains(catId)) {
//       result = pet.categories.firstWhere((cat) => cat.id == catId);
//     }
//   });
//   return result;
// }
//
// List<StructPet> fetch() {
//   if (_cache.isNotEmpty) {
//     return _cache.values.toList();
//   } else {
//     throw Exception('structure cache is not initialized');
//   }
// }
}
