import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/constants/breakpoints.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/navigation/route_aware_widget.dart';
import 'package:vaccination_manager/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:vaccination_manager/presentation/screens/settings/settings_screen.dart';
import 'package:vaccination_manager/presentation/screens/users/user_edit_screen.dart';
import 'package:vaccination_manager/presentation/screens/users/user_management_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _contentNavKey = GlobalKey<NavigatorState>();
  int _selectedIndex = 0;
  bool _isRailExtended = true;

  final _routes = [Routes.dashboard, Routes.users, Routes.settings];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _contentNavKey.currentState?.pushNamedAndRemoveUntil(_routes[index], (route) => false);
  }

  void _updateSelectedIndex(String route) {
    debugPrint('[MainScreen] Update selected index for route: $route');
    final int index = _routes.indexWhere((r) => route == r || r.startsWith('$route/'));
    if (index != -1 && index != _selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('[MainScreen] Sync index to route: $route → $index');
        setState(() => _selectedIndex = index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= Breakpoints.desktop;

        return Scaffold(
          appBar: isDesktop ? null : AppBar(title: Text(local.title)),
          drawer: isDesktop ? null : _buildDrawer(local),
          body: Row(
            children: [
              if (isDesktop) _buildNavigationRail(local),
              Expanded(
                child: Navigator(
                  key: _contentNavKey,
                  observers: [routeObserver],
                  initialRoute: _routes[_selectedIndex],
                  onGenerateRoute: (settings) {
                    switch (settings.name) {
                      case Routes.dashboard:
                        return _buildRoute(Routes.dashboard, const DashboardScreen());
                      case Routes.users:
                        return _buildRoute(Routes.users, const UserManagementScreen());
                      case Routes.userEdit:
                        return _buildRoute(Routes.userEdit, UserEditScreen(initialUser: settings.arguments as dynamic));
                      case Routes.settings:
                        return _buildRoute(Routes.settings, const SettingsScreen());
                      default:
                        return MaterialPageRoute(
                          builder: (_) => const Scaffold(body: Center(child: Text('404 - Route Not Found'))),
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  MaterialPageRoute _buildRoute(String route, Widget screen) {
    return MaterialPageRoute(
      settings: RouteSettings(name: route),
      builder: (_) => RouteAwareWidget(onRouteChanged: _updateSelectedIndex, child: screen),
    );
  }

  Widget _buildNavigationRail(AppLocalizations local) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      extended: _isRailExtended,
      leading: IconButton(
        icon: Icon(_isRailExtended ? Icons.arrow_back : Icons.menu),
        onPressed: () {
          setState(() {
            _isRailExtended = !_isRailExtended;
          });
        },
      ),
      destinations: [
        NavigationRailDestination(icon: const Icon(Icons.dashboard), label: Text(local.dashboard)),
        NavigationRailDestination(icon: const Icon(Icons.people), label: Text(local.users)),
        NavigationRailDestination(icon: const Icon(Icons.settings), label: Text(local.settings)),
      ],
    );
  }

  Widget _buildDrawer(AppLocalizations local) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(local.menue, style: const TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text(local.dashboard),
            selected: _selectedIndex == 0,
            onTap: () {
              _onItemTapped(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(local.users),
            selected: _selectedIndex == 1,
            onTap: () {
              _onItemTapped(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(local.settings),
            selected: _selectedIndex == 2,
            onTap: () {
              _onItemTapped(2);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
