import 'package:ev_pmis_app/screen/qualitychecklist/quality_admin/quality_home_admin.dart';
import 'package:flutter/material.dart';

import '../qualitychecklist/quality_home.dart';

class QualityChecklistAction extends StatefulWidget {
  String? role;
  String? cityName;
  String? depoName;
  String userId;
  String roleCentre;

  QualityChecklistAction(
      {super.key,
      required this.roleCentre,
      this.cityName,
      this.role,
      this.depoName,
      required this.userId});

  @override
  State<QualityChecklistAction> createState() => _QualityChecklistActionState();
}

class _QualityChecklistActionState extends State<QualityChecklistAction> {
  Widget selectedUi = Container();

  @override
  void initState() {
    selectWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return selectedUi;
  }

  Widget selectWidget() {
    if (widget.roleCentre == "PMIS") {
    switch (widget.role) {
      case 'user':
        selectedUi = QualityHome(
          cityName: widget.cityName,
          depoName: widget.depoName,
          role: widget.role,
          userId: widget.userId,
        );
        break;
      case 'admin':
        selectedUi = QualityHomeAdmin(
            role: widget.role!,
            cityName: widget.cityName,
            userId: widget.userId,
            depoName: widget.depoName);
        break;
      case 'projectManager':
        selectedUi = QualityHomeAdmin(
            role: widget.role!,
            userId: widget.userId,
            cityName: widget.cityName,
            depoName: widget.depoName);
        break;
    }
    }
    else if(widget.roleCentre == "O&M"){
          switch (widget.role) {
      case 'user':
        selectedUi = QualityHome(
          cityName: widget.cityName,
          depoName: widget.depoName,
          role: widget.role,
          userId: widget.userId,
        );
        break;
      case 'admin':
        selectedUi = QualityHomeAdmin(
            role: widget.role!,
            cityName: widget.cityName,
            userId: widget.userId,
            depoName: widget.depoName);
        break;
      case 'projectManager':
        selectedUi = QualityHomeAdmin(
            role: widget.role!,
            userId: widget.userId,
            cityName: widget.cityName,
            depoName: widget.depoName);
        break;
    }
    }

    return selectedUi;
  }
}
