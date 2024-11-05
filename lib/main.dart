import 'dart:html' as html;
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    // Add an event listener to handle browser back button (popstate)
    html.window.onPopState.listen((event) {
      AppRouterDelegate.instance.handleBrowserBack();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Web Split Screen Navigation',
      routerDelegate: AppRouterDelegate.instance,
      routeInformationParser: RouteInformationParserImpl(),
    );
  }
}

// Custom Router Delegate to manage browser history
class AppRouterDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  static final AppRouterDelegate instance = AppRouterDelegate();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  String selectedPage = 'page1';

  // Stack to keep track of navigation history
  final List<String> pageStack = ['page1'];

  @override
  RoutePath get currentConfiguration => RoutePath(selectedPage);

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
          // Dynamic Section: Navigator handling right panel content
          Expanded(
            flex: 3,
            child: Navigator(
              key: navigatorKey,
              pages: [
                if (selectedPage == 'page1')
                  MaterialPage(child: DynamicPage(title: 'Page 1', content: 'This is the content of Page 1.', onBack: _navigateBack)),
                if (selectedPage == 'page2')
                  MaterialPage(child: DynamicPage(title: 'Page 2', content: 'This is the content of Page 2.', onBack: _navigateBack)),
                if (selectedPage == 'page3')
                  MaterialPage(child: DynamicPage(title: 'Page 3', content: 'This is the content of Page 3.', onBack: _navigateBack)),
              ],
              onPopPage: (route, result) {
                if (!route.didPop(result)) return false;
                pageStack.removeLast(); // Remove the last page from stack on pop
                selectedPage = pageStack.isNotEmpty ? pageStack.last : 'page1';
                notifyListeners();
                return true;
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String page) {
    // Navigate to a new page and add it to the stack if it’s not already on top
    if (selectedPage != page) {
      selectedPage = page;
      if (pageStack.isEmpty || pageStack.last != page) {
        pageStack.add(page);
        html.window.history.pushState(null, 'Flutter Web', '/$page');
      }
      notifyListeners();
    }
  }

  void _navigateBack() {
    // Custom back navigation to replace the last entry in history
    if (pageStack.length > 1) {
      pageStack.removeLast();
      selectedPage = pageStack.last;
      notifyListeners();
      // Use replaceState to prevent adding extra history entries for back navigation
      html.window.history.replaceState(null, 'Flutter Web', '/$selectedPage');
    }
  }

  void handleBrowserBack() {
    // Custom handling of browser back button
    if (pageStack.length > 1) {
      pageStack.removeLast();
      selectedPage = pageStack.last;
      notifyListeners();
    } else {
      // If on the first page, do nothing or potentially handle browser close if needed
    }
  }

  @override
  Future<void> setNewRoutePath(RoutePath path) async {
    selectedPage = path.page;
  }
}

class RoutePath {
  final String page;
  RoutePath(this.page);
}

class RouteInformationParserImpl extends RouteInformationParser<RoutePath> {
  @override
  Future<RoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '/');
    if (uri.pathSegments.isEmpty) return RoutePath('page1');
    final page = uri.pathSegments.first;
    return RoutePath(page);
  }

  @override
  RouteInformation restoreRouteInformation(RoutePath configuration) {
    return RouteInformation(location: '/${configuration.page}');
  }
}

// Dynamic pages used in the right section
class DynamicPage extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onBack;

  DynamicPage({required this.title, required this.content, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
