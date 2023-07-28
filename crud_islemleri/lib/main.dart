import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/posts_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  
  Widget build(BuildContext context) {
    
    return  MaterialApp(
      title: 'kitap app',
      routes: {
        
        '/postscreen': (context) => PostScreen(),
      },
      debugShowCheckedModeBanner: false,
      home: PostScreen(),
    );
  }
}