import 'package:flutter/material.dart';
import 'package:flutter_ethiopian_date_picker/flutter_ethiopian_date_picker.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethiopian Date Picker — Example',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(onToggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  EthiopianDate? _selectedDate;
  EthiopianDateRange? _selectedRange;

  // EthiopianLocale is the enum used for the UI dropdown; every picker
  // API takes the raw String code (locale.code), not the enum itself.
  EthiopianLocale _locale = EthiopianLocale.english;

  final _formKey = GlobalKey<FormState>();
  EthiopianDate? _formDate;

  bool _useCustomTheme = false;

  /// EthiopianDatePickerTheme has no lightweight constructor — every
  /// field (including onSelectedColor/todayBorderColor/disabledColor)
  /// is required, so a custom theme starts from the Material 3 default
  /// and overrides just the colors we care about.
  EthiopianDatePickerTheme? _resolveTheme(BuildContext context) {
    if (!_useCustomTheme) return null;
    return EthiopianDatePickerTheme.material3(context).copyWith(
      primaryColor: Colors.deepOrange,
      selectedColor: Colors.deepOrange,
      backgroundColor: Colors.white,
    );
  }

  Future<void> _openBasicPicker() async {
    final result = await showEthiopianDatePicker(
      context: context,
      initialDate: _selectedDate ?? EthiopianDate.today(),
      firstDate: EthiopianDate(2010, 1, 1),
      lastDate: EthiopianDate(2020, 13, 5),
      locale: _locale.code,
      theme: _resolveTheme(context),
    );

    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  Future<void> _openRangePicker() async {
    final result = await showEthiopianDateRangePicker(
      context: context,
      initialRange: _selectedRange,
      firstDate: EthiopianDate(2010, 1, 1),
      lastDate: EthiopianDate(2020, 13, 5),
      locale: _locale.code,
      theme: _resolveTheme(context),
    );

    if (result != null) {
      setState(() => _selectedRange = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ethiopian Date Picker'),
        actions: [
          IconButton(
            tooltip: 'Toggle light / dark theme',
            icon: Icon(
              widget.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Locale switch ---
              Text('Locale', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<EthiopianLocale>(
                initialValue: _locale,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: EthiopianLocale.values
                    .map(
                      (l) => DropdownMenuItem(
                        value: l,
                        child: Text('${l.name} (${l.code})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _locale = value);
                },
              ),
              const SizedBox(height: 16),

              // --- Custom theme switch ---
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use custom picker theme'),
                subtitle: const Text(
                    'Deep orange, based on EthiopianDatePickerTheme.material3'),
                value: _useCustomTheme,
                onChanged: (value) => setState(() => _useCustomTheme = value),
              ),
              const Divider(height: 32),

              // --- Basic picker ---
              Text(
                'Single date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text('Open date picker'),
                onPressed: _openBasicPicker,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedDate == null
                    ? 'No date selected'
                    : 'Selected: $_selectedDate',
              ),
              const Divider(height: 32),

              // --- Range picker ---
              Text('Date range',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text('Open range picker'),
                onPressed: _openRangePicker,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedRange == null
                    ? 'No range selected'
                    : 'Range: ${_selectedRange!.start} → ${_selectedRange!.end}',
              ),
              const Divider(height: 32),

              // --- Form field usage ---
              Text(
                'Form field integration',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EthiopianDateFormField(
                      locale: _locale.code,
                      firstDate: EthiopianDate(2010, 1, 1),
                      lastDate: EthiopianDate(2020, 13, 5),
                      decoration: const InputDecoration(
                        labelText: 'Birth date',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null ? 'Please pick a date' : null,
                      onSaved: (value) => _formDate = value,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Saved: $_formDate')),
                          );
                        }
                      },
                      child: const Text('Validate & Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
