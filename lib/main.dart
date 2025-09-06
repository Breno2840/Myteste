import 'package.flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora Bonita',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  // Variáveis para guardar o estado da calculadora
  String output = "0"; // O que é exibido na tela
  String _output = "0"; // Variável interna para cálculos
  double num1 = 0;
  double num2 = 0;
  String operand = "";
  // Variável para saber se um operador foi pressionado
  bool operandPressed = false;

  // Função chamada quando qualquer botão é pressionado
  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        // Limpa tudo
        _output = "0";
        num1 = 0;
        num2 = 0;
        operand = "";
        operandPressed = false;
        // ATUALIZA O VISOR
        output = _output;
      } else if (buttonText == "+" || buttonText == "-" || buttonText == "/" || buttonText == "x") {
        // Se um operador é pressionado
        // Evita erro se o usuário clicar em um operador duas vezes
        if (operand.isEmpty || !operandPressed) {
          num1 = double.parse(output);
          operand = buttonText;
          operandPressed = true;
        }
      } else if (buttonText == ".") {
        // Se o ponto decimal é pressionado
        if (operandPressed) {
          _output = "0.";
          operandPressed = false;
        } else if (!_output.contains(".")) {
          _output = _output + buttonText;
        }
        // ATUALIZA O VISOR
        output = _output;
      } else if (buttonText == "=") {
        // Se o botão de igual é pressionado
        if(operand.isNotEmpty){
          num2 = double.parse(output);

          if (operand == "+") {
            _output = (num1 + num2).toString();
          }
          if (operand == "-") {
            _output = (num1 - num2).toString();
          }
          if (operand == "x") {
            _output = (num1 * num2).toString();
          }
          if (operand == "/") {
            // Evita divisão por zero
            if (num2 == 0) {
              _output = "Erro";
            } else {
              _output = (num1 / num2).toString();
            }
          }

          num1 = 0;
          num2 = 0;
          operand = "";
          
          // Remove o ".0" de resultados inteiros e ATUALIZA O VISOR
          if (_output != "Erro" && _output.endsWith(".0")) {
            output = _output.replaceAll(".0", "");
          } else {
            output = _output;
          }

          _output = output == "Erro" ? "0" : output; // Guarda o resultado para futuras operações
        }
      } else {
        // Se um número é pressionado
        if (operandPressed || _output == "0") {
            _output = buttonText;
            operandPressed = false;
        } else {
            _output = _output + buttonText;
        }
        // ATUALIZA O VISOR
        output = _output;
      }
    });
  }

  // Widget para construir cada botão
  Widget buildButton(String buttonText, Color textColor, Color buttonColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: Material(
          color: buttonColor,
          borderRadius: BorderRadius.circular(24.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(24.0),
            onTap: () => buttonPressed(buttonText),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definindo as cores para o tema escuro
    const Color bgColor = Color(0xFF1C1C1E); // Fundo
    const Color displayColor = Colors.white; // Cor do texto do visor
    const Color numberButtonColor = Color(0xFF505050); // Botões de número
    const Color numberTextColor = Colors.white;
    const Color operatorButtonColor = Color(0xFFFF9500); // Botões de operador (laranja)
    const Color operatorTextColor = Colors.white;
    const Color topButtonColor = Color(0xFFD4D4D2); // Botões de cima (C, +/-, %)
    const Color topTextColor = Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Visor da calculadora
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
                child: Text(
                  output,
                  style: const TextStyle(
                    fontSize: 72.0,
                    fontWeight: FontWeight.bold,
                    color: displayColor,
                  ),
                ),
              ),
            ),
            // Linha de botões
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buildButton("C", topTextColor, topButtonColor),
                        buildButton("+/-", topTextColor, topButtonColor), // Função não implementada, apenas visual
                        buildButton("%", topTextColor, topButtonColor),  // Função não implementada, apenas visual
                        buildButton("/", operatorTextColor, operatorButtonColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buildButton("7", numberTextColor, numberButtonColor),
                        buildButton("8", numberTextColor, numberButtonColor),
                        buildButton("9", numberTextColor, numberButtonColor),
                        buildButton("x", operatorTextColor, operatorButtonColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buildButton("4", numberTextColor, numberButtonColor),
                        buildButton("5", numberTextColor, numberButtonColor),
                        buildButton("6", numberTextColor, numberButtonColor),
                        buildButton("-", operatorTextColor, operatorButtonColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buildButton("1", numberTextColor, numberButtonColor),
                        buildButton("2", numberTextColor, numberButtonColor),
                        buildButton("3", numberTextColor, numberButtonColor),
                        buildButton("+", operatorTextColor, operatorButtonColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        // Botão "0" ocupando dois espaços
                        Expanded(flex: 2, child: buildButton("0", numberTextColor, numberButtonColor)),
                        buildButton(".", numberTextColor, numberButtonColor),
                        buildButton("=", operatorTextColor, operatorButtonColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
