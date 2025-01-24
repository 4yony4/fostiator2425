import 'package:flutter/material.dart';
import 'package:fostiator/Games/FostiatorGame.dart';

import '../DataHolder.dart';


class MainMenu extends StatelessWidget {
  // Reference to parent game.
  final FostiatorGame game;
  TextEditingController controller=TextEditingController();

  MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child:
      Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 850,
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'FOSTIATOR',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('MainMenu');
                    game.nuevoJuego();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Jugar',
                    style: TextStyle(
                      fontSize: 40.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    //if(controller.text.isNotEmpty)
                      DataHolder().service.createOffer("sala1");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Crear Sala',
                    style: TextStyle(
                      fontSize: 40.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    //if(controller.text.isNotEmpty)
                    DataHolder().service.joinRoom("sala1");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Unirse a sala',
                    style: TextStyle(
                      fontSize: 40.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
              /*SizedBox(
                width: 250,
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: whiteTextColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Enter text here',
                    hintStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),*/
              const SizedBox(height: 20),
              const Text(
                '''Use WASD or Arrow Keys for movement.
Space bar to jump.
Collect as many stars as you can and avoid enemies!''',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}