import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/banner_section.dart';
import 'widgets/action_card.dart';
import 'widgets/event_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const BannerSection(),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        ActionCard(
                          icon: Icons.people,
                          title: "Study Buddy",
                          onTap: () => context.go('/study-buddy'),
                        ),
                        ActionCard(
                          icon: Icons.favorite,
                          title: "Hobby Match",
                          onTap: () {},
                        ),
                        ActionCard(
                          icon: Icons.chat,
                          title: "HallWire",
                          onTap: () {},
                        ),
                        ActionCard(
                          icon: Icons.store,
                          title: "Marketplace",
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Event
              const Padding(padding: EdgeInsets.all(16), child: EventCard()),
            ],
          ),
        ),
      ),
    );
  }
}
