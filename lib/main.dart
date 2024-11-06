import 'dart:html' as html;
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Split Screen Navigation',
      home: SplitScreen(),
    );
  }
}

class SplitScreen extends StatefulWidget {
  @override
  _SplitScreenState createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  String selectedPage = 'page1';

  // Stack to keep track of navigation history
  final List<String> pageStack = ['page1'];

  @override
  void initState() {
    super.initState();
    // Add an event listener to handle browser back button (popstate)
    html.window.onPopState.listen((event) {
      _handleBrowserBack();
    });
  }

  void _navigateTo(String page) {
    if (selectedPage != page) {
      setState(() {
        selectedPage = page;
        if (pageStack.isEmpty || pageStack.last != page) {
          pageStack.add(page);
          html.window.history.pushState(null, 'Flutter Web', '/$page');
        }
      });
    }
  }

  void _navigateToAnotherScreen() {
    setState(() {
      selectedPage = 'anotherPage';
      pageStack.add('anotherPage');
      html.window.history.pushState(null, 'Flutter Web', '/anotherPage');
    });
  }

  void _navigateBack() {
    if (pageStack.length > 1) {
      setState(() {
        pageStack.removeLast();
        selectedPage = pageStack.last;
        html.window.history.replaceState(null, 'Flutter Web', '/$selectedPage');
      });
    }
  }

  void _handleBrowserBack() {
    if (pageStack.length > 1) {
      setState(() {
        pageStack.removeLast();
        selectedPage = pageStack.last;
      });
    }
  }

  Widget _buildDynamicContent() {
    switch (selectedPage) {
      case 'page1':
        return Page1(onBack: _navigateBack, onNavigate: _navigateToAnotherScreen);
      case 'page2':
        return Page2(onBack: _navigateBack, onNavigate: _navigateToAnotherScreen);
      case 'page3':
        return Page3(onBack: _navigateBack, onNavigate: _navigateToAnotherScreen);
      case 'anotherPage':
        return AnotherScreen(onBack: _navigateBack);
      default:
        return Page1(onBack: _navigateBack, onNavigate: _navigateToAnotherScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Static Section: Master List of Items
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blueGrey.shade50,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Item 1'),
                    onTap: () {
                      _navigateTo('page1');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Item 2'),
                    onTap: () {
                      _navigateTo('page2');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Item 3'),
                    onTap: () {
                      _navigateTo('page3');
                    },
                  ),
                ],
              ),
            ),
          ),
          // Dynamic Section: Handling right panel content
          Expanded(
            flex: 3,
            child: _buildDynamicContent(),
          ),
        ],
      ),
    );
  }
}

// Page1 with a back button and navigation button
class Page1 extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNavigate;

  Page1({required this.onBack, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text('Page 1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is Page 1'),
            ElevatedButton(
              onPressed: onNavigate,
              child: Text('Go to Another Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

// Page2 with a back button and navigation button
class Page2 extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNavigate;

  Page2({required this.onBack, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text('Page 2'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is Page 2'),
            ElevatedButton(
              onPressed: onNavigate,
              child: Text('Go to Another Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

// Page3 with a back button and navigation button
class Page3 extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNavigate;

  Page3({required this.onBack, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text('Page 3'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is Page 3'),
            ElevatedButton(
              onPressed: onNavigate,
              child: Text('Go to Another Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

// AnotherScreen with a back button
class AnotherScreen extends StatelessWidget {
  final VoidCallback onBack;

  AnotherScreen({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text('Another Screen'),
      ),
      body: Center(
        child: Text('This is Another Screen'),
      ),
    );
  }
}
