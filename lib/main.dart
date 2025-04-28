import 'package:flutter/material.dart';
import 'simple_math.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final result = SimpleMath.add(5, 7); // 5 + 7 = 12

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Native .so FFI')),
        body: Center(child: Text('Result from native .so: $result')),
      ),
    );
  }
}
