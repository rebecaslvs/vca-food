
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/restaurante.dart';
import '../widgets/cartao_restaurante.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({Key? key}) : super(key: key);

  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  List<Restaurante> restaurantes = [];
  int quantidadeVisivel = 4;
  bool carregando = false;
  final ScrollController _controladorScroll = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _carregarRestaurantes();
    _controladorScroll.addListener(_aoRolar);
  }

  @override
  void dispose() {
    _controladorScroll.dispose();
    super.dispose();
  }

  Future<void> _carregarRestaurantes() async {
    try {
      final String resposta =
          await rootBundle.loadString('assets/restaurantes.json');
      final List<dynamic> dados = json.decode(resposta);

      setState(() {
        restaurantes = dados.map<Restaurante>((jsonRestaurante) {
          return Restaurante.fromJson(jsonRestaurante);
        }).toList();
      });
    } catch (e) {
      print("Erro ao carregar restaurantes: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar restaurantes. Tente novamente.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _aoRolar() {
    if (_controladorScroll.position.pixels ==
        _controladorScroll.position.maxScrollExtent) {
      if (quantidadeVisivel < restaurantes.length && !carregando) {
        setState(() {
          carregando = true;
        });

        Timer(const Duration(milliseconds: 500), () {
          setState(() {
            quantidadeVisivel += 2;
            carregando = false;
          });
        });
      }
    }
  }

  Future<void> _fazerLogin() async {
    try {
      final GoogleSignInAccount? usuarioGoogle = await _googleSignIn.signIn();
      if (usuarioGoogle == null) {
        return;
      }

      final GoogleSignInAuthentication authGoogle =
          await usuarioGoogle.authentication;
      final OAuthCredential credenciais = GoogleAuthProvider.credential(
        accessToken: authGoogle.accessToken,
        idToken: authGoogle.idToken,
      );

      await _auth.signInWithCredential(credenciais);

      // Feedback de sucesso com SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Erro ao realizar login: $e");
      // Feedback de erro com SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao realizar login. Tente novamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _fazerLogout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            const Text(
              'VCA Food',
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(), // Isso alinha o título à esquerda e o botão à direita
            StreamBuilder<User?>(
              stream: _auth.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  return TextButton(
                    onPressed: _fazerLogout,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Logout'),
                  );
                } else {
                  return TextButton(
                    onPressed: _fazerLogin,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Login'),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: restaurantes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      controller: _controladorScroll,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.55,
                      ),
                      itemCount: quantidadeVisivel,
                      itemBuilder: (context, index) {
                        return CartaoRestaurante(
                            restaurante: restaurantes[index]);
                      },
                    ),
                  ),
                ),
                if (carregando)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}
