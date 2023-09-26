import 'package:dio/dio.dart';
import 'package:flutter_stream/models/api_model.dart';

Future<List<Products>> fetchProducts({int limit = 10, int skip = 0}) async {
  var res =
      await Dio().get('https://dummyjson.com/products?limit=$limit&skip=$skip');
  if (res.statusCode == 200) {
    var data = res.data;
    return [Products.fromJson(data)];
  }
  return [];
}
