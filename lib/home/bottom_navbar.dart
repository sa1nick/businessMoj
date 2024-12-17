import 'package:flutter/material.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/home/friendlist_screen.dart';
import 'package:ut_messenger/home/home_screen.dart';
import 'package:ut_messenger/home/notification_screen.dart';
import 'package:ut_messenger/home/settings.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';


class BottomNavBarMain extends StatefulWidget {
  const BottomNavBarMain({super.key});

  @override
  State<BottomNavBarMain> createState() => _BottomNavBarMainState();
}

class _BottomNavBarMainState extends State<BottomNavBarMain> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index){
    setState((){
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomeScreen(),
    FriendListScreen(),
  //  NotificationScreen(),
    SettingScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: WaterDropNavBar(
        backgroundColor: MyColor.primary,
        waterDropColor: MyColor.white,
        inactiveIconColor: Colors.white,
        iconSize: 30,
        bottomPadding: 10,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        barItems: [
          BarItem(
            filledIcon: Icons.chat,
            outlinedIcon: Icons.chat_bubble_outline,
          ),
          BarItem(
              filledIcon: Icons.contact_mail,
              outlinedIcon: Icons.contact_mail_outlined),
          /*BarItem(
              filledIcon: Icons.notifications,
              outlinedIcon: Icons.notifications_none_outlined),*/
          BarItem(
              filledIcon: Icons.settings_suggest,
              outlinedIcon: Icons.settings_suggest_outlined),
        ],
      ),
    );
  }
}
