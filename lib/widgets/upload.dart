import 'dart:io';

import 'package:ev_pmis_app/components/Loading_page.dart';
import 'package:ev_pmis_app/views/authentication/authservice.dart';
import 'package:ev_pmis_app/widgets/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../style.dart';
import '../views/controller/upload_image_controller.dart';
import '../views/overviewpage/view_AllFiles.dart';
import 'custom_appbar.dart';

// ignore: must_be_immutable
class UploadDocument extends StatefulWidget {
  String? title;
  String? subtitle;
  String? cityName;
  String? depoName;
  dynamic userId;
  String? fldrName;
  String? date;
  int? srNo;
  String? pagetitle;
  String? role;

  UploadDocument({
    super.key,
    this.title,
    this.subtitle,
    required this.cityName,
    required this.depoName,
    required this.userId,
    required this.fldrName,
    this.date,
    this.srNo,
    this.pagetitle,
    this.role,
  });

  @override
  State<UploadDocument> createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument> {
  FilePickerResult? result;
  final AuthService authService = AuthService();
  List<String> assignedDepots = [];
  bool isFieldEditable = false;
  bool isLoading = true;

  @override
  void initState() {
    getAssignedDepots().whenComplete(() {
      isLoading = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    imagePickerController.pickedImagePath.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isImage = ['.jpeg', '.jpg', '.png'];
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: CustomAppBar(
              depoName: widget.depoName ?? '',
              title: 'Upload Checklist',
              isSync: false,
              isCentered: true,
              height: 50,
            )),
        body: isLoading
            ? const LoadingPage()
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // if (result != null)
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Center(
                    //         child: Text(
                    //           'Selected file:',
                    //           style: TextStyle(
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ),
                    //       ListView.builder(
                    //           shrinkWrap: true,
                    //           itemCount: result?.files.length ?? 0,
                    //           itemBuilder: (context, index) {
                    //             return Center(
                    //               child: Container(
                    //                 padding: const EdgeInsets.all(5),
                    //                 margin: const EdgeInsets.all(5),
                    //                 decoration: BoxDecoration(
                    //                     border: Border.all(color: blue),
                    //                     borderRadius:
                    //                         BorderRadius.circular(5)),
                    //                 child: Text(
                    //                     result?.files[index].name ?? '',
                    //                     style: const TextStyle(
                    //                         fontSize: 14,
                    //                         fontWeight: FontWeight.bold)),
                    //               ),
                    //             );
                    //           })
                    //     ],
                    //   ),
                    // ),

                    Container(
                      height: 400,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Obx(() {
                          if (imagePickerController
                              .pickedImagePath.value.isNotEmpty) {
                            print(imagePickerController.pickedImagePath);
                            return GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1.0),
                                shrinkWrap: true,
                                itemCount: imagePickerController
                                    .pickedImagePath.length,
                                itemBuilder: (context, index) {
                                  final filePath = imagePickerController
                                      .pickedImagePath[index];
                                  bool isImageFile = isImage.any((extension) =>
                                      filePath.contains(extension));
                                  return Center(
                                      child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: blue),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: isImageFile
                                              ? Image.file(
                                                  File(imagePickerController
                                                      .pickedImagePath[index]),
                                                  height: 50,
                                                  width: 50
                                                  //  fit: BoxFit.fill,
                                                  )
                                              : imagePickerController
                                                      .pickedImagePath[index]
                                                      .contains('.pdf')
                                                  ? Image.asset(
                                                      'assets/pdf_logo.jpeg',
                                                      height: 50,
                                                    )
                                                  : imagePickerController.pickedImagePath[index]
                                                          .contains('.mp4')
                                                      ? Image.asset(
                                                          'assets/video_image.jpg')
                                                      : imagePickerController.pickedImagePath[index]
                                                              .contains('.xlsx')
                                                          ? Image.asset(
                                                              'assets/excel.png',
                                                              height: 50)
                                                          : Image.asset(
                                                              'assets/other_file.png',
                                                              height: 50)));
                                });
                          } else {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.2),
                              child: Text(
                                'Selected Files Displayed Here',
                                textAlign: TextAlign.center,
                                style: headlineBold,
                              ),
                            );
                          }
                        }),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 70,
                            child: ElevatedButton(
                                onPressed: isFieldEditable == false
                                    ? null
                                    : () async {
                                        showPickerOptions(widget.pagetitle!);
                                        // result =
                                        //     await FilePicker.platform.pickFiles(
                                        //   withData: true,
                                        //   type: FileType.any,
                                        //   allowMultiple: false,

                                        //   // allowedExtensions: ['pdf']
                                        // );
                                        // if (result == null) {
                                        // } else {
                                        //   setState(() {});
                                        //   result?.files.forEach((element) {
                                        //     print(element.name);
                                        //   });
                                        // }
                                      },
                                child: Text(
                                  'Pick file',
                                  style: uploadViewStyle,
                                )),
                          ),
                          const SizedBox(width: 15),
                          SizedBox(
                            width: 100,
                            height: 70,
                            child: ElevatedButton(
                                onPressed: isFieldEditable == false
                                    ? null
                                    : () async {
                                        if (imagePickerController
                                                .pickedImagePath !=
                                            null) {
                                          showCupertinoDialog(
                                            context: context,
                                            builder: (context) =>
                                                CupertinoAlertDialog(
                                              content: SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: blue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                          Uint8List? fileBytes;
                                          // Uint8List? fileBytes =
                                          //     result!.files.first.bytes;

                                          for (String imagePath
                                              in imagePickerController
                                                  .pickedImagePath) {
                                            // Read the file as bytes
                                            File imageFile = File(imagePath);
                                            Uint8List fileBytes =
                                                await imageFile.readAsBytes();

                                            String imageName =
                                                imagePath.split('/').last;

                                            String refname = (widget.title ==
                                                    'QualityChecklist'
                                                ? '${widget.title}/${widget.subtitle}/${widget.cityName}/${widget.depoName}/${widget.userId}/${widget.fldrName}/${widget.date}/${widget.srNo}/$imageName'
                                                : widget.pagetitle ==
                                                        'ClosureReport'
                                                    ? '${widget.pagetitle}/${widget.cityName}/${widget.depoName}/${widget.userId}/${widget.fldrName}/$imageName'
                                                    : widget.pagetitle ==
                                                            'KeyEvents'
                                                        ? '${widget.title}/${widget.cityName}/${widget.depoName}/${widget.userId}/${widget.fldrName!}/$imageName'
                                                        : widget.pagetitle ==
                                                                'Depot Insights'
                                                            ? '${widget.pagetitle}/${widget.cityName}/${widget.depoName}/${widget.fldrName}/${imageName}'
                                                            : '${widget.pagetitle}/${widget.cityName}/${widget.depoName}/${widget.userId}/${widget.date}/${widget.fldrName}/$imageName');

                                            // String? fileName = result!.files.first.name;

                                            await FirebaseStorage.instance
                                                .ref(refname)
                                                .putData(
                                                  fileBytes,
                                                  // SettableMetadata(contentType: 'application/pdf')
                                                );
                                            // .whenComplete(() => ScaffoldMessenger
                                            //         .of(context)
                                            //     .showSnackBar(const SnackBar(
                                            //         content: Text(
                                            //             'Image is Uploaded'))));
                                          }
                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(context);
                                          // ignore: use_build_context_synchronously
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor: blue,
                                                  content: Text(
                                                    'Files are Uploaded',
                                                    style:
                                                        TextStyle(color: white),
                                                  )));
                                        }
                                      },
                                child: Text(
                                  'Upload file',
                                  style: uploadViewStyle,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 250,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Back to ${widget.title == 'QualityChecklist' ? 'Quality Checklist' : widget.pagetitle}',
                              style: uploadViewStyle,
                            )),
                      ),
                    ),
                    widget.pagetitle == 'Depot Insights'
                        ? ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return ViewAllPdf(
                                    title: 'Depot Insights',
                                    cityName: widget.cityName,
                                    depoName: widget.depoName,
                                    userId: widget.userId,
                                    docId: 'DepotImages',
                                  );
                                },
                              ));
                            },
                            child: Text('View File', style: uploadViewStyle))
                        : Container()
                  ],
                ),
              ));
  }

  Future getAssignedDepots() async {
    assignedDepots = await authService.getDepotList();
    print("assignedDepots : $assignedDepots");
    isFieldEditable =
        authService.verifyAssignedDepot(widget.depoName!, assignedDepots);
    print("isFieldEditable : $isFieldEditable");
  }
}
