//Definindo a classe restaurante, representando as suas informações

class Restaurante {
  final String nome;
  final String descricao;
  final String urlImagem;
  final List<String> imagensAdicionais;
  final String contato;
  final String instagram;
  final String localizacao;
  final List<Map<String, dynamic>> avaliacoes;

  Restaurante({
    required this.nome,
    required this.descricao,
    required this.urlImagem,
    required this.imagensAdicionais,
    required this.contato,
    required this.instagram,
    required this.localizacao,
    required this.avaliacoes,
  });

  //Método para criar uma instância a partir do JSON

  factory Restaurante.fromJson(Map<String, dynamic> json) {
    return Restaurante(
      nome: json['nome'],
      descricao: json['descricao'],
      urlImagem: json['imagemUrl'],
      imagensAdicionais: List<String>.from(json['imagensAdicionais']),
      contato: json['contato'],
      instagram: json['instagram'],
      localizacao: json['localizacao'],
      avaliacoes: List<Map<String, dynamic>>.from(json['avaliacoes'] ?? []),
    );
  }
}
