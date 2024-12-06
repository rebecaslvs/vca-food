//Importações necessárias para o projeto
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vca_food/telas/tela_inicial.dart';

//Função principal do aplicativo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializando o Firebase
  runApp(const VCAFoodApp()); //
}

// Widget raiz do aplicativo
class VCAFoodApp extends StatelessWidget {
  const VCAFoodApp({Key? key}) : super(key: key);

//Personalizando
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VCA Food',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 117, 132, 233)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
      ),
      home: const TelaInicial(),
    );
  }
}
