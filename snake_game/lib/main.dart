import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          // Убедитесь, что вы используете корректные параметры
          titleLarge: TextStyle(color: Colors.white), // Заголовок
          bodyLarge: TextStyle(color: Colors.white), // Основной текст
        ),
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 20; // Размер сетки
  static const double cellSize = 20.0; // Размер клетки
  List<Offset> snake = [Offset(5, 5)];
  Offset food = Offset(10, 10);
  String direction = 'RIGHT'; // Начальное направление
  Timer? timer;

  @override
  void initState() {
    super.initState();
    spawnFood();
    startGame();
  }

  void startGame() {
    timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      moveSnake();
    });
  }

  void moveSnake() {
    setState(() {
      Offset newHead = snake.first;
      if (direction == 'UP') {
        newHead = Offset(newHead.dx, newHead.dy - 1);
      } else if (direction == 'DOWN') {
        newHead = Offset(newHead.dx, newHead.dy + 1);
      } else if (direction == 'LEFT') {
        newHead = Offset(newHead.dx - 1, newHead.dy);
      } else if (direction == 'RIGHT') {
        newHead = Offset(newHead.dx + 1, newHead.dy);
      }

      snake.insert(0, newHead);

      if (newHead == food) {
        spawnFood();
      } else {
        snake.removeLast();
      }

      // Проверка на столкновение со стенами или самим собой
      if (newHead.dx < 0 ||
          newHead.dx >= gridSize ||
          newHead.dy < 0 ||
          newHead.dy >= gridSize ||
          snake.sublist(1).contains(newHead)) {
        timer?.cancel(); // Остановка таймера
        showGameOverDialog();
      }
    });
  }

  void spawnFood() {
    Random random = Random();
    food = Offset(random.nextInt(gridSize.toInt()).toDouble(),
        random.nextInt(gridSize.toInt()).toDouble());
  }

  void showGameOverDialog() {
    timer?.cancel(); // Остановка таймера перед показом диалога
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text('Game Over', style: TextStyle(color: Colors.red)),
          content: Text(
            'Your score is: ${snake.length}',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  Text('Restart', style: TextStyle(color: Colors.greenAccent)),
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    timer?.cancel(); // Остановка таймера перед перезапуском
    setState(() {
      snake = [Offset(5, 5)];
      direction = 'RIGHT';
      spawnFood();
      startGame();
    });
  }

  void changeDirection(String newDirection) {
    setState(() {
      if ((direction == 'UP' && newDirection != 'DOWN') ||
          (direction == 'DOWN' && newDirection != 'UP') ||
          (direction == 'LEFT' && newDirection != 'RIGHT') ||
          (direction == 'RIGHT' && newDirection != 'LEFT')) {
        direction = newDirection;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game',
            style: TextStyle(
                color: Colors.black)), // Измененный цвет текста заголовка
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  Container(
                    width: gridSize * cellSize,
                    height: gridSize * cellSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.greenAccent),
                    ),
                    child: CustomPaint(
                      painter: SnakePainter(snake, food),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Joystick(
            onDirectionChanged: changeDirection,
          ),
        ],
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;

  SnakePainter(this.snake, this.food);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.greenAccent;
    for (var segment in snake) {
      canvas.drawRect(
          Rect.fromLTWH(segment.dx * 20, segment.dy * 20, 20, 20), paint);
    }

    paint.color = Colors.redAccent;
    canvas.drawRect(Rect.fromLTWH(food.dx * 20, food.dy * 20, 20, 20), paint);
  }

  @override
  bool shouldRepaint(SnakePainter oldDelegate) {
    return true;
  }
}

class Joystick extends StatelessWidget {
  final Function(String) onDirectionChanged;

  Joystick({Key? key, required this.onDirectionChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () => onDirectionChanged('LEFT'),
            child: Text('LEFT', style: TextStyle(color: Colors.black)),
          ),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent),
                onPressed: () => onDirectionChanged('UP'),
                child: Text('UP', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent),
                onPressed: () => onDirectionChanged('DOWN'),
                child: Text('DOWN', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () => onDirectionChanged('RIGHT'),
            child: Text('RIGHT', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
