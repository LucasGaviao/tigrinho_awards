import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/game.dart';
import '../models/category_game.dart';
import '../repositories/category_game_repository.dart';
import '../repositories/game_repository.dart';

class CategoryGamesScreen extends StatefulWidget {
  final User user;
  final Category category;

  const CategoryGamesScreen({
    Key? key,
    required this.user,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryGamesScreen> createState() => _CategoryGamesScreenState();
}

class _CategoryGamesScreenState extends State<CategoryGamesScreen> {
  final CategoryGameRepository _categoryGameRepository =
      CategoryGameRepository();
  final GameRepository _gameRepository = GameRepository();

  List<Game> _associatedGames = [];
  List<Game> _allGames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final allGames = await _gameRepository.getAllGames();
      final categoryGames = await _categoryGameRepository.getCatGames();

      final associatedGameIds = categoryGames
          .where((cg) => cg.categoryId == widget.category.id)
          .map((cg) => cg.gameId)
          .toSet();

      final associated = allGames
          .where((g) => associatedGameIds.contains(g.id))
          .toList();

      setState(() {
        _allGames = allGames;
        _associatedGames = associated;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao carregar jogos: $e');
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

  void _showAddGamesDialog() {
    final associatedGameIds = _associatedGames.map((g) => g.id).toSet();
    final availableGames = _allGames
        .where((g) => !associatedGameIds.contains(g.id))
        .toList();

    if (availableGames.isEmpty) {
      _showError('Todos os jogos já estão associados a esta categoria');
      return;
    }

    List<int> selectedGameIds = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Adicionar Jogos'),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 400),
            child: ListView(
              shrinkWrap: true,
              children: availableGames.map((game) {
                return CheckboxListTile(
                  title: Text(game.name),
                  subtitle: Text(
                    game.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  value: selectedGameIds.contains(game.id),
                  onChanged: (checked) {
                    setDialogState(() {
                      if (checked == true) {
                        selectedGameIds.add(game.id!);
                      } else {
                        selectedGameIds.remove(game.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedGameIds.isEmpty
                  ? null
                  : () async {
                      try {
                        for (var gameId in selectedGameIds) {
                          await _categoryGameRepository.createCatGame(
                            CategoryGame(
                              categoryId: widget.category.id!,
                              gameId: gameId,
                            ),
                          );
                        }
                        _showSuccess(
                          '${selectedGameIds.length} jogo(s) adicionado(s) com sucesso!',
                        );
                        Navigator.pop(context);
                        _loadData();
                      } catch (e) {
                        _showError('Erro ao adicionar jogos: $e');
                      }
                    },
              child: Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeGame(Game game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Remoção'),
        content: Text('Deseja remover "${game.name}" desta categoria?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final categoryGames = await _categoryGameRepository.getCatGames();
        final categoryGame = categoryGames.firstWhere(
          (cg) => cg.categoryId == widget.category.id && cg.gameId == game.id,
        );

        await _categoryGameRepository.deleteCatGame(categoryGame.id!);
        _showSuccess('Jogo removido com sucesso!');
        _loadData();
      } catch (e) {
        _showError('Erro ao remover jogo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jogos da Categoria', style: TextStyle(fontSize: 18)),
            Text(
              widget.category.title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
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
            : Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.black26,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jogos Associados: ${_associatedGames.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddGamesDialog,
                          icon: Icon(Icons.add, color: Colors.black),
                          label: Text(
                            'Adicionar',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _associatedGames.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videogame_asset_off,
                                  size: 64,
                                  color: Colors.white54,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhum jogo associado',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Clique em "Adicionar" para associar jogos',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _associatedGames.length,
                            itemBuilder: (context, index) {
                              final game = _associatedGames[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.purple.shade700,
                                    child: Icon(
                                      Icons.videogame_asset,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    game.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
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
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeGame(game),
                                    tooltip: 'Remover da categoria',
                                  ),
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
