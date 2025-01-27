import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fostiator/Games/FostiatorGame.dart';
import '../DataHolder.dart';

class MainMenu extends StatefulWidget {
  // Reference to parent game.
  final FostiatorGame game;

  const MainMenu({Key? key, required this.game}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // For displaying or copying the "created room" code.
  String _createdRoomCode = '';

  // For user to type an existing room code.
  final TextEditingController _joinController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DataHolder().positionChannel.onConnected=() {
      // Start the game or switch overlays, etc.
      widget.game.nuevoJugador();
      widget.game.overlays.remove('MainMenu');
      widget.game.nuevoJuego();
    };
  }

  /// Generates a short random "room code" (e.g. 6 chars).
  String _generateRandomRoomCode() {
    final random = Random();
    const length = 3;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// Called when user taps "Create Room".
  void _createRoom() {
    // 1) Generate a random code
    final roomCode = _generateRandomRoomCode();

    // 2) Use your service to create a room (WebRTC offer flow)
    DataHolder().positionChannel.initConnection(true, roomCode);

    // 3) Show the new code in the UI so the user can share it
    setState(() {
      _createdRoomCode = roomCode;
    });
  }

  /// Called when user taps "Join Room".
  void _joinRoom() {
    final code = _joinController.text.trim();
    if (code.isNotEmpty) {
      DataHolder().positionChannel.initConnection(false,code);
    }
  }

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 850,
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: BorderRadius.all(
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

              // Single-player or local play
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    // Start a new local game
                    widget.game.overlays.remove('MainMenu');
                    widget.game.nuevoJuego();
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
              const SizedBox(height: 30),

              // CREATE ROOM
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: _createRoom,
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
              if (_createdRoomCode.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Código de Sala: $_createdRoomCode',
                  style: const TextStyle(color: whiteTextColor),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Comparte este código con tu amigo para que se una',
                  style: TextStyle(color: whiteTextColor, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 40),

              // JOIN ROOM
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _joinController,
                  style: const TextStyle(color: whiteTextColor),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Ingresa código de sala',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _joinRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Unirse a Sala',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                '''Use WASD o Flechas para moverte.
Barra espaciadora para saltar.
¡Recoge tantas estrellas como puedas y evita enemigos!''',
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