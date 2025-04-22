import 'package:flutter/material.dart';

class DocumentationScreen extends StatefulWidget {
  const DocumentationScreen({Key? key}) : super(key: key);

  @override
  _DocumentationScreenState createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  late ScrollController _scrollController;
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _showBackToTopButton = _scrollController.offset >= 300;
      });
    });
  }

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SQL Documentation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Will implement search later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Search Documentation',
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () {
              // Implement bookmark feature
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bookmarks feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Your Bookmarks',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(
              icon: Icon(Icons.code),
              text: 'SQL Basics',
            ),
            Tab(
              icon: Icon(Icons.account_tree),
              text: 'Joins & Relations',
            ),
            Tab(
              icon: Icon(Icons.functions),
              text: 'Functions',
            ),
            Tab(
              icon: Icon(Icons.schema),
              text: 'Database Design',
            ),
            Tab(
              icon: Icon(Icons.upgrade),
              text: 'Advanced SQL',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(0),
          _buildTabContent(1),
          _buildTabContent(2),
          _buildTabContent(3),
          _buildTabContent(4),
        ],
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.arrow_upward),
              mini: true,
              tooltip: 'Back to top',
            )
          : null,
    );
  }

  Widget _buildTabContent(int tabIndex) {
    final category = _getCategory(tabIndex);
    
    return Scrollbar(
      controller: _scrollController,
      thickness: 6,
      radius: const Radius.circular(8),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // Category header
          _buildCategoryHeader(category),

          const SizedBox(height: 24),
          
          // Topic grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 
                             MediaQuery.of(context).size.width > 600 ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: MediaQuery.of(context).size.width > 800 ? 3.2 :
                               MediaQuery.of(context).size.width > 600 ? 3.0 : 4.0,
            ),
            itemCount: category['topics'].length,
            itemBuilder: (context, index) {
              final topic = category['topics'][index];
              return _buildTopicCard(topic, category['color']);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(Map<String, dynamic> category) {
    final Color categoryColor = category['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withOpacity(0.8),
            categoryColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                category['icon'],
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoMono',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'RobotoMono',
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic, Color categoryColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDocumentationContent(topic),
        splashColor: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use LayoutBuilder to adapt to available width
              final bool isNarrow = constraints.maxWidth < 180;
              
              return isNarrow
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          topic['icon'] ?? Icons.article,
                          color: categoryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        topic['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (topic['subtitle'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            topic['subtitle'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          topic['icon'] ?? Icons.article,
                          color: categoryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              topic['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            if (topic['subtitle'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  topic['subtitle'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
            }
          ),
        ),
      ),
    );
  }

  void _showDocumentationContent(Map<String, dynamic> topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocContentScreen(topic: topic),
      ),
    );
  }

  Map<String, dynamic> _getCategory(int index) {
    return sqlDocumentation[index];
  }
}

class DocContentScreen extends StatelessWidget {
  final Map<String, dynamic> topic;

  const DocContentScreen({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          topic['title'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Topic bookmarked!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Bookmark this topic',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Share this topic',
          ),
        ],
      ),
      body: Scrollbar(
        controller: scrollController,
        thickness: 6,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        topic['icon'] ?? Icons.article,
                        color: Colors.indigo,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic['title'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'RobotoMono',
                              color: Colors.indigo,
                            ),
                          ),
                          if (topic['subtitle'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                topic['subtitle'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content based on topic title
              if (topic['title'] == 'SELECT Statement')
                _buildSelectStatementContent()
              else if (topic['title'] == 'WHERE Clause')
                _buildWhereClauseContent()
              else if (topic['title'] == 'ORDER BY Clause')
                _buildOrderByClauseContent()
              else if (topic['title'] == 'INSERT Statement')
                _buildInsertStatementContent()
              else if (topic['title'] == 'UPDATE Statement')
                _buildUpdateStatementContent()
              else if (topic['title'] == 'DELETE Statement')
                _buildDeleteStatementContent()
              else if (topic['title'] == 'GROUP BY Clause')
                _buildGroupByClauseContent()
              else if (topic['title'] == 'INNER JOIN')
                _buildInnerJoinContent()
              else if (topic['title'] == 'LEFT JOIN')
                _buildLeftJoinContent()
              else if (topic['title'] == 'RIGHT JOIN')
                _buildRightJoinContent()
              else if (topic['title'] == 'FULL JOIN')
                _buildFullJoinContent()
              else if (topic['title'] == 'CROSS JOIN')
                _buildCrossJoinContent()
              else if (topic['title'] == 'Self JOIN')
                _buildSelfJoinContent()
              else if (topic['title'] == 'Aggregate Functions')
                _buildAggregateFunctionsContent()
              else if (topic['title'] == 'String Functions')
                _buildStringFunctionsContent()
              else if (topic['title'] == 'Numeric Functions')
                _buildNumericFunctionsContent()
              else if (topic['title'] == 'Date Functions')
                _buildDateFunctionsContent()
              else if (topic['title'] == 'Window Functions')
                _buildWindowFunctionsContent()
              else if (topic['title'] == 'Data Types')
                _buildDataTypesContent()
              else if (topic['title'] == 'Primary Keys')
                _buildPrimaryKeysContent()
              else if (topic['title'] == 'Foreign Keys')
                _buildForeignKeysContent()
              else if (topic['title'] == 'Normalization')
                _buildNormalizationContent()
              else if (topic['title'] == 'Indexes')
                _buildIndexesContent()
              else if (topic['title'] == 'Constraints')
                _buildConstraintsContent()
              else if (topic['title'] == 'Subqueries')
                _buildSubqueriesContent()
              else if (topic['title'] == 'Common Table Expressions')
                _buildCommonTableExpressionsContent()
              else if (topic['title'] == 'Stored Procedures')
                _buildStoredProceduresContent()
              else if (topic['title'] == 'Triggers')
                _buildTriggersContent()
              else if (topic['title'] == 'Transactions')
                _buildTransactionsContent()
              else if (topic['title'] == 'Views')
                _buildViewsContent()
              else
                const Text(
                  'Detailed documentation content will be shown here. We are working on adding comprehensive content for all SQL topics.',
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectStatementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The SELECT statement is one of the most fundamental SQL commands used to retrieve data from one or more tables in a database.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'SELECT column1, column2, ... \nFROM table_name;'
        ),
        const SizedBox(height: 20),
        
        // Description Section
        _buildSectionHeader('Key Components'),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'SELECT',
          content: 'Specifies which columns to include in the query results. Use an asterisk (*) to retrieve all columns.',
          icon: Icons.view_column,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'FROM',
          content: 'Specifies the table or tables from which to retrieve data.',
          icon: Icons.table_chart,
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Select all columns',
          description: 'Retrieve all columns from the customers table:',
          code: 'SELECT * \nFROM customers;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Select specific columns',
          description: 'Retrieve only the name and email columns from the customers table:',
          code: 'SELECT name, email \nFROM customers;',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'Select with column aliases',
          description: 'Retrieve columns with custom names in the result set:',
          code: 'SELECT \n  first_name AS "First Name", \n  last_name AS "Last Name" \nFROM employees;',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Select with calculations',
          description: 'Perform calculations in the SELECT statement:',
          code: 'SELECT \n  product_name, \n  unit_price, \n  units_in_stock, \n  unit_price * units_in_stock AS inventory_value \nFROM products;',
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Avoid using SELECT * in production code - specify only the columns you need',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use meaningful column aliases for calculated fields',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider performance implications when selecting from large tables',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use appropriate filtering with WHERE clauses to limit data retrieval',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('WHERE Clause'),
            _buildChip('ORDER BY Clause'),
            _buildChip('GROUP BY Clause'),
            _buildChip('HAVING Clause'),
            _buildChip('DISTINCT Keyword'),
            _buildChip('Joins'),
          ],
        ),
      ],
    );
  }

  Widget _buildWhereClauseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The WHERE clause is used to filter records in SQL queries. It allows you to extract only the records that fulfill a specified condition.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        const Text(
          'The WHERE clause is used with SELECT, UPDATE, and DELETE statements to filter records based on specific conditions.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'SELECT column1, column2, ... \nFROM table_name \nWHERE condition;'
        ),
        const SizedBox(height: 20),
        
        // Operators Section
        _buildSectionHeader('Common Operators'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.withOpacity(0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• = (Equal)', style: TextStyle(fontSize: 15, height: 1.5)),
              Text('• <> (Not equal)', style: TextStyle(fontSize: 15, height: 1.5)),
              Text('• > (Greater than)', style: TextStyle(fontSize: 15, height: 1.5)),
              Text('• < (Less than)', style: TextStyle(fontSize: 15, height: 1.5)),
              Text('• >= (Greater than or equal)', style: TextStyle(fontSize: 15, height: 1.5)),
              Text('• <= (Less than or equal)', style: TextStyle(fontSize: 15, height: 1.5)),
              Text('• BETWEEN (Between a range)', style: TextStyle(fontSize: 15, height: 1.5)),
              Text('• LIKE (Pattern matching)', style: TextStyle(fontSize: 15, height: 1.5)),
              Text('• IN (Match any in a list)', style: TextStyle(fontSize: 15, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Basic comparison',
          description: 'Find products with price greater than 50:',
          code: 'SELECT product_name, price \nFROM products \nWHERE price > 50;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Multiple conditions',
          description: 'Find US customers who are 21 or older:',
          code: 'SELECT name, email \nFROM customers \nWHERE country = \'USA\' AND age >= 21;',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'Using IN operator',
          description: 'Find employees in specific departments:',
          code: 'SELECT employee_name, department \nFROM employees \nWHERE department IN (\'Sales\', \'Marketing\', \'IT\');',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Using BETWEEN operator',
          description: 'Find products within a price range:',
          code: 'SELECT product_name, price \nFROM products \nWHERE price BETWEEN 10 AND 50;',
        ),
        const SizedBox(height: 16),
        
        // Example 5
        _buildExampleCard(
          title: 'Using LIKE for pattern matching',
          description: 'Find names starting with "A":',
          code: 'SELECT first_name, last_name \nFROM customers \nWHERE first_name LIKE \'A%\';',
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Use parentheses to make complex conditions clearer',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be careful with NULL values - use IS NULL and IS NOT NULL',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider creating indexes for columns frequently used in WHERE clauses',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use parameterized queries to prevent SQL injection',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderByClauseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The ORDER BY clause is used to sort the result set of a SQL query based on one or more columns, either in ascending or descending order.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'SELECT column1, column2, ... \nFROM table_name \nORDER BY column1 [ASC|DESC], column2 [ASC|DESC], ...'
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ASC (Ascending): Default sort order if not specified. Sorts from smallest to largest, A to Z.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• DESC (Descending): Sorts from largest to smallest, Z to A.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Sort by single column',
          description: 'Sort customers by their last name in alphabetical order:',
          code: 'SELECT customer_id, first_name, last_name \nFROM customers \nORDER BY last_name ASC;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Sort by multiple columns',
          description: 'Sort employees by department (ascending) and salary (descending):',
          code: 'SELECT employee_id, first_name, last_name, department, salary \nFROM employees \nORDER BY department ASC, salary DESC;',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'Sort by column position',
          description: 'You can also sort by column position (1-based indexing):',
          code: 'SELECT product_name, category, price \nFROM products \nORDER BY 2 ASC, 3 DESC; -- Sort by category ASC and price DESC',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Sort with expressions',
          description: 'Sort products by their price per unit:',
          code: 'SELECT product_name, price, quantity, (price / quantity) AS unit_price \nFROM products \nORDER BY unit_price DESC;',
        ),
        const SizedBox(height: 20),
        
        // Advanced Features
        _buildSectionHeader('Advanced Features'),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'NULLS FIRST / NULLS LAST',
          content: 'Some database systems allow controlling where NULL values appear in sorted results using NULLS FIRST or NULLS LAST modifiers.',
          icon: Icons.sort,
        ),
        const SizedBox(height: 12),
        _buildCodeBlock(
          '-- PostgreSQL example\nSELECT product_name, release_date \nFROM products \nORDER BY release_date DESC NULLS LAST;'
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• For large result sets, ensure columns used in ORDER BY are indexed for better performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Prefer sorting by column names instead of positions for better code readability',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be aware that ORDER BY operations can be resource-intensive on large tables',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• When using ORDER BY with LIMIT, make sure the ORDER BY produces consistent results',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('GROUP BY Clause'),
            _buildChip('LIMIT Clause'),
            _buildChip('SELECT Statement'),
            _buildChip('WHERE Clause'),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 14,
          height: 1.5,
          fontFamily: 'RobotoMono',
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content, required IconData icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.indigo,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard({required String title, required String description, required String code}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.code, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 14,
                  height: 1.5,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.indigo.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.indigo),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildInsertStatementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The INSERT statement is used to add new records (rows) into a database table.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          '-- Method 1: Specify both columns and values\nINSERT INTO table_name (column1, column2, column3, ...)\nVALUES (value1, value2, value3, ...);\n\n-- Method 2: Insert values for all columns in order\nINSERT INTO table_name\nVALUES (value1, value2, value3, ...);'
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Insert a single row with specific columns',
          description: 'Add a new customer, specifying only certain columns:',
          code: 'INSERT INTO customers (first_name, last_name, email, city)\nVALUES (\'John\', \'Doe\', \'john.doe@example.com\', \'New York\');',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Insert a row with all columns',
          description: 'Add a product with values for all columns in table order:',
          code: 'INSERT INTO products\nVALUES (101, \'Wireless Keyboard\', \'Electronics\', 49.99, 25);',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'Insert multiple rows at once',
          description: 'Add several records in a single statement:',
          code: 'INSERT INTO employees (employee_id, name, department, salary)\nVALUES\n  (1001, \'Alice Smith\', \'Marketing\', 65000),\n  (1002, \'Bob Johnson\', \'Engineering\', 78000),\n  (1003, \'Carol Williams\', \'Sales\', 72000);',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Insert data from another table',
          description: 'Insert records based on a SELECT query:',
          code: 'INSERT INTO customers_backup (customer_id, name, email)\nSELECT customer_id, name, email\nFROM customers\nWHERE signup_date < \'2023-01-01\';',
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Always specify the column names to avoid issues if table structure changes',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use prepared statements with parameters for dynamic values to prevent SQL injection',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• For large amounts of data, consider batch inserts for better performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be aware of auto-increment columns and default values when designing your INSERT statements',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('UPDATE Statement'),
            _buildChip('DELETE Statement'),
            _buildChip('SELECT Statement'),
            _buildChip('Constraints'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildUpdateStatementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The UPDATE statement is used to modify existing records in a database table.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'UPDATE table_name\nSET column1 = value1, column2 = value2, ...\nWHERE condition;'
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'WARNING: If you omit the WHERE clause, all records in the table will be updated!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Update a single column',
          description: 'Change the email address for a specific customer:',
          code: 'UPDATE customers\nSET email = \'newemail@example.com\'\nWHERE customer_id = 1005;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Update multiple columns',
          description: 'Update both the price and stock quantity for a product:',
          code: 'UPDATE products\nSET price = 24.99, stock_quantity = 50\nWHERE product_id = 101;',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'Update with calculated values',
          description: 'Increase all employee salaries by 5%:',
          code: 'UPDATE employees\nSET salary = salary * 1.05\nWHERE department = \'Sales\';',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Update with subquery',
          description: 'Update product categories based on another table:',
          code: 'UPDATE products p\nSET category = (\n  SELECT category_name\n  FROM categories c\n  WHERE c.category_id = p.category_id\n)\nWHERE EXISTS (\n  SELECT 1 FROM categories c WHERE c.category_id = p.category_id\n);',
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Always include a WHERE clause unless you specifically want to update all rows',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Test your UPDATE statements with a SELECT using the same WHERE clause first',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider using transactions for complex updates to ensure data integrity',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use prepared statements for dynamic values to prevent SQL injection',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('INSERT Statement'),
            _buildChip('DELETE Statement'),
            _buildChip('WHERE Clause'),
            _buildChip('Transactions'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDeleteStatementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The DELETE statement is used to remove existing records from a database table.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'DELETE FROM table_name\nWHERE condition;'
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'WARNING: If you omit the WHERE clause, all records in the table will be deleted!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Delete specific records',
          description: 'Remove a customer with a specific ID:',
          code: 'DELETE FROM customers\nWHERE customer_id = 1005;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Delete multiple records',
          description: 'Remove all products in a specific category:',
          code: 'DELETE FROM products\nWHERE category = \'Discontinued\';',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'Delete with complex conditions',
          description: 'Remove customers who haven\'t placed an order in the last year:',
          code: 'DELETE FROM customers\nWHERE customer_id NOT IN (\n  SELECT DISTINCT customer_id\n  FROM orders\n  WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)\n);',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Truncate a table',
          description: 'Remove all records from a table (faster than DELETE FROM without WHERE):',
          code: '-- Note: TRUNCATE TABLE removes all data but does not log individual row deletions\n-- and cannot be rolled back in most database systems\nTRUNCATE TABLE logs;',
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Always include a WHERE clause unless you specifically want to delete all rows',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Test your DELETE statements with a SELECT using the same WHERE clause first',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be careful with foreign key constraints when deleting records',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider using transactions for complex deletes to ensure data integrity',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('INSERT Statement'),
            _buildChip('UPDATE Statement'),
            _buildChip('WHERE Clause'),
            _buildChip('Transactions'),
            _buildChip('TRUNCATE TABLE'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildGroupByClauseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The GROUP BY clause is used to organize data into groups based on one or more columns, often used with aggregate functions to perform calculations on each group.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'SELECT column1, column2, ..., aggregate_function(column)\nFROM table_name\nWHERE condition\nGROUP BY column1, column2, ...\nHAVING condition;'
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Aggregate Functions',
          content: 'Common aggregate functions used with GROUP BY include COUNT(), SUM(), AVG(), MIN(), and MAX().',
          icon: Icons.functions,
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Simple grouping',
          description: 'Count the number of customers in each country:',
          code: 'SELECT country, COUNT(*) AS customer_count\nFROM customers\nGROUP BY country\nORDER BY customer_count DESC;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Multiple grouping columns',
          description: 'Calculate average order value by category and year:',
          code: 'SELECT category, YEAR(order_date) AS year, AVG(order_total) AS avg_order\nFROM orders\nJOIN products ON orders.product_id = products.product_id\nGROUP BY category, YEAR(order_date)\nORDER BY category, year;',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'Using HAVING clause',
          description: 'Find departments with more than 5 employees:',
          code: 'SELECT department, COUNT(*) AS employee_count\nFROM employees\nGROUP BY department\nHAVING COUNT(*) > 5\nORDER BY employee_count DESC;',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Multiple aggregate functions',
          description: 'Calculate statistics for each product category:',
          code: 'SELECT category,\n  COUNT(*) AS product_count,\n  AVG(price) AS avg_price,\n  MIN(price) AS min_price,\n  MAX(price) AS max_price,\n  SUM(stock_quantity) AS total_inventory\nFROM products\nGROUP BY category;',
        ),
        const SizedBox(height: 20),
        
        // Important Concepts
        _buildSectionHeader('Important Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'HAVING vs WHERE',
          content: 'WHERE filters rows before grouping, while HAVING filters groups after the GROUP BY is applied. HAVING is used with aggregate functions, WHERE is not.',
          icon: Icons.compare_arrows,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'SELECT columns',
          content: 'In standard SQL, all columns in the SELECT statement must either be in the GROUP BY clause or be used with an aggregate function.',
          icon: Icons.view_column,
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Use WHERE to filter rows before grouping for better performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Create indexes on columns used in GROUP BY clause for large datasets',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be aware that GROUP BY can be resource-intensive on large tables',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider using CUBE or ROLLUP extensions (in supporting databases) for hierarchical grouping',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Aggregate Functions'),
            _buildChip('HAVING Clause'),
            _buildChip('ORDER BY Clause'),
            _buildChip('SELECT Statement'),
          ],
        ),
      ],
    );
  }

  Widget _buildInnerJoinContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The INNER JOIN keyword selects records that have matching values in both tables being joined. It returns only the rows where there is a match in both tables based on the join condition.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'SELECT columns\nFROM table1\nINNER JOIN table2\nON table1.column = table2.column;'
        ),
        const SizedBox(height: 20),
        
        // Visual Explanation
        _buildSectionHeader('Visual Representation'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('Table A', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('Table B', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Only matching rows from both tables are included in the result',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Basic INNER JOIN',
          description: 'Join customers and orders tables to find customers who have placed orders:',
          code: 'SELECT customers.customer_name, orders.order_id, orders.order_date\nFROM customers\nINNER JOIN orders\nON customers.customer_id = orders.customer_id;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'INNER JOIN with WHERE clause',
          description: 'Join customers and orders to find high-value orders:',
          code: 'SELECT customers.customer_name, orders.order_id, orders.amount\nFROM customers\nINNER JOIN orders\nON customers.customer_id = orders.customer_id\nWHERE orders.amount > 1000\nORDER BY orders.amount DESC;',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'INNER JOIN with multiple tables',
          description: 'Join three tables to get order details:',
          code: 'SELECT c.customer_name, o.order_id, o.order_date, p.product_name, od.quantity\nFROM customers c\nINNER JOIN orders o ON c.customer_id = o.customer_id\nINNER JOIN order_details od ON o.order_id = od.order_id\nINNER JOIN products p ON od.product_id = p.product_id;',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'INNER JOIN with table aliases',
          description: 'Using aliases for shorter query:',
          code: 'SELECT e.employee_name, d.department_name\nFROM employees e\nINNER JOIN departments d\nON e.department_id = d.department_id;',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Matching Records Only',
          content: 'INNER JOIN returns only the rows where there is a match in both tables. If a record in one table does not have a matching record in the joined table, it will NOT appear in the results.',
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Join Conditions',
          content: 'The ON clause specifies the condition that determines which records will be joined. Typically this is based on primary key and foreign key relationships.',
          icon: Icons.link,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Multiple Join Conditions',
          content: 'You can use AND or OR operators to create more complex join conditions with multiple criteria.',
          icon: Icons.account_tree,
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Always use meaningful table aliases for readability in complex joins',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Ensure the columns used in join conditions are indexed for better performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be specific about which columns to select instead of using SELECT *',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider the order of joins in complex queries - join smaller result sets first when possible',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('LEFT JOIN'),
            _buildChip('RIGHT JOIN'),
            _buildChip('FULL JOIN'),
            _buildChip('CROSS JOIN'),
            _buildChip('Self JOIN'),
          ],
        ),
      ],
    );
  }

  Widget _buildLeftJoinContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The LEFT JOIN keyword returns all records from the left table (table1), and the matching records from the right table (table2). The result is NULL from the right side if there is no match.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'SELECT columns\nFROM table1\nLEFT JOIN table2\nON table1.column = table2.column;'
        ),
        const SizedBox(height: 20),
        
        // Visual Explanation
        _buildSectionHeader('Visual Representation'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('Table A\n(LEFT)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('Table B', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'All rows from left table + matching rows from right table',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Basic LEFT JOIN',
          description: 'Find all customers and their orders (if they have any):',
          code: 'SELECT customers.customer_name, orders.order_id, orders.order_date\nFROM customers\nLEFT JOIN orders\nON customers.customer_id = orders.customer_id;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Finding missing relationships',
          description: 'Identify customers who have never placed an order:',
          code: 'SELECT customers.customer_name, orders.order_id\nFROM customers\nLEFT JOIN orders\nON customers.customer_id = orders.customer_id\nWHERE orders.order_id IS NULL;',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'LEFT JOIN with aggregate function',
          description: 'Count the number of orders for each customer:',
          code: 'SELECT c.customer_name, COUNT(o.order_id) AS order_count\nFROM customers c\nLEFT JOIN orders o ON c.customer_id = o.customer_id\nGROUP BY c.customer_name\nORDER BY order_count DESC;',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Multiple LEFT JOINs',
          description: 'Get customer information with their orders and shipping details:',
          code: 'SELECT c.customer_name, o.order_id, o.order_date, s.shipping_method, s.tracking_number\nFROM customers c\nLEFT JOIN orders o ON c.customer_id = o.customer_id\nLEFT JOIN shipping s ON o.order_id = s.order_id\nORDER BY c.customer_name, o.order_date DESC;',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'NULL Values',
          content: 'When there is no match in the right table, the result will contain NULL values for all right table columns.',
          icon: Icons.highlight_off,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'All Left Records Preserved',
          content: 'Every record from the left table will appear in the results at least once, even if there are no matching records in the right table.',
          icon: Icons.arrow_forward,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Common Use Cases',
          content: 'LEFT JOIN is particularly useful for finding records that don\'t have related records, reporting on all items regardless of activity, and creating complete datasets with optional related information.',
          icon: Icons.lightbulb,
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Be mindful of the table order - which table is "left" matters significantly',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use IS NULL in the WHERE clause to find records with no matches',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider using COALESCE() function to replace NULL values with meaningful defaults',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• When using aggregate functions with LEFT JOIN, understand how NULLs affect calculations',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('INNER JOIN'),
            _buildChip('RIGHT JOIN'),
            _buildChip('FULL JOIN'),
            _buildChip('IS NULL'),
            _buildChip('COALESCE()'),
          ],
        ),
      ],
    );
  }

  Widget _buildRightJoinContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The RIGHT JOIN keyword returns all records from the right table (table2), and the matching records from the left table (table1). The result is NULL from the left side if there is no match.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'SELECT columns\nFROM table1\nRIGHT JOIN table2\nON table1.column = table2.column;'
        ),
        const SizedBox(height: 20),
        
        // Visual Explanation
        _buildSectionHeader('Visual Representation'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('Table A', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('Table B\n(RIGHT)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'All rows from right table + matching rows from left table',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Basic RIGHT JOIN',
          description: 'Find all departments and their employees (if any):',
          code: 'SELECT employees.employee_name, departments.department_name\nFROM employees\nRIGHT JOIN departments\nON employees.department_id = departments.department_id;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Finding departments without employees',
          description: 'Identify departments that have no employees assigned:',
          code: 'SELECT departments.department_name, employees.employee_id\nFROM employees\nRIGHT JOIN departments\nON employees.department_id = departments.department_id\nWHERE employees.employee_id IS NULL;',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'RIGHT JOIN with aggregate function',
          description: 'Count employees in each department, including departments with zero employees:',
          code: 'SELECT d.department_name, COUNT(e.employee_id) AS employee_count\nFROM employees e\nRIGHT JOIN departments d ON e.department_id = d.department_id\nGROUP BY d.department_name\nORDER BY employee_count;',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Multiple RIGHT JOINs',
          description: 'Get all possible locations with their departments and employees (if any):',
          code: 'SELECT l.location_name, d.department_name, e.employee_name\nFROM employees e\nRIGHT JOIN departments d ON e.department_id = d.department_id\nRIGHT JOIN locations l ON d.location_id = l.location_id\nORDER BY l.location_name, d.department_name;',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'NULL Values',
          content: 'When there is no match in the left table, the result will contain NULL values for all left table columns.',
          icon: Icons.highlight_off,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'All Right Records Preserved',
          content: 'Every record from the right table will appear in the results at least once, even if there are no matching records in the left table.',
          icon: Icons.arrow_back,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Relationship to LEFT JOIN',
          content: 'A RIGHT JOIN can always be rewritten as a LEFT JOIN by swapping the order of the tables. Which one to use depends on the logical flow of your query.',
          icon: Icons.compare_arrows,
        ),
        const SizedBox(height: 20),
        
        // Database Support Note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Note: Not all database systems support RIGHT JOIN. For example, SQLite does not have RIGHT JOIN support. In these cases, you can rewrite your query using LEFT JOIN by switching the table order.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• For consistency in large code bases, consider standardizing on either LEFT or RIGHT JOINs to make queries more predictable',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use IS NULL in the WHERE clause to find right table records with no matches',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be cautious when joining large tables with RIGHT JOIN as performance can suffer',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider portability issues if your application might use different database systems',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('INNER JOIN'),
            _buildChip('LEFT JOIN'),
            _buildChip('FULL JOIN'),
            _buildChip('IS NULL'),
            _buildChip('Cross Database Development'),
          ],
        ),
      ],
    );
  }

  Widget _buildFullJoinContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The FULL JOIN keyword returns all records when there is a match in either left (table1) or right (table2) table records. It combines the results of both LEFT JOIN and RIGHT JOIN.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'SELECT columns\nFROM table1\nFULL [OUTER] JOIN table2\nON table1.column = table2.column;'
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• The word "OUTER" is optional and often omitted',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Not all database systems support FULL JOIN (notably MySQL and SQLite)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Visual Explanation
        _buildSectionHeader('Visual Representation'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('Table A', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('Table B', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'All rows from both tables, with NULL values where there are no matches',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Basic FULL JOIN',
          description: 'Combine all records from students and enrollments tables:',
          code: 'SELECT s.student_id, s.student_name, e.course_id, e.enrollment_date\nFROM students s\nFULL JOIN enrollments e\nON s.student_id = e.student_id;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Finding unmatched records in both tables',
          description: 'Find students not enrolled in any course and courses with no students:',
          code: 'SELECT s.student_id, s.student_name, e.course_id\nFROM students s\nFULL JOIN enrollments e ON s.student_id = e.student_id\nWHERE s.student_id IS NULL OR e.course_id IS NULL;',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'Alternative to FULL JOIN in MySQL',
          description: 'For databases without FULL JOIN support, you can use UNION of LEFT and RIGHT JOINs:',
          code: '-- Alternative to FULL JOIN using UNION\nSELECT s.student_id, s.student_name, e.course_id\nFROM students s\nLEFT JOIN enrollments e ON s.student_id = e.student_id\n\nUNION\n\nSELECT s.student_id, s.student_name, e.course_id\nFROM students s\nRIGHT JOIN enrollments e ON s.student_id = e.student_id\nWHERE s.student_id IS NULL;',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Multiple FULL JOINs',
          description: 'Combine data from students, enrollments, and courses tables:',
          code: 'SELECT s.student_name, e.enrollment_date, c.course_name\nFROM students s\nFULL JOIN enrollments e ON s.student_id = e.student_id\nFULL JOIN courses c ON e.course_id = c.course_id\nORDER BY s.student_name, c.course_name;',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Complete Dataset',
          content: 'A FULL JOIN returns all records from both tables, whether they have matches or not. It\'s the most inclusive type of join.',
          icon: Icons.all_inclusive,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'NULL Values',
          content: 'When a row in either table doesn\'t have a matching row in the other table, the result will contain NULL values for the columns from the non-matching table.',
          icon: Icons.highlight_off,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Use Cases',
          content: 'FULL JOINs are particularly useful for data integration, finding missing relationships, and creating complete reports that must include all data.',
          icon: Icons.cases,
        ),
        const SizedBox(height: 20),
        
        // Database Support Note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, color: Colors.red),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Important: FULL JOIN is not supported in MySQL or SQLite. In these databases, you need to use a UNION of a LEFT JOIN and a RIGHT JOIN to achieve the same result.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Be aware of potential performance implications - FULL JOINs can produce large result sets',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use appropriate filters in the WHERE clause to limit results when possible',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider database portability if your application might need to work with multiple database systems',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use IS NULL checks to find unmatched records in either table',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('INNER JOIN'),
            _buildChip('LEFT JOIN'),
            _buildChip('RIGHT JOIN'),
            _buildChip('UNION'),
            _buildChip('IS NULL'),
          ],
        ),
      ],
    );
  }

  Widget _buildCrossJoinContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The CROSS JOIN keyword returns the Cartesian product of two tables, which means it returns all possible combinations of rows from both tables. Each row from the first table is combined with each row from the second table.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          '-- Method 1: Explicit CROSS JOIN syntax\nSELECT columns\nFROM table1\nCROSS JOIN table2;\n\n-- Method 2: Implicit cross join syntax\nSELECT columns\nFROM table1, table2;'
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Basic CROSS JOIN',
          description: 'Generate all possible combinations of colors and sizes for a product:',
          code: 'SELECT c.color_name, s.size_name\nFROM colors c\nCROSS JOIN sizes s;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Using implicit syntax',
          description: 'Generate the same combinations using the comma syntax:',
          code: 'SELECT c.color_name, s.size_name\nFROM colors c, sizes s;',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Cartesian Product',
          content: 'A CROSS JOIN produces the mathematical Cartesian product of all rows from the tables in the join. The result set has one row for each possible combination of rows from the tables.',
          icon: Icons.grid_on,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'No Join Condition',
          content: 'Unlike other joins (INNER, LEFT, etc.), a CROSS JOIN does not have a join condition or ON clause. Every row from the first table is matched with every row from the second table.',
          icon: Icons.clear_all,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Result Set Size',
          content: 'The number of rows in the result set will be equal to the number of rows in the first table multiplied by the number of rows in the second table.',
          icon: Icons.calculate,
        ),
        const SizedBox(height: 20),
        
        // Warning Note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, color: Colors.red),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Warning: Using CROSS JOIN on large tables can result in extremely large result sets and may cause performance issues. Always be cautious and consider the size of your tables before using CROSS JOIN.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Common Use Cases
        _buildSectionHeader('Common Use Cases'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Generating product combinations (e.g., all possible color/size combinations)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Creating date/time dimension tables for data warehousing',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Calculating all possible matchups in competitions or scheduling',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('INNER JOIN'),
            _buildChip('Cartesian Product'),
            _buildChip('Performance Tuning'),
            _buildChip('WHERE Clause'),
          ],
        ),
      ],
    );
  }

  Widget _buildSelfJoinContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A Self JOIN is a regular join operation where a table is joined with itself. This is useful when you want to compare rows within the same table or when a table contains hierarchical data (like employee-manager relationships).',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax Section
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'SELECT a.column_name, b.column_name\nFROM table_name a\nJOIN table_name b\nON a.common_field = b.common_field;'
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• Notice that table aliases (a, b) are essential in self joins to distinguish between the two instances of the same table',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• You can use any join type (INNER, LEFT, RIGHT, FULL) with a self join',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Examples Section
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1
        _buildExampleCard(
          title: 'Employee-Manager Relationship',
          description: 'Find all employees and their managers:',
          code: 'SELECT e.employee_name AS "Employee",\n       m.employee_name AS "Manager"\nFROM employees e\nINNER JOIN employees m ON e.manager_id = m.employee_id;',
        ),
        const SizedBox(height: 16),
        
        // Example 2
        _buildExampleCard(
          title: 'Finding Employees with the Same Job',
          description: 'Identify employees who have the same job title:',
          code: 'SELECT a.employee_name, b.employee_name, a.job_title\nFROM employees a\nINNER JOIN employees b ON a.job_title = b.job_title\nWHERE a.employee_id < b.employee_id\nORDER BY a.job_title, a.employee_name;',
        ),
        const SizedBox(height: 16),
        
        // Example 3
        _buildExampleCard(
          title: 'Self LEFT JOIN for Hierarchy',
          description: 'Show all employees, including those without a manager:',
          code: 'SELECT e.employee_name AS "Employee",\n       COALESCE(m.employee_name, \'Top Level\') AS "Manager"\nFROM employees e\nLEFT JOIN employees m ON e.manager_id = m.employee_id\nORDER BY m.employee_name, e.employee_name;',
        ),
        const SizedBox(height: 16),
        
        // Example 4
        _buildExampleCard(
          title: 'Finding Nodes in a Tree Structure',
          description: 'Navigate a hierarchical category structure:',
          code: 'SELECT child.category_name AS "Child Category",\n       parent.category_name AS "Parent Category"\nFROM categories child\nJOIN categories parent ON child.parent_id = parent.category_id;',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Table Aliases',
          content: 'Table aliases are required in self joins to give each instance of the table a distinct reference name in the query.',
          icon: Icons.badge,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Hierarchical Data',
          content: 'Self joins are particularly useful for querying hierarchical data structures, like organizational charts, categories and subcategories, or any parent-child relationship stored in a single table.',
          icon: Icons.account_tree,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Avoiding Duplicates',
          content: 'When finding relationships between rows, use conditions like "a.id < b.id" to avoid duplicate pairs and self-matching.',
          icon: Icons.filter_alt,
        ),
        const SizedBox(height: 20),
        
        // Use Cases
        _buildSectionHeader('Common Use Cases'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Employee-manager relationships in organizational charts',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Category and subcategory relationships',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Finding duplicate records within a table',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Comparing items in the same table (e.g., products with similar prices)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Representing graph-like data where nodes connect to other nodes',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Best Practices Section
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Always use meaningful table aliases to improve query readability',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be aware of performance implications when joining a large table to itself',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use appropriate indexes on join columns for better performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider alternative designs for deeply nested hierarchies (such as adjacency lists or nested sets)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics Section
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Table Aliases'),
            _buildChip('Hierarchical Data'),
            _buildChip('INNER JOIN'),
            _buildChip('LEFT JOIN'),
            _buildChip('Recursive Queries'),
          ],
        ),
      ],
    );
  }

  Widget _buildAggregateFunctionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aggregate functions perform calculations on a set of values and return a single value. They operate on multiple rows and are commonly used with the GROUP BY clause to summarize data.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Most Common Aggregate Functions
        _buildSectionHeader('Common Aggregate Functions'),
        const SizedBox(height: 16),
        
        // COUNT()
        _buildExampleCard(
          title: 'COUNT()',
          description: 'Returns the number of rows that match a specified criterion:',
          code: '-- Count all rows in a table\nSELECT COUNT(*) FROM employees;\n\n-- Count non-NULL values in a column\nSELECT COUNT(email) FROM employees;\n\n-- Count distinct values\nSELECT COUNT(DISTINCT department) FROM employees;',
        ),
        const SizedBox(height: 16),
        
        // SUM()
        _buildExampleCard(
          title: 'SUM()',
          description: 'Calculates the sum of a set of values:',
          code: '-- Calculate total salary across all employees\nSELECT SUM(salary) FROM employees;\n\n-- Calculate total salary by department\nSELECT department, SUM(salary) AS total_salary\nFROM employees\nGROUP BY department;',
        ),
        const SizedBox(height: 16),
        
        // AVG()
        _buildExampleCard(
          title: 'AVG()',
          description: 'Calculates the average value of a set of values:',
          code: '-- Calculate average employee salary\nSELECT AVG(salary) FROM employees;\n\n-- Calculate average salary by department\nSELECT department, AVG(salary) AS avg_salary\nFROM employees\nGROUP BY department;',
        ),
        const SizedBox(height: 16),
        
        // MIN()
        _buildExampleCard(
          title: 'MIN()',
          description: 'Returns the minimum value in a set of values:',
          code: '-- Find the lowest salary\nSELECT MIN(salary) FROM employees;\n\n-- Find the earliest hire date\nSELECT MIN(hire_date) FROM employees;\n\n-- Find minimum salary by department\nSELECT department, MIN(salary) AS min_salary\nFROM employees\nGROUP BY department;',
        ),
        const SizedBox(height: 16),
        
        // MAX()
        _buildExampleCard(
          title: 'MAX()',
          description: 'Returns the maximum value in a set of values:',
          code: '-- Find the highest salary\nSELECT MAX(salary) FROM employees;\n\n-- Find the most recent hire date\nSELECT MAX(hire_date) FROM employees;\n\n-- Find maximum salary by department\nSELECT department, MAX(salary) AS max_salary\nFROM employees\nGROUP BY department;',
        ),
        const SizedBox(height: 20),
        
        // Using with GROUP BY
        _buildSectionHeader('Using with GROUP BY'),
        const SizedBox(height: 12),
        const Text(
          'Aggregate functions are typically used with GROUP BY to perform calculations on groups of rows:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        _buildCodeBlock(
          'SELECT department, \n  COUNT(*) AS employee_count,\n  AVG(salary) AS avg_salary,\n  SUM(salary) AS total_salary,\n  MIN(salary) AS min_salary,\n  MAX(salary) AS max_salary\nFROM employees\nGROUP BY department\nORDER BY total_salary DESC;'
        ),
        const SizedBox(height: 20),
        
        // Additional functions
        _buildSectionHeader('Additional Aggregate Functions'),
        const SizedBox(height: 16),
        
        // GROUP_CONCAT / STRING_AGG
        _buildExampleCard(
          title: 'GROUP_CONCAT / STRING_AGG',
          description: 'Concatenates values from multiple rows into a single string (syntax varies by database):',
          code: '-- MySQL/SQLite\nSELECT department, GROUP_CONCAT(employee_name) AS employees\nFROM employees\nGROUP BY department;\n\n-- SQL Server\nSELECT department, STRING_AGG(employee_name, \',\') AS employees\nFROM employees\nGROUP BY department;\n\n-- PostgreSQL\nSELECT department, STRING_AGG(employee_name, \',\') AS employees\nFROM employees\nGROUP BY department;',
        ),
        const SizedBox(height: 16),
        
        // STDEV / STDEV_SAMP
        _buildExampleCard(
          title: 'STDEV / STDEV_SAMP',
          description: 'Calculates the statistical standard deviation of a set of values:',
          code: '-- SQL Server\nSELECT department, STDEV(salary) AS salary_stdev\nFROM employees\nGROUP BY department;\n\n-- PostgreSQL/Oracle\nSELECT department, STDDEV_SAMP(salary) AS salary_stdev\nFROM employees\nGROUP BY department;',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'NULL Handling',
          content: 'Aggregate functions typically ignore NULL values in their calculations (except COUNT(*), which counts all rows).',
          icon: Icons.do_not_disturb_alt,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'DISTINCT Keyword',
          content: 'Many aggregate functions can be combined with DISTINCT to operate only on unique values (e.g., COUNT(DISTINCT column)).',
          icon: Icons.auto_awesome,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'ALL Keyword',
          content: 'By default, aggregate functions use ALL implicitly, meaning they include all values. You can explicitly write SUM(ALL column).',
          icon: Icons.all_inclusive,
        ),
        const SizedBox(height: 20),
        
        // Using with HAVING
        _buildSectionHeader('Filtering Aggregate Results with HAVING'),
        const SizedBox(height: 12),
        const Text(
          'The HAVING clause allows you to filter the results of aggregate functions, similar to how WHERE filters rows:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        _buildCodeBlock(
          'SELECT department, COUNT(*) AS employee_count\nFROM employees\nGROUP BY department\nHAVING COUNT(*) > 5;'
        ),
        const SizedBox(height: 16),
        _buildCodeBlock(
          'SELECT department, AVG(salary) AS avg_salary\nFROM employees\nWHERE hire_date >= \'2020-01-01\'\nGROUP BY department\nHAVING AVG(salary) > 50000\nORDER BY avg_salary DESC;'
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Use WHERE to filter rows before applying aggregate functions for better performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use HAVING to filter based on the results of aggregate functions',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be aware of how each function handles NULL values in your data',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider indexing columns used in GROUP BY clauses for better performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use DISTINCT only when necessary, as it can impact performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('GROUP BY'),
            _buildChip('HAVING'),
            _buildChip('Window Functions'),
            _buildChip('NULL Values'),
            _buildChip('DISTINCT'),
          ],
        ),
      ],
    );
  }

  Widget _buildStringFunctionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'String functions allow you to manipulate and transform text data in SQL, such as extracting substrings, changing case, finding string length, and concatenating values. These functions are essential for text processing and data formatting in databases.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Common String Functions
        _buildSectionHeader('Common String Functions'),
        const SizedBox(height: 16),
        
        // CONCAT / ||
        _buildExampleCard(
          title: 'CONCAT / ||',
          description: 'Joins two or more strings together:',
          code: '-- Standard SQL & MySQL\nSELECT CONCAT(first_name, \' \', last_name) AS full_name\nFROM employees;\n\n-- Oracle, PostgreSQL, SQLite\nSELECT first_name || \' \' || last_name AS full_name\nFROM employees;\n\n-- SQL Server\nSELECT first_name + \' \' + last_name AS full_name\nFROM employees;',
        ),
        const SizedBox(height: 16),
        
        // UPPER / LOWER
        _buildExampleCard(
          title: 'UPPER / LOWER',
          description: 'Converts a string to uppercase or lowercase:',
          code: '-- Convert to uppercase\nSELECT UPPER(email) FROM users;\n\n-- Convert to lowercase\nSELECT LOWER(product_name) FROM products;\n\n-- Case-insensitive comparison\nSELECT * FROM customers\nWHERE LOWER(city) = \'london\';',
        ),
        const SizedBox(height: 16),
        
        // LENGTH / LEN
        _buildExampleCard(
          title: 'LENGTH / LEN / CHAR_LENGTH',
          description: 'Returns the length of a string in characters:',
          code: '-- Standard SQL, MySQL, PostgreSQL, SQLite\nSELECT LENGTH(description) AS desc_length\nFROM products;\n\n-- SQL Server\nSELECT LEN(description) AS desc_length\nFROM products;\n\n-- Find all products with short names\nSELECT * FROM products\nWHERE LENGTH(product_name) < 10;',
        ),
        const SizedBox(height: 16),
        
        // SUBSTRING / SUBSTR
        _buildExampleCard(
          title: 'SUBSTRING / SUBSTR',
          description: 'Extracts a portion of a string:',
          code: '-- Standard SQL & SQL Server\nSELECT SUBSTRING(phone_number, 1, 3) AS area_code\nFROM customers;\n\n-- MySQL, Oracle, PostgreSQL, SQLite\nSELECT SUBSTR(phone_number, 1, 3) AS area_code\nFROM customers;\n\n-- Extract domain from email\nSELECT SUBSTRING(email, POSITION(\'@\' IN email) + 1) AS domain\nFROM users;',
        ),
        const SizedBox(height: 16),
        
        // TRIM / LTRIM / RTRIM
        _buildExampleCard(
          title: 'TRIM / LTRIM / RTRIM',
          description: 'Removes leading and/or trailing spaces (or other specified characters):',
          code: '-- Remove spaces from both ends\nSELECT TRIM(product_name) FROM products;\n\n-- Remove leading spaces\nSELECT LTRIM(address) FROM customers;\n\n-- Remove trailing spaces\nSELECT RTRIM(notes) FROM orders;\n\n-- Remove specific characters\nSELECT TRIM(\'#\' FROM product_code) FROM products;',
        ),
        const SizedBox(height: 20),
        
        // Advanced String Functions
        _buildSectionHeader('Advanced String Functions'),
        const SizedBox(height: 16),
        
        // REPLACE
        _buildExampleCard(
          title: 'REPLACE',
          description: 'Replaces all occurrences of a substring with another substring:',
          code: 'SELECT REPLACE(phone_number, \'-\', \'\') AS clean_number\nFROM customers;\n\n-- Replace multiple characters\nSELECT REPLACE(REPLACE(product_code, \'-\', \'\'), \'#\', \'\') AS clean_code\nFROM products;',
        ),
        const SizedBox(height: 16),
        
        // POSITION / INSTR / CHARINDEX
        _buildExampleCard(
          title: 'POSITION / INSTR / CHARINDEX',
          description: 'Finds the position of a substring within a string:',
          code: '-- Standard SQL\nSELECT POSITION(\'@\' IN email) AS at_position\nFROM users;\n\n-- Oracle, MySQL\nSELECT INSTR(email, \'@\') AS at_position\nFROM users;\n\n-- SQL Server\nSELECT CHARINDEX(\'@\', email) AS at_position\nFROM users;',
        ),
        const SizedBox(height: 16),
        
        // LEFT / RIGHT
        _buildExampleCard(
          title: 'LEFT / RIGHT',
          description: 'Extracts a specified number of characters from the left or right side of a string:',
          code: '-- Extract first 3 characters\nSELECT LEFT(product_code, 3) AS product_category\nFROM products;\n\n-- Extract last 4 characters\nSELECT RIGHT(phone_number, 4) AS last_four_digits\nFROM customers;',
        ),
        const SizedBox(height: 16),
        
        // LPAD / RPAD
        _buildExampleCard(
          title: 'LPAD / RPAD',
          description: 'Pads a string to a specified length with a specified string:',
          code: '-- Pad on the left to create fixed-width fields\nSELECT LPAD(order_id, 10, \'0\') AS formatted_order_id\nFROM orders;\n\n-- Pad on the right\nSELECT RPAD(last_name, 20, \' \') AS fixed_width_name\nFROM employees;',
        ),
        const SizedBox(height: 20),
        
        // Pattern Matching
        _buildSectionHeader('Pattern Matching with LIKE and Regex'),
        const SizedBox(height: 12),
        const Text(
          'SQL provides several ways to perform pattern matching in strings:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        
        // LIKE Operator
        _buildExampleCard(
          title: 'LIKE Operator',
          description: 'Simple pattern matching with wildcards:',
          code: '-- Names starting with \'J\'\nSELECT * FROM employees\nWHERE first_name LIKE \'J%\';\n\n-- Email addresses at example.com\nSELECT * FROM users\nWHERE email LIKE \'%@example.com\';\n\n-- Exactly 5 character product codes\nSELECT * FROM products\nWHERE product_code LIKE \'_____\';\n\n-- Phone numbers containing \'555\'\nSELECT * FROM customers\nWHERE phone_number LIKE \'%555%\';',
        ),
        const SizedBox(height: 16),
        
        // Additional Pattern Examples
        _buildExampleCard(
          title: 'Additional Pattern Examples',
          description: 'More advanced pattern matching techniques:',
          code: '-- Names that start with A or B\nSELECT * FROM employees\nWHERE last_name LIKE \'[AB]%\';\n\n-- Finding phone numbers with specific format\nSELECT * FROM customers\nWHERE phone LIKE \'___-___-____\';\n\n-- Finding values not matching a pattern\nSELECT * FROM products\nWHERE product_code NOT LIKE \'TEST%\';',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Index-Based Positions',
          content: 'In most SQL databases, string positions are 1-indexed (the first character is at position 1), not 0-indexed as in many programming languages.',
          icon: Icons.looks_one,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'NULL Handling',
          content: 'Most string functions return NULL if any of the input arguments are NULL. This is important to consider when manipulating data that might contain NULL values.',
          icon: Icons.do_not_disturb_alt,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Database Differences',
          content: 'String function names and behaviors can vary significantly between database systems. Always check your specific database documentation.',
          icon: Icons.compare,
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Use TRIM functions on user input to avoid issues with leading/trailing spaces',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider case sensitivity requirements when comparing strings (use UPPER/LOWER for case-insensitive comparisons)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be aware of performance implications when using string functions on large datasets',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• For complex pattern matching, consider using regular expressions when available',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Remember that string manipulations in the database can be less efficient than in application code',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('LIKE Operator'),
            _buildChip('Regular Expressions'),
            _buildChip('Character Sets'),
            _buildChip('Collations'),
            _buildChip('Unicode Support'),
          ],
        ),
      ],
    );
  }

  Widget _buildNumericFunctionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Numeric functions perform mathematical operations on numeric data in SQL, allowing you to round values, calculate powers, find absolute values, and perform other mathematical calculations within your queries.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Numeric Functions
        _buildSectionHeader('Basic Numeric Functions'),
        const SizedBox(height: 16),
        
        // ROUND
        _buildExampleCard(
          title: 'ROUND',
          description: 'Rounds a number to a specified number of decimal places:',
          code: '-- Round to nearest whole number\nSELECT ROUND(price) FROM products;\n\n-- Round to 2 decimal places\nSELECT ROUND(price, 2) FROM products;\n\n-- Round down to the nearest hundred\nSELECT ROUND(sales, -2) FROM monthly_sales;',
        ),
        const SizedBox(height: 16),
        
        // CEIL / CEILING
        _buildExampleCard(
          title: 'CEIL / CEILING',
          description: 'Rounds a number up to the nearest integer:',
          code: 'SELECT CEIL(price) AS ceiling_price FROM products;\n\n-- SQL Server and MySQL\nSELECT CEILING(price) AS ceiling_price FROM products;',
        ),
        const SizedBox(height: 16),
        
        // FLOOR
        _buildExampleCard(
          title: 'FLOOR',
          description: 'Rounds a number down to the nearest integer:',
          code: 'SELECT FLOOR(price) AS floor_price FROM products;\n\n-- Calculate whole batches needed\nSELECT item_name, quantity, batch_size,\n       FLOOR((quantity + batch_size - 1) / batch_size) AS batches_needed\nFROM inventory;',
        ),
        const SizedBox(height: 16),
        
        // TRUNC / TRUNCATE
        _buildExampleCard(
          title: 'TRUNC / TRUNCATE',
          description: 'Truncates a number to a specified number of decimal places without rounding:',
          code: '-- Oracle, PostgreSQL\nSELECT TRUNC(price, 2) FROM products;\n\n-- MySQL\nSELECT TRUNCATE(price, 2) FROM products;\n\n-- Remove all decimal places\nSELECT TRUNC(measurement) FROM scientific_data;',
        ),
        const SizedBox(height: 16),
        
        // ABS
        _buildExampleCard(
          title: 'ABS',
          description: 'Returns the absolute (positive) value of a number:',
          code: 'SELECT ABS(temperature_difference) FROM climate_data;\n\n-- Find largest deviation regardless of direction\nSELECT product_id, ABS(target_inventory - current_inventory) AS inventory_deviation\nFROM inventory\nORDER BY inventory_deviation DESC;',
        ),
        const SizedBox(height: 20),
        
        // Advanced Numeric Functions
        _buildSectionHeader('Advanced Numeric Functions'),
        const SizedBox(height: 16),
        
        // POWER / POW
        _buildExampleCard(
          title: 'POWER / POW',
          description: 'Raises a number to the specified power:',
          code: '-- Calculate square\nSELECT POWER(side_length, 2) AS area FROM squares;\n\n-- Calculate cube\nSELECT POWER(side_length, 3) AS volume FROM cubes;\n\n-- Compound interest\nSELECT principal * POWER(1 + interest_rate, years) AS future_value\nFROM investments;',
        ),
        const SizedBox(height: 16),
        
        // SQRT
        _buildExampleCard(
          title: 'SQRT',
          description: 'Returns the square root of a number:',
          code: 'SELECT SQRT(area) AS side_length FROM squares;\n\n-- Calculate distance between two points\nSELECT SQRT(POWER(x2 - x1, 2) + POWER(y2 - y1, 2)) AS distance\nFROM points;',
        ),
        const SizedBox(height: 16),
        
        // MOD
        _buildExampleCard(
          title: 'MOD',
          description: 'Returns the remainder of a division operation:',
          code: '-- Check if number is even or odd\nSELECT product_id, \n       CASE WHEN MOD(product_id, 2) = 0 THEN \'Even\' ELSE \'Odd\' END AS even_odd\nFROM products;\n\n-- Group by remainder when divided by 5\nSELECT MOD(value, 5) AS remainder, COUNT(*) AS count\nFROM numbers\nGROUP BY MOD(value, 5);',
        ),
        const SizedBox(height: 16),
        
        // Random Numbers
        _buildExampleCard(
          title: 'RAND / RANDOM',
          description: 'Generates a random number (syntax varies by database):',
          code: '-- MySQL, SQL Server\nSELECT RAND() AS random_value;\n\n-- PostgreSQL\nSELECT RANDOM() AS random_value;\n\n-- Select random rows\nSELECT * FROM products\nORDER BY RAND()\nLIMIT 5;',
        ),
        const SizedBox(height: 20),
        
        // Trigonometric Functions
        _buildSectionHeader('Trigonometric Functions'),
        const SizedBox(height: 12),
        const Text(
          'Most database systems provide standard trigonometric functions:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• SIN, COS, TAN - Basic trigonometric functions',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• ASIN, ACOS, ATAN - Inverse trigonometric functions',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• ATAN2 - Calculates the arctangent of y/x coordinates',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• DEGREES, RADIANS - Convert between degrees and radians',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCodeBlock(
          '-- Calculate distance on Earth (Haversine formula)\nSELECT\n  3963.0 * ACOS(\n    SIN(RADIANS(lat1)) * SIN(RADIANS(lat2)) +\n    COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * COS(RADIANS(lon2 - lon1))\n  ) AS distance_miles\nFROM locations;'
        ),
        const SizedBox(height: 20),
        
        // Sign and Comparison Functions
        _buildSectionHeader('Sign and Comparison Functions'),
        const SizedBox(height: 16),
        
        // SIGN
        _buildExampleCard(
          title: 'SIGN',
          description: 'Returns the sign of a number (-1 for negative, 0, or 1 for positive):',
          code: 'SELECT\n  account_balance,\n  SIGN(account_balance) AS balance_status\nFROM accounts;\n\n-- Use in a CASE statement\nSELECT\n  transaction_amount,\n  CASE SIGN(transaction_amount)\n    WHEN -1 THEN \'Debit\'\n    WHEN 1 THEN \'Credit\'\n    ELSE \'No change\'\n  END AS transaction_type\nFROM transactions;',
        ),
        const SizedBox(height: 16),
        
        // GREATEST / LEAST
        _buildExampleCard(
          title: 'GREATEST / LEAST',
          description: 'Returns the largest or smallest value from a list of values:',
          code: '-- Find the higher of two scores\nSELECT student_id, GREATEST(exam1, exam2) AS best_score\nFROM grades;\n\n-- Find the lower of two prices\nSELECT product_id, LEAST(regular_price, sale_price) AS display_price\nFROM products;\n\n-- Ensure value is within range\nSELECT GREATEST(LEAST(value, 100), 0) AS clamped_value\nFROM measurements;',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Precision Considerations',
          content: 'Be aware of how rounding and precision affect your calculations, especially with financial data or other calculations requiring exact precision.',
          icon: Icons.precision_manufacturing,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'NULL Handling',
          content: 'Most numeric functions return NULL if any of the inputs are NULL. Consider using COALESCE or IFNULL to handle NULL values.',
          icon: Icons.do_not_disturb_alt,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Performance Impact',
          content: 'Complex mathematical operations on large datasets can impact performance. Consider alternatives like pre-computing values or performing calculations in application code.',
          icon: Icons.speed,
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• For financial calculations, consider using DECIMAL/NUMERIC data types instead of FLOAT/DOUBLE to avoid precision issues',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be consistent with rounding methods across your application',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Document complex calculations with clear comments',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Test edge cases, especially with division operations that could result in division by zero errors',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Numeric Data Types'),
            _buildChip('Aggregate Functions'),
            _buildChip('Mathematical Operators'),
            _buildChip('Precision & Scale'),
            _buildChip('CASE Expressions'),
          ],
        ),
      ],
    );
  }

  Widget _buildDateFunctionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date functions allow you to manipulate, format, and extract information from date and time values in SQL. These functions are essential for working with temporal data in databases and performing date-based calculations and analysis.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Current Date/Time Functions
        _buildSectionHeader('Current Date and Time'),
        const SizedBox(height: 16),
        
        // CURRENT_DATE / GETDATE
        _buildExampleCard(
          title: 'Current Date Functions',
          description: 'Getting the current date/time (syntax varies by database):',
          code: '-- Standard SQL/PostgreSQL\nSELECT CURRENT_DATE;\nSELECT CURRENT_TIMESTAMP;\n\n-- MySQL\nSELECT CURDATE();\nSELECT NOW();\n\n-- SQL Server\nSELECT GETDATE();\nSELECT SYSDATETIME();\n\n-- Oracle\nSELECT SYSDATE FROM dual;\nSELECT CURRENT_DATE FROM dual;',
        ),
        const SizedBox(height: 20),
        
        // Date Formatting and Extraction
        _buildSectionHeader('Date Formatting and Extraction'),
        const SizedBox(height: 16),
        
        // DATE_FORMAT / TO_CHAR
        _buildExampleCard(
          title: 'Date Formatting',
          description: 'Formatting dates as strings (syntax varies by database):',
          code: '-- MySQL\nSELECT DATE_FORMAT(order_date, \'%Y-%m-%d\') FROM orders;\nSELECT DATE_FORMAT(order_date, \'%M %d, %Y\') FROM orders;\n\n-- PostgreSQL/Oracle\nSELECT TO_CHAR(order_date, \'YYYY-MM-DD\') FROM orders;\nSELECT TO_CHAR(order_date, \'Month DD, YYYY\') FROM orders;\n\n-- SQL Server\nSELECT FORMAT(order_date, \'yyyy-MM-dd\') FROM orders;\nSELECT FORMAT(order_date, \'MMMM dd, yyyy\') FROM orders;',
        ),
        const SizedBox(height: 16),
        
        // EXTRACT / DATEPART
        _buildExampleCard(
          title: 'Extracting Components',
          description: 'Extracting specific parts from date values:',
          code: '-- Standard SQL/PostgreSQL\nSELECT EXTRACT(YEAR FROM order_date) FROM orders;\nSELECT EXTRACT(MONTH FROM order_date) FROM orders;\nSELECT EXTRACT(DAY FROM order_date) FROM orders;\n\n-- MySQL\nSELECT YEAR(order_date) FROM orders;\nSELECT MONTH(order_date) FROM orders;\nSELECT DAY(order_date) FROM orders;\n\n-- SQL Server\nSELECT DATEPART(YEAR, order_date) FROM orders;\nSELECT DATEPART(MONTH, order_date) FROM orders;\nSELECT DATEPART(DAY, order_date) FROM orders;',
        ),
        const SizedBox(height: 20),
        
        // Date Arithmetic
        _buildSectionHeader('Date Arithmetic'),
        const SizedBox(height: 16),
        
        // Date Addition/Subtraction
        _buildExampleCard(
          title: 'Date Addition and Subtraction',
          description: 'Adding or subtracting intervals from dates:',
          code: '-- Standard SQL/PostgreSQL\nSELECT order_date + INTERVAL \'7 days\' FROM orders;\nSELECT order_date - INTERVAL \'1 month\' FROM orders;\n\n-- MySQL\nSELECT DATE_ADD(order_date, INTERVAL 7 DAY) FROM orders;\nSELECT DATE_SUB(order_date, INTERVAL 1 MONTH) FROM orders;\n\n-- SQL Server\nSELECT DATEADD(DAY, 7, order_date) FROM orders;\nSELECT DATEADD(MONTH, -1, order_date) FROM orders;\n\n-- Oracle\nSELECT order_date + 7 FROM orders; -- Add 7 days\nSELECT ADD_MONTHS(order_date, -1) FROM orders; -- Subtract 1 month',
        ),
        const SizedBox(height: 16),
        
        // DATEDIFF
        _buildExampleCard(
          title: 'Date Differences',
          description: 'Calculating the difference between dates:',
          code: '-- MySQL\nSELECT DATEDIFF(end_date, start_date) FROM projects; -- Days between\n\n-- SQL Server\nSELECT DATEDIFF(DAY, start_date, end_date) FROM projects;\nSELECT DATEDIFF(MONTH, start_date, end_date) FROM projects;\nSELECT DATEDIFF(YEAR, start_date, end_date) FROM projects;\n\n-- PostgreSQL\nSELECT end_date - start_date FROM projects; -- Days between\nSELECT AGE(end_date, start_date) FROM projects; -- Full interval\n\n-- Oracle\nSELECT end_date - start_date FROM projects; -- Days between\nSELECT MONTHS_BETWEEN(end_date, start_date) FROM projects;',
        ),
        const SizedBox(height: 20),
        
        // Date Conversion
        _buildSectionHeader('Date Conversion'),
        const SizedBox(height: 16),
        
        // String to Date
        _buildExampleCard(
          title: 'String to Date Conversion',
          description: 'Converting string values to dates:',
          code: '-- Standard SQL\nSELECT DATE \'2023-05-15\';\n\n-- MySQL\nSELECT STR_TO_DATE(\'May 15, 2023\', \'%M %d, %Y\');\nSELECT CAST(\'2023-05-15\' AS DATE);\n\n-- PostgreSQL\nSELECT TO_DATE(\'May 15, 2023\', \'Month DD, YYYY\');\nSELECT CAST(\'2023-05-15\' AS DATE);\n\n-- SQL Server\nSELECT CONVERT(DATE, \'2023-05-15\');\nSELECT PARSE(\'May 15, 2023\' AS DATE USING \'en-US\');\n\n-- Oracle\nSELECT TO_DATE(\'May 15, 2023\', \'Month DD, YYYY\') FROM dual;',
        ),
        const SizedBox(height: 20),
        
        // Practical Examples
        _buildSectionHeader('Practical Examples'),
        const SizedBox(height: 16),
        
        // Grouping by Date Parts
        _buildExampleCard(
          title: 'Grouping by Date Parts',
          description: 'Aggregating data by different date components:',
          code: '-- Monthly sales totals\nSELECT\n  EXTRACT(YEAR FROM order_date) AS year,\n  EXTRACT(MONTH FROM order_date) AS month,\n  SUM(total_amount) AS monthly_sales\nFROM orders\nGROUP BY\n  EXTRACT(YEAR FROM order_date),\n  EXTRACT(MONTH FROM order_date)\nORDER BY\n  year, month;\n\n-- Quarterly sales\nSELECT\n  EXTRACT(YEAR FROM order_date) AS year,\n  CEIL(EXTRACT(MONTH FROM order_date) / 3) AS quarter,\n  SUM(total_amount) AS quarterly_sales\nFROM orders\nGROUP BY\n  EXTRACT(YEAR FROM order_date),\n  CEIL(EXTRACT(MONTH FROM order_date) / 3)\nORDER BY\n  year, quarter;',
        ),
        const SizedBox(height: 16),
        
        // Date Filtering
        _buildExampleCard(
          title: 'Date Filtering',
          description: 'Common date-based filtering scenarios:',
          code: '-- Orders from the last 30 days\nSELECT * FROM orders\nWHERE order_date >= CURRENT_DATE - INTERVAL \'30 days\';\n\n-- Orders from the current year\nSELECT * FROM orders\nWHERE EXTRACT(YEAR FROM order_date) = EXTRACT(YEAR FROM CURRENT_DATE);\n\n-- Orders from a specific date range\nSELECT * FROM orders\nWHERE order_date BETWEEN \'2023-01-01\' AND \'2023-03-31\';\n\n-- Orders from a specific month across all years\nSELECT * FROM orders\nWHERE EXTRACT(MONTH FROM order_date) = 3; -- March',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Date Storage',
          content: 'Different databases store dates in different internal formats. Always use the appropriate date functions provided by your database system rather than string manipulation for date operations.',
          icon: Icons.storage,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Timezone Handling',
          content: 'Be aware of timezone issues when working with dates, especially when storing timestamps. Many databases offer functions like AT TIME ZONE to handle timezone conversions.',
          icon: Icons.language,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Database Differences',
          content: 'Date functions vary significantly between database systems. Check your database documentation for the exact syntax and available functions.',
          icon: Icons.compare,
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Store dates in proper DATE or TIMESTAMP columns rather than as strings',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use ISO format (YYYY-MM-DD) when representing dates as strings for consistency',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider timezone requirements when storing and querying date/time data',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use indexes on date columns that are frequently used in WHERE clauses',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be aware of leap year and daylight saving time issues in date calculations',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Date Data Types'),
            _buildChip('Timezones'),
            _buildChip('GROUP BY'),
            _buildChip('Indexing'),
            _buildChip('Date Ranges'),
          ],
        ),
      ],
    );
  }

  Widget _buildWindowFunctionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Window functions perform calculations across a set of table rows that are related to the current row. Unlike regular aggregate functions, window functions don\'t collapse the rows into a single output row - they return a result for each row, based on a "window" of related rows.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          'SELECT column1, column2,\n       WINDOW_FUNCTION() OVER (\n           [PARTITION BY column1, column2, ...]\n           [ORDER BY column3, column4, ...]\n           [frame_clause]\n       )\nFROM table_name;'
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• PARTITION BY divides rows into groups (similar to GROUP BY but doesn\'t collapse rows)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• ORDER BY determines the order of rows within each partition for functions that depend on order',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• frame_clause defines which rows constitute the current window frame (e.g., ROWS BETWEEN)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Types of Window Functions
        _buildSectionHeader('Common Window Functions'),
        const SizedBox(height: 16),
        
        // Ranking Functions
        _buildExampleCard(
          title: 'Ranking Functions',
          description: 'Assign ranks to rows within a partition:',
          code: '-- Rank employees by salary within each department\nSELECT\n  employee_name,\n  department,\n  salary,\n  RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank\nFROM employees;\n\n-- Other ranking functions:\nROW_NUMBER() OVER (...) -- Unique sequential number\nDENSE_RANK() OVER (...) -- Rank without gaps\nNTILE(n) OVER (...) -- Divides rows into n groups\nPERCENT_RANK() OVER (...) -- Relative rank as percentage',
        ),
        const SizedBox(height: 16),
        
        // Aggregate Window Functions
        _buildExampleCard(
          title: 'Aggregate Window Functions',
          description: 'Apply aggregate functions over a window:',
          code: '-- Calculate running total of sales\nSELECT\n  sale_date,\n  amount,\n  SUM(amount) OVER (ORDER BY sale_date) AS running_total\nFROM sales;\n\n-- Show sales and department average\nSELECT\n  employee_name,\n  department,\n  sales_amount,\n  AVG(sales_amount) OVER (PARTITION BY department) AS dept_avg\nFROM sales_data;\n\n-- Other aggregate window functions:\nCOUNT(), MIN(), MAX(), AVG(), SUM()',
        ),
        const SizedBox(height: 16),
        
        // Value Functions
        _buildExampleCard(
          title: 'Value Functions',
          description: 'Access values from other rows within the window:',
          code: '-- Compare current salary to previous and next employee\'s\nSELECT\n  employee_name,\n  department,\n  salary,\n  LAG(salary) OVER (PARTITION BY department ORDER BY salary) AS prev_salary,\n  LEAD(salary) OVER (PARTITION BY department ORDER BY salary) AS next_salary\nFROM employees;\n\n-- Get first and last value in a window\nSELECT\n  product_name,\n  category,\n  price,\n  FIRST_VALUE(price) OVER (PARTITION BY category ORDER BY price) AS lowest_in_category,\n  LAST_VALUE(price) OVER (\n    PARTITION BY category ORDER BY price\n    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING\n  ) AS highest_in_category\nFROM products;',
        ),
        const SizedBox(height: 20),
        
        // Window Frame Clause
        _buildSectionHeader('Window Frame Clause'),
        const SizedBox(height: 12),
        const Text(
          'The frame clause determines which rows are included in the window function calculation relative to the current row:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        _buildCodeBlock(
          '-- Default frame: all rows from start of partition to current row\nSUM(amount) OVER (ORDER BY date) -- Implicit frame: RANGE UNBOUNDED PRECEDING\n\n-- Explicit frames:\nSUM(amount) OVER (ORDER BY date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) -- Current row plus previous 3 rows\nSUM(amount) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) -- All rows in partition\nAVG(amount) OVER (ORDER BY date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) -- Current row plus one row before and after'
        ),
        const SizedBox(height: 20),
        
        // Practical Examples
        _buildSectionHeader('Practical Examples'),
        const SizedBox(height: 16),
        
        // Running Totals
        _buildExampleCard(
          title: 'Running Totals and Moving Averages',
          description: 'Calculate running sums or sliding window averages:',
          code: '-- Monthly sales with running total for the year\nSELECT\n  EXTRACT(YEAR FROM sale_date) AS year,\n  EXTRACT(MONTH FROM sale_date) AS month,\n  SUM(amount) AS monthly_sales,\n  SUM(SUM(amount)) OVER (\n    PARTITION BY EXTRACT(YEAR FROM sale_date)\n    ORDER BY EXTRACT(MONTH FROM sale_date)\n  ) AS running_yearly_total\nFROM sales\nGROUP BY year, month\nORDER BY year, month;\n\n-- 3-day moving average of stock prices\nSELECT\n  stock_date,\n  stock_price,\n  AVG(stock_price) OVER (\n    ORDER BY stock_date\n    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW\n  ) AS moving_avg_3day\nFROM stock_prices\nORDER BY stock_date;',
        ),
        const SizedBox(height: 16),
        
        // Percentiles and Distributions
        _buildExampleCard(
          title: 'Percentiles and Distributions',
          description: 'Calculate rankings, percentiles, and distributions:',
          code: '-- Calculate percentile for each student\'s score\nSELECT\n  student_name,\n  score,\n  PERCENT_RANK() OVER (ORDER BY score DESC) AS percentile\nFROM exam_results;\n\n-- Divide employees into salary quartiles\nSELECT\n  employee_name,\n  department,\n  salary,\n  NTILE(4) OVER (ORDER BY salary DESC) AS salary_quartile\nFROM employees;\n\n-- Calculate percent of department total\nSELECT\n  employee_name,\n  department,\n  sales_amount,\n  sales_amount / SUM(sales_amount) OVER (PARTITION BY department) * 100 AS pct_of_dept_total\nFROM sales_data;',
        ),
        const SizedBox(height: 16),
        
        // Gap Analysis
        _buildExampleCard(
          title: 'Gap Detection and Analysis',
          description: 'Compare rows to find gaps or changes:',
          code: '-- Detect gaps in sequence\nSELECT\n  sequence_id,\n  transaction_date,\n  transaction_date - LAG(transaction_date) OVER (ORDER BY transaction_date) AS days_since_last\nFROM transactions\nORDER BY transaction_date;\n\n-- Calculate changes in values\nSELECT\n  reading_date,\n  temperature,\n  temperature - LAG(temperature) OVER (ORDER BY reading_date) AS temperature_change\nFROM weather_readings\nORDER BY reading_date;',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Processing Order',
          content: 'Window functions are processed after JOIN, WHERE, GROUP BY, and HAVING clauses, but before ORDER BY and SELECT DISTINCT.',
          icon: Icons.swap_vert,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Performance Considerations',
          content: 'Window functions can be resource-intensive on large datasets. Use appropriate indexes and consider partitioning for better performance.',
          icon: Icons.speed,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Compatibility',
          content: 'Window functions were introduced in SQL:2003 standard, but support varies by database system. Check your database documentation for specific syntax and available functions.',
          icon: Icons.compare,
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Use appropriate frame clauses to limit window size for better performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider using common table expressions (CTEs) to make complex window queries more readable',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be careful with PARTITION BY on high-cardinality columns, as it may impact performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use ORDER BY with window functions even when not required for consistency and readability',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be aware that LAST_VALUE may not work as expected without an explicit frame clause',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Aggregate Functions'),
            _buildChip('GROUP BY'),
            _buildChip('Common Table Expressions'),
            _buildChip('Performance Tuning'),
            _buildChip('OLAP Functions'),
          ],
        ),
      ],
    );
  }

  Widget _buildDataTypesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SQL data types define the type of data that can be stored in a column of a database table. Choosing the right data type is essential for database performance, data integrity, and storage efficiency.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Numeric Data Types
        _buildSectionHeader('Numeric Data Types'),
        const SizedBox(height: 16),
        
        // Integer Types
        _buildExampleCard(
          title: 'Integer Types',
          description: 'Whole numbers without decimal places:',
          code: 'INTEGER / INT -- Standard integer type (-2,147,483,648 to 2,147,483,647)\nSMALLINT -- Small integer (-32,768 to 32,767)\nBIGINT -- Large integer (±9.22×10^18)\nTINYINT -- Tiny integer (0 to 255, varies by database)\n\n-- Usage examples:\nCREATE TABLE products (\n  product_id INT PRIMARY KEY,\n  quantity SMALLINT,\n  total_sold BIGINT\n);',
        ),
        const SizedBox(height: 16),
        
        // Decimal/Numeric Types
        _buildExampleCard(
          title: 'Decimal/Numeric Types',
          description: 'Exact numeric values with fixed precision and scale:',
          code: 'DECIMAL(p,s) / NUMERIC(p,s) -- Exact decimal where p=total digits, s=decimal digits\nMONEY -- Currency values (database-specific)\n\n-- Usage examples:\nCREATE TABLE financial (\n  transaction_id INT PRIMARY KEY,\n  amount DECIMAL(10,2),  -- Up to 10 digits with 2 after decimal point\n  tax_rate DECIMAL(5,4),  -- e.g., 0.0825 for 8.25%\n  balance MONEY\n);',
        ),
        const SizedBox(height: 16),
        
        // Floating Point Types
        _buildExampleCard(
          title: 'Floating Point Types',
          description: 'Approximate numeric values with variable precision:',
          code: 'FLOAT(n) -- Floating point number with precision n\nREAL / DOUBLE PRECISION -- Double precision floating point\n\n-- Usage examples:\nCREATE TABLE scientific_data (\n  reading_id INT PRIMARY KEY,\n  temperature FLOAT(24),  -- Single precision\n  pressure DOUBLE PRECISION,  -- Double precision\n  measurement REAL\n);',
        ),
        const SizedBox(height: 20),
        
        // String Data Types
        _buildSectionHeader('String Data Types'),
        const SizedBox(height: 16),
        
        // Fixed and Variable Length
        _buildExampleCard(
          title: 'Character String Types',
          description: 'Fixed and variable length character strings:',
          code: 'CHAR(n) -- Fixed-length string, padded with spaces (1 to 255 characters)\nVARCHAR(n) -- Variable-length string (1 to 65,535 characters)\nTEXT -- Variable unlimited length text (up to 65,535 characters)\nMEDIUMTEXT -- Medium length text (up to 16.7 million characters)\nLONGTEXT -- Long text (up to 4.29 billion characters)\n\n-- Usage examples:\nCREATE TABLE users (\n  user_id INT PRIMARY KEY,\n  country_code CHAR(2),      -- Always 2 characters (fixed)\n  username VARCHAR(50),      -- Variable length up to 50\n  email VARCHAR(100),        -- Variable length up to 100\n  bio TEXT,                  -- Longer variable text\n  resume MEDIUMTEXT          -- Even longer text\n);',
        ),
        const SizedBox(height: 16),
        
        // Binary Types
        _buildExampleCard(
          title: 'Binary String Types',
          description: 'For storing binary data such as files and images:',
          code: 'BINARY(n) -- Fixed-length binary data\nVARBINARY(n) -- Variable-length binary data\nBLOB -- Binary Large Object (up to 65,535 bytes)\nMEDIUMBLOB -- Medium size binary object (up to 16.7 million bytes)\nLONGBLOB -- Large binary object (up to 4.29 billion bytes)\n\n-- Usage examples:\nCREATE TABLE documents (\n  document_id INT PRIMARY KEY,\n  file_hash BINARY(32),      -- SHA-256 hash (always 32 bytes)\n  small_icon VARBINARY(1000),-- Variable length binary\n  document_file MEDIUMBLOB   -- Larger binary content\n);',
        ),
        const SizedBox(height: 20),
        
        // Date and Time Types
        _buildSectionHeader('Date and Time Data Types'),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Date and Time Types',
          description: 'For storing temporal data:',
          code: 'DATE -- Date only (YYYY-MM-DD)\nTIME -- Time only (HH:MM:SS)\nDATETIME -- Date and time\nTIMESTAMP -- Date and time, often with timezone awareness\nYEAR -- Year value\n\n-- Usage examples:\nCREATE TABLE events (\n  event_id INT PRIMARY KEY,\n  event_date DATE,           -- Only the date\n  start_time TIME,           -- Only the time\n  end_time TIME,             -- Only the time\n  created_at DATETIME,       -- Date and time when created\n  last_updated TIMESTAMP     -- Automatically updates on change\n);',
        ),
        const SizedBox(height: 20),
        
        // Boolean and Special Types
        _buildSectionHeader('Boolean and Special Types'),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Boolean and Special Types',
          description: 'Other useful data types:',
          code: 'BOOLEAN / BOOL -- True or false values\nENUM -- Enumeration of string values\nSET -- Set of string values\nJSON -- JSON document (supported in modern databases)\nUUID -- Universally Unique Identifier (not native to all databases)\n\n-- Usage examples:\nCREATE TABLE products (\n  product_id INT PRIMARY KEY,\n  is_active BOOLEAN,\n  size ENUM(\'S\', \'M\', \'L\', \'XL\'),\n  available_colors SET(\'red\', \'green\', \'blue\', \'black\'),\n  metadata JSON\n);',
        ),
        const SizedBox(height: 20),
        
        // Database Specific Types
        _buildSectionHeader('Database-Specific Variations'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• MySQL: TINYTEXT, MEDIUMTEXT, LONGTEXT; TINYINT as BOOLEAN',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• PostgreSQL: SERIAL for auto-increment, TEXT with no limit, JSONB for binary JSON',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• SQL Server: NVARCHAR for Unicode, UNIQUEIDENTIFIER for UUIDs',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Oracle: NUMBER, VARCHAR2, CLOB, NCLOB for large text',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• SQLite: Dynamic typing with storage classes (NULL, INTEGER, REAL, TEXT, BLOB)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Storage Efficiency',
          content: 'Choose the smallest data type that can reliably store your data. For example, use SMALLINT instead of INT for values that will never exceed 32,767.',
          icon: Icons.storage,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Precision vs. Scale',
          content: 'For DECIMAL/NUMERIC types, precision is the total number of significant digits, and scale is the number of digits after the decimal point.',
          icon: Icons.precision_manufacturing,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Fixed vs. Variable Length',
          content: 'Fixed-length types (CHAR, BINARY) always use the same amount of storage regardless of content, while variable-length types (VARCHAR, VARBINARY) use only what\'s needed plus a small overhead.',
          icon: Icons.compare_arrows,
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Use INT for primary keys and foreign keys unless you have specific requirements',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use DECIMAL rather than FLOAT/REAL for financial data to avoid rounding errors',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Define appropriate size limits for VARCHAR fields to save space and improve performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use TEXT or BLOB types for very large data, but consider storing files in the filesystem instead',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider database portability when choosing data types for applications that may use different database systems',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Type Conversion'),
            _buildChip('Database Schema Design'),
            _buildChip('Constraints'),
            _buildChip('Storage Optimization'),
            _buildChip('Indexing'),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryKeysContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary keys are columns or sets of columns that uniquely identify each row in a table. They enforce entity integrity by ensuring that no duplicate or null values can exist in the key columns.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          '-- Creating a table with a primary key\nCREATE TABLE customers (\n  customer_id INT PRIMARY KEY,  -- Single-column primary key\n  first_name VARCHAR(50),\n  last_name VARCHAR(50),\n  email VARCHAR(100)\n);\n\n-- Alternative syntax\nCREATE TABLE products (\n  product_id INT,\n  sku VARCHAR(20),\n  product_name VARCHAR(100),\n  PRIMARY KEY (product_id)  -- Defined separately\n);\n\n-- Composite primary key (multiple columns)\nCREATE TABLE order_items (\n  order_id INT,\n  product_id INT,\n  quantity INT,\n  price DECIMAL(10,2),\n  PRIMARY KEY (order_id, product_id)  -- Composite key\n);'
        ),
        const SizedBox(height: 20),
        
        // Adding or Modifying Primary Keys
        _buildSectionHeader('Adding or Modifying Primary Keys'),
        const SizedBox(height: 16),
        
        // Adding to existing table
        _buildExampleCard(
          title: 'Adding to Existing Table',
          description: 'Adding a primary key to a table that doesn\'t have one:',
          code: '-- Add a primary key to an existing table\nALTER TABLE customers\nADD PRIMARY KEY (customer_id);\n\n-- Add a composite primary key\nALTER TABLE order_items\nADD PRIMARY KEY (order_id, product_id);',
        ),
        const SizedBox(height: 16),
        
        // Removing primary key
        _buildExampleCard(
          title: 'Removing a Primary Key',
          description: 'Dropping a primary key constraint:',
          code: '-- Drop the primary key constraint\nALTER TABLE customers\nDROP PRIMARY KEY;\n\n-- For some databases (like SQL Server), you need to know the constraint name\nALTER TABLE customers\nDROP CONSTRAINT pk_customers;',
        ),
        const SizedBox(height: 20),
        
        // Auto-Increment Primary Keys
        _buildSectionHeader('Auto-Increment Primary Keys'),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Auto-Increment/Identity Columns',
          description: 'Creating primary keys that automatically generate unique values:',
          code: '-- MySQL\nCREATE TABLE customers (\n  customer_id INT AUTO_INCREMENT PRIMARY KEY,\n  first_name VARCHAR(50),\n  last_name VARCHAR(50)\n);\n\n-- SQL Server\nCREATE TABLE customers (\n  customer_id INT IDENTITY(1,1) PRIMARY KEY,\n  first_name VARCHAR(50),\n  last_name VARCHAR(50)\n);\n\n-- PostgreSQL\nCREATE TABLE customers (\n  customer_id SERIAL PRIMARY KEY,  -- SERIAL is auto-incrementing\n  first_name VARCHAR(50),\n  last_name VARCHAR(50)\n);\n\n-- Oracle\nCREATE TABLE customers (\n  customer_id NUMBER PRIMARY KEY,\n  first_name VARCHAR2(50),\n  last_name VARCHAR2(50)\n);\n-- Then create a sequence and trigger (not shown here)',
        ),
        const SizedBox(height: 20),
        
        // Natural vs. Surrogate Keys
        _buildSectionHeader('Natural vs. Surrogate Keys'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Primary keys can be either natural or surrogate:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Natural Keys',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Derived from the actual data (e.g., social security number, ISBN)\n• Meaningful to users and business processes\n• May change over time (problematic for primary keys)\n• Can be longer and more complex',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Surrogate Keys',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Artificially generated (e.g., auto-increment ID)\n• No business meaning, purely for database use\n• Never changes, enhancing stability\n• Typically smaller and more efficient',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Most modern database designs use surrogate keys, but natural keys may be appropriate in some scenarios.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Primary Key Constraints in Action
        _buildSectionHeader('Primary Key Constraints in Action'),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Enforcing Uniqueness',
          description: 'Primary keys prevent duplicate rows:',
          code: '-- This will succeed\nINSERT INTO customers (customer_id, first_name, last_name)\nVALUES (1, \'John\', \'Doe\');\n\n-- This will fail with a primary key violation\nINSERT INTO customers (customer_id, first_name, last_name)\nVALUES (1, \'Jane\', \'Smith\');  -- customer_id 1 already exists',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Preventing NULL Values',
          description: 'Primary keys cannot contain NULL values:',
          code: '-- This will fail with a constraint violation\nINSERT INTO customers (customer_id, first_name, last_name)\nVALUES (NULL, \'John\', \'Doe\');  -- Primary key cannot be NULL',
        ),
        const SizedBox(height: 20),
        
        // Indexing and Performance
        _buildSectionHeader('Indexing and Performance'),
        const SizedBox(height: 12),
        const Text(
          'A primary key automatically creates a clustered or unique index on the key columns, providing several benefits:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Fast Row Retrieval',
          content: 'Queries that filter on primary key columns are very fast because the database can directly access the rows without scanning the entire table.',
          icon: Icons.speed,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Improved JOIN Performance',
          content: 'JOINs between tables using primary key columns (and foreign keys that reference them) are efficient because of the indexed lookups.',
          icon: Icons.link,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Physical Organization',
          content: 'In many databases, the primary key determines how the data is physically organized on disk (clustered index), further improving performance.',
          icon: Icons.storage,
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Choose simple, stable values for primary keys that won\'t need to change',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use integer types for surrogate keys when possible (usually the most efficient)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Keep primary keys as small as possible, especially for large tables',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Avoid using composite primary keys with many columns',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider using UUIDs for distributed systems or when rows are created in multiple locations',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Foreign Keys'),
            _buildChip('Indexes'),
            _buildChip('Unique Constraints'),
            _buildChip('Data Integrity'),
            _buildChip('Entity-Relationship Modeling'),
          ],
        ),
      ],
    );
  }

  Widget _buildForeignKeysContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foreign keys are columns that establish relationships between tables by referencing the primary key of another table. They enforce referential integrity in the database, ensuring that relationships remain consistent when data is updated or deleted.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Syntax
        _buildSectionHeader('Basic Syntax'),
        const SizedBox(height: 12),
        _buildCodeBlock(
          '-- Creating a table with a foreign key\nCREATE TABLE orders (\n  order_id INT PRIMARY KEY,\n  customer_id INT,\n  order_date DATE,\n  -- ... other columns ...\n  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)\n);\n\n-- Adding a foreign key to an existing table\nALTER TABLE orders\nADD CONSTRAINT fk_customer\nFOREIGN KEY (customer_id) REFERENCES customers(customer_id);'
        ),
        const SizedBox(height: 20),
        
        // Examples
        _buildSectionHeader('Examples'),
        const SizedBox(height: 16),
        
        // Example 1: Basic Foreign Key
        _buildExampleCard(
          title: 'Basic Foreign Key Relationship',
          description: 'Create a one-to-many relationship between customers and orders:',
          code: 'CREATE TABLE customers (\n  customer_id INT PRIMARY KEY,\n  customer_name VARCHAR(100),\n  email VARCHAR(100)\n);\n\nCREATE TABLE orders (\n  order_id INT PRIMARY KEY,\n  order_date DATE,\n  customer_id INT,\n  amount DECIMAL(10, 2),\n  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)\n);',
        ),
        const SizedBox(height: 16),
        
        // Example 2: Referential Actions
        _buildExampleCard(
          title: 'Referential Actions',
          description: 'Specify what happens when referenced rows are modified:',
          code: 'CREATE TABLE departments (\n  dept_id INT PRIMARY KEY,\n  dept_name VARCHAR(100)\n);\n\nCREATE TABLE employees (\n  employee_id INT PRIMARY KEY,\n  employee_name VARCHAR(100),\n  dept_id INT,\n  FOREIGN KEY (dept_id) REFERENCES departments(dept_id)\n    ON DELETE SET NULL     -- Set foreign key to NULL when parent row is deleted\n    ON UPDATE CASCADE      -- Update foreign key when primary key is updated\n);',
        ),
        const SizedBox(height: 20),
        
        // Key Concepts
        _buildSectionHeader('Key Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Referential Integrity',
          content: 'Ensures that a foreign key value always points to an existing row in the referenced table, maintaining data consistency.',
          icon: Icons.verified,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Relationship Types',
          content: 'Foreign keys can implement one-to-many, many-to-many (via junction tables), and self-referencing relationships.',
          icon: Icons.device_hub,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Cascading Actions',
          content: 'ON DELETE and ON UPDATE clauses control what happens when referenced rows change: CASCADE, SET NULL, RESTRICT, or NO ACTION.',
          icon: Icons.auto_fix_high,
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Name foreign keys consistently using a convention',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Index foreign key columns to improve join performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider the impact of cascading actions in complex relationships',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be cautious with ON DELETE CASCADE in production environments',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Primary Keys'),
            _buildChip('Normalization'),
            _buildChip('Indexes'),
            _buildChip('JOIN Operations'),
          ],
        ),
      ],
    );
  }

  Widget _buildNormalizationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Normalization is the process of organizing data in a database to reduce redundancy and improve data integrity. It involves dividing large tables into smaller, related tables and defining relationships between them using foreign keys.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Normal Forms
        _buildSectionHeader('Normal Forms'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Data normalization is typically described in terms of "normal forms":',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '1NF (First Normal Form): Eliminate repeating groups and ensure atomic values',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '2NF (Second Normal Form): Meet 1NF and eliminate partial dependencies',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '3NF (Third Normal Form): Meet 2NF and eliminate transitive dependencies',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                'BCNF (Boyce-Codd Normal Form): A stronger version of 3NF',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '4NF, 5NF, 6NF: Higher normal forms for specific use cases',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // First Normal Form (1NF)
        _buildSectionHeader('First Normal Form (1NF)'),
        const SizedBox(height: 12),
        const Text(
          'A table is in 1NF if:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('• Each column contains atomic (indivisible) values'),
              SizedBox(height: 4),
              Text('• Each column has a unique name'),
              SizedBox(height: 4),
              Text('• The order of rows and columns doesn\'t matter'),
              SizedBox(height: 4),
              Text('• Each row is unique (typically ensured by a primary key)'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // 1NF Example
        _buildExampleCard(
          title: 'Converting to 1NF',
          description: 'Breaking down non-atomic values into separate rows:',
          code: '-- Non-normalized table (violates 1NF)\nCustomerID | CustomerName | PhoneNumbers\n----------|--------------|-----------------\n1         | John Smith   | 555-1234, 555-5678\n2         | Mary Jones   | 555-8765\n\n-- Converted to 1NF\nCustomerID | CustomerName | PhoneNumber\n----------|--------------|------------\n1         | John Smith   | 555-1234\n1         | John Smith   | 555-5678\n2         | Mary Jones   | 555-8765',
        ),
        const SizedBox(height: 20),
        
        // Second Normal Form (2NF)
        _buildSectionHeader('Second Normal Form (2NF)'),
        const SizedBox(height: 12),
        const Text(
          'A table is in 2NF if it is in 1NF and all non-key attributes are fully functionally dependent on the primary key (no partial dependencies).',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        
        // 2NF Example
        _buildExampleCard(
          title: 'Converting to 2NF',
          description: 'Removing partial dependencies by splitting tables:',
          code: '-- Table in 1NF but not 2NF (OrderItem depends partially on {OrderID, ProductID})\nOrderID | ProductID | Quantity | ProductName | ProductPrice\n--------|-----------|----------|-------------|-------------\n1       | 101       | 2        | Widget A    | 9.99\n1       | 102       | 1        | Widget B    | 19.99\n2       | 101       | 3        | Widget A    | 9.99\n\n-- Converted to 2NF by splitting into two tables\n-- Orders table\nOrderID | ProductID | Quantity\n--------|-----------|----------\n1       | 101       | 2\n1       | 102       | 1\n2       | 101       | 3\n\n-- Products table\nProductID | ProductName | ProductPrice\n----------|-------------|-------------\n101       | Widget A    | 9.99\n102       | Widget B    | 19.99',
        ),
        const SizedBox(height: 20),
        
        // Third Normal Form (3NF)
        _buildSectionHeader('Third Normal Form (3NF)'),
        const SizedBox(height: 12),
        const Text(
          'A table is in 3NF if it is in 2NF and all attributes depend only on the primary key (no transitive dependencies).',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        
        // 3NF Example
        _buildExampleCard(
          title: 'Converting to 3NF',
          description: 'Removing transitive dependencies by splitting tables:',
          code: '-- Table in 2NF but not 3NF (ZipCode determines City and State)\nEmployeeID | Name       | Department | DeptManager | ZipCode | City      | State\n-----------|------------|------------|-------------|---------|-----------|-------\n1          | John Smith | Sales      | Mary Jones  | 12345   | Springfield| IL\n2          | Jane Doe   | Marketing  | Bob Williams| 54321   | Centerville| OH\n3          | Bob Evans  | Sales      | Mary Jones  | 12345   | Springfield| IL\n\n-- Converted to 3NF by splitting into three tables\n-- Employees table\nEmployeeID | Name       | DepartmentID | ZipCode\n-----------|------------|--------------|--------\n1          | John Smith | 1            | 12345\n2          | Jane Doe   | 2            | 54321\n3          | Bob Evans  | 1            | 12345\n\n-- Departments table\nDepartmentID | Department | ManagerName\n-------------|------------|-------------\n1            | Sales      | Mary Jones\n2            | Marketing  | Bob Williams\n\n-- Locations table\nZipCode | City        | State\n--------|-------------|-------\n12345   | Springfield | IL\n54321   | Centerville | OH',
        ),
        const SizedBox(height: 20),
        
        // Benefits of Normalization
        _buildSectionHeader('Benefits of Normalization'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Minimized Redundancy',
          content: 'Data is stored in only one place, reducing storage requirements and eliminating update anomalies.',
          icon: Icons.compress,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Improved Data Integrity',
          content: 'With reduced redundancy, there\'s less chance of inconsistencies when data is updated, inserted, or deleted.',
          icon: Icons.verified,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Better Database Organization',
          content: 'The logical structure becomes cleaner and more focused on specific entities, making it easier to understand and maintain.',
          icon: Icons.architecture,
        ),
        const SizedBox(height: 20),
        
        // Denormalization
        _buildSectionHeader('Denormalization'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Denormalization is the process of intentionally introducing redundancy for performance reasons:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '• Used in read-heavy systems like data warehouses and analytical databases',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Reduces the need for complex joins, improving query performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Increases storage requirements and complicates data updates',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Often implemented via materialized views, calculated columns, or redundant data',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Aim for 3NF for most transactional databases',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider the specific requirements and usage patterns of your application',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Balance normalization benefits against performance needs',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use indexes effectively to maintain performance with normalized schemas',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Document your database design decisions and the reasoning behind them',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Primary Keys'),
            _buildChip('Foreign Keys'),
            _buildChip('Entity-Relationship Modeling'),
            _buildChip('Database Design'),
            _buildChip('Functional Dependencies'),
          ],
        ),
      ],
    );
  }

  Widget _buildIndexesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Indexes are database structures that improve the speed of data retrieval operations on database tables by creating pointers to the data, similar to how an index in a book helps you find information quickly.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Index Types
        _buildSectionHeader('Types of Indexes'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'B-tree Index (Default)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Balanced tree structure suitable for most scenarios. Excellent for equality and range queries.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Hash Index',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Very fast for equality comparisons but not useful for range searches or sorting.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Bitmap Index',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Efficient for columns with low cardinality (few distinct values). Common in data warehousing.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Full-Text Index',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Specialized index for text search capabilities beyond basic pattern matching.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Creating Indexes
        _buildSectionHeader('Creating Indexes'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'Basic Index Creation',
          description: 'Create a single-column index:',
          code: '-- Basic syntax\nCREATE INDEX index_name ON table_name (column_name);\n\n-- Example\nCREATE INDEX idx_customers_last_name ON customers (last_name);',
        ),
        const SizedBox(height: 16),
        _buildExampleCard(
          title: 'Composite Index',
          description: 'Create an index on multiple columns:',
          code: '-- Useful when you frequently filter or join on these columns together\nCREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date);\n\n-- This index can help queries that filter on customer_id alone or\n-- on both customer_id and order_date, but not order_date alone',
        ),
        const SizedBox(height: 16),
        _buildExampleCard(
          title: 'Unique Index',
          description: 'Create an index that enforces uniqueness:',
          code: '-- Ensures no duplicate values in the indexed column(s)\nCREATE UNIQUE INDEX idx_users_email ON users (email);\n\n-- Can be used as an alternative to a UNIQUE constraint',
        ),
        const SizedBox(height: 20),
        
        // Managing Indexes
        _buildSectionHeader('Managing Indexes'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'Viewing Indexes',
          description: 'See what indexes exist on a table:',
          code: '-- PostgreSQL\nSELECT * FROM pg_indexes WHERE tablename = \'table_name\';\n\n-- MySQL\nSHOW INDEXES FROM table_name;\n\n-- SQL Server\nSP_HELPINDEX \'table_name\';',
        ),
        const SizedBox(height: 16),
        _buildExampleCard(
          title: 'Dropping Indexes',
          description: 'Remove an index that\'s no longer needed:',
          code: '-- Standard syntax\nDROP INDEX index_name ON table_name;\n\n-- MySQL syntax\nDROP INDEX index_name ON table_name;\n\n-- SQL Server syntax\nDROP INDEX table_name.index_name;',
        ),
        const SizedBox(height: 20),
        
        // When to Use Indexes
        _buildSectionHeader('When to Use Indexes'),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Columns Used in WHERE Clauses',
          content: 'Index columns that are frequently used in WHERE clauses, particularly in large tables.',
          icon: Icons.filter_alt,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'JOIN Columns',
          content: 'Index foreign key columns used in JOINs to speed up table joins.',
          icon: Icons.link,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'ORDER BY Columns',
          content: 'Index columns used in ORDER BY clauses to avoid expensive sorting operations.',
          icon: Icons.sort,
        ),
        const SizedBox(height: 20),
        
        // When to Avoid Indexes
        _buildSectionHeader('When to Avoid Indexes'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Small tables where a full table scan is already fast',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Columns with low cardinality (few unique values) like status or gender',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Tables with frequent large batch INSERT/UPDATE/DELETE operations',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Columns rarely used in WHERE clauses or joins',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Index Performance Considerations
        _buildSectionHeader('Performance Considerations'),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Index Overhead',
          content: 'Indexes speed up reads but slow down writes because the index must be updated with each data change.',
          icon: Icons.speed,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Index Selectivity',
          content: 'Indexes work best on columns with high selectivity (many unique values). Low selectivity can cause the optimizer to ignore the index.',
          icon: Icons.filter_list,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Index Size',
          content: 'Indexes consume additional storage space and memory. Monitor index size, especially for large tables.',
          icon: Icons.storage,
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Don\'t over-index: Each index adds overhead to writes',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Place most selective columns first in composite indexes',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Regularly analyze query performance with EXPLAIN/EXPLAIN ANALYZE',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider partial indexes for large tables with common filters',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Maintain indexes: Rebuild or reorganize periodically',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Index Fragmentation
        _buildSectionHeader('Index Fragmentation'),
        const SizedBox(height: 12),
        const Text(
          'Over time, as data is modified, indexes become fragmented, leading to decreased performance. Regular maintenance helps keep indexes efficient:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        _buildExampleCard(
          title: 'Checking Fragmentation (SQL Server)',
          description: 'View fragmentation levels:',
          code: 'SELECT a.index_id, name, avg_fragmentation_in_percent\nFROM sys.dm_db_index_physical_stats\n  (DB_ID(\'YourDatabase\'), OBJECT_ID(\'YourTable\'), NULL, NULL, NULL) AS a\nJOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id;',
        ),
        const SizedBox(height: 16),
        _buildExampleCard(
          title: 'Rebuilding an Index',
          description: 'Completely recreate the index:',
          code: '-- SQL Server\nALTER INDEX index_name ON table_name REBUILD;\n\n-- PostgreSQL\nREINDEX INDEX index_name;\n\n-- MySQL\nALTER TABLE table_name DROP INDEX index_name;\nALTER TABLE table_name ADD INDEX index_name (column_list);',
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Database Performance'),
            _buildChip('Query Optimization'),
            _buildChip('Table Partitioning'),
            _buildChip('Execution Plans'),
            _buildChip('Database Monitoring'),
          ],
        ),
      ],
    );
  }

  Widget _buildConstraintsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Constraints are rules enforced on columns or tables that limit the type of data that can be stored, ensuring accuracy, reliability, and integrity of the data in a database.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Types of Constraints
        _buildSectionHeader('Types of Constraints'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'PRIMARY KEY',
          content: 'Uniquely identifies each record in a table. Combines UNIQUE and NOT NULL constraints. A table can have only one primary key.',
          icon: Icons.key,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'FOREIGN KEY',
          content: 'Ensures referential integrity by linking data in one table to data in another table. Prevents actions that would destroy links between tables.',
          icon: Icons.link,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'UNIQUE',
          content: 'Ensures all values in a column are different. Unlike PRIMARY KEY, a table can have multiple UNIQUE constraints, and UNIQUE columns can contain NULL values.',
          icon: Icons.verified,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'NOT NULL',
          content: 'Ensures a column cannot have a NULL value. Forces a column to always contain a value, which means that you cannot insert a new record or update a record without adding a value to this column.',
          icon: Icons.block,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'CHECK',
          content: 'Ensures all values in a column satisfy a specific condition. Used to limit the values that can be placed in a column.',
          icon: Icons.rule,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'DEFAULT',
          content: 'Provides a default value for a column when no value is specified during an insert operation.',
          icon: Icons.settings_backup_restore,
        ),
        const SizedBox(height: 20),
        
        // Creating Constraints
        _buildSectionHeader('Creating Constraints'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'Creating Constraints at Table Creation',
          description: 'Adding constraints when you first create a table:',
          code: 'CREATE TABLE employees (\n  employee_id INT PRIMARY KEY,\n  first_name VARCHAR(50) NOT NULL,\n  last_name VARCHAR(50) NOT NULL,\n  email VARCHAR(100) UNIQUE,\n  hire_date DATE NOT NULL,\n  salary DECIMAL(10,2) CHECK (salary > 0),\n  department_id INT,\n  manager_id INT DEFAULT NULL,\n  CONSTRAINT fk_department FOREIGN KEY (department_id) \n    REFERENCES departments(department_id),\n  CONSTRAINT fk_manager FOREIGN KEY (manager_id) \n    REFERENCES employees(employee_id)\n);',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Adding Constraints to Existing Tables',
          description: 'Modifying an existing table to add constraints:',
          code: '-- Adding a PRIMARY KEY constraint\nALTER TABLE employees\nADD CONSTRAINT pk_employees PRIMARY KEY (employee_id);\n\n-- Adding a FOREIGN KEY constraint\nALTER TABLE employees\nADD CONSTRAINT fk_department FOREIGN KEY (department_id) \n  REFERENCES departments(department_id);\n\n-- Adding a UNIQUE constraint\nALTER TABLE employees\nADD CONSTRAINT uq_email UNIQUE (email);\n\n-- Adding a CHECK constraint\nALTER TABLE employees\nADD CONSTRAINT chk_salary CHECK (salary > 0);',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Adding Column-Level Constraints',
          description: 'Modifying a column to add constraints:',
          code: '-- Adding a NOT NULL constraint\nALTER TABLE employees\nALTER COLUMN first_name SET NOT NULL;\n\n-- Adding a DEFAULT constraint\nALTER TABLE employees\nALTER COLUMN active SET DEFAULT TRUE;\n\n-- Note: Syntax varies slightly between database systems',
        ),
        const SizedBox(height: 20),
        
        // Viewing Constraints
        _buildSectionHeader('Viewing Constraints'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'Viewing Table Constraints',
          description: 'SQL queries to view existing constraints:',
          code: '-- PostgreSQL\nSELECT conname, contype, pg_get_constraintdef(oid)\nFROM pg_constraint\nWHERE conrelid = \'employees\'::regclass;\n\n-- MySQL\nSELECT CONSTRAINT_NAME, CONSTRAINT_TYPE\nFROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS\nWHERE TABLE_NAME = \'employees\';\n\n-- SQL Server\nSELECT name, type_desc\nFROM sys.objects\nWHERE parent_object_id = OBJECT_ID(\'employees\')\nAND type_desc LIKE \'%CONSTRAINT\';',
        ),
        const SizedBox(height: 20),
        
        // Dropping Constraints
        _buildSectionHeader('Dropping Constraints'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'Removing Constraints',
          description: 'SQL commands to remove constraints:',
          code: '-- Dropping a PRIMARY KEY constraint\nALTER TABLE employees\nDROP CONSTRAINT pk_employees;\n\n-- Dropping a FOREIGN KEY constraint\nALTER TABLE employees\nDROP CONSTRAINT fk_department;\n\n-- Dropping a UNIQUE constraint\nALTER TABLE employees\nDROP CONSTRAINT uq_email;\n\n-- Dropping a CHECK constraint\nALTER TABLE employees\nDROP CONSTRAINT chk_salary;\n\n-- Dropping a DEFAULT constraint (SQL Server)\nALTER TABLE employees\nALTER COLUMN manager_id DROP DEFAULT;',
        ),
        const SizedBox(height: 20),
        
        // Constraint Examples
        _buildSectionHeader('Constraint Examples'),
        const SizedBox(height: 12),
        
        _buildExampleCard(
          title: 'PRIMARY KEY Example',
          description: 'Using a primary key to uniquely identify records:',
          code: 'CREATE TABLE products (\n  product_id INT PRIMARY KEY,\n  product_name VARCHAR(100) NOT NULL,\n  price DECIMAL(10,2) NOT NULL\n);\n\n-- Attempting to insert duplicate primary key (will fail)\nINSERT INTO products VALUES (1, \'Laptop\', 999.99);\nINSERT INTO products VALUES (1, \'Smartphone\', 499.99);',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'FOREIGN KEY Example',
          description: 'Enforcing referential integrity between tables:',
          code: 'CREATE TABLE categories (\n  category_id INT PRIMARY KEY,\n  category_name VARCHAR(50) NOT NULL\n);\n\nCREATE TABLE products (\n  product_id INT PRIMARY KEY,\n  product_name VARCHAR(100) NOT NULL,\n  category_id INT,\n  FOREIGN KEY (category_id) REFERENCES categories(category_id)\n);\n\n-- This will fail if category_id 100 doesn\'t exist in categories table\nINSERT INTO products VALUES (1, \'Laptop\', 100);',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'CHECK Constraint Example',
          description: 'Validating data before insertion or update:',
          code: 'CREATE TABLE employees (\n  employee_id INT PRIMARY KEY,\n  first_name VARCHAR(50) NOT NULL,\n  last_name VARCHAR(50) NOT NULL,\n  email VARCHAR(100) UNIQUE,\n  hire_date DATE NOT NULL,\n  salary DECIMAL(10,2),\n  CONSTRAINT chk_salary CHECK (salary > 0),\n  CONSTRAINT chk_hire_date CHECK (hire_date <= CURRENT_DATE)\n);\n\n-- This will fail due to negative salary\nINSERT INTO employees VALUES (1, \'John\', \'Doe\', \'john@example.com\', \'2023-01-15\', -50000);',
        ),
        const SizedBox(height: 20),
        
        // Foreign Key Actions
        _buildSectionHeader('Foreign Key Actions'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ON DELETE Options:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• CASCADE: When a parent record is deleted, automatically delete the related child records',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 4),
              Text(
                '• SET NULL: When a parent record is deleted, set the foreign key in child records to NULL',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 4),
              Text(
                '• SET DEFAULT: When a parent record is deleted, set the foreign key in child records to its default value',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 4),
              Text(
                '• RESTRICT: Prevent deletion of a parent record if it has any child records (implicit default in many databases)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 4),
              Text(
                '• NO ACTION: Similar to RESTRICT, but checked at the end of the transaction',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'ON UPDATE Options:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Similar options apply when updating a primary key in the parent table',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Foreign Key with Actions',
          description: 'Setting up cascade delete and update:',
          code: 'CREATE TABLE orders (\n  order_id INT PRIMARY KEY,\n  customer_id INT,\n  order_date DATE,\n  FOREIGN KEY (customer_id) \n    REFERENCES customers(customer_id)\n    ON DELETE CASCADE\n    ON UPDATE CASCADE\n);\n\n-- If a customer is deleted, all their orders will also be deleted\n-- If a customer_id is updated, it will automatically update in the orders table',
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Always use constraints to enforce data integrity at the database level',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Name constraints explicitly for better maintenance and troubleshooting',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Index foreign key columns to improve join performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Be cautious with ON DELETE/UPDATE CASCADE - it can lead to unintended mass deletions',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider the performance impact of complex CHECK constraints on large tables',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use application-level validation in addition to database constraints for a better user experience',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Primary Keys'),
            _buildChip('Foreign Keys'),
            _buildChip('Database Design'),
            _buildChip('Normalization'),
            _buildChip('Data Integrity'),
            _buildChip('Indexes'),
          ],
        ),
      ],
    );
  }

  Widget _buildSubqueriesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subqueries (also known as nested queries or inner queries) are queries nested within another query, allowing for complex data retrieval and manipulation. They can appear in the SELECT, FROM, WHERE, or HAVING clauses.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Types of Subqueries
        _buildSectionHeader('Types of Subqueries'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Scalar Subquery',
          content: 'Returns a single value (one row, one column) that can be used in a comparison or as a column value.',
          icon: Icons.filter_1,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Row Subquery',
          content: 'Returns a single row with multiple columns that can be compared with another row.',
          icon: Icons.table_rows,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Column Subquery',
          content: 'Returns a single column with multiple rows, often used with IN operators.',
          icon: Icons.view_column,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Table Subquery',
          content: 'Returns multiple rows and columns, essentially a derived table used in the FROM clause.',
          icon: Icons.grid_view,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Correlated Subquery',
          content: 'References columns from the outer query, reevaluating for each row processed by the outer query.',
          icon: Icons.link,
        ),
        const SizedBox(height: 20),
        
        // Subquery in WHERE Clause
        _buildSectionHeader('Subquery in WHERE Clause'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'Scalar Subquery with Comparison Operator',
          description: 'Finding employees with salary above average:',
          code: 'SELECT employee_id, first_name, last_name, salary\nFROM employees\nWHERE salary > (\n  SELECT AVG(salary)\n  FROM employees\n);',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Subquery with IN Operator',
          description: 'Finding employees in the IT department:',
          code: 'SELECT employee_id, first_name, last_name\nFROM employees\nWHERE department_id IN (\n  SELECT department_id\n  FROM departments\n  WHERE department_name = \'IT\'\n);',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Subquery with NOT IN',
          description: 'Finding products that have never been ordered:',
          code: 'SELECT product_id, product_name\nFROM products\nWHERE product_id NOT IN (\n  SELECT DISTINCT product_id\n  FROM order_items\n);',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Subquery with EXISTS',
          description: 'Finding departments that have at least one employee:',
          code: 'SELECT department_id, department_name\nFROM departments d\nWHERE EXISTS (\n  SELECT 1\n  FROM employees e\n  WHERE e.department_id = d.department_id\n);',
        ),
        const SizedBox(height: 20),
        
        // Subquery in SELECT Clause
        _buildSectionHeader('Subquery in SELECT Clause'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'Scalar Subquery in SELECT',
          description: 'Displaying department name along with employee details:',
          code: 'SELECT e.employee_id, e.first_name, e.last_name,\n  (SELECT department_name FROM departments d WHERE d.department_id = e.department_id) AS department\nFROM employees e;',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Calculating Deviation from Average',
          description: 'Showing how each employee\'s salary compares to the average:',
          code: 'SELECT employee_id, first_name, last_name, salary,\n  salary - (SELECT AVG(salary) FROM employees) AS salary_deviation\nFROM employees;',
        ),
        const SizedBox(height: 20),
        
        // Subquery in FROM Clause
        _buildSectionHeader('Subquery in FROM Clause'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'Derived Tables',
          description: 'Using a subquery to create a temporary result set:',
          code: 'SELECT dept_name, avg_salary\nFROM (\n  SELECT d.department_name AS dept_name, AVG(e.salary) AS avg_salary\n  FROM employees e\n  JOIN departments d ON e.department_id = d.department_id\n  GROUP BY d.department_name\n) AS dept_salaries\nWHERE avg_salary > 5000;',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Aggregating from a Derived Table',
          description: 'Calculating the highest and lowest department average salaries:',
          code: 'SELECT MAX(avg_salary) AS highest_avg, MIN(avg_salary) AS lowest_avg\nFROM (\n  SELECT department_id, AVG(salary) AS avg_salary\n  FROM employees\n  GROUP BY department_id\n) AS dept_avg;',
        ),
        const SizedBox(height: 20),
        
        // Correlated Subqueries
        _buildSectionHeader('Correlated Subqueries'),
        const SizedBox(height: 12),
        const Text(
          'Correlated subqueries reference columns from the outer query and are re-evaluated for each row processed by the outer query.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Finding Top Earners in Each Department',
          description: 'Identifies employees with the highest salary in their department:',
          code: 'SELECT d.department_name, e.first_name, e.last_name, e.salary\nFROM employees e\nJOIN departments d ON e.department_id = d.department_id\nWHERE e.salary = (\n  SELECT MAX(salary)\n  FROM employees\n  WHERE department_id = e.department_id\n);',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Finding Employees Above Department Average',
          description: 'Identifies employees earning more than their department\'s average:',
          code: 'SELECT e.employee_id, e.first_name, e.last_name, e.salary, d.department_name\nFROM employees e\nJOIN departments d ON e.department_id = d.department_id\nWHERE e.salary > (\n  SELECT AVG(salary)\n  FROM employees\n  WHERE department_id = e.department_id\n);',
        ),
        const SizedBox(height: 20),
        
        // Nested Subqueries
        _buildSectionHeader('Nested Subqueries'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'Multiple Levels of Nesting',
          description: 'Finding employees in the department with the highest average salary:',
          code: 'SELECT employee_id, first_name, last_name, salary\nFROM employees\nWHERE department_id = (\n  SELECT department_id\n  FROM employees\n  GROUP BY department_id\n  HAVING AVG(salary) = (\n    SELECT MAX(avg_sal)\n    FROM (\n      SELECT AVG(salary) AS avg_sal\n      FROM employees\n      GROUP BY department_id\n    ) AS dept_avg\n  )\n);',
        ),
        const SizedBox(height: 20),
        
        // Performance Considerations
        _buildSectionHeader('Performance Considerations'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Correlated subqueries can be performance-intensive as they execute once for each row in the outer query',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider using JOINs instead of subqueries when possible, especially for large datasets',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Deeply nested subqueries can be difficult to optimize and maintain',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use EXISTS instead of IN for better performance when checking for the existence of related records',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• The query optimizer may rewrite your subquery as a join internally for better performance',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Use meaningful aliases for derived tables to improve readability',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Format nested queries with proper indentation to maintain clarity',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider using CTEs (Common Table Expressions) as an alternative to complex subqueries',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• For testing, write subqueries separately before integrating them into the main query',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use EXPLAIN or execution plans to understand how your subqueries are being processed',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Common Table Expressions'),
            _buildChip('JOINs'),
            _buildChip('Query Optimization'),
            _buildChip('Execution Plans'),
            _buildChip('Aggregate Functions'),
          ],
        ),
      ],
    );
  }

  Widget _buildCommonTableExpressionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Common Table Expressions (CTEs) define temporary result sets that can be referenced within a SELECT, INSERT, UPDATE, or DELETE statement. They provide a way to write more readable and maintainable complex queries.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic CTE Syntax
        _buildSectionHeader('Basic CTE Syntax'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'CTE Structure',
          description: 'The basic structure of a CTE query:',
          code: 'WITH cte_name (column1, column2, ...) AS (\n  -- CTE query definition\n  SELECT column1, column2, ...\n  FROM table_name\n  WHERE condition\n)\nSELECT * FROM cte_name;\n\n-- Column names are optional if they match the column names in the CTE query',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Simple CTE Example',
          description: 'Using a CTE to find employees with above-average salaries:',
          code: 'WITH HighPaidEmployees AS (\n  SELECT *\n  FROM employees\n  WHERE salary > (SELECT AVG(salary) FROM employees)\n)\nSELECT employee_id, first_name, last_name, salary\nFROM HighPaidEmployees\nORDER BY salary DESC;',
        ),
        const SizedBox(height: 20),
        
        // CTE vs Subqueries
        _buildSectionHeader('CTEs vs Subqueries'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Advantages of CTEs over Subqueries:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Improved readability with named result sets',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 4),
              Text(
                '• Ability to reference the same CTE multiple times in a query',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 4),
              Text(
                '• Self-referencing capabilities for recursive queries',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 4),
              Text(
                '• Better structure for complex multi-step logic',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 4),
              Text(
                '• Can be used within DML statements (INSERT, UPDATE, DELETE)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Multiple CTEs
        _buildSectionHeader('Multiple CTEs'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'Using Multiple CTEs in a Query',
          description: 'Chaining CTEs for complex multi-step analysis:',
          code: 'WITH \nDepartmentSalaries AS (\n  SELECT department_id, AVG(salary) AS avg_salary\n  FROM employees\n  GROUP BY department_id\n),\nHighPaidDepartments AS (\n  SELECT department_id\n  FROM DepartmentSalaries\n  WHERE avg_salary > 5000\n)\nSELECT e.employee_id, e.first_name, e.last_name, d.department_name\nFROM employees e\nJOIN departments d ON e.department_id = d.department_id\nWHERE e.department_id IN (SELECT department_id FROM HighPaidDepartments);',
        ),
        const SizedBox(height: 20),
        
        // Recursive CTEs
        _buildSectionHeader('Recursive CTEs'),
        const SizedBox(height: 12),
        const Text(
          'Recursive CTEs allow you to reference the CTE itself within its definition, enabling hierarchical or graph-based queries such as organizational charts, bill of materials, or network paths.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Recursive CTE Syntax',
          description: 'The structure of a recursive CTE:',
          code: 'WITH RECURSIVE cte_name AS (\n  -- Anchor member (non-recursive term)\n  SELECT columns FROM table WHERE condition\n  \n  UNION [ALL]\n  \n  -- Recursive member (recursive term)\n  SELECT columns FROM table JOIN cte_name ON join_condition\n)\nSELECT columns FROM cte_name;\n\n-- Note: Some databases (like SQL Server) don\'t require the RECURSIVE keyword',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Employee Hierarchy Example',
          description: 'Finding all employees under a manager:',
          code: 'WITH RECURSIVE EmployeeHierarchy AS (\n  -- Anchor: Start with the specified manager\n  SELECT employee_id, first_name, last_name, manager_id, 0 AS level\n  FROM employees\n  WHERE employee_id = 100  -- Starting manager ID\n  \n  UNION ALL\n  \n  -- Recursive: Get all direct reports\n  SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, eh.level + 1\n  FROM employees e\n  JOIN EmployeeHierarchy eh ON e.manager_id = eh.employee_id\n)\nSELECT employee_id, first_name, last_name, level\nFROM EmployeeHierarchy\nORDER BY level, first_name;',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'Number Sequence Example',
          description: 'Generating a sequence of numbers from 1 to 10:',
          code: 'WITH RECURSIVE NumberSequence AS (\n  -- Anchor: Start with 1\n  SELECT 1 AS n\n  \n  UNION ALL\n  \n  -- Recursive: Add one to previous number until reaching 10\n  SELECT n + 1\n  FROM NumberSequence\n  WHERE n < 10\n)\nSELECT n FROM NumberSequence;',
        ),
        const SizedBox(height: 20),
        
        // CTEs in DML Statements
        _buildSectionHeader('CTEs in DML Statements'),
        const SizedBox(height: 12),
        _buildExampleCard(
          title: 'CTE with INSERT',
          description: 'Inserting data using a CTE to filter source data:',
          code: 'WITH NewEmployees AS (\n  SELECT *\n  FROM temp_employees\n  WHERE hire_date > \'2023-01-01\'\n)\nINSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary)\nSELECT employee_id, first_name, last_name, email, hire_date, salary\nFROM NewEmployees;',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'CTE with UPDATE',
          description: 'Updating records based on a CTE calculation:',
          code: 'WITH SalaryAdjustments AS (\n  SELECT employee_id, salary, \n         department_id,\n         salary * 1.1 AS new_salary\n  FROM employees\n  WHERE department_id = 10\n  AND performance_rating > 4\n)\nUPDATE employees\nSET salary = sa.new_salary\nFROM SalaryAdjustments sa\nWHERE employees.employee_id = sa.employee_id;',
        ),
        const SizedBox(height: 16),
        
        _buildExampleCard(
          title: 'CTE with DELETE',
          description: 'Deleting records using a CTE to identify candidates:',
          code: 'WITH InactiveAccounts AS (\n  SELECT user_id\n  FROM users\n  WHERE last_login_date < DATEADD(YEAR, -1, GETDATE())\n  AND account_status = \'Dormant\'\n)\nDELETE FROM users\nWHERE user_id IN (SELECT user_id FROM InactiveAccounts);',
        ),
        const SizedBox(height: 20),
        
        // Common Use Cases
        _buildSectionHeader('Common Use Cases'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Data Preparation',
          content: 'Using CTEs as intermediate steps to clean or transform data before final analysis.',
          icon: Icons.cleaning_services,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Hierarchical Data',
          content: 'Traversing tree structures like organizational charts, parts assemblies, or category hierarchies.',
          icon: Icons.account_tree,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Report Generation',
          content: 'Building complex reports with multiple aggregation levels or comparison points.',
          icon: Icons.summarize,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Substituting Complex Views',
          content: 'Using CTEs instead of creating permanent views for one-time complex queries.',
          icon: Icons.preview,
        ),
        const SizedBox(height: 20),
        
        // Performance Considerations
        _buildSectionHeader('Performance Considerations'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• CTEs are not materialized in most database systems - they\'re essentially named subqueries',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• If a CTE is referenced multiple times, it may be executed multiple times unless optimized by the query planner',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Recursive CTEs can be performance-intensive for deeply nested hierarchies',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider using temporary tables for very complex intermediate results that are referenced multiple times',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Always use termination conditions in recursive CTEs to prevent infinite loops',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Use meaningful names for CTEs that describe their purpose',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Break complex queries into logical steps using multiple CTEs',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Include comments explaining what each CTE does in complex scenarios',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Test recursive CTEs with known data to verify they produce expected results',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider database-specific optimizations like SQL Server\'s OPTION (MAXRECURSION n)',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Subqueries'),
            _buildChip('Recursive Queries'),
            _buildChip('Hierarchical Data'),
            _buildChip('Temporary Tables'),
            _buildChip('Query Optimization'),
          ],
        ),
      ],
    );
  }

  Widget _buildStoredProceduresContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stored procedures are prepared SQL code that can be saved and reused, making database operations more efficient and consistent.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        
        const SizedBox(height: 20),
        
        // Introduction
        _buildSectionHeader('What are Stored Procedures?'),
        const SizedBox(height: 12),
        const Text(
          'A stored procedure is a prepared SQL code that you can save and reuse. Instead of writing the same query multiple times, you can call the stored procedure with different parameters. Stored procedures are compiled once and stored in the database, making them faster and more efficient than sending multiple queries from your application.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Benefits Section
        _buildSectionHeader('Benefits of Stored Procedures'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Improved Performance',
          content: 'Stored procedures are compiled once and cached, resulting in faster execution for repeated calls. They also reduce network traffic by sending only the procedure name and parameters instead of the entire SQL statement.',
          icon: Icons.speed,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Better Security',
          content: 'Stored procedures can provide an additional security layer by restricting direct access to tables. Users can be given permission to execute specific procedures without having direct access to the underlying tables.',
          icon: Icons.security,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Code Modularity',
          content: 'Complex operations can be encapsulated in a single procedure, making application code cleaner and more maintainable. Changes to database logic can be made in one place without modifying application code.',
          icon: Icons.format_align_center,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Reduced Network Traffic',
          content: 'Only the call to the procedure is sent over the network, not the entire SQL statement, which can significantly reduce network traffic for complex operations.',
          icon: Icons.network_check,
        ),
        const SizedBox(height: 20),
        
        // Creating Stored Procedures
        _buildSectionHeader('Creating Stored Procedures'),
        const SizedBox(height: 16),
        
        // SQL Server Example
        _buildExampleCard(
          title: 'SQL Server Syntax',
          description: 'Creating a basic stored procedure in SQL Server:',
          code: 'CREATE PROCEDURE GetEmployeesByDepartment\n    @DepartmentID INT\nAS\nBEGIN\n    SELECT \n        EmployeeID,\n        FirstName,\n        LastName,\n        HireDate\n    FROM \n        Employees\n    WHERE \n        DepartmentID = @DepartmentID\nEND',
        ),
        const SizedBox(height: 16),
        
        // MySQL Example
        _buildExampleCard(
          title: 'MySQL Syntax',
          description: 'Creating a basic stored procedure in MySQL:',
          code: 'DELIMITER //\n\nCREATE PROCEDURE GetEmployeesByDepartment(\n    IN department_id INT\n)\nBEGIN\n    SELECT \n        employee_id,\n        first_name,\n        last_name,\n        hire_date\n    FROM \n        employees\n    WHERE \n        department_id = department_id;\nEND //\n\nDELIMITER ;',
        ),
        const SizedBox(height: 16),
        
        // PostgreSQL Example
        _buildExampleCard(
          title: 'PostgreSQL Syntax',
          description: 'Creating a basic stored procedure in PostgreSQL:',
          code: 'CREATE OR REPLACE PROCEDURE get_employees_by_department(\n    department_id INTEGER\n)\nLANGUAGE plpgsql\nAS \$\$\nBEGIN\n    SELECT \n        employee_id,\n        first_name,\n        last_name,\n        hire_date\n    FROM \n        employees\n    WHERE \n        department_id = \$1;\nEND;\n\$\$;',
        ),
        const SizedBox(height: 20),
        
        // Parameters in Stored Procedures
        _buildSectionHeader('Parameters in Stored Procedures'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Input Parameters',
          content: 'Values passed to the stored procedure that it can use in its operations. These allow the same procedure to be used with different values.',
          icon: Icons.input,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Output Parameters',
          content: 'Parameters that allow the procedure to return values back to the caller. These are useful when you need to return multiple values or status information.',
          icon: Icons.output,
        ),
        const SizedBox(height: 16),
        
        // Parameter Examples
        _buildExampleCard(
          title: 'Procedure with Output Parameter',
          description: 'SQL Server procedure that returns a value via an output parameter:',
          code: 'CREATE PROCEDURE CalculateOrderTotal\n    @OrderID INT,\n    @TotalAmount DECIMAL(10,2) OUTPUT\nAS\nBEGIN\n    SELECT @TotalAmount = SUM(UnitPrice * Quantity * (1 - Discount))\n    FROM Order_Details\n    WHERE OrderID = @OrderID\nEND',
        ),
        const SizedBox(height: 16),
        
        // Executing Stored Procedures
        _buildSectionHeader('Executing Stored Procedures'),
        const SizedBox(height: 16),
        
        // SQL Server Execute
        _buildExampleCard(
          title: 'Executing in SQL Server',
          description: 'Calling a stored procedure with parameters:',
          code: '-- Simple execution\nEXECUTE GetEmployeesByDepartment 5;\n\n-- With output parameter\nDECLARE @Total DECIMAL(10,2)\nEXECUTE CalculateOrderTotal 10248, @Total OUTPUT\nSELECT @Total AS OrderTotal',
        ),
        const SizedBox(height: 16),
        
        // MySQL Execute
        _buildExampleCard(
          title: 'Executing in MySQL',
          description: 'Calling a stored procedure with parameters:',
          code: 'CALL GetEmployeesByDepartment(5);',
        ),
        const SizedBox(height: 20),
        
        // Control Flow in Stored Procedures
        _buildSectionHeader('Control Flow in Stored Procedures'),
        const SizedBox(height: 16),
        
        // IF-ELSE Example
        _buildExampleCard(
          title: 'Conditional Logic (IF-ELSE)',
          description: 'Using conditional logic in a stored procedure:',
          code: 'CREATE PROCEDURE ApplyDiscount\n    @CustomerID INT,\n    @OrderID INT,\n    @DiscountPercent DECIMAL(5,2)\nAS\nBEGIN\n    DECLARE @CustomerType VARCHAR(20)\n    \n    SELECT @CustomerType = CustomerType\n    FROM Customers \n    WHERE CustomerID = @CustomerID\n    \n    IF @CustomerType = \'Premium\'\n    BEGIN\n        -- Premium customers get an extra 5% discount\n        UPDATE Orders\n        SET Discount = @DiscountPercent + 5.00\n        WHERE OrderID = @OrderID\n    END\n    ELSE\n    BEGIN\n        UPDATE Orders\n        SET Discount = @DiscountPercent\n        WHERE OrderID = @OrderID\n    END\nEND',
        ),
        const SizedBox(height: 16),
        
        // Loop Example
        _buildExampleCard(
          title: 'Loops',
          description: 'Using loops in a stored procedure:',
          code: 'CREATE PROCEDURE ProcessBatchOrders\n    @BatchSize INT\nAS\nBEGIN\n    DECLARE @Counter INT = 0\n    DECLARE @MaxOrderID INT\n    \n    SELECT @MaxOrderID = MAX(OrderID) FROM PendingOrders\n    \n    WHILE @Counter < @BatchSize AND @Counter <= @MaxOrderID\n    BEGIN\n        -- Process each order\n        UPDATE PendingOrders\n        SET Status = \'Processed\'\n        WHERE OrderID = @Counter\n        \n        SET @Counter = @Counter + 1\n    END\nEND',
        ),
        const SizedBox(height: 20),
        
        // Error Handling in Stored Procedures
        _buildSectionHeader('Error Handling'),
        const SizedBox(height: 16),
        
        // SQL Server Error Handling
        _buildExampleCard(
          title: 'TRY-CATCH in SQL Server',
          description: 'Handling errors in SQL Server stored procedures:',
          code: 'CREATE PROCEDURE TransferFunds\n    @FromAccount INT,\n    @ToAccount INT,\n    @Amount DECIMAL(10,2)\nAS\nBEGIN\n    BEGIN TRY\n        BEGIN TRANSACTION\n            \n            -- Deduct from source account\n            UPDATE Accounts\n            SET Balance = Balance - @Amount\n            WHERE AccountID = @FromAccount\n            \n            -- Add to destination account\n            UPDATE Accounts\n            SET Balance = Balance + @Amount\n            WHERE AccountID = @ToAccount\n            \n        COMMIT TRANSACTION\n    END TRY\n    BEGIN CATCH\n        ROLLBACK TRANSACTION\n        \n        -- Log the error\n        INSERT INTO ErrorLog (ErrorNumber, ErrorMessage, ErrorTime)\n        VALUES (ERROR_NUMBER(), ERROR_MESSAGE(), GETDATE())\n        \n        -- Return error to caller\n        THROW\n    END CATCH\nEND',
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Use meaningful names for procedures and parameters',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Document procedures with comments explaining their purpose and parameters',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Include proper error handling to make procedures robust',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Keep procedures focused on a single task or related set of tasks',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use transactions when modifying multiple tables to ensure data consistency',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Test procedures thoroughly with different parameter values',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Triggers'),
            _buildChip('Transactions'),
            _buildChip('User-Defined Functions'),
            _buildChip('Views'),
            _buildChip('Batch Processing'),
          ],
        ),
      ],
    );
  }

  Widget _buildTriggersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Triggers are special types of stored procedures that automatically execute when a specified database event occurs, such as an insert, update, or delete operation. They help enforce business rules, maintain data integrity, and automate tasks within the database.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Basic Trigger Concepts
        _buildSectionHeader('Trigger Concepts'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Activation Time',
          content: 'Triggers can execute BEFORE, AFTER, or INSTEAD OF the triggering event, depending on the database system.',
          icon: Icons.timer,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Trigger Events',
          content: 'Events that can trigger execution include INSERT, UPDATE, DELETE, or combinations of these operations.',
          icon: Icons.event,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Granularity',
          content: 'Triggers can fire once per statement (statement-level) or once for each affected row (row-level).',
          icon: Icons.grain,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Special References',
          content: 'NEW and OLD references allow access to the values of columns before and after a change (syntax varies by database).',
          icon: Icons.compare_arrows,
        ),
        const SizedBox(height: 20),
        
        // Creating Triggers
        _buildSectionHeader('Creating Triggers'),
        const SizedBox(height: 16),
        
        // MySQL Trigger
        _buildExampleCard(
          title: 'MySQL Trigger Example',
          description: 'AFTER INSERT trigger that logs new employee records:',
          code: 'CREATE TRIGGER after_employee_insert\nAFTER INSERT ON employees\nFOR EACH ROW\nBEGIN\n  INSERT INTO employee_audit (employee_id, action, change_date)\n  VALUES (NEW.employee_id, \'INSERT\', NOW());\nEND;',
        ),
        const SizedBox(height: 16),
        
        // SQL Server Trigger
        _buildExampleCard(
          title: 'SQL Server Trigger Example',
          description: 'AFTER UPDATE trigger that tracks salary changes:',
          code: 'CREATE TRIGGER trg_salary_changes\nON employees\nAFTER UPDATE\nAS\nBEGIN\n  IF UPDATE(salary)\n  BEGIN\n    INSERT INTO salary_audit (employee_id, old_salary, new_salary, change_date)\n    SELECT i.employee_id, d.salary, i.salary, GETDATE()\n    FROM inserted i\n    INNER JOIN deleted d ON i.employee_id = d.employee_id\n    WHERE i.salary <> d.salary;\n  END\nEND;',
        ),
        const SizedBox(height: 16),
        
        // PostgreSQL Trigger
        _buildExampleCard(
          title: 'PostgreSQL Trigger Example',
          description: 'BEFORE DELETE trigger that prevents deleting active products:',
          code: 'CREATE OR REPLACE FUNCTION prevent_product_deletion()\nRETURNS TRIGGER AS \$\$\nBEGIN\n  IF (OLD.status = \'active\') THEN\n    RAISE EXCEPTION \'Cannot delete active products\';\n  END IF;\n  RETURN OLD;\nEND;\n\$\$ LANGUAGE plpgsql;\n\nCREATE TRIGGER trg_prevent_product_deletion\nBEFORE DELETE ON products\nFOR EACH ROW\nEXECUTE FUNCTION prevent_product_deletion();',
        ),
        const SizedBox(height: 20),
        
        // Practical Use Cases
        _buildSectionHeader('Common Use Cases'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Audit Trails',
          content: 'Track changes to sensitive data (who, what, when) by logging modifications to an audit table.',
          icon: Icons.history,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Data Validation',
          content: 'Ensure complex business rules by validating data before it\'s committed to the database.',
          icon: Icons.check_circle,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Calculated Fields',
          content: 'Automatically update calculated or derived values when source data changes.',
          icon: Icons.calculate,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Referential Integrity',
          content: 'Enforce complex relationships beyond foreign key constraints.',
          icon: Icons.link,
        ),
        const SizedBox(height: 20),
        
        // Trigger Management
        _buildSectionHeader('Managing Triggers'),
        const SizedBox(height: 16),
        
        // Disabling Triggers
        _buildExampleCard(
          title: 'Disabling Triggers',
          description: 'Temporarily disable triggers for bulk operations:',
          code: '-- SQL Server\nDISABLE TRIGGER trg_salary_changes ON employees;\n\n-- Oracle\nALTER TRIGGER emp_salary_check DISABLE;\n\n-- MySQL\nSET @TRIGGER_CHECKS = 0; -- Disables all triggers',
        ),
        const SizedBox(height: 16),
        
        // Dropping Triggers
        _buildExampleCard(
          title: 'Dropping Triggers',
          description: 'Remove triggers that are no longer needed:',
          code: '-- SQL Server, MySQL, PostgreSQL\nDROP TRIGGER [trigger_name] ON [table_name];\n\n-- Oracle\nDROP TRIGGER [trigger_name];',
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Keep trigger logic simple and focused on a single purpose',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Avoid recursive trigger chains that may cause infinite loops',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider performance impacts, especially for tables with high transaction volumes',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use error handling in triggers to gracefully handle exceptions',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Document triggers carefully, as they represent "invisible" logic that executes automatically',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Potential Issues
        _buildSectionHeader('Potential Issues'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Performance overhead: Triggers execute for every qualifying operation, potentially slowing down DML operations',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Hidden logic: Code in triggers isn\'t visible at the application layer, making debugging more difficult',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Cascading effects: Triggers that modify other tables can cause additional triggers to fire',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Portability issues: Trigger syntax and capabilities vary significantly between database systems',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Stored Procedures'),
            _buildChip('Transactions'),
            _buildChip('Constraints'),
            _buildChip('Event Scheduling'),
            _buildChip('Database Security'),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transactions are logical units of work that consist of one or more SQL operations (such as INSERT, UPDATE, or DELETE) treated as a single, indivisible operation. They ensure that a series of operations either all complete successfully or all fail, maintaining database consistency even during errors or system failures.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // ACID Properties
        _buildSectionHeader('ACID Properties'),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Atomicity',
          content: 'All operations in a transaction are completed successfully, or none of them are. This prevents partial updates that could leave the database in an inconsistent state.',
          icon: Icons.all_inclusive,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Consistency',
          content: 'A transaction brings the database from one valid state to another valid state, ensuring that all data integrity constraints are maintained.',
          icon: Icons.verified,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Isolation',
          content: 'Concurrent transactions execute as if they were running sequentially, preventing interference between transactions executing at the same time.',
          icon: Icons.security,
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Durability',
          content: 'Once a transaction is committed, its changes are permanent and will survive system failures, including power outages or crashes.',
          icon: Icons.save_alt,
        ),
        const SizedBox(height: 20),
        
        // Transaction Control Commands
        _buildSectionHeader('Transaction Control Commands'),
        const SizedBox(height: 16),
        
        // BEGIN/START TRANSACTION
        _buildExampleCard(
          title: 'BEGIN/START TRANSACTION',
          description: 'Marks the starting point of a transaction:',
          code: '-- SQL Standard, PostgreSQL, MySQL\nBEGIN TRANSACTION;\n\n-- SQL Server\nBEGIN TRANSACTION;\n\n-- Oracle\nSET TRANSACTION;',
        ),
        const SizedBox(height: 16),
        
        // COMMIT
        _buildExampleCard(
          title: 'COMMIT',
          description: 'Makes all changes permanent:',
          code: '-- Universal syntax\nCOMMIT;',
        ),
        const SizedBox(height: 16),
        
        // ROLLBACK
        _buildExampleCard(
          title: 'ROLLBACK',
          description: 'Undoes all changes made in the current transaction:',
          code: '-- Universal syntax\nROLLBACK;',
        ),
        const SizedBox(height: 16),
        
        // SAVEPOINT
        _buildExampleCard(
          title: 'SAVEPOINT',
          description: 'Creates a point to which you can roll back within a transaction:',
          code: '-- Create a savepoint\nSAVEPOINT savepoint_name;\n\n-- Roll back to a savepoint\nROLLBACK TO SAVEPOINT savepoint_name;',
        ),
        const SizedBox(height: 20),
        
        // Transaction Examples
        _buildSectionHeader('Transaction Examples'),
        const SizedBox(height: 16),
        
        // Basic Transaction
        _buildExampleCard(
          title: 'Basic Transaction',
          description: 'Transfer money between two accounts:',
          code: 'BEGIN TRANSACTION;\n\n-- Deduct from source account\nUPDATE accounts\nSET balance = balance - 1000\nWHERE account_id = 123;\n\n-- Add to destination account\nUPDATE accounts\nSET balance = balance + 1000\nWHERE account_id = 456;\n\n-- Check if both operations succeeded\nIF @@ERROR = 0\n  COMMIT;\nELSE\n  ROLLBACK;\n',
        ),
        const SizedBox(height: 16),
        
        // Transaction with Error Handling
        _buildExampleCard(
          title: 'Transaction with Error Handling',
          description: 'Using TRY-CATCH (SQL Server) for robust error handling:',
          code: 'BEGIN TRY\n  BEGIN TRANSACTION;\n    \n    INSERT INTO orders (customer_id, order_date, total)\n    VALUES (101, GETDATE(), 499.99);\n    \n    -- Get the new order ID\n    DECLARE @order_id INT = SCOPE_IDENTITY();\n    \n    -- Insert order items\n    INSERT INTO order_items (order_id, product_id, quantity, price)\n    VALUES (@order_id, 1001, 2, 199.99),\n           (@order_id, 1002, 1, 100.01);\n  \n  COMMIT TRANSACTION;\n  \n  SELECT \'Order placed successfully\' AS status;\nEND TRY\nBEGIN CATCH\n  ROLLBACK TRANSACTION;\n  \n  SELECT\n    \'Transaction failed: \' + ERROR_MESSAGE() AS status,\n    ERROR_NUMBER() AS error_number,\n    ERROR_LINE() AS error_line;\nEND CATCH;',
        ),
        const SizedBox(height: 20),
        
        // Transaction Isolation Levels
        _buildSectionHeader('Transaction Isolation Levels'),
        const SizedBox(height: 12),
        const Text(
          'Isolation levels control how transactions interact with each other, balancing data consistency with performance:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        
        // Isolation Levels Table
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                ),
                child: const Text(
                  'Isolation Levels and Concurrency Phenomena',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Table rows
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIsolationLevelRow(
                      'READ UNCOMMITTED',
                      'Lowest isolation level. Allows transactions to read uncommitted changes, risking dirty reads.',
                      'Low',
                      'High',
                    ),
                    const Divider(),
                    _buildIsolationLevelRow(
                      'READ COMMITTED',
                      'Ensures a transaction only reads committed data, preventing dirty reads.',
                      'Medium-Low',
                      'Medium-High',
                    ),
                    const Divider(),
                    _buildIsolationLevelRow(
                      'REPEATABLE READ',
                      'Ensures rows read during a transaction won\'t change until the transaction completes.',
                      'Medium-High',
                      'Medium-Low',
                    ),
                    const Divider(),
                    _buildIsolationLevelRow(
                      'SERIALIZABLE',
                      'Highest isolation level. Transactions execute as if they were sequential, preventing all concurrency issues.',
                      'High',
                      'Low',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Setting Isolation Level
        _buildExampleCard(
          title: 'Setting Isolation Level',
          description: 'Specifying a transaction\'s isolation level:',
          code: '-- SQL Server, PostgreSQL\nSET TRANSACTION ISOLATION LEVEL READ COMMITTED;\n\n-- MySQL\nSET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;\n\n-- Oracle\nSET TRANSACTION ISOLATION LEVEL SERIALIZABLE;',
        ),
        const SizedBox(height: 20),
        
        // Best Practices
        _buildSectionHeader('Best Practices'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Keep transactions as short as possible to minimize lock contention',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Choose the appropriate isolation level based on your consistency requirements',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Use error handling to properly manage transaction flow',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Avoid user interaction during an open transaction',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider using savepoints for complex transactions that may need partial rollbacks',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Related Topics
        _buildSectionHeader('Related Topics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Concurrency Control'),
            _buildChip('Locks'),
            _buildChip('Deadlocks'),
            _buildChip('Error Handling'),
            _buildChip('Database Recovery'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildIsolationLevelRow(String level, String description, String consistency, String performance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Consistency',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  consistency,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Performance',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  performance,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Views are virtual tables based on the result set of an SQL query. They simplify complex queries, provide an additional security layer, and enable data abstraction without duplicating data. Views appear and can be queried like regular tables but don\'t store data themselves.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        
        // Creating Views
        _buildSectionHeader('Creating Views'),
        const SizedBox(height: 12),
        const Text(
          'The basic syntax for creating a view:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 16),
        _buildCodeBlock(
          'CREATE VIEW view_name AS\nSELECT column1, column2, ...\nFROM table_name\nWHERE condition;'
        ),
        const SizedBox(height: 20),
        
        // View Examples
        _buildSectionHeader('View Examples'),
        const SizedBox(height: 16),
        
        // Simple View
        _buildExampleCard(
          title: 'Simple View',
          description: 'Create a view showing active customers:',
          code: 'CREATE VIEW active_customers AS\nSELECT customer_id, first_name, last_name, email, phone\nFROM customers\nWHERE status = \'active\';',
        ),
        const SizedBox(height: 16),
        
        // View with Joins
        _buildExampleCard(
          title: 'View with Joins',
          description: 'Create a view that joins order information with customer details:',
          code: 'CREATE VIEW order_details AS\nSELECT \n  o.order_id,\n  c.customer_id,\n  c.first_name,\n  c.last_name,\n  o.order_date,\n  o.total_amount,\n  o.status\nFROM orders o\nJOIN customers c ON o.customer_id = c.customer_id;',
        ),
      ],
    );
  }
}

// Temporary data structure - will be expanded later
final List<Map<String, dynamic>> sqlDocumentation = [
  // SQL Basics
  {
    'title': 'SQL Basics',
    'description': 'The fundamental SQL commands and concepts every developer should know.',
    'icon': Icons.code,
    'color': Colors.blue,
    'topics': [
      {
        'title': 'SELECT Statement',
        'icon': Icons.list_alt,
        'subtitle': 'Retrieve data from database tables',
      },
      {
        'title': 'WHERE Clause',
        'icon': Icons.filter_alt,
        'subtitle': 'Filter data based on conditions',
      },
      {
        'title': 'ORDER BY Clause',
        'icon': Icons.sort,
        'subtitle': 'Sort your query results',
      },
      {
        'title': 'INSERT Statement',
        'icon': Icons.add_circle_outline,
        'subtitle': 'Add new records to tables',
      },
      {
        'title': 'UPDATE Statement',
        'icon': Icons.edit,
        'subtitle': 'Modify existing data in tables',
      },
      {
        'title': 'DELETE Statement',
        'icon': Icons.delete_outline,
        'subtitle': 'Remove records from tables',
      },
      {
        'title': 'GROUP BY Clause',
        'icon': Icons.group_work,
        'subtitle': 'Group rows and apply aggregate functions',
      },
    ],
  },
  // Joins & Relations
  {
    'title': 'Joins & Relations',
    'description': 'Connect and combine data from multiple tables with various join types.',
    'icon': Icons.account_tree,
    'color': Colors.green,
    'topics': [
      {
        'title': 'INNER JOIN',
        'icon': Icons.link,
        'subtitle': 'Retrieve matching records from both tables',
      },
      {
        'title': 'LEFT JOIN',
        'icon': Icons.arrow_forward,
        'subtitle': 'Get all records from the left table with matched data from the right',
      },
      {
        'title': 'RIGHT JOIN',
        'icon': Icons.arrow_back,
        'subtitle': 'Get all records from the right table with matched data from the left',
      },
      {
        'title': 'FULL JOIN',
        'icon': Icons.compare_arrows,
        'subtitle': 'Get all records from both tables',
      },
      {
        'title': 'CROSS JOIN',
        'icon': Icons.grid_on,
        'subtitle': 'Create a Cartesian product of two tables',
      },
      {
        'title': 'Self JOIN',
        'icon': Icons.loop,
        'subtitle': 'Join a table to itself',
      },
    ],
  },
  // Functions
  {
    'title': 'Functions',
    'description': 'Powerful SQL functions for data transformation, calculation and analysis.',
    'icon': Icons.functions,
    'color': Colors.orange,
    'topics': [
      {
        'title': 'Aggregate Functions',
        'icon': Icons.summarize,
        'subtitle': 'Perform calculations across multiple rows',
      },
      {
        'title': 'String Functions',
        'icon': Icons.text_fields,
        'subtitle': 'Manipulate and transform text data',
      },
      {
        'title': 'Numeric Functions',
        'icon': Icons.calculate,
        'subtitle': 'Perform mathematical operations on numeric data',
      },
      {
        'title': 'Date Functions',
        'icon': Icons.calendar_today,
        'subtitle': 'Manipulate and extract information from dates and times',
      },
      {
        'title': 'Window Functions',
        'icon': Icons.table_chart,
        'subtitle': 'Perform calculations across rows related to the current row',
      },
    ],
  },
  // Database Design
  {
    'title': 'Database Design',
    'description': 'Principles and techniques for effective database structure and organization.',
    'icon': Icons.schema,
    'color': Colors.purple,
    'topics': [
      {
        'title': 'Data Types',
        'icon': Icons.category,
        'subtitle': 'Understanding SQL data types and choosing the right ones',
      },
      {
        'title': 'Primary Keys',
        'icon': Icons.key,
        'subtitle': 'Creating unique identifiers for your records',
      },
      {
        'title': 'Foreign Keys',
        'icon': Icons.link,
        'subtitle': 'Establishing relationships between tables',
      },
      {
        'title': 'Normalization',
        'icon': Icons.storage,
        'subtitle': 'Organizing data to reduce redundancy and improve integrity',
      },
      {
        'title': 'Indexes',
        'icon': Icons.speed,
        'subtitle': 'Optimizing query performance',
      },
      {
        'title': 'Constraints',
        'icon': Icons.rule,
        'subtitle': 'Enforcing data integrity rules',
      },
    ],
  },
  // Advanced SQL
  {
    'title': 'Advanced SQL',
    'description': 'Advanced features and techniques for complex data operations.',
    'icon': Icons.upgrade,
    'color': Colors.red,
    'topics': [
      {
        'title': 'Subqueries',
        'icon': Icons.subdirectory_arrow_right,
        'subtitle': 'Queries nested within other queries',
      },
      {
        'title': 'Common Table Expressions',
        'icon': Icons.view_stream,
        'subtitle': 'Creating temporary result sets with the WITH clause',
      },
      {
        'title': 'Stored Procedures',
        'icon': Icons.grid_view,
        'subtitle': 'Creating reusable SQL code blocks',
      },
      {
        'title': 'Triggers',
        'icon': Icons.flash_on,
        'subtitle': 'Automatically responding to database events',
      },
      {
        'title': 'Transactions',
        'icon': Icons.sync_alt,
        'subtitle': 'Ensuring data consistency with atomic operations',
      },
      {
        'title': 'Views',
        'icon': Icons.visibility,
        'subtitle': 'Creating virtual tables for simplified access',
      },
    ],
  },
]; 