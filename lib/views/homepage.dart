import 'package:flutter/material.dart';
import '../models/game.dart';
import '../repositories/game_repository.dart';
import '../models/category_game.dart'; 
import '../repositories/category_game_repository.dart';
import '../models/category.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Teste",
      debugShowCheckedModeBanner: false,
      home: Container(
        //color: Colors.blue,
        decoration: BoxDecoration(
          color: Colors.lightGreen,
          border: Border.all(
            width: 3,
            color: Colors.blue
          ) 
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final novoJogo = Game(
                  id: 1, 
                  userId: 1, 
                  name: "Call of Tigrinhos",
                  description: "Battleroyale dos Tigres",
                  releaseDate: "2025-01-01",
                );

                GameRepository repo = GameRepository(); 

                await repo.createGame(novoJogo);

                print("Salvo com sucesso!");
              },
              child: Text("Criar jogo Call of Tigrinhos")
            ),
            ElevatedButton(
              onPressed: () async {
                
                GameRepository repo = GameRepository(); 

                List<Game> games = await repo.getAllGames();

                if(games.isEmpty){
                  print('Não há jogo cadastrado');
                }
                else{
                  for(var game in games){
                    print("ID: ${game.id} || Name: ${game.name} || Description: ${game.description}");
                  }
                }
              },
              child: Text("Listar todos os jogos (TERMINAL)")
            ),
            ElevatedButton(
              onPressed: () async {
                CategoryGameRepository repo = CategoryGameRepository();
                GameRepository game_repo = GameRepository();

                Game game = Game(
                    userId: 1, 
                    name: "Tigrinho Game", 
                    description: "Qualquer coisa", 
                    releaseDate: "2025"
                );

                await game_repo.createGame(game);
                


                Category category = Category(
                    userId: 1, 
                    title: "GOTY", 
                    description: "Game of the year", 
                    date: "1/1/2025"
                );

                List<Game> games = await game_repo.getAllGames();
                for (var game in games){
                    if (game.name == "Tigrinho Game"){
                        CategoryGame cat_game = CategoryGame(categoryId: 1, gameId: game.id);
                        await repo.createCatGame(cat_game);
                        print("Salvo");
                        break;
                    }
                }

              },
              child : Text("Criar jogo tigrinho com Categoria GOTY")
            ),
            ElevatedButton(
                onPressed: () async {
                    CategoryGameRepository repo = CategoryGameRepository();
                    List<CategoryGame> games = await repo.getCatGames();
                    if(games.isEmpty){
                      print('Não há jogo cadastrado');
                    }
                    else{
                      for(var game in games){
                        print("ID: ${game.id} || CategoryId: ${game.categoryId}, || GameId: ${game.gameId}");
                      }
                    }
                },
                child: Text("Listar todas os jogos com categoria")
            ),
          ],
        )
      )
    );
  }
}
