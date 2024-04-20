import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';



import 'screens/banners.dart';
import 'screens/customers.dart';
import 'screens/dashbord.dart';
import 'screens/feedbacks.dart';
import 'screens/orders.dart';
import 'screens/tankers.dart';
import 'screens/reports.dart';

class HomePage extends StatefulWidget {
  static const String id ="home_page";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Widget _selectedItem =  DashboardScreen();

  String _selectedRoute = DashboardScreen.routeName;
  bool _isSidebarOpen = true;


  ScreenSelector(item) {
    switch (item.route) {
      case DashboardScreen.routeName:
        setState(() {
          _selectedItem =  DashboardScreen();
          _selectedRoute = DashboardScreen.routeName;
        });

        break;

      case Customers.routeName:
        setState(() {
          _selectedItem =  Customers();
          _selectedRoute = Customers.routeName;
        });

        break;

      case Tankers.routeName:
        setState(() {
          _selectedItem =  Tankers();
          _selectedRoute = Tankers.routeName;
        });

        break;

      case Orders.routeName:
        setState(() {
          _selectedItem =  Orders();
          _selectedRoute = Orders.routeName;
        });

        break;

      case Banners.routeName:
        setState(() {
          _selectedItem =  Banners();
          _selectedRoute = Banners.routeName;
        });

        break;

        case FeedbackPage.routeName:
        setState(() {
          _selectedItem = FeedbackPage();
          _selectedRoute = FeedbackPage.routeName;
        });

        break;

        case ReportsPage.routeName:
        setState(() {
          _selectedItem = ReportsPage();
          _selectedRoute = ReportsPage.routeName;
        });

        break;

    }
  }

  void toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          onPressed: toggleSidebar,
          icon: Icon(_isSidebarOpen ? Icons.menu : Icons.menu, color: Colors.white,),
        ),
        title: const Text('Management', style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Row(
        children: [
          AnimatedContainer(
            duration:  const Duration(milliseconds: 300),
            width: _isSidebarOpen ? 230 : 0,
            child: Visibility(
              visible: _isSidebarOpen,
              child: SideBar(
                items: const [
                  AdminMenuItem(
                      title: 'Dashboard',
                      icon: Icons.dashboard,
                      route: DashboardScreen.routeName),
                  AdminMenuItem(
                    title: 'Customers',
                    icon: CupertinoIcons.person_3,
                    route: Customers.routeName,
                  ),
                  AdminMenuItem(
                      title: 'Tankers',
                      icon: CupertinoIcons.person_3_fill,
                      route: Tankers.routeName),
                  AdminMenuItem(
                      title: 'Orders',
                      icon: CupertinoIcons.shopping_cart,
                      route: Orders.routeName),
                  AdminMenuItem(
                      title: 'Banner Upload',
                      icon: CupertinoIcons.add,
                      route: Banners.routeName),
                  AdminMenuItem(
                      title: 'App Feedbacks',
                      icon: Icons.feedback,
                      route: FeedbackPage.routeName),
                  AdminMenuItem(
                      title: 'Reports',
                      icon: Icons.report,
                      route: ReportsPage.routeName),
                ],
                selectedRoute: _selectedRoute,
                onSelected: (item) {
                  ScreenSelector(item);
                },
              ),
            ),
          ),
          Expanded(
            flex: _isSidebarOpen ? 5 : 5,
            child: _selectedItem,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleSidebar,
        child: Icon(_isSidebarOpen ? Icons.arrow_back : Icons.menu),
      ),
    );
  }
}

class SideBar extends StatelessWidget {
  final List<AdminMenuItem> items;
  final String selectedRoute;
  final Function(AdminMenuItem) onSelected;

  const SideBar({
    required this.items,
    required this.selectedRoute,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text('Admin Menu'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          for (var item in items)
            Container(
              decoration: BoxDecoration(
                color: item.route == selectedRoute ? Colors.blue.shade200 : Colors.transparent,
              ),
              child: ListTile(
                title: Text(item.title),
                leading: Icon(item.icon),
                onTap: () => onSelected(item),
              ),
            ),
        ],
      ),
    );
  }
}
