import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> with WidgetsBindingObserver {
  int stepCount = 0;
  double previousValue = 0.0;
  double threshold = 100.0;
  TextEditingController dateController = TextEditingController();
  DateTime? selectedDate;
  XFile? selectedImage;
  AppLifecycleState? _appLifecycleState;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print(stepCount);
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
  }


  @override
  void dispose() {
    dateController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _appLifecycleState = state;
      if(state == AppLifecycleState.hidden){
        return print("Chupha Huwa");
      } else if(state == AppLifecycleState.inactive){
        return print("Ni Chal rahi");
      } else if (state == AppLifecycleState.paused){
        return print("Roki Huwi ha ");
      } else if (state == AppLifecycleState.resumed){
        return print("Chal Rahi h");
      }
      print(_appLifecycleState);
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
                              controller: dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                filled: true,
                                fillColor: Color.fromARGB(255, 231, 237, 222),
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
                              controller: dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                filled: true,
                                fillColor: Color.fromARGB(255, 231, 237, 222),
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
                  const Row(
                    children: [
                      Text(
                        "kms walked:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Text(
                        "Sample Text",
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
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
                          keyboardType: TextInputType.number,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(onPressed: (){},
                        child: Text("Share")
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
        dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
    }
  }
}
