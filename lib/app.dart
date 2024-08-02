import 'package:flutter/material.dart';

import 'Views/HomePage/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

theme: ThemeData(
  colorSchemeSeed: Colors.blue,
),
      home: HomePage(),
      routes:{
        // '/detailpage' : (context)=> DetailPage(),
      },
    );
  }
}
