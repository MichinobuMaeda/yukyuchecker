import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../config/version.dart';
import '../config/theme.dart';
import '../services/authorization.dart';
import '../services/helpers.dart';

enum MediaSize { narrow, middle, wide }

class Layout extends HookConsumerWidget {
  const Layout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privilege = ref.watch(privilegeProvider);
    final pages = ref.watch(pagesProvider);
    final selectedIndex = useState(0);
    final selectedPage = useState(pages.first);

    ref.listen<String?>(snackBarMessageProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      if (next != null && next.isNotEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(next)));
      }
    });

    void onDestinationSelected(int index) {
      selectedIndex.value = index;
      selectedPage.value = pages[index];
    }

    useEffect(() {
      selectedIndex.value = 0;
      selectedPage.value = pages.first;
      return null;
    }, [privilege]);

    useEffect(() {
      if (selectedIndex.value >= pages.length) {
        selectedIndex.value = pages.length - 1;
      }
      return null;
    }, [pages.length]);

    final mediaSize = MediaQuery.sizeOf(context);
    MediaSize media() => mediaSize.width < mediaSize.height
        ? MediaSize.narrow
        : (mediaSize.width < (navDrawerWidth + contentMaxWidth)
              ? MediaSize.middle
              : MediaSize.wide);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Row(
          children: [
            if (media() == MediaSize.middle)
              NavigationRail(
                labelType: NavigationRailLabelType.all,
                destinations: pages
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
                selectedIndex: selectedIndex.value,
                onDestinationSelected: onDestinationSelected,
              ),
            if (media() == MediaSize.wide)
              SizedBox(
                width: navDrawerWidth,
                child: NavigationDrawer(
                  selectedIndex: selectedIndex.value,
                  onDestinationSelected: onDestinationSelected,
                  header: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image.asset(assetAppLogo),
                  ),
                  children: pages
                      .map(
                        (item) => NavigationDrawerDestination(
                          icon: Icon(item.icon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: contentMaxWidth),
                  child: CustomScrollView(
                    slivers: [
                      if (media() != MediaSize.wide)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Image.asset(assetAppLogo, height: 48.0),
                          ),
                        ),
                      ...selectedPage.value.contents,
                      const _Footer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: media() == MediaSize.narrow
          ? NavigationBar(
              destinations: pages
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),

              selectedIndex: selectedIndex.value,
              onDestinationSelected: onDestinationSelected,
            )
          : null,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Divider(), Text('yukyuchecker $packageVersion')],
        ),
      ),
    );
  }
}
