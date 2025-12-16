import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/game.dart';
import '../models/user_vote.dart';
import '../repositories/category_game_repository.dart';
import '../repositories/game_repository.dart';
import '../repositories/user_vote_repository.dart';

class CategoryVotingScreen extends StatefulWidget {
  final User? user;
  final Category category;

  const CategoryVotingScreen({Key? key, this.user, required this.category})
    : super(key: key);

  @override
  State<CategoryVotingScreen> createState() => _CategoryVotingScreenState();
}

class _CategoryVotingScreenState extends State<CategoryVotingScreen> {
  final CategoryGameRepository _categoryGameRepository =
      CategoryGameRepository();
  final GameRepository _gameRepository = GameRepository();
  final UserVoteRepository _userVoteRepository = UserVoteRepository();

  List<Game> _categoryGames = [];
  Map<int, int> _voteCounts = {};
  UserVote? _userCurrentVote;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categoryGames = await _categoryGameRepository.getCatGames();
      final gameIds = categoryGames
          .where((cg) => cg.categoryId == widget.category.id)
          .map((cg) => cg.gameId)
          .toList();

      List<Game> games = [];
      for (var gameId in gameIds) {
        if (gameId != null) {
          final gameList = await _gameRepository.searchGamesById(gameId);
          if (gameList.isNotEmpty) {
            games.add(gameList.first);
          }
        }
      }

      // Calcular contagem de votos
      final allVotes = await _userVoteRepository.getAll();
      final categoryVotes = allVotes.where(
        (v) => v.categoryId == widget.category.id,
      );

      Map<int, int> counts = {};
      for (var vote in categoryVotes) {
        counts[vote.voteGameId] = (counts[vote.voteGameId] ?? 0) + 1;
      }

      // Buscar voto atual do usuário
      UserVote? currentVote;
      if (widget.user != null) {
        currentVote = await _userVoteRepository.getByUserAndCategory(
          widget.user!.id!,
          widget.category.id!,
        );
      }

      setState(() {
        _categoryGames = games;
        _voteCounts = counts;
        _userCurrentVote = currentVote;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao carregar dados: $e');
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

  Future<void> _vote(Game game) async {
    if (widget.user == null) {
      _showError('Você precisa estar logado para votar');
      return;
    }

    try {
      if (_userCurrentVote != null) {
        // Atualizar voto existente
        final updatedVote = UserVote(
          id: _userCurrentVote!.id,
          userId: widget.user!.id!,
          categoryId: widget.category.id!,
          voteGameId: game.id!,
        );
        await _userVoteRepository.update(updatedVote);
        _showSuccess('Voto alterado com sucesso!');
      } else {
        // Criar novo voto
        final newVote = UserVote(
          userId: widget.user!.id!,
          categoryId: widget.category.id!,
          voteGameId: game.id!,
        );
        await _userVoteRepository.insert(newVote);
        _showSuccess('Voto registrado com sucesso!');
      }
      _loadData();
    } catch (e) {
      _showError('Erro ao registrar voto: $e');
    }
  }

  Future<void> _removeVote() async {
    if (_userCurrentVote == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar'),
        content: Text('Deseja realmente remover seu voto desta categoria?'),
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
        await _userVoteRepository.delete(_userCurrentVote!.id!);
        _showSuccess('Voto removido com sucesso!');
        _loadData();
      } catch (e) {
        _showError('Erro ao remover voto: $e');
      }
    }
  }

  List<MapEntry<Game, int>> _getRanking() {
    final ranking = _categoryGames.map((game) {
      final votes = _voteCounts[game.id] ?? 0;
      return MapEntry(game, votes);
    }).toList();

    ranking.sort((a, b) => b.value.compareTo(a.value));
    return ranking;
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = widget.user != null;
    final canVote = isLoggedIn && widget.user!.role == 1;
    final ranking = _getRanking();

    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.category.title, style: TextStyle(fontSize: 18)),
            if (_userCurrentVote != null)
              Text(
                'Você já votou',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
        actions: [
          if (_userCurrentVote != null)
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: _removeVote,
              tooltip: 'Remover voto',
            ),
        ],
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
            : _categoryGames.isEmpty
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
                      'Nenhum jogo nesta categoria',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Card(
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.description,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Encerramento: ${widget.category.date}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            if (!canVote && !isLoggedIn)
                              Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Faça login para votar',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Ranking Section
                    Text(
                      '🏆 Ranking',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Top 3
                    if (ranking.isNotEmpty)
                      ...ranking.take(3).toList().asMap().entries.map((entry) {
                        final position = entry.key + 1;
                        final gameEntry = entry.value;
                        final game = gameEntry.key;
                        final votes = gameEntry.value;
                        final isUserVote =
                            _userCurrentVote?.voteGameId == game.id;

                        Color medalColor = Colors.grey;
                        if (position == 1) medalColor = Colors.amber;
                        if (position == 2) medalColor = Colors.grey.shade400;
                        if (position == 3) medalColor = Colors.brown.shade400;

                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          elevation: position <= 3 ? 8 : 2,
                          color: isUserVote
                              ? Colors.green.shade50
                              : Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: medalColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$position°',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              game.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          if (isUserVote)
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        game.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.how_to_vote,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '$votes voto${votes != 1 ? 's' : ''}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (canVote)
                                  ElevatedButton(
                                    onPressed: () => _vote(game),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isUserVote
                                          ? Colors.grey
                                          : Colors.amber,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: Text(
                                      isUserVote ? 'Votado' : 'Votar',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),

                    // Outros jogos
                    if (ranking.length > 3) ...[
                      SizedBox(height: 24),
                      Text(
                        'Outros Jogos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...ranking.skip(3).map((entry) {
                        final game = entry.key;
                        final votes = entry.value;
                        final isUserVote =
                            _userCurrentVote?.voteGameId == game.id;

                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          color: isUserVote
                              ? Colors.green.shade50
                              : Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade700,
                              child: Icon(
                                Icons.videogame_asset,
                                color: Colors.white,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(game.name)),
                                if (isUserVote)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '$votes voto${votes != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: canVote
                                ? ElevatedButton(
                                    onPressed: () => _vote(game),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isUserVote
                                          ? Colors.grey
                                          : Colors.amber,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: Text(
                                      isUserVote ? 'Votado' : 'Votar',
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
