import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ev_pmis_app/widgets/appbar_back_date.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../FirebaseApi/firebase_api.dart';
import '../../components/Loading_page.dart';
import '../../datasource/energymanagement_datasource.dart';
import '../../provider/energy_provider_user.dart';
import '../../style.dart';
import '../../viewmodels/energy_management.dart';
import '../dailyreport/summary.dart';

class EnergyManagement extends StatefulWidget {
  String? cityName;
  String? depoName;
  String? userId;
  EnergyManagement(
      {super.key,
      required this.cityName,
      required this.depoName,
      required this.userId});

  @override
  State<EnergyManagement> createState() => _EnergyManagementState();
}

class _EnergyManagementState extends State<EnergyManagement> {
  late EnergyManagementDatasource _energyManagementdatasource;
  late DataGridController _dataGridController;
  final List<EnergyManagementModel> _energyManagement =
      <EnergyManagementModel>[];
  Stream? _stream;
  bool _isloading = true;
  List<dynamic> tabledata2 = [];
  int currentMonth = DateTime.now().month;
  final double candleWidth = 20;
  EnergyProvider? _energyProvider;
  final List<dynamic> timeIntervalList = [];
  String monthName = DateFormat('MMMM').format(DateTime.now());
  dynamic alldata;

  @override
  void initState() {
    print(widget.userId);
    _energyProvider = Provider.of<EnergyProvider>(context, listen: false);

    String monthName = DateFormat('MMMM').format(DateTime.now());
    _stream = FirebaseFirestore.instance
        .collection('EnergyManagementTable')
        .doc(widget.cityName)
        .collection('Depots')
        .doc(widget.depoName)
        .collection('Year')
        .doc(DateTime.now().year.toString())
        .collection('Months')
        .doc(monthName)
        .collection('Date')
        .doc(DateFormat.yMMMMd().format(DateTime.now()))
        .collection('UserId')
        .doc(widget.userId)
        .snapshots();

    _energyManagementdatasource = EnergyManagementDatasource(_energyManagement,
        context, widget.userId!, widget.cityName, widget.depoName);
    _dataGridController = DataGridController();

    setState(() {});

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeLeft,
    // ]);
    _isloading = false;
    super.initState();
  }

  // @override
  // void dispose() {
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //   ]);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    _energyProvider!
        .fetchGraphData(widget.cityName!, widget.depoName!, widget.userId);
    return Scaffold(
      appBar: PreferredSize(
          // ignore: sort_child_properties_last
          child: CustomAppBarBackDate(
            depoName: widget.depoName,
            // showDepoBar: true,
            // toOverview: true,
            // cityName: widget.cityName,
            // depoName: widget.depoName,
            // userId: userId,
            text: 'Depot Energy Management',
            haveSummary: true,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewSummary(
                    cityName: widget.cityName.toString(),
                    depoName: widget.depoName.toString(),
                    id: 'Energy Management',
                    userId: widget.userId,
                  ),
                )),
            haveSynced: true,
            store: () {
              FirebaseApi().defaultKeyEventsField(
                  'EnergyManagementTable', widget.cityName!);
              FirebaseApi().nestedKeyEventsField('EnergyManagementTable',
                  widget.cityName!, 'Depots', widget.depoName!);
              FirebaseApi().energydefaultKeyEventsField(
                  'EnergyManagementTable',
                  widget.cityName!,
                  'Depots',
                  widget.depoName!,
                  'Year',
                  DateTime.now().year.toString());
              FirebaseApi().energynestedKeyEventsField(
                  'EnergyManagementTable',
                  widget.cityName!,
                  'Depots',
                  widget.depoName!,
                  'Year',
                  DateTime.now().year.toString(),
                  'Months',
                  monthName);

              FirebaseApi().energynestedKeyEventsField2(
                  'EnergyManagementTable',
                  widget.cityName!,
                  'Depots',
                  widget.depoName!,
                  'Year',
                  DateTime.now().year.toString(),
                  'Months',
                  monthName,
                  'Date',
                  DateFormat.yMMMMd().format(DateTime.now()));

              storeData();
            },
          ),
          preferredSize: const Size.fromHeight(50)),
      body: _isloading
          ? const LoadingPage()
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SfDataGridTheme(
                  data: SfDataGridThemeData(
                      gridLineColor: blue,
                      gridLineStrokeWidth: 2,
                      frozenPaneLineColor: blue,
                      frozenPaneLineWidth: 2),
                  child: StreamBuilder(
                    stream: _stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.exists == false) {
                        _energyManagementdatasource =
                            EnergyManagementDatasource(
                                _energyManagement,
                                context,
                                widget.userId!,
                                widget.cityName,
                                widget.depoName);
                        _dataGridController = DataGridController();
                        return SfDataGrid(
                          source: _energyManagementdatasource,
                          allowEditing: true,
                          frozenColumnsCount: 1,
                          gridLinesVisibility: GridLinesVisibility.both,
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          // checkboxColumnSettings:
                          //     DataGridCheckboxColumnSettings(
                          //         showCheckboxOnHeader: false),

                          // showCheckboxColumn: true,
                          selectionMode: SelectionMode.multiple,
                          navigationMode: GridNavigationMode.cell,
                          columnWidthMode: ColumnWidthMode.auto,
                          editingGestureType: EditingGestureType.tap,
                          controller: _dataGridController,

                          // onQueryRowHeight: (details) {
                          //   return details.rowIndex == 0 ? 60.0 : 49.0;
                          // },
                          columns: [
                            GridColumn(
                              visible: true,
                              columnName: 'srNo',
                              allowEditing: false,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Sr No',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor
                                    //    textAlign: TextAlign.center,
                                    ),
                              ),
                            ),
                            GridColumn(
                              columnName: 'DepotName',
                              width: 180,
                              allowEditing: false,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Depot Name',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'VehicleNo',
                              width: 180,
                              allowEditing: true,
                              label: Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Veghicle No',
                                    textAlign: TextAlign.center,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'pssNo',
                              width: 80,
                              allowEditing: true,
                              label: Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('PSS No',
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'chargerId',
                              width: 80,
                              allowEditing: true,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Charger ID',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'startSoc',
                              allowEditing: true,
                              width: 80,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Start SOC',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'endSoc',
                              allowEditing: true,
                              columnWidthMode: ColumnWidthMode.fitByCellValue,
                              width: 80,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('End SOC',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'startDate',
                              allowEditing: false,
                              width: 230,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Start Date & Time',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'endDate',
                              allowEditing: false,
                              width: 230,
                              label: Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text('End Date & Time',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                            ),
                            GridColumn(
                              columnName: 'totalTime',
                              allowEditing: false,
                              width: 180,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Total time of Charging',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'energyConsumed',
                              allowEditing: true,
                              width: 160,
                              label: Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Engery Consumed (inkW)',
                                    overflow: TextOverflow.values.first,
                                    textAlign: TextAlign.center,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'timeInterval',
                              allowEditing: false,
                              width: 150,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Interval',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'Add',
                              autoFitPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              allowEditing: false,
                              width: 120,
                              label: Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Add Row',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor
                                    //    textAlign: TextAlign.center,
                                    ),
                              ),
                            ),
                            GridColumn(
                              columnName: 'Delete',
                              autoFitPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              allowEditing: false,
                              width: 120,
                              label: Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Delete Row',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor
                                    //    textAlign: TextAlign.center,
                                    ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        alldata = '';
                        alldata = snapshot.data!['data'] as List<dynamic>;
                        _energyManagement.clear();
                        _energyManagementdatasource.buildDataGridRows();
                        _energyManagementdatasource.updateDatagridSource();

                        alldata.forEach((element) {
                          _energyManagement
                              .add(EnergyManagementModel.fromJson(element));
                          _energyManagementdatasource =
                              EnergyManagementDatasource(
                                  _energyManagement,
                                  context,
                                  widget.userId,
                                  widget.cityName,
                                  widget.depoName);
                          _dataGridController = DataGridController();
                          _energyManagementdatasource.buildDataGridRows();
                          _energyManagementdatasource.updateDatagridSource();
                        });
                        return SfDataGrid(
                          source: _energyManagementdatasource,
                          allowEditing: true,
                          frozenColumnsCount: 1,
                          gridLinesVisibility: GridLinesVisibility.both,
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          headerRowHeight: 40,
                          selectionMode: SelectionMode.multiple,
                          navigationMode: GridNavigationMode.cell,
                          columnWidthMode: ColumnWidthMode.auto,
                          editingGestureType: EditingGestureType.tap,
                          controller: _dataGridController,

                          // onQueryRowHeight: (details) {
                          //   return details.rowIndex == 0 ? 60.0 : 49.0;
                          // },
                          columns: [
                            GridColumn(
                              visible: true,
                              columnName: 'srNo',
                              allowEditing: false,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Sr No',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor
                                    //    textAlign: TextAlign.center,
                                    ),
                              ),
                            ),
                            GridColumn(
                              columnName: 'DepotName',
                              width: 180,
                              allowEditing: false,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Depot Name',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'VehicleNo',
                              width: 180,
                              allowEditing: true,
                              label: Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Veghicle No',
                                    textAlign: TextAlign.center,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'pssNo',
                              width: 80,
                              allowEditing: true,
                              label: Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('PSS No',
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'chargerId',
                              width: 80,
                              allowEditing: true,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Charger ID',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'startSoc',
                              allowEditing: true,
                              width: 80,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Start SOC',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'endSoc',
                              allowEditing: true,
                              columnWidthMode: ColumnWidthMode.fitByCellValue,
                              width: 80,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('End SOC',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'startDate',
                              allowEditing: false,
                              width: 230,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Start Date & Time',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'endDate',
                              allowEditing: false,
                              width: 230,
                              label: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text('End Date & Time',
                                      overflow: TextOverflow.values.first,
                                      style: tableheaderwhitecolor),
                                ),
                              ),
                            ),
                            GridColumn(
                              columnName: 'totalTime',
                              allowEditing: false,
                              width: 180,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Total time of Charging',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'energyConsumed',
                              allowEditing: true,
                              width: 160,
                              label: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                alignment: Alignment.center,
                                child: Text('Engery Consumed (inkW)',
                                    overflow: TextOverflow.values.first,
                                    textAlign: TextAlign.center,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'timeInterval',
                              allowEditing: false,
                              width: 150,
                              label: Container(
                                alignment: Alignment.center,
                                child: Text('Interval',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor),
                              ),
                            ),
                            GridColumn(
                              columnName: 'Add',
                              autoFitPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              allowEditing: false,
                              width: 120,
                              label: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                alignment: Alignment.center,
                                child: Text('Add Row',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor
                                    //    textAlign: TextAlign.center,
                                    ),
                              ),
                            ),
                            GridColumn(
                              columnName: 'Delete',
                              autoFitPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              allowEditing: false,
                              width: 120,
                              label: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                alignment: Alignment.center,
                                child: Text('Delete Row',
                                    overflow: TextOverflow.values.first,
                                    style: tableheaderwhitecolor
                                    //    textAlign: TextAlign.center,
                                    ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                Consumer<EnergyProvider>(builder: (context, value, child) {
                  _energyProvider!.fetchGraphData(
                      widget.cityName!, widget.depoName!, widget.userId);

                  return Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: BarChart(
                        swapAnimationCurve: Curves.linear,
                        swapAnimationDuration:
                            const Duration(milliseconds: 1000),
                        BarChartData(
                          backgroundColor: white,
                          barTouchData: BarTouchData(
                            enabled: true,
                            allowTouchBarBackDraw: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipRoundedRadius: 5,
                              tooltipBgColor: Colors.transparent,
                              tooltipMargin: 5,
                            ),
                          ),
                          minY: 0,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (data1, meta) {
                                  return Text(
                                    value.intervalData[data1.toInt()] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                                getTitlesWidget: (data2, meta) {
                                  return Text(
                                    value.energyData[data2.toInt()] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            drawHorizontalLine: true,
                            drawVerticalLine: true,
                          ),
                          borderData: FlBorderData(
                            border: const Border(
                              left: BorderSide(),
                              bottom: BorderSide(),
                            ),
                          ),
                          maxY: (value.intervalData.isEmpty &&
                                  value.energyData.isEmpty)
                              ? 50000
                              : value.energyData.reduce((max, current) =>
                                  max > current ? max : current),
                          barGroups: barChartGroupData(value.energyData),
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (() {
            _energyManagement.add(EnergyManagementModel(
                srNo: _energyManagement.length + 1,
                depotName: widget.depoName.toString(),
                vehicleNo: 'vehicleNo',
                pssNo: 1,
                chargerId: 1,
                startSoc: 1,
                endSoc: 1,
                startDate:
                    DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),
                endDate:
                    DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),
                totalTime:
                    DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),
                energyConsumed: 1500,
                timeInterval:
                    '${DateTime.now().hour}:${DateTime.now().minute} - ${DateTime.now().add(const Duration(hours: 6)).hour}:${DateTime.now().add(const Duration(hours: 6)).minute}'));
            _energyManagementdatasource.buildDataGridRows();
            _energyManagementdatasource.updateDatagridSource();
          })),
    );
  }

  void storeData() {
    _energyManagementdatasource.buildDataGridRows();
    _energyManagementdatasource.updateDatagridSource();
    Map<String, dynamic> tableData = Map();
    String monthName = DateFormat('MMMM').format(DateTime.now());
    for (var i in _energyManagementdatasource.dataGridRows) {
      for (var data in i.getCells()) {
        if (data.columnName != 'Add' && data.columnName != 'Delete') {
          tableData[data.columnName] = data.value;
        }
      }
      tabledata2.add(tableData);
      tableData = {};
    }

    FirebaseFirestore.instance
        .collection('EnergyManagementTable')
        .doc(widget.cityName)
        .collection('Depots')
        .doc(widget.depoName)
        .collection('Year')
        .doc(DateTime.now().year.toString())
        .collection('Months')
        .doc(monthName)
        .collection('Date')
        .doc(DateFormat.yMMMMd().format(DateTime.now()))
        .collection('UserId')
        .doc(widget.userId)
        .set({
      'data': tabledata2,
    }).whenComplete(() async {
      tabledata2.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Data are synced'),
        backgroundColor: blue,
      ));
    });
  }

  List<BarChartGroupData> barChartGroupData(List<dynamic> data) {
    return List.generate(data.length, ((index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
              borderSide: BorderSide(color: white),
              backDrawRodData: BackgroundBarChartRodData(
                toY: 0,
                fromY: 0,
                show: true,
              ),
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 16, 81, 231),
                  Color.fromARGB(255, 190, 207, 252)
                ],
              ),
              width: candleWidth,
              borderRadius: BorderRadius.circular(2),
              toY: data[index]),
        ],
      );
    }));
  }
}
