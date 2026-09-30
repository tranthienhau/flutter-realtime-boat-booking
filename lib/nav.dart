import 'package:flutter/material.dart';

import 'screens/boat_screens.dart';
import 'screens/bookings_screens.dart';
import 'screens/checkout_screens.dart';
import 'screens/explore_screens.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screens.dart';
import 'screens/profile_screens.dart';

/// Single navigator so taps and the demo autopilot share one route stack.
final navKey = GlobalKey<NavigatorState>();

NavigatorState get _nav => navKey.currentState!;

Future<T?> _push<T>(Widget w) => _nav.push<T>(PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => w,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (_, a, __, child) {
        final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    ));

class Nav {
  static void signIn() => _push(const SignInScreen());
  static void home() => _nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false);
  static void destination(String id) => _push(DestinationScreen(destinationId: id));
  static void boat(String id) => _push(BoatDetailScreen(boatId: id));
  static void availability() => _push(const AvailabilityScreen());
  static void checkout() => _push(const CheckoutScreen());
  static void lastSeatTaken() => _push(const LastSeatTakenScreen());
  static void confirmed() =>
      _nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const BookingConfirmedScreen()), (r) => r.isFirst);
  static void bookingDetail(String id) => _push(BookingDetailScreen(bookingId: id));
  static void cancelBooking(String id) => _push(CancelBookingScreen(bookingId: id));
  static void notifications() => _push(const NotificationsScreen());
  static void operatorConsole() => _push(const OperatorConsoleScreen());
  static void backToRoot() => _nav.popUntil((r) => r.isFirst);
  static void pop() {
    if (_nav.canPop()) _nav.pop();
  }
}
