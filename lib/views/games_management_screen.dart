import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/game.dart';
import '../models/genre.dart';
import '../models/game_genre.dart';
import '../repositories/game_repository.dart';
import '../repositories/genre_repository.dart';
import '../repositories/game_genre_repository.dart';

class GamesManagementScreen extends StatefulWidget {
  final User user;

  const GamesManagementScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<GamesManagementScreen> createState() => _GamesManagementScreenState();
}

class _GamesManagementScreenState extends State<GamesManagementScreen> {
  final GameRepository _gameRepository = GameRepository();
  final GenreRepository _genreRepository = GenreRepository();
  final GameGenreRepository _gameGenreRepository = GameGenreRepository();

  List<Game> _games = [];
  List<Genre> _allGenres = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final games = await _gameRepository.getAllGames();
      final genres = await _genreRepository.getAllGenres();
      setState(() {
        _games = games;
        _allGenres = genres;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao carregar dados: $e');
    }
  }

  Future<List<Genre>> _getGameGenres(int gameId) async {
    try {
      final gameGenres = await _gameGenreRepository.getGameGenres();
      final genreIds = gameGenres
          .where((gg) => gg.gameId == gameId)
          .map((gg) => gg.genreId)
          .toList();

      return _allGenres.where((g) => genreIds.contains(g.id)).toList();
    } catch (e) {
      return [];
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showGameDialog({Game? game}) async {
    final nameController = TextEditingController(text: game?.name ?? '');
    final descriptionController = TextEditingController(
      text: game?.description ?? '',
    );
    final releaseDateController = TextEditingController(
      text: game?.releaseDate ?? '',
    );

    List<int> selectedGenreIds = [];

    if (game != null) {
      final genres = await _getGameGenres(game.id!);
      selectedGenreIds = genres.map((g) => g.id!).toList();
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(game == null ? 'Adicionar Jogo' : 'Editar Jogo'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome do Jogo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: releaseDateController,
                    decoration: InputDecoration(
                      labelText: 'Data de Lançamento',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1970),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        releaseDateController.text =
                            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Gêneros:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  if (_allGenres.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nenhum gênero cadastrado'),
                    )
                  else
                    ..._allGenres.map((genre) {
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(genre.name),
                        value: selectedGenreIds.contains(genre.id),
                        onChanged: (checked) {
                          setDialogState(() {
                            if (checked == true) {
                              selectedGenreIds.add(genre.id!);
                            } else {
                              selectedGenreIds.remove(genre.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  final newGame = Game(
                    id: game?.id,
                    userId: widget.user.id!,
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    releaseDate: releaseDateController.text.trim(),
                  );

                  int gameId;
                  if (game == null) {
                    gameId = await _gameRepository.createGame(newGame);
                    _showSuccess('Jogo adicionado com sucesso!');
                  } else {
                    await _gameRepository.updateGame(newGame);
                    gameId = game.id!;
                    _showSuccess('Jogo atualizado com sucesso!');

                    // Remove associações antigas
                    final oldGameGenres = await _gameGenreRepository
                        .getGameGenres();
                    for (var gg in oldGameGenres.where(
                      (gg) => gg.gameId == gameId,
                    )) {
                      await _gameGenreRepository.deleteGameGenre(
                        gg.gameId,
                        gg.genreId,
                      );
                    }
                  }

                  // Adiciona novas associações de gênero
                  for (var genreId in selectedGenreIds) {
                    await _gameGenreRepository.createGameGenre(
                      GameGenre(gameId: gameId, genreId: genreId),
                    );
                  }

                  Navigator.pop(context);
                  _loadData();
                } catch (e) {
                  _showError('Erro ao salvar jogo: $e');
                }
              },
              child: Text(game == null ? 'Adicionar' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteGame(Game game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o jogo "${game.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Remove associações de gênero primeiro
        final gameGenres = await _gameGenreRepository.getGameGenres();
        for (var gg in gameGenres.where((gg) => gg.gameId == game.id)) {
          await _gameGenreRepository.deleteGameGenre(gg.gameId, gg.genreId);
        }

        await _gameRepository.deleteGame(game.id!);
        _showSuccess('Jogo excluído com sucesso!');
        _loadData();
      } catch (e) {
        _showError('Erro ao excluir jogo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Jogos'),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.deepPurple.shade700,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.amber))
            : _games.isEmpty
            ? Center(
                child: Text(
                  'Nenhum jogo cadastrado',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return FutureBuilder<List<Genre>>(
                    future: _getGameGenres(game.id!),
                    builder: (context, snapshot) {
                      final genres = snapshot.data ?? [];
                      final genresText = genres.map((g) => g.name).join(', ');

                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(
                            game.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(game.description),
                              SizedBox(height: 4),
                              Text(
                                'Lançamento: ${game.releaseDate}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              if (genresText.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Gêneros: $genresText',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showGameDialog(game: game),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteGame(game),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGameDialog(),
        backgroundColor: Colors.amber,
        icon: Icon(Icons.add, color: Colors.black),
        label: Text('Novo Jogo', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
