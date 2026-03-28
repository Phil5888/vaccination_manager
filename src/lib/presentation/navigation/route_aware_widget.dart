import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class RouteAwareWidget extends StatefulWidget {
  final Widget child;
  final void Function(String routeName) onRouteChanged;

  const RouteAwareWidget({super.key, required this.child, required this.onRouteChanged});

  @override
  State<RouteAwareWidget> createState() => _RouteAwareWidgetState();
}

class _RouteAwareWidgetState extends State<RouteAwareWidget> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() => _update();
  @override
  void didPopNext() => _update();

  void _update() {
    final name = ModalRoute.of(context)?.settings.name;
    if (name != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('[RouteAware] Route changed: $name');
        widget.onRouteChanged(name);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
