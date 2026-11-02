import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../discover/discover_screen.dart';
import '../messages/message_screens.dart';
import '../account/account_screens.dart';
import 'feed_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, this.initialTab = 0, this.homeStyle = 0});
  final int initialTab, homeStyle;
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  late int selected = widget.initialTab;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: IndexedStack(
            index: selected,
            children: [
              FeedScreen(style: widget.homeStyle),
              const DiscoverScreen(),
              const SizedBox(),
              const MessagesScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 108,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: BalbColors.background,
                    ),
                    child: Row(
                      children: List.generate(5, (i) {
                        if (i == 2) return const Expanded(child: SizedBox());
                        final label = [
                          'Home',
                          'Discover',
                          '',
                          'Message',
                          'Account',
                        ][i];
                        return Expanded(
                          child: Semantics(
                            selected: selected == i,
                            button: true,
                            label: label,
                            child: InkWell(
                              onTap: () => setState(() => selected = i),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    [
                                      Icons.home_outlined,
                                      Icons.search,
                                      Icons.add,
                                      Icons.mail_outline,
                                      Icons.account_circle_outlined,
                                    ][i],
                                    color: selected == i
                                        ? BalbColors.primary
                                        : const Color(0xff454b56),
                                    size: 25,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: selected == i
                                          ? BalbColors.primary
                                          : const Color(0xff454b56),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Semantics(
                      button: true,
                      label: 'Create post',
                      child: GestureDetector(
                        onTap: () => go(context, '/camera'),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xff89dbd0), Color(0xff5583f2)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x554f2d53),
                                offset: Offset(-7, 5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
