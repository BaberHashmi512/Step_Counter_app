import 'package:client_practice_app/container_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var status = await Permission.location.request();

  if (status.isGranted) {
    runApp(const MyApp());
  } else {
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 231, 237, 222)),
          useMaterial3: true,
        ),
        home: const ContainerPage());
  }
}
