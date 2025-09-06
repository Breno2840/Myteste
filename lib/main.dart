import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

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
  // Novas variáveis de estado
  String expression = "";
  String result = "0";

  // Nova lógica de pressionar o botão
  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        expression = "";
        result = "0";
      } else if (buttonText == "=") {
        try {
          // Prepara a expressão para ser calculada
          String finalExpression = expression;
          finalExpression = finalExpression.replaceAll('x', '*'); // Troca 'x' por '*'

          // Usa o pacote math_expressions para calcular
          Parser p = Parser();
          Expression exp = p.parse(finalExpression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);

          // Formata o resultado
          if (eval == eval.toInt()) {
            result = eval.toInt().toString();
          } else {
            result = eval.toString();
          }
        } catch (e) {
          result = "Erro";
        }
      } else {
        // Se o resultado atual for "0" ou "Erro", começa uma nova expressão
        if (result != "0" && expression == "") {
           expression = result;
        }
        
        // Se o valor inicial é "0", substitui pelo botão pressionado
        if (expression == "0") {
            expression = buttonText;
        } else {
            expression = expression + buttonText;
        }
      }
    });
  }

  // Widget para construir cada botão (continua o mesmo)
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
    // Definindo as cores para o tema escuro (continua o mesmo)
    const Color bgColor = Color(0xFF1C1C1E);
    const Color numberButtonColor = Color(0xFF505050);
    const Color operatorButtonColor = Color(0xFFFF9500);
    const Color topButtonColor = Color(0xFFD4D4D2);
    const Color topTextColor = Colors.black;
    const Color defaultTextColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ✅ NOVO VISOR COM DUAS LINHAS
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // A expressão/conta
                    Text(
                      expression.isEmpty ? " " : expression,
                      style: const TextStyle(fontSize: 48.0, color: Colors.white60),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // O resultado
                    Text(
                      result,
                      style: const TextStyle(
                        fontSize: 72.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Linha de botões (continua o mesmo)
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buildButton("C", topTextColor, topButtonColor),
                        buildButton("()", topTextColor, topButtonColor), // Apenas visual
                        buildButton("%", topTextColor, topButtonColor),  // Apenas visual
                        buildButton("/", defaultTextColor, operatorButtonColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buildButton("7", defaultTextColor, numberButtonColor),
                        buildButton("8", defaultTextColor, numberButtonColor),
                        buildButton("9", defaultTextColor, numberButtonColor),
                        buildButton("x", defaultTextColor, operatorButtonColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buildButton("4", defaultTextColor, numberButtonColor),
                        buildButton("5", defaultTextColor, numberButtonColor),
                        buildButton("6", defaultTextColor, numberButtonColor),
                        buildButton("-", defaultTextColor, operatorButtonColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buildButton("1", defaultTextColor, numberButtonColor),
                        buildButton("2", defaultTextColor, numberButtonColor),
                        buildButton("3", defaultTextColor, numberButtonColor),
                        buildButton("+", defaultTextColor, operatorButtonColor),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(flex: 2, child: buildButton("0", defaultTextColor, numberButtonColor)),
                        buildButton(".", defaultTextColor, numberButtonColor),
                        buildButton("=", defaultTextColor, operatorButtonColor),
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
