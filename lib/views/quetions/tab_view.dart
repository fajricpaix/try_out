import 'package:flutter/material.dart';

class TabView extends StatelessWidget {
  const TabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          labelColor: Color(0xFF6A5AE0),
          unselectedLabelColor: Colors.black54,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Color(0xFF6A5AE0), width: 1),
            insets: EdgeInsets.only(left: -16, right: -16, bottom: 10),
          ),
          dividerColor: Colors.transparent,
          tabs: const [Tab(text: 'TWK'), Tab(text: 'TIU'), Tab(text: 'TKP')],
        ),
        SizedBox(
          child: TabBarView(
            children: [
              Center(child: Text('Content for TKP')),
              Center(child: Text('Content for TIU')),
              Center(child: Text('Content for TKP')),
            ],
          ),
        ),
      ],
    );
  }
}
