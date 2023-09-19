import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:share_plus/share_plus.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage>
    with WidgetsBindingObserver {
  int stepCount = 0;
  double previousValue = 0.0;
  double threshold = 100.0;
  TextEditingController dateControllerOne = TextEditingController();
  TextEditingController dateControllerTwo = TextEditingController();
  DateTime? selectedDate;
  XFile? selectedImage;
  AppLifecycleState? _appLifecycleState;
  final GlobalKey globalKey = GlobalKey();
  bool isButtonVisible = true;
  double totalKilometers = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    accelerometerEvents.listen((event) {
      final double currentValue =
          event.x * event.x + event.y * event.y + event.z * event.z;
      if ((currentValue - previousValue).abs() > threshold) {
        setState(() {
          stepCount++;
        });
      }
      previousValue = currentValue;
    });
    _calculateTotalKilometers();
  }

  @override
  void dispose() {
    dateControllerOne.dispose();
    dateControllerTwo.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _appLifecycleState = state;
      if (state == AppLifecycleState.hidden) {
        return print("Chupha Huwa");
      } else if (state == AppLifecycleState.inactive) {
        return print("Ni Chal rahi");
      } else if (state == AppLifecycleState.paused) {
        return print("Roki Huwi ha ");
      } else if (state == AppLifecycleState.resumed) {
        return print("Chal Rahi h");
      }
      print(_appLifecycleState);
    });
  }

  void _calculateTotalKilometers() async {
    List<Position> positions = [];

    for (int i = 0; i < 100; i++) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      positions.add(position);
    }

    double kilometers = 0.0;

    for (int i = 0; i < positions.length - 1; i++) {
      double distanceInMeters = Geolocator.distanceBetween(
        positions[i].latitude,
        positions[i].longitude,
        positions[i + 1].latitude,
        positions[i + 1].longitude,
      );

      kilometers += distanceInMeters / 1000;
    }

    setState(() {
      totalKilometers = kilometers;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = pickedImage;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateControllerOne.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
        dateControllerTwo.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
    }
  }

  Future<Uint8List> _capturePng() async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    if (boundary.debugNeedsPaint) {
      print("Waiting for boundary to be painted.");
      await Future.delayed(const Duration(milliseconds: 20));
      return _capturePng();
    }
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }

  Future<void> _shareCard() async {
    final pngBytes = await _capturePng();
    final shareResult = await Share.shareXFiles(
      [
        XFile.fromData(
          pngBytes,
          name: 'flutter_logo.png',
          mimeType: 'image/png',
        ),
      ],
    );
    print('share ka result $shareResult');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Goals",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: GestureDetector(
            onLongPress: _shareCard,
            child: RepaintBoundary(
              key: globalKey,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: selectedImage == null
                            ? Container(
                                width: 120.0,
                                height: 120.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(70.0),
                                ),
                                child: const Icon(Icons.add_a_photo,
                                    size: 40.0, color: Colors.grey),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Image.file(
                                  File(selectedImage!.path),
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16.0),
                      const TextField(
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          filled: true,
                          fillColor: Color.fromARGB(255, 231, 237, 222),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Previous Weight',
                                filled: true,
                                fillColor: Color.fromARGB(255, 231, 237, 222),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          GestureDetector(
                            onTap: () {
                              _selectDate(context);
                            },
                            child: AbsorbPointer(
                              child: SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: dateControllerOne,
                                  decoration: const InputDecoration(
                                    labelText: 'Date',
                                    filled: true,
                                    fillColor:
                                        Color.fromARGB(255, 231, 237, 222),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Current Weight',
                                filled: true,
                                fillColor: Color.fromARGB(255, 231, 237, 222),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          GestureDetector(
                            onTap: () {
                              _selectDate(context);
                            },
                            child: AbsorbPointer(
                              child: SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: dateControllerTwo,
                                  decoration: const InputDecoration(
                                    labelText: 'Date',
                                    filled: true,
                                    fillColor:
                                        Color.fromARGB(255, 231, 237, 222),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Text(
                            "Foot steps:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Text(
                            '$stepCount',
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Text(
                            "kms walked:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Text(
                            totalKilometers.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                              onTap: _calculateTotalKilometers,
                              child: Image.asset(
                                "assets/images/refresh.png",
                                height: 20,
                                width: 20,
                                color: Colors.black,
                              ))
                          // IconButton(
                          //   icon: const Icon(Icons.refresh_outlined),
                          //   onPressed:
                          //       _calculateTotalKilometers, // Recalculate when refreshed
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Text(
                            "Water Glass:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              autofocus: false,
                              focusNode: FocusNode(canRequestFocus: false),
                              keyboardType: TextInputType.number,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Visibility(
                          visible: isButtonVisible,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isButtonVisible = false;
                              });
                              await _shareCard();
                            },
                            child: const Text("Share"),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
