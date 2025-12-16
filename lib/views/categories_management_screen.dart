import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';
import '../repositories/category_game_repository.dart';
import 'category_games_screen.dart';

class CategoriesManagementScreen extends StatefulWidget {
  final User user;

  const CategoriesManagementScreen({Key? key, required this.user})
    : super(key: key);

  @override
  State<CategoriesManagementScreen> createState() =>
      _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState
    extends State<CategoriesManagementScreen> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final CategoryGameRepository _categoryGameRepository =
      CategoryGameRepository();

  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _categoryRepository.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao carregar categorias: $e');
    }
  }

  bool _isCategoryActive(String categoryDate) {
    try {
      final date = DateTime.parse(categoryDate);
      final now = DateTime.now();
      return date.isAfter(now) ||
          (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day);
    } catch (e) {
      return false;
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

  void _showCategoryDialog({Category? category}) {
    final titleController = TextEditingController(text: category?.title ?? '');
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    final dateController = TextEditingController(text: category?.date ?? '');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          category == null ? 'Adicionar Categoria' : 'Editar Categoria',
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título',
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
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                    helperText: 'Data de encerramento da votação',
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      dateController.text =
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
                final newCategory = Category(
                  id: category?.id,
                  userId: widget.user.id!,
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  date: dateController.text.trim(),
                );

                if (category == null) {
                  await _categoryRepository.createCategory(newCategory);
                  _showSuccess('Categoria adicionada com sucesso!');
                } else {
                  await _categoryRepository.updateCategory(newCategory);
                  _showSuccess('Categoria atualizada com sucesso!');
                }

                Navigator.pop(context);
                _loadCategories();
              } catch (e) {
                _showError('Erro ao salvar categoria: $e');
              }
            },
            child: Text(category == null ? 'Adicionar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir a categoria "${category.title}"?',
        ),
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
        // Remove associações de jogos primeiro
        final catGames = await _categoryGameRepository.getCatGames();
        for (var cg in catGames.where((cg) => cg.categoryId == category.id)) {
          await _categoryGameRepository.deleteCatGame(cg.id!);
        }

        await _categoryRepository.deleteCategory(category.id!);
        _showSuccess('Categoria excluída com sucesso!');
        _loadCategories();
      } catch (e) {
        _showError('Erro ao excluir categoria: $e');
      }
    }
  }

  void _navigateToCategoryGames(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CategoryGamesScreen(user: widget.user, category: category),
      ),
    ).then((_) => _loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Categorias'),
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
            : _categories.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma categoria cadastrada',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isActive = _isCategoryActive(category.date);

                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isActive ? 'ATIVA' : 'INATIVA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(category.description),
                              SizedBox(height: 4),
                              Text(
                                'Encerramento: ${category.date}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              icon: Icon(Icons.videogame_asset, size: 18),
                              label: Text('Jogos'),
                              onPressed: () =>
                                  _navigateToCategoryGames(category),
                            ),
                            TextButton.icon(
                              icon: Icon(Icons.edit, size: 18),
                              label: Text('Editar'),
                              onPressed: () =>
                                  _showCategoryDialog(category: category),
                            ),
                            TextButton.icon(
                              icon: Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              label: Text(
                                'Excluir',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () => _deleteCategory(category),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: Colors.amber,
        icon: Icon(Icons.add, color: Colors.black),
        label: Text('Nova Categoria', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
