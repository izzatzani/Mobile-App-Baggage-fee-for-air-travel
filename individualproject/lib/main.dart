import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const BaggageApp());

// ====== EDIT THESE WITH YOUR OWN DETAILS ======
const String kAppTitle = 'Excess Baggage Estimator';
const String kAuthorName = 'IZZAT IZZANI BIN MOHD NASIR';
const String kMatricNo = '2025219938';
const String kCourse = 'CS251 - Bachelor of Computer Science (Hons.) Netcentric Computing';
const String kGithubUrl = 'https://github.com/your-username/your-repo';
// ===============================================

class BaggageApp extends StatelessWidget {
  const BaggageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      // Customization: theme + title bar styling
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ---------------------------------------------------------------
// Shared navigation drawer (Home / About)
// ---------------------------------------------------------------
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                kAppTitle,
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// Home page (calculator)
// ---------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

  String _ticketClass = 'Economy'; // input #2 uses a different widget (dropdown)

  double? _excessWeight;
  double? _excessCharge;
  double? _totalPayable;

  static const double _taxRate = 0.08;

  double get _allowance => _ticketClass == 'Economy' ? 20 : 40;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightCtrl.text.trim());
    final rate = double.parse(_rateCtrl.text.trim());

    // Excess weight is never negative
    final excess = (weight - _allowance) > 0 ? (weight - _allowance) : 0.0;
    final charge = excess * rate;
    final total = charge + (_taxRate * charge);

    setState(() {
      _excessWeight = excess;
      _excessCharge = charge;
      _totalPayable = total;
    });
  }

  void _reset() {
    _formKey.currentState?.reset();
    _weightCtrl.clear();
    _rateCtrl.clear();
    setState(() {
      _ticketClass = 'Economy';
      _excessWeight = null;
      _excessCharge = null;
      _totalPayable = null;
    });
  }

  String? _validatePositive(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label';
    }
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number (e.g. 25 or 25.5)';
    if (n < 0) return '$label cannot be negative';
    return null;
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppTitle), // application title visible
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: const [Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.flight_takeoff),
        )],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions / helpful notice
              Card(
                color: Colors.indigo.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'How to use: enter your checked baggage weight, choose '
                    'your ticket class and type the excess rate per kg.\n\n'
                    'Free allowance: Economy = 20 kg, Business = 40 kg.\n'
                    'An 8% service tax is added to the excess charge.',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input 1: weight (TextField)
              TextFormField(
                controller: _weightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Baggage weight (kg)',
                  prefixIcon: Icon(Icons.luggage),
                  helperText: 'Weight of your checked baggage',
                ),
                validator: (v) => _validatePositive(v, 'baggage weight'),
              ),
              const SizedBox(height: 16),

              // Input 2: ticket class (Dropdown - a different widget)
              DropdownButtonFormField<String>(
                value: _ticketClass,
                decoration: const InputDecoration(
                  labelText: 'Ticket class',
                  prefixIcon: Icon(Icons.airline_seat_recline_extra),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Economy', child: Text('Economy (20 kg)')),
                  DropdownMenuItem(
                      value: 'Business', child: Text('Business (40 kg)')),
                ],
                onChanged: (v) => setState(() => _ticketClass = v!),
              ),
              const SizedBox(height: 16),

              // Input 3: rate per kg (TextField)
              TextFormField(
                controller: _rateCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Excess baggage rate per kg (RM)',
                  prefixIcon: Icon(Icons.attach_money),
                  helperText: 'Example: 15',
                ),
                validator: (v) => _validatePositive(v, 'the rate per kg'),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Outputs (formatted)
              if (_totalPayable != null) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Result',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _resultRow('Excess baggage weight',
                '${_excessWeight!.toStringAsFixed(2)} kg'),
            _resultRow('Excess baggage charge',
                'RM ${_excessCharge!.toStringAsFixed(2)}'),
            const Divider(),
            _resultRow('Total amount payable',
                'RM ${_totalPayable!.toStringAsFixed(2)}',
                bold: true),
            if (_excessWeight == 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Your baggage is within the free allowance. No charge!',
                  style: TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 18 : 16,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// About page
// ---------------------------------------------------------------
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openGithub(BuildContext context) async {
    final uri = Uri.parse(kGithubUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      drawer: const AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
             Image.asset(
  'assets/icon.png',
  width: 120,
  height: 120,
  errorBuilder: (context, error, stack) =>
      const Icon(Icons.luggage, size: 120),
),
              const SizedBox(height: 16),
              const Text(kAppTitle,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Author Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Name: $kAuthorName'),
              const Text('Matric No: $kMatricNo'),
              const Text('Course: $kCourse', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => _openGithub(context),
                child: const Text(
                  kGithubUrl,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '© 2026 $kAuthorName. All rights reserved.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
