import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';
import 'category_voting_screen.dart';
import 'games_search_screen.dart';
import 'welcome_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  final User? user;

  const UserDashboardScreen({Key? key, this.user}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final CategoryRepository _categoryRepository = CategoryRepository();

  List<Category> _activeCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveCategories();
  }

  Future<void> _loadActiveCategories() async {
    setState(() => _isLoading = true);
    try {
      final allCategories = await _categoryRepository.getCategories();
      final now = DateTime.now();

      final active = allCategories.where((category) {
        try {
          final categoryDate = DateTime.parse(category.date);
          return categoryDate.isAfter(now) ||
              (categoryDate.year == now.year &&
                  categoryDate.month == now.month &&
                  categoryDate.day == now.day);
        } catch (e) {
          return false;
        }
      }).toList();

      setState(() {
        _activeCategories = active;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao carregar categorias: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToVoting(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CategoryVotingScreen(user: widget.user, category: category),
      ),
    ).then((_) => _loadActiveCategories());
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar'),
        content: Text('Deseja sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (route) => false,
              );
            },
            child: Text('Sair'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = widget.user != null;
    final isRegularUser = isLoggedIn && widget.user!.role == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('The Game Awards'),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: !isLoggedIn
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  );
                },
                tooltip: 'Voltar',
              )
            : null,
        actions: [
          if (isLoggedIn)
            PopupMenuButton<String>(
              icon: Icon(Icons.account_circle),
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user!.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.user!.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Sair'),
                    ],
                  ),
                ),
              ],
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
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                    SizedBox(height: 16),
                    Text(
                      isLoggedIn
                          ? 'Bem-vindo, ${widget.user!.name}!'
                          : 'Bem-vindo!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      isRegularUser
                          ? 'Vote nas suas categorias favoritas'
                          : 'Navegue pelas categorias disponíveis',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    if (!isLoggedIn)
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Faça login para votar nas categorias',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    // Botão de Pesquisa
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GamesSearchScreen(user: widget.user),
                            ),
                          );
                        },
                        icon: Icon(Icons.search),
                        label: Text('Pesquisar Jogos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      )
                    : _activeCategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma categoria ativa no momento',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Aguarde novas votações',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadActiveCategories,
                        color: Colors.amber,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _activeCategories.length,
                          itemBuilder: (context, index) {
                            final category = _activeCategories[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _navigateToVoting(category),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.emoji_events,
                                            color: Colors.amber,
                                            size: 28,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              category.title,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        category.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Encerra em: ${category.date}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Spacer(),
                                          if (isRegularUser)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.how_to_vote,
                                                    size: 16,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Votar',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
