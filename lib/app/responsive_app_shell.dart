import 'package:flutter/material.dart';

import '../core/layout/app_breakpoints.dart';

class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class ResponsiveAppShell extends StatelessWidget {
  const ResponsiveAppShell({
    required this.title,
    required this.destinations,
    required this.selectedIndex,
    required this.child,
    this.actions,
    super.key,
  });

  final String title;
  final List<ShellDestination> destinations;
  final int selectedIndex;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final layout = AppBreakpoints.layoutForWidth(MediaQuery.sizeOf(context).width);

    switch (layout) {
      case AppLayout.compact:
        return Scaffold(
          appBar: AppBar(title: Text(title), actions: actions),
          drawer: Drawer(
            child: _NavigationList(
              destinations: destinations,
              selectedIndex: selectedIndex,
              closeDrawerOnTap: true,
            ),
          ),
          body: child,
        );
      case AppLayout.medium:
        return Scaffold(
          appBar: AppBar(title: Text(title), actions: actions),
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                destinations: destinations
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
                onDestinationSelected: (index) => destinations[index].onTap(),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      case AppLayout.expanded:
        return Scaffold(
          body: Row(
            children: [
              Container(
                width: 280,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _NavigationList(
                        destinations: destinations,
                        selectedIndex: selectedIndex,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (actions != null) ...actions!,
                        ],
                      ),
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _NavigationList extends StatelessWidget {
  const _NavigationList({
    required this.destinations,
    required this.selectedIndex,
    this.closeDrawerOnTap = false,
  });

  final List<ShellDestination> destinations;
  final int selectedIndex;
  final bool closeDrawerOnTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: destinations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final destination = destinations[index];
        final selected = index == selectedIndex;

        return ListTile(
          selected: selected,
          leading: Icon(destination.icon),
          title: Text(destination.label),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onTap: () {
            if (closeDrawerOnTap) {
              Navigator.of(context).pop();
            }
            destination.onTap();
          },
        );
      },
    );
  }
}
