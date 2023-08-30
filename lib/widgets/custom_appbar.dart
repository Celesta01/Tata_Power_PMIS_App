import 'package:ev_pmis_app/style.dart';
import 'package:flutter/material.dart';

import '../authentication/login_register.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  String title;
  final double height;
  bool isSync = false;
  final void Function()? store;
  CustomAppBar({
    super.key,
    required this.title,
    required this.height,
    required this.isSync,
    this.store,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title),
      backgroundColor: blue,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      actions: [
        isSync
            ? Padding(
                padding: const EdgeInsets.only(
                    right: 10, top: 3, bottom: 3, left: 10),
                child: Container(
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue),
                  child: TextButton(
                      onPressed: () {
                        store!();
                      },
                      child: Text(
                        'Sync Data',
                        style: TextStyle(color: white, fontSize: 15),
                      )),
                ),
              )
            : Container(),
        Padding(
            padding: const EdgeInsets.all(6.0),
            child: IconButton(
              onPressed: () {
                onWillPop(context);
              },
              icon: const Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Icon(
                  Icons.logout_rounded,
                ),
              ),
            ))
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

Future<bool> onWillPop(BuildContext context) async {
  bool a = false;
  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Close TATA POWER?",
                    style: subtitleWhite,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            //color: blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          //color: blue,
                          child: Center(
                              child: Text(
                            "No",
                            style: button.copyWith(color: blue),
                          )),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          a = true;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginRegister(),
                              ));
                          // exit(0);
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          //color: blue,
                          child: Center(
                              child: Text(
                            "Yes",
                            style: button,
                          )),
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          ));
  return a;
}
