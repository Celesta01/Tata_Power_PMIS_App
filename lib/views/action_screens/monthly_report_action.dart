import 'package:ev_pmis_app/views/management_screen/monthly_page/monthly_home.dart';
import 'package:flutter/material.dart';

import '../monthlyreport/monthly_admin/monthly_report_admin.dart';
import '../monthlyreport/monthly_project.dart';

class MonthlyReportAction extends StatefulWidget {
  String? role;
  String? cityName;
  String? depoName;
  String userId;
  String roleCentre;

  MonthlyReportAction({super.key,
  required this.roleCentre, this.cityName, this.role, this.depoName, required this.userId});

  @override
  State<MonthlyReportAction> createState() => _MonthlyReportActionState();
}

class _MonthlyReportActionState extends State<MonthlyReportAction> {
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
     if(widget.roleCentre == "PMIS"){
          switch (widget.role) {
      
      case 'user':
        selectedUi = MonthlyProject(depoName: widget.depoName,
        role: widget.role,cityName: widget.cityName,
        userId: widget.userId,);
        break;

      case 'admin':
        selectedUi = MonthlySummary(
          cityName: widget.cityName,
          depoName: widget.depoName,

          role: widget.role!,
          userId: widget.userId,
        );
        break;

      case 'projectManager':
        selectedUi = MonthlySummary(
          cityName: widget.cityName,
          depoName: widget.depoName,
          role: widget.role!,
          userId: widget.userId,
        );
        break;
    }
    }
    else if(widget.roleCentre == "O&M"){
          switch (widget.role) {
      
      case 'user':
        selectedUi = MonthlyManagementHomePage(
          depoName: widget.depoName,
        role: widget.role,cityName: widget.cityName,
        userId: widget.userId,);
        break;

      case 'admin':
        selectedUi = MonthlySummary(
          cityName: widget.cityName,
          depoName: widget.depoName,

          role: widget.role!,
          userId: widget.userId,
        );
        break;

      case 'projectManager':
        selectedUi = MonthlySummary(
          cityName: widget.cityName,
          depoName: widget.depoName,
          role: widget.role!,
          userId: widget.userId,
        );
        break;
    }
    }


    return selectedUi;
  }
}
