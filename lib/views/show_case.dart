import 'package:flutter/material.dart';
import 'BioShowcase.dart';
import 'SkillShowcase.dart';
import 'InterestShowcase.dart';

class Showcase extends StatefulWidget {
  Showcase();

  // final Friend friend;

  @override
  _ShowcaseState createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> with TickerProviderStateMixin {
  List<Tab> _tabs;
  List<Widget> _pages;
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _tabs = [
      Tab(text: 'Bio'),
      Tab(text: 'Interests'),
      Tab(text: 'Skills'),
    ];
    _pages = [
      BioShowcase(),
      InterestShowcase(),
      SkillsShowcase(),
    ];
    _controller = TabController(
      length: _tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TabBar(
              controller: _controller,
              tabs: _tabs,
              indicatorColor: Colors.white,
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(300.0),
              child: TabBarView(
                controller: _controller,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
