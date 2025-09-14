import 'package:flutter/material.dart';

class SafetyTips extends StatelessWidget {
  const SafetyTips({super.key});

  final List<Tab> _tabs = const [
    Tab(text: "Earthquake", icon: Icon(Icons.vibration)),
    Tab(text: "Flood", icon: Icon(Icons.water)),
    Tab(text: "Cyclone", icon: Icon(Icons.air)),
    Tab(text: "Volcano", icon: Icon(Icons.terrain)),
    Tab(text: "Heatwave", icon: Icon(Icons.wb_sunny)),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Safety Tips'),
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          bottom: TabBar(
            isScrollable: true,
            labelColor: colorScheme.onPrimary,
            unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.5),
            tabs: _tabs,
          ),
        ),
        body: TabBarView(
          children: [
            _buildTipsList(_earthquakeTips(), context),
            _buildTipsList(_floodTips(), context),
            _buildTipsList(_cycloneTips(), context),
            _buildTipsList(_volcanoTips(), context),
            _buildTipsList(_heatwaveTips(), context),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsList(List<String> tips, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: colorScheme.surfaceVariant,
          child: ListTile(
            leading: Icon(Icons.check_circle, color: colorScheme.primary),
            title: Text(
              tips[index],
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        );
      },
    );
  }

// Earthquake Safety Tips
  List<String> _earthquakeTips() => [
    "Immediately drop to your hands and knees, take cover under sturdy furniture, and hold on until the shaking stops.",
    "If indoors, remain inside and move away from windows, mirrors, and heavy objects that may fall.",
    "Protect your head and neck with your arms if no shelter is nearby.",
    "Do not use elevators during and immediately after shaking.",
    "If outdoors, move to an open area away from buildings, trees, streetlights, and power lines.",
    "If driving, pull over to a clear area, stop, and remain inside until the shaking ceases.",
    "Expect aftershocks and be prepared to Drop, Cover, and Hold On again.",
    "Check yourself and others for injuries and administer first aid if needed.",
    "Inspect your surroundings for hazards such as gas leaks, fires, and damaged power lines.",
    "Avoid open flames until certain there are no gas leaks.",
    "Keep an emergency kit with water, food, flashlight, and first aid supplies accessible.",
    "Stay informed via official emergency channels for updates and evacuation orders.",
    "Avoid entering damaged buildings until authorities declare them safe."
  ];

// Flood Safety Tips
  List<String> _floodTips() => [
    "Move immediately to higher ground if flooding occurs in your area.",
    "Avoid walking, swimming, or driving through floodwaters — just 6 inches of moving water can knock you down, and 2 feet can sweep away a vehicle.",
    "Stay away from rivers, streams, and storm drains during heavy rainfall.",
    "Disconnect electrical appliances to reduce risk of electrocution.",
    "Do not touch electrical equipment if you are wet or standing in water.",
    "Listen to weather alerts and follow evacuation orders issued by local authorities.",
    "Keep emergency supplies and important documents in waterproof containers.",
    "After floods, avoid areas with standing water which may be contaminated or hide hazards.",
    "Inspect your home for structural damage before re-entering.",
    "Avoid driving until roads are declared safe by authorities."
  ];

// Cyclone / Tropical Storm Safety Tips
  List<String> _cycloneTips() => [
    "Stay informed with weather updates and official alerts about approaching cyclones.",
    "Secure outdoor items such as furniture, tools, and debris that could become projectiles in strong winds.",
    "Board up windows and reinforce doors to reduce damage from high winds.",
    "Prepare an emergency kit with food, water, medicines, flashlight, and batteries.",
    "Charge all mobile devices and keep a portable power bank ready.",
    "If evacuation orders are given, leave immediately and follow designated routes.",
    "Stay indoors during the storm, away from windows and glass doors.",
    "Avoid using candles during power outages to reduce fire risk; use flashlights instead.",
    "After the cyclone, avoid downed power lines and report them to authorities.",
    "Do not return to coastal or low-lying areas until officials declare them safe."
  ];

// Volcanic Activity Safety Tips
  List<String> _volcanoTips() => [
    "Stay informed about volcanic activity through official alerts and monitoring agencies.",
    "Prepare emergency kits with face masks, goggles, food, and clean water.",
    "If indoors during ashfall, close windows, doors, and all ventilation systems.",
    "If outdoors, wear long-sleeved clothing, protective masks, and goggles to avoid inhaling ash.",
    "Avoid low-lying areas prone to lava flows, lahars, or mudflows.",
    "Protect water sources by sealing containers; volcanic ash can contaminate water supplies.",
    "Do not drive during heavy ashfall, as it reduces visibility and damages engines.",
    "Follow evacuation instructions immediately if ordered by authorities.",
    "After the eruption, clean ash carefully using damp cloths; avoid sweeping dry ash to prevent respiratory issues.",
    "Avoid river valleys downstream of volcanoes due to possible mudflows or flooding."
  ];

// Heatwave Safety Tips
  List<String> _heatwaveTips() => [
    "Stay hydrated by drinking plenty of water, even if you do not feel thirsty.",
    "Avoid drinks with caffeine, alcohol, or excessive sugar as they contribute to dehydration.",
    "Limit outdoor activities, especially during the hottest parts of the day (10 AM to 4 PM).",
    "Wear lightweight, loose-fitting, and light-colored clothing to stay cool.",
    "Use fans, air conditioning, or visit air-conditioned public spaces to cool down.",
    "Take cool showers or baths to help regulate body temperature.",
    "Check on vulnerable individuals such as children, elderly, and those with chronic illnesses.",
    "Never leave children or pets in parked vehicles, even for a few minutes.",
    "Eat light, balanced meals to maintain energy without overheating the body.",
    "Stay informed about heat advisories and follow health authority recommendations."
  ];

}
