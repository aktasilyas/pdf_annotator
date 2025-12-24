/// Home Screen
///
/// Ana ekran - doküman listesi.
/// PDF import, listeleme ve silme işlemleri.
/// Error handling ve loading state destekler.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf_annotator/core/utils/file_utils.dart';
import 'package:pdf_annotator/core/utils/logger.dart';
import 'package:pdf_annotator/features/documents/domain/entities/document.dart';
import 'package:pdf_annotator/features/documents/presentation/providers/documents_provider.dart';
import 'package:pdf_annotator/features/viewer/presentation/screens/viewer_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentsProvider);

    // Error snackbar göster
    ref.listen<DocumentsState>(documentsProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Kapat',
              textColor: Colors.white,
              onPressed: () {
                ref.read(documentsProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Annotator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () {
              ref.read(documentsProvider.notifier).loadDocuments();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ayarlar',
            onPressed: () {
              // TODO: Settings screen
            },
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _importPdf(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('PDF Ekle'),
      ),
    );
  }

  /// Body widget - state'e göre farklı içerik gösterir
  Widget _buildBody(BuildContext context, WidgetRef ref, DocumentsState state) {
    if (state.isLoading && state.documents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.documents.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(documentsProvider.notifier).loadDocuments(),
      child: _DocumentGrid(documents: state.documents),
    );
  }

  /// PDF import işlemi
  Future<void> _importPdf(BuildContext context, WidgetRef ref) async {
    try {
      logger.debug('Starting PDF import');

      // PDF seç
      final file = await FileUtils.pickPdfFile();
      if (file == null) {
        logger.debug('PDF selection cancelled');
        return;
      }

      // Loading göster
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      // Dosyayı uygulama dizinine kopyala
      final copiedFile = await FileUtils.copyToAppDirectory(file);
      final fileSize = await FileUtils.getFileSize(copiedFile);
      final fileName = FileUtils.getFileName(file.path);

      logger.info(
        'PDF file copied',
        details: {'fileName': fileName, 'fileSize': fileSize},
      );

      // Document oluştur
      final now = DateTime.now();
      final document = Document(
        id: const Uuid().v4(),
        title: fileName,
        filePath: copiedFile.path,
        fileSize: fileSize,
        createdAt: now,
        updatedAt: now,
      );

      // Kaydet
      final success = await ref
          .read(documentsProvider.notifier)
          .addDocument(document);

      // Dialog kapat
      if (context.mounted) {
        Navigator.of(context).pop();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$fileName eklendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e, st) {
      logger.error('PDF import failed', error: e, stackTrace: st);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF eklenemedi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Henüz PDF yok',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'PDF eklemek için + butonuna tıkla',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Document grid widget
class _DocumentGrid extends StatelessWidget {
  final List<Document> documents;

  const _DocumentGrid({required this.documents});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return _DocumentCard(document: documents[index]);
      },
    );
  }
}

/// Document card widget
class _DocumentCard extends ConsumerWidget {
  final Document document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDocument(context),
        onLongPress: () => _showOptions(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail placeholder
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.picture_as_pdf,
                  size: 64,
                  color: Colors.red,
                ),
              ),
            ),
            // Title and info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(document.updatedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dokümanı aç
  void _openDocument(BuildContext context) {
    logger.debug('Opening document: ${document.title}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewerScreen(document: document)),
    );
  }

  /// Seçenekleri göster
  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Sil'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Silme onayı
  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Sil'),
        content: Text('${document.title} silinecek. Emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              logger.debug('Deleting document: ${document.id}');

              // Dosyayı sil
              await FileUtils.deleteFile(document.filePath);

              // DB'den sil
              await ref
                  .read(documentsProvider.notifier)
                  .deleteDocument(document.id);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Bugün';
    } else if (diff.inDays == 1) {
      return 'Dün';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
