import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ 1. IMPORTADO PARA O FEEDBACK DE VIBRAÇÃO
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
  String expression = "";
  String result = "0";
  String liveResult = "";
  // ✅ 2. LISTA PARA GUARDAR O HISTÓRICO
  List<String> history = [];

  void _calculateLiveResult() {
    if (expression.isEmpty || "+-x/".contains(expression.substring(expression.length - 1))) {
      if (liveResult.isNotEmpty && expression.isNotEmpty) {
        setState(() {
          liveResult = "";
        });
      }
      return;
    }
    try {
      String finalExpression = expression.replaceAll('x', '*');
      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        if (eval == eval.toInt()) {
          liveResult = "= ${eval.toInt()}";
        } else {
          liveResult = "= ${eval.toStringAsFixed(2)}";
        }
      });
    } catch (e) {
      // Ignora erros no preview
    }
  }

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        expression = "";
        result = "0";
        liveResult = "";
      } else if (buttonText == "=") {
        if (liveResult.isNotEmpty) {
          String finalResult = liveResult.substring(2);
          // ✅ 3. SALVA A CONTA NO HISTÓRICO
          history.insert(0, "$expression = $finalResult");
          result = finalResult;
          expression = "";
          liveResult = "";
        }
      } else {
        if (result != "0" && expression.isEmpty) {
          expression = result == "Erro" ? "" : result;
          result = "0";
        }
        expression += buttonText;
        _calculateLiveResult();
      }
    });
  }
  
  // ✅ 5. FUNÇÃO PARA MOSTRAR O PAINEL DE HISTÓRICO
  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF505050),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Histórico",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum histórico ainda.",
                        style: TextStyle(fontSize: 18, color: Colors.white60),
                      ),
                    )
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            history[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget buildButton(String buttonText, Color textColor, Color buttonColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: Material(
          color: buttonColor,
          borderRadius: BorderRadius.circular(24.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(24.0),
            onTap: () {
              // ✅ 4. ADICIONA A VIBRAÇÃO AQUI
              HapticFeedback.lightImpact();
              buttonPressed(buttonText);
            },
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
    const Color bgColor = Color(0xFF1C1C1E);
    const Color numberButtonColor = Color(0xFF505050);
    const Color operatorButtonColor = Color(0xFFFF9500);
    const Color topButtonColor = Color(0xFFD4D4D2);
    const Color topTextColor = Colors.black;
    const Color defaultTextColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      // ✅ 6. APPBAR COM O BOTÃO DE HISTÓRICO
      appBar: AppBar(
        title: const Text("Calculadora", style: TextStyle(color: Colors.white)),
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _showHistory,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      expression.isEmpty ? result : expression,
                      style: const TextStyle(fontSize: 48.0, color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      liveResult,
                      style: const TextStyle(
                        fontSize: 36.0,
                        color: Colors.white60,
                      ),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Linhas de botões
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buildButton("C", topTextColor, topButtonColor),
                        buildButton("()", topTextColor, topButtonColor),
                        buildButton("%", topTextColor, topButtonColor),
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
