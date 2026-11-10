import 'dart:io';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs_detail_controller.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/models/docs_models.dart';
import 'package:provider/provider.dart';

class DocsDetailScreen extends StatelessWidget {
  const DocsDetailScreen({
    super.key,
    required this.docId,
    required this.docName,
  });

  final String docId;
  final String docName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DocsDetailController>(
      create: (_) =>
          getIt<DocsDetailController>(param1: docId, param2: docName),
      child: const _DocsDetailScreenBody(),
    );
  }
}

class _DocsDetailScreenBody extends StatefulWidget {
  const _DocsDetailScreenBody();

  @override
  State<_DocsDetailScreenBody> createState() => _DocsDetailScreenBodyState();
}

class _DocsDetailScreenBodyState extends State<_DocsDetailScreenBody> {
  late final Stream<List<ScannedDocumentModel>> _docStream;

  @override
  void initState() {
    super.initState();
    // Cache the stream reference ONCE so StreamBuilder never re-subscribes or resets
    _docStream = context.read<DocsDetailController>().watchScannedDocument();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: StreamBuilder<List<ScannedDocumentModel>>(
        stream: _docStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];

          final controller = context.read<DocsDetailController>();

          return Scaffold(
            appBar: AppBar(title: Text(controller.docName)),
            body: GridView.builder(
              padding: const EdgeInsets.all(DocsUiConstants.paddingAll),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                // Max width per item; Flutter dynamically adds/removes columns based on width
                maxCrossAxisExtent: 240.0,
                childAspectRatio: 0.85,
                crossAxisSpacing: DocsUiConstants.gridSpacing,
                mainAxisSpacing: DocsUiConstants.gridSpacing,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];

                return Card(
                  key: ValueKey(doc.id),
                  child: Hero(
                    tag: "${controller.docId}_${doc.absoluteFilePath}",
                    child: Padding(
                      padding: const EdgeInsets.all(
                        DocsUiConstants.spacingSmall,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.file(
                              File(doc.absoluteFilePath),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              cacheWidth: DocsUiConstants.thumbnailCacheWidth,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            doc.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: DocsUiConstants.spacingTiny),
                          Text(
                            DateFormat('MM-dd-yyyy HH:mm')
                                .format(doc.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
