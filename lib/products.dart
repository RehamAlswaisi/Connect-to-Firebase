import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class Products with ChangeNotifier {
  List<Product> productsList = [];
  String? authToken;
  //Products(this.authToken, this.productsList);

  getData(String authTok, List<Product> products) {
    authToken = authTok;
    productsList = products;
    notifyListeners();
  }

// لجلب البيانات
  Future<void> fetchData() async {
    print('????????????????? $authToken');
    final url =
        'https://flutter-app-1e44d-default-rtdb.firebaseio.com/product/.json?auth=$authToken';
    try {
      final http.Response res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      extractedData.forEach((prodId, prodData) {
        final prodIndex =
            productsList.indexWhere((element) => element.id == prodId);
        if (prodIndex >= 0) {
          productsList[prodIndex] = Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
          );
        } else {
          productsList.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
          ));
        }
      });

      notifyListeners();
    } catch (error) {
      print('??????????????????>>>>>>>>>>>>> $error');
      throw error;
    }
  }

  Future<void> updateData(String id) async {
    final url =
        'https://flutter-app-1e44d-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken';
    final prodIndex = productsList.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      // تحديث البيانات على قاعدة البيانات فقط
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': 'new title',
            'description': 'new description',
            'price': 199.8,
            'imageUrl':
                'https://images.unsplash.com/photo-1604085572504-a392ddf0d86a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8b3JhbmdlJTIwZmxvd2VyfGVufDB8fDB8fA%3D%3D&w=1000&q=80'
          }));
      // التحديث على البيانات على التطبيق
      productsList[prodIndex] = Product(
          id: id,
          title: 'new title',
          description: 'new description',
          price: 199.8,
          imageUrl:
              'https://images.unsplash.com/photo-1604085572504-a392ddf0d86a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8b3JhbmdlJTIwZmxvd2VyfGVufDB8fDB8fA%3D%3D&w=1000&q=80');

      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> add(
      {required String id,
      required String title,
      required String description,
      required double price,
      required String imageUrl}) async {
    // لخزن البيانات في الداتا بيز
    final url =
        'https://flutter-app-1e44d-default-rtdb.firebaseio.com/product.json?auth=$authToken';
    try {
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({
            'id': id,
            'title': title,
            'description': description,
            'price': price,
            'imageUrl': imageUrl
          }));

      print(json.decode(res.body));

      productsList.add(Product(
          id: json.decode(res.body)['name'],
          title: title,
          description: description,
          price: price,
          imageUrl: imageUrl));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> delete(String id) async {
    final url =
        'https://flutter-app-1e44d-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken';
    final prodIndex = productsList.indexWhere((element) => element.id == id);

    var prodItem = productsList[prodIndex];
    productsList.removeAt(prodIndex);
    notifyListeners();

    var res = await http.delete(Uri.parse(url));
    if (res.statusCode >= 400) {
      productsList.insert(prodIndex, prodItem);
      notifyListeners();
      print("Could not deleted item");
    } else {
      //productsList.removeAt(prodIndex);
      Product? prodItem;
      print('Item Deleted');
    }
    //prodItem = productsList[prodIndex];
    //print('Item Deleted');
  }
}
