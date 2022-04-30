import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final List _drawerMenu = [
      {
        "icon": Icons.restore,
        "text": "Past Bookings",
        "route": "/bookings",
      },
      {"icon": Icons.car_rental, "text": "My Cars", "route": "/cars"},
      {
        "icon": Icons.credit_card,
        "text": "Payment Methods",
        "route": "/payments",
      },
      {
        "icon": Icons.notifications,
        "text": "Notification",
      },
      {
        "icon": Icons.chat,
        "text": "Support",
        "route": "/connect/support/",
      }
    ];
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width -
          (MediaQuery.of(context).size.width * 0.2),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              height: 170.0,
              color: _theme.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage("assets/images/user_img.png"),
                  ),
                  const SizedBox(
                    height: 7.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        "Tarun Wadhwa",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed("/profile");
                        },
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  const Text(
                    "8568800310",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  top: 20.0,
                ),
                child: ListView(
                  children: _drawerMenu.map((menu) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(menu["route"]);
                      },
                      child: ListTile(
                        leading: Icon(menu["icon"]),
                        title: Text(
                          menu["text"],
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
