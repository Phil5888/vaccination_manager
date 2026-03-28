import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Named screen-size constants
// ---------------------------------------------------------------------------

const phoneSmall = Size(320, 568); // iPhone SE 1st gen
const phone = Size(390, 844); // iPhone 14
const phoneLarge = Size(428, 926); // iPhone 14 Plus
const tabletPortrait = Size(768, 1024);
const tabletLandscape = Size(1024, 768);
const tabletLargeLandscape = Size(1024, 1366); // iPad Pro 12.9"

const allScreenSizes = [
  phoneSmall,
  phone,
  phoneLarge,
  tabletPortrait,
  tabletLandscape,
  tabletLargeLandscape,
];

// ---------------------------------------------------------------------------
// pumpAtSize helper
// ---------------------------------------------------------------------------

/// Pumps [widgetBuilder()] at the given logical [size].
///
/// The caller is responsible for building the full widget tree
/// (ProviderScope + MaterialApp + target widget). This helper only sets
/// the surface size, pumps the widget, and registers a teardown to reset.
Future<void> pumpAtSize(
  WidgetTester tester,
  Widget Function() widgetBuilder,
  Size size,
) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(widgetBuilder());
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Overflow assertion helper
// ---------------------------------------------------------------------------

/// Asserts that no [FlutterError] (including RenderFlex overflow) was thrown
/// during the last pump.
void expectNoOverflow(WidgetTester tester) {
  expect(
    tester.takeException(),
    isNull,
    reason: 'Expected no overflow/exception but one was thrown',
  );
}
