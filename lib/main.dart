import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quick_notes_app/screens/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  //Setting up the supabase
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env["Supabase_Project_URL"] ?? 'Missing URL',
    anonKey: dotenv.env["Supabase_Project_API_KEY"] ?? 'missing API Key',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}
