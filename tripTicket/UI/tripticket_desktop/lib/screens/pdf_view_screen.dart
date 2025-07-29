import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_selector/file_selector.dart';

class PdfViewerPage extends StatefulWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const PdfViewerPage({
    required this.pdfBytes,
    required this.fileName,
    super.key,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  void _printPdf() {
    Printing.layoutPdf(onLayout: (format) => widget.pdfBytes);
  }

  Future<void> _downloadPdf() async {
    try {
      final FileSaveLocation? result = await getSaveLocation(
        suggestedName: widget.fileName,
        acceptedTypeGroups: [
          XTypeGroup(label: 'PDF', extensions: ['pdf']),
        ],
      );

      if (result == null) return;

      final XFile pdfFile = XFile.fromData(
        widget.pdfBytes,
        mimeType: 'application/pdf',
        name: widget.fileName,
      );

      await pdfFile.saveTo(result.path);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved at: ${result.path}')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print PDF',
            onPressed: _printPdf,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          padding: const EdgeInsets.all(12),
          child: SfPdfViewer.memory(widget.pdfBytes),
        ),
      ),
    );
  }
}
