import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      } 
      // Lógica para o botão de apagar
      else if (buttonText == "backspace") {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
          _calculateLiveResult(); // Recalcula o preview
        }
      }
      else if (buttonText == "=") {
        if (liveResult.isNotEmpty) {
          String finalResult = liveResult.substring(2);
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

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF505050),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Histórico",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        onPressed: history.isEmpty ? null : () {
                          showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                title: const Text('Limpar Histórico'),
                                content: const Text('Você tem certeza que deseja apagar todo o histórico?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Limpar', style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      setModalState(() {
                                        history.clear();
                                      });
                                      setState(() {});
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
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
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: history[index]));
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cálculo copiado para a área de transferência!')),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ WIDGET DO BOTÃO ATUALIZADO PARA USAR O ÍCONE
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
              HapticFeedback.lightImpact();
              buttonPressed(buttonText);
            },
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Center(
              child: buttonText == "backspace"
                  ? Icon(Icons.backspace_outlined, color: textColor, size: 30)
                  : Text(
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
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        buildButton("C", topTextColor, topButtonColor),
                        // ✅ BOTÃO DE APAGAR COM O NOVO ÍCONE
                        buildButton("backspace", topTextColor, topButtonColor),
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
