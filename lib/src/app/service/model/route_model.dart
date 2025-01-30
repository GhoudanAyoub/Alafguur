import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// relative imports
import '../../../module/base/page/abstract_page.dart';

/// Route guards are functions that take the current [route] and check whether
/// the current state allows to open the desired page.
///
/// If the page can be opened, the route guard _should return null_.
///
/// Otherwise, the route guard should return a [Widget] to be rendered instead
/// of the desired page.
typedef RouteGuard = Widget? Function(
  RouteModel route,
  Map<String, List<String>> routeParams,
  Map<String, dynamic> widgetParams,
  GetIt serviceLocator,
);

/// A page factory returns an instance of the requested page and optionally
/// passes the provided [routeParams] and [widgetParams] to it..
///
/// Page factories are called when all the attached [RouteGuard]s are passed
/// successfully.
///
/// The [AbstractPage] instance returned by the page factory is rendered as the
/// requested page.
typedef PageFactory = AbstractPage Function(
  Map<String, List<String>> routeParams,
  Map<String, dynamic> widgetParams,
);

/// Route visibility defines the auth state in which the desired page is
/// visible.
///
/// member - the page is visible only to the logged in members
/// guest  - the page is visible only to guests
/// all    - the page is visible to anyone
enum RouteVisibility { member, guest, all }

/// Route model is a simplified abstraction of a route in the internal routing
/// system.
///
/// The [path] property defines the URI on which the page is available. This URI
/// is also used for deep linking. Can contain parameters starting with `:`,
/// e.g. `/users/:userId`.
///
/// The [visibility] property is used by the auth guards to determine whether
/// the page can be opened depending on the current auth state.
///
/// The [pageFactory] function should return a [Widget] that describes the page.
/// This widget will be rendered if all guards execute successfully.
///
/// The optional [guards] list contains route guards to be executed to determine
/// whether the desired page can be rendered.
class RouteModel {
  final String path;
  final RouteVisibility visibility;
  final PageFactory pageFactory;
  List<RouteGuard> guards;

  RouteModel({
    required this.path,
    required this.visibility,
    required this.pageFactory,
    this.guards = const [],
  });
}
