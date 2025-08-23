import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class UploadHealthRecordPage extends StatefulWidget {
  @override
  _UploadHealthRecordPageState createState() => _UploadHealthRecordPageState();
}

class _UploadHealthRecordPageState extends State<UploadHealthRecordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late User _user;
  String? _filePath;
  TextEditingController _fileNameController = TextEditingController();
  Uint8List? _pdfBytes;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Health Record',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Container(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                width: 200,
                padding: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextButton(
                  onPressed: _selectFile,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Text(
                    'Select File',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_pdfBytes != null) ...[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: _pdfBytes != null
                        ? PDFPreviewWidget(
                      pdfBytes: _pdfBytes,
                      key: UniqueKey(), // Use UniqueKey to force rebuild when _pdfBytes changes
                    )
                        : CircularProgressIndicator(),
                  ),
                ),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _fileNameController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        fillColor: Colors.black,
                        filled: true,
                        hintText: 'File Name',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a file name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 250,
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _uploadFile();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Text(
                      'Upload File',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Text(""),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFile() async {
    if (_filePath != null) {
      File file = File(_filePath!);
      String fileName = _fileNameController.text.toString();
      fileName += '.pdf';
      Reference ref = _storage.ref().child('user_records/${_user.uid}/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => print('File uploaded'));
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await _db.collection('user_records').add({
        'userId': _user.uid,
        'fileName': fileName,
        'downloadUrl': downloadUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('File uploaded successfully!'),
      ));
      Navigator.pop(context);
    } else {
      // No file selected
    }
  }

  Future<void> _selectFile() async {
    _pdfBytes = null;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      File file = File(filePath);
      int fileSizeInBytes = await file.length();
      if (fileSizeInBytes > 10 * 1024 * 1024) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('File Too Large'),
              content: Text('Please select a file smaller than 10 MB.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _filePath = filePath;
        });
        _loadPdfPreview(_filePath!); // Load the new PDF file
      }
    } else {
      // User canceled the picker
    }
  }

  Future<void> _loadPdfPreview(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      setState(() {
        _pdfBytes = bytes;
        _filePath = path;
      });

      // Clear cache by deleting existing cache file
      final cacheDir = await getTemporaryDirectory();
      final cacheFile = File('${cacheDir.path}/flutter_pdfview_cached_file');
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
    } catch (error) {
      print('Error loading PDF preview: $error');
    }
  }
}
class PDFPreviewWidget extends StatefulWidget {
  final Uint8List? pdfBytes;
  final Key key;

  const PDFPreviewWidget({
    required this.pdfBytes,
    required this.key,
  }) : super(key: key);

  @override
  _PDFPreviewWidgetState createState() => _PDFPreviewWidgetState();
}

class _PDFPreviewWidgetState extends State<PDFPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    return PDFView(
      key: widget.key,
      pdfData: widget.pdfBytes, // Pass pdfBytes as pdfData
      enableSwipe: true,
      pageSnap: true,
      pageFling: true,
      onViewCreated: (PDFViewController pdfViewController) {
        pdfViewController.setPage(1);
      },
    );
  }
}
