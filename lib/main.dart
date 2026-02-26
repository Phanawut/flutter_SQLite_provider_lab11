// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/state/event_provider.dart'; // <-- เช็คว่า import ถูกไฟล์ไหม
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // จุดสำคัญ: ต้องมี MultiProvider ครอบ MaterialApp ไว้
    return MultiProvider(
      providers: [
        // ต้องประกาศ EventProvider ตรงนี้ เพื่อให้ทุกหน้าเรียกใช้ได้
        ChangeNotifierProvider(create: (_) => EventProvider()), 
      ],
      child: MaterialApp(
        title: 'Event App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}