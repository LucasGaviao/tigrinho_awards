import 'package:flutter/material.dart';
import '../models/game.dart';
import '../repositories/game_repository.dart';

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
                  userId: 1, 
                  name: "Call of Tigrinhos",
                  description: "Battleroyale dos Tigres",
                  releaseDate: "2025-01-01",
                );

                GameRepository repo = GameRepository(); 

                await repo.insertGame(novoJogo);

                print("Salvo com sucesso!");
              },
              child: Text("Criar jogo Call of Tigrinhos")
            ),
            ElevatedButton(
              onPressed: () async {
                
                GameRepository repo = GameRepository(); 

                List<Game> games = await repo.getGames();

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
          ],
        )
      )
    );
  }
}