import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conversor de Monedas',
      theme: ThemeData.dark(),
      home: CurrencyConverterScreen(),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController amountController = TextEditingController();
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double result = 0;
  DateTime selectedDate = DateTime.now();
  List<String> currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'SEK', 'NZD',
    'MXN', 'SGD', 'HKD', 'NOK', 'KRW', 'TRY'
  ];
  List<Map<String, dynamic>> conversionHistory = [];

  Future<void> convertCurrency() async {
    if (fromCurrency == toCurrency) {
      setState(() {
        result = double.tryParse(amountController.text) ?? 0;
      });
      return;
    }

    String date = "${selectedDate.toIso8601String().split('T')[0]}";
    String url = 'https://api.frankfurter.app/$date?from=$fromCurrency&to=$toCurrency';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      double rate = data['rates'][toCurrency];
      setState(() {
        result = (double.tryParse(amountController.text) ?? 0) * rate;
        // Guardar el historial de la conversión
        conversionHistory.add({
          'fromCurrency': fromCurrency,
          'toCurrency': toCurrency,
          'amount': amountController.text,
          'result': result,
          'rate': rate,
          'date': date,
        });
      });
    } else {
      setState(() {
        result = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener la tasa de cambio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Conversor de Monedas')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Moneda de Origen:', style: TextStyle(color: Colors.white)),
                    DropdownButton<String>(
                      dropdownColor: Colors.black,
                      value: fromCurrency,
                      onChanged: (value) => setState(() => fromCurrency = value!),
                      items: currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency, style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Moneda de Destino:', style: TextStyle(color: Colors.white)),
                    DropdownButton<String>(
                      dropdownColor: Colors.black,
                      value: toCurrency,
                      onChanged: (value) => setState(() => toCurrency = value!),
                      items: currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency, style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha de Conversión:', style: TextStyle(color: Colors.white)),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (newDate != null) {
                          setState(() {
                            selectedDate = newDate;
                          });
                        }
                      },
                      child: Text('${selectedDate.toLocal()}'.split(' ')[0]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Cantidad',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: convertCurrency,
                child: Text('Convertir'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$result $toCurrency', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(width: 10),
                    Image.network(
                      'https://flagcdn.com/w40/${toCurrency.substring(0, 2).toLowerCase()}.png',
                      width: 40,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.flag, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Botón de historial en la esquina inferior derecha
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HistoryScreen(conversionHistory: conversionHistory)),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.history),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> conversionHistory;

  HistoryScreen({required this.conversionHistory});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedBaseCurrency = 'USD'; // La moneda base seleccionada
  List<Map<String, dynamic>> filteredHistory = [];

  @override
  void initState() {
    super.initState();
    filterHistory();
  }

  // Filtra el historial según la moneda base seleccionada
  void filterHistory() {
    setState(() {
      filteredHistory = widget.conversionHistory
          .where((entry) => entry['fromCurrency'] == selectedBaseCurrency)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial de Conversiones')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown para seleccionar la moneda base
            DropdownButton<String>(
              value: selectedBaseCurrency,
              onChanged: (newBaseCurrency) {
                setState(() {
                  selectedBaseCurrency = newBaseCurrency!;
                  filterHistory(); // Filtra el historial según la moneda base seleccionada
                });
              },
              items: ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'SEK', 'NZD']
                  .map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredHistory.length,
                itemBuilder: (context, index) {
                  var entry = filteredHistory[index];
                  return ListTile(
                    title: Text('${entry['amount']} ${entry['fromCurrency']} → ${entry['result']} ${entry['toCurrency']}'),
                    subtitle: Text('Tasa: ${entry['rate']} | Fecha: ${entry['date']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
