import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:elada/data/models/invoice.dart';
import 'package:elada/data/repositories/invoice_repository.dart';
import 'package:elada/domain/services/pdf_service.dart';
import 'package:elada/domain/services/filename_service.dart';
import 'package:elada/domain/services/file_export_service.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(InvoiceAdapter());
  }

  final invoiceBox = await Hive.openBox<Invoice>('invoices');
  final draftsBox = await Hive.openBox<Invoice>('drafts');
  final settingsBox = await Hive.openBox('settings');

  final invoiceRepository = InvoiceRepository(
    invoiceBox,
    settingsBox,
    draftBox: draftsBox,
  );
  final pdfService = PdfService();
  final filenameService = FilenameService();
  final fileExportService = FileExportService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InvoiceProvider(
            invoiceRepository,
            pdfService,
            filenameService,
            fileExportService,
          ),
        ),
      ],
      child: const EladaApp(),
    ),
  );
}

class EladaApp extends StatelessWidget {
  const EladaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elada Invoice Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shadowColor: Colors.deepPurple.withAlpha(77), // ~0.3 opacity
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
