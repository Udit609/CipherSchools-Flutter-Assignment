import 'package:cipher_schools_assignment/constants/color_consts.dart';
import 'package:cipher_schools_assignment/screens/budget_page.dart';
import 'package:cipher_schools_assignment/screens/home_page.dart';
import 'package:cipher_schools_assignment/screens/profile_page.dart';
import 'package:cipher_schools_assignment/screens/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import '../main.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const TransactionsPage(),
    const BudgetPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushNamed(context, MyApp.expenseRoute);
                },
                style: TextButton.styleFrom(
                  backgroundColor: kRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Expense',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushNamed(context, MyApp.incomeRoute);
                },
                style: TextButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Income',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0x33000000)
                  : const Color(0x1A000000),
              blurRadius: 5.0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: StylishBottomBar(
          option: AnimatedBarOptions(
            barAnimation: BarAnimation.fade,
            iconStyle: IconStyle.Default,
            iconSize: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          items: [
            BottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text(
                'Home',
                style: TextStyle(fontSize: 10.0),
              ),
              selectedColor: kPrimaryColor,
              unSelectedColor: kGrey,
            ),
            BottomBarItem(
              icon: const Icon(Icons.swap_horiz),
              title: const Text(
                'Transaction',
                style: TextStyle(fontSize: 10.0),
              ),
              selectedColor: kPrimaryColor,
              unSelectedColor: kGrey,
            ),
            BottomBarItem(
              icon: const Icon(Icons.pie_chart),
              title: const Text(
                'Budget',
                style: TextStyle(fontSize: 10.0),
              ),
              selectedColor: kPrimaryColor,
              unSelectedColor: kGrey,
            ),
            BottomBarItem(
              icon: const Icon(Icons.person),
              title: const Text(
                'Profile',
                style: TextStyle(fontSize: 10.0),
              ),
              selectedColor: kPrimaryColor,
              unSelectedColor: kGrey,
            ),
          ],
          hasNotch: true,
          fabLocation: StylishBarFabLocation.center,
          currentIndex: _selectedIndex,
          notchStyle: NotchStyle.circle,
          onTap: _onItemTapped,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        elevation: 0.0,
        backgroundColor: kPrimaryColor,
        shape: CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
