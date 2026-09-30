import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../widgets/common.dart';
import 'bookings_screens.dart';
import 'explore_screens.dart';
import 'profile_screens.dart';
import 'search_screen.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(tabProvider);
    return Scaffold(
      body: IndexedStack(index: tab, children: const [
        ExploreHomeScreen(),
        SearchScreen(),
        MyBookingsScreen(),
        ProfileScreen(),
      ]),
      bottomNavigationBar: BoatingoTabBar(
        index: tab,
        onTap: (i) => ref.read(tabProvider.notifier).state = i,
      ),
    );
  }
}
