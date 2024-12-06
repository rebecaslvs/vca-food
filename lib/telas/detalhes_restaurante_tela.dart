import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/restaurante.dart';

class DetalhesRestauranteTela extends StatelessWidget {
  final Restaurante restaurante;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DetalhesRestauranteTela({Key? key, required this.restaurante})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? usuario = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurante.nome),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem principal
              Image.asset(
                restaurante.urlImagem,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              // Nome do restaurante
              Text(
                restaurante.nome,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Descrição do restaurante
              Text(
                restaurante.descricao,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Lista de imagens adicionais
              const Text(
                'Mais imagens:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurante.imagensAdicionais.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        restaurante.imagensAdicionais[index],
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Informações de contato e localização
              const Text(
                'Informações:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Contato: ${restaurante.contato}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Instagram: ${restaurante.instagram}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Localização: ${restaurante.localizacao}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Avaliações e Comentários
              const Text(
                'Avaliações:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (restaurante.avaliacoes.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: restaurante.avaliacoes.length,
                  itemBuilder: (context, index) {
                    final avaliacao = restaurante.avaliacoes[index];
                    return ListTile(
                      title: Text(avaliacao['usuario'] ?? 'Anônimo'),
                      subtitle: Text(avaliacao['comentario'] ?? ''),
                      trailing: avaliacao['nota'] != null
                          ? Text('${avaliacao['nota']}⭐')
                          : null,
                    );
                  },
                )
              else
                const Text(
                  'Nenhuma avaliação disponível.',
                  style: TextStyle(color: Colors.grey),
                ),
              const SizedBox(height: 16),
              if (usuario != null) ...[
                ElevatedButton(
                  onPressed: () => _adicionarComentario(context),
                  child: const Text('Deixar Comentário'),
                ),
                ElevatedButton(
                  onPressed: () => _avaliarRestaurante(context),
                  child: const Text('Avaliar Restaurante'),
                ),
              ] else
                const Text(
                  'Faça login para deixar comentários ou avaliações.',
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _adicionarComentario(BuildContext context) {
    String textoComentario = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deixar Comentário'),
          content: TextField(
            onChanged: (value) => textoComentario = value,
            decoration:
                const InputDecoration(hintText: 'Digite seu comentário'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (textoComentario.isNotEmpty) {
                  restaurante.avaliacoes.add({
                    'usuario': _auth.currentUser?.email ?? 'Anônimo',
                    'comentario': textoComentario,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _avaliarRestaurante(BuildContext context) {
    int nota = 0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Avaliar Restaurante'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < nota ? Icons.star : Icons.star_border,
                ),
                color: Colors.yellow[700],
                onPressed: () {
                  nota = index + 1;
                },
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nota > 0) {
                  restaurante.avaliacoes.add({
                    'usuario': _auth.currentUser?.email ?? 'Anônimo',
                    'nota': nota,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}
