import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/documentation_provider.dart';
import 'bookmarks_screen.dart';

class SQLDocumentationScreen extends StatefulWidget {
  const SQLDocumentationScreen({Key? key}) : super(key: key);

  @override
  State<SQLDocumentationScreen> createState() => _SQLDocumentationScreenState();
}

class _SQLDocumentationScreenState extends State<SQLDocumentationScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Navigation items
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      title: 'SQL Basics',
      icon: Icons.code,
      route: '/sql-basics',
    ),
    NavigationItem(
      title: 'Joins & Relations',
      icon: Icons.account_tree,
      route: '/joins-relations',
    ),
    NavigationItem(
      title: 'Functions',
      icon: Icons.functions,
      route: '/functions',
    ),
    NavigationItem(
      title: 'Database Design',
      icon: Icons.storage,
      route: '/database-design',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search documentation...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('SQL Documentation'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarksScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DocumentationProvider>(
        builder: (context, docProvider, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.indigo.shade700,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: docProvider.sections.keys
                        .map((section) => _buildNavItem(
                              NavigationItem(
                                title: section,
                                icon: _getIconForSection(section),
                                route: '/${section.toLowerCase().replaceAll(' ', '-')}',
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey.shade100,
                  child: _buildContent(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(NavigationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          // Handle navigation
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<DocumentationProvider>(
      builder: (context, docProvider, child) {
        final sections = docProvider.sections;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final sectionTitle = sections.keys.elementAt(index);
            final sectionItems = sections[sectionTitle] ?? [];
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0) const SizedBox(height: 24),
                Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...sectionItems.map((item) => _buildDocItem(item)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDocItem(String title) {
    final bool isMatch = _searchController.text.isEmpty ||
        title.toLowerCase().contains(_searchController.text.toLowerCase());

    if (!isMatch) {
      return const SizedBox.shrink();
    }

    return Consumer<DocumentationProvider>(
      builder: (context, docProvider, child) {
        final isBookmarked = docProvider.isBookmarked(title);
        
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
            title: Text(title),
            trailing: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? Colors.indigo : Colors.grey,
              ),
              onPressed: () {
                docProvider.toggleBookmark(title);
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
  }

  IconData _getIconForSection(String section) {
    switch (section) {
      case 'SQL Basics':
        return Icons.code;
      case 'Joins & Relations':
        return Icons.account_tree;
      case 'Functions':
        return Icons.functions;
      case 'Database Design':
        return Icons.storage;
      default:
        return Icons.article;
    }
  }
}

class NavigationItem {
  final String title;
  final IconData icon;
  final String route;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.route,
  });
} 