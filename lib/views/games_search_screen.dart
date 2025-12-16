import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/game.dart';
import '../models/category.dart';
import '../models/genre.dart';
import '../repositories/game_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/category_game_repository.dart';
import '../repositories/genre_repository.dart';
import '../repositories/game_genre_repository.dart';
import '../repositories/user_vote_repository.dart';

class GamesSearchScreen extends StatefulWidget {
  final User? user;

  const GamesSearchScreen({Key? key, this.user}) : super(key: key);

  @override
  State<GamesSearchScreen> createState() => _GamesSearchScreenState();
}

class _GamesSearchScreenState extends State<GamesSearchScreen> {
  final GameRepository _gameRepository = GameRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final CategoryGameRepository _categoryGameRepository =
      CategoryGameRepository();
  final GenreRepository _genreRepository = GenreRepository();
  final GameGenreRepository _gameGenreRepository = GameGenreRepository();
  final UserVoteRepository _userVoteRepository = UserVoteRepository();

  List<Game> _filteredGames = [];
  List<Category> _allCategories = [];
  List<Genre> _allGenres = [];
  bool _isLoading = true;

  Category? _selectedCategory;
  Set<Genre> _selectedGenres = {};
  String _selectedPosition = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _categoryRepository.getCategories();
      final genres = await _genreRepository.getAllGenres();

      setState(() {
        _allCategories = categories;
        _allGenres = genres;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao carregar dados: $e');
    }
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);
    try {
      List<Game> games = [];
      Set<int> gameIds = {};

      if (_selectedCategory != null) {
        // Filtrar por categoria específica
        final categoryGames = await _categoryGameRepository
            .getGamesByCategoryId(_selectedCategory!.id!);

        if (_selectedPosition != 'Todas') {
          // Filtrar por posição (ranking) na categoria específica
          final voteCounts = await _userVoteRepository.getVoteCountsByCategory(
            _selectedCategory!.id!,
          );

          final ranking = categoryGames.map((game) {
            final count = voteCounts[game.id] ?? 0;
            return MapEntry(game, count);
          }).toList()..sort((a, b) => b.value.compareTo(a.value));

          if (_selectedPosition == '1º Lugar' && ranking.isNotEmpty) {
            games = [ranking[0].key];
          } else if (_selectedPosition == '2º Lugar' && ranking.length > 1) {
            games = [ranking[1].key];
          } else if (_selectedPosition == '3º Lugar' && ranking.length > 2) {
            games = [ranking[2].key];
          }
        } else {
          games = categoryGames;
        }
      } else if (_selectedPosition != 'Todas') {
        // Buscar por posição em todas as categorias
        for (var category in _allCategories) {
          final categoryGames = await _categoryGameRepository
              .getGamesByCategoryId(category.id!);
          final voteCounts = await _userVoteRepository.getVoteCountsByCategory(
            category.id!,
          );

          final ranking = categoryGames.map((game) {
            final count = voteCounts[game.id] ?? 0;
            return MapEntry(game, count);
          }).toList()..sort((a, b) => b.value.compareTo(a.value));

          if (_selectedPosition == '1º Lugar' && ranking.isNotEmpty) {
            gameIds.add(ranking[0].key.id!);
          } else if (_selectedPosition == '2º Lugar' && ranking.length > 1) {
            gameIds.add(ranking[1].key.id!);
          } else if (_selectedPosition == '3º Lugar' && ranking.length > 2) {
            gameIds.add(ranking[2].key.id!);
          }
        }

        // Buscar os jogos pelos IDs encontrados
        final allGames = await _gameRepository.getAllGames();
        games = allGames.where((g) => gameIds.contains(g.id)).toList();
      } else {
        // Todos os jogos
        games = await _gameRepository.getAllGames();
      }

      // Filtrar por gênero
      if (_selectedGenres.isNotEmpty) {
        final gameGenres = await _gameGenreRepository.getGameGenres();
        final selectedGenreIds = _selectedGenres.map((g) => g.id).toSet();
        final gameIdsWithGenre = gameGenres
            .where((gg) => selectedGenreIds.contains(gg.genreId))
            .map((gg) => gg.gameId)
            .toSet();

        games = games.where((g) => gameIdsWithGenre.contains(g.id)).toList();
      }

      setState(() {
        _filteredGames = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao aplicar filtros: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      appBar: AppBar(
        title: Text('Pesquisar Jogos'),
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
        child: Column(
          children: [
            // Filtros
            Container(
              color: Colors.white.withOpacity(0.1),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Filtro de Categoria
                  DropdownButtonFormField<Category?>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Categoria de Premiação',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                    dropdownColor: Colors.purple.shade800,
                    style: TextStyle(color: Colors.white),
                    items: [
                      DropdownMenuItem<Category?>(
                        value: null,
                        child: Text(
                          'Todas as categorias',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ..._allCategories.map((category) {
                        return DropdownMenuItem<Category?>(
                          value: category,
                          child: Text(
                            category.title,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      _applyFilters();
                    },
                  ),
                  SizedBox(height: 12),

                  // Filtro de Gênero (seleção múltipla)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gêneros',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allGenres.map((genre) {
                          final isSelected = _selectedGenres.contains(genre);
                          return FilterChip(
                            label: Text(genre.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedGenres.add(genre);
                                } else {
                                  _selectedGenres.remove(genre);
                                }
                              });
                              _applyFilters();
                            },
                            backgroundColor: Colors.deepPurple.shade900
                                .withOpacity(0.5),
                            selectedColor: Colors.deepPurple.shade600,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.purple.shade300
                                  : Colors.deepPurple.shade400,
                              width: isSelected ? 2 : 1,
                            ),
                          );
                        }).toList(),
                      ),
                      if (_selectedGenres.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedGenres.clear();
                              });
                              _applyFilters();
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white70,
                              size: 18,
                            ),
                            label: Text(
                              'Limpar seleção',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Filtro de Posição
                  DropdownButtonFormField<String>(
                    value: _selectedPosition,
                    decoration: InputDecoration(
                      labelText: 'Posição',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                    dropdownColor: Colors.purple.shade800,
                    style: TextStyle(color: Colors.white),
                    items: ['Todas', '1º Lugar', '2º Lugar', '3º Lugar'].map((
                      position,
                    ) {
                      return DropdownMenuItem<String>(
                        value: position,
                        child: Text(
                          position,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPosition = value!;
                      });
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),

            // Resultados
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                  : _filteredGames.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum jogo encontrado',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _filteredGames.length,
                      itemBuilder: (context, index) {
                        final game = _filteredGames[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade900,
                              child: Icon(
                                Icons.videogame_asset,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              game.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Lançamento: ${game.releaseDate}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
