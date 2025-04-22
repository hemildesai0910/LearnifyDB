import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/documentation_provider.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade700,
        title: const Text('Bookmarks'),
        elevation: 0,
      ),
      body: Consumer<DocumentationProvider>(
        builder: (context, docProvider, child) {
          final bookmarks = docProvider.bookmarks;
          
          if (bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Topics you bookmark will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final topic = bookmarks.elementAt(index);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(topic),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.bookmark,
                      color: Colors.indigo,
                    ),
                    onPressed: () {
                      docProvider.toggleBookmark(topic);
                    },
                  ),
                  onTap: () {
                    // Navigate to documentation detail
                    // TODO: Implement navigation to documentation detail
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 