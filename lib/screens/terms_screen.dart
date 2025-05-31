import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  String? _termsContent;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final content = await rootBundle.loadString('assets/texts/terms_and_conditions.md');
      setState(() {
        _termsContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudieron cargar los términos y condiciones: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y condiciones'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _termsContent == null
                  ? const Center(child: Text('No hay contenido disponible.'))
                  : SingleChildScrollView(
                      child: Markdown(
                        data: _termsContent!,
                        padding: const EdgeInsets.all(16.0),
                        // For basic styling, you can use styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(...),
                      ),
                    ),
    );
  }
}
