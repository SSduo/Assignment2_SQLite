import 'package:flutter/material.dart';
import 'screens/product_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductManager(),
      debugShowCheckedModeBanner: false,
    );
  }
}