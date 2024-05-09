import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CurrencyExchangeApp());
}

class CurrencyExchangeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Exchange',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system, // Automatically adapt to system theme
      home: ExchangePage(),
    );
  }
}

class ExchangePage extends StatefulWidget {
  @override
  _ExchangePageState createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  double _amount = 1.0;
  String _baseCurrency = 'USD';
  String _targetCurrency = 'EUR';
  double _exchangeRate = 0.0;
  List<String> _currencies = ['USD', 'EUR', 'INR', 'GBP', 'JPY'];

  Future<void> _fetchExchangeRate() async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/$_baseCurrency'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _exchangeRate = data['rates'][_targetCurrency] * _amount;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Currency Exchange',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink, // Pink background color
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Convert $_baseCurrency to $_targetCurrency',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _amount = double.tryParse(value) ?? 0.0;
                        });
                        _fetchExchangeRate();
                      },
                    ),
                  ),
                  DropdownButton<String>(
                    value: _baseCurrency,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _baseCurrency = newValue;
                          if (_targetCurrency == _baseCurrency) {
                            _targetCurrency = _currencies.firstWhere(
                                (currency) => currency != _baseCurrency);
                          }
                        });
                        _fetchExchangeRate();
                      }
                    },
                    items: _currencies
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _targetCurrency,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _targetCurrency = newValue;
                    });
                    _fetchExchangeRate();
                  }
                },
                items: _currencies
                    .where((currency) => currency != _baseCurrency)
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                '$_amount $_baseCurrency = $_exchangeRate $_targetCurrency',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
