// import 'dart:io';
// import 'package:ace_taxis/helpers/document_type.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import '../providers/document_provider.dart';
// import 'home_screen.dart';

// class DocumentScreen extends StatefulWidget {
//   const DocumentScreen({super.key});

//   @override
//   State<DocumentScreen> createState() => _DocumentScreenState();
// }

// class _DocumentScreenState extends State<DocumentScreen> {
//   final ImagePicker _picker = ImagePicker();

//   final Map<int, File?> _pickedImages = {};

//   Future<void> _pickImageDialog(DocumentType docType) async {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
//       ),
//       backgroundColor: Colors.white,
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Wrap(
//               children: [
//                 ListTile(
//                   leading: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       shape: BoxShape.circle,
//                     ),
//                     padding: const EdgeInsets.all(8),
//                     child: const Icon(Icons.camera_alt, color: Colors.black87),
//                   ),
//                   title: const Text(
//                     "Upload from Camera",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImage(docType, ImageSource.camera);
//                   },
//                 ),
//                 ListTile(
//                   leading: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       shape: BoxShape.circle,
//                     ),
//                     padding: const EdgeInsets.all(8),
//                     child: const Icon(
//                       Icons.photo_library,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   title: const Text(
//                     "Upload from Gallery",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImage(docType, ImageSource.gallery);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _pickImage(DocumentType docType, ImageSource source) async {
//     final XFile? pickedFile = await _picker.pickImage(source: source);

//     if (pickedFile == null) return;

//     final file = File(pickedFile.path);

//     setState(() {
//       _pickedImages[docType.index] = file;
//     });

//     final provider = Provider.of<DocumentProvider>(context, listen: false);
//     await provider.uploadDocument(type: docType.indexValue, file: file);

//     if (provider.errorMessage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("${docType.title} uploaded successfully ✅")),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: ${provider.errorMessage}")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<DocumentProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFCD1A21),
//         elevation: 6,
//         shadowColor: Colors.black26,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const HomeScreen(initialIndex: 3),
//               ),
//             );
//           },
//         ),
//         title: const Text(
//           "Documents",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//       ),

//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(14.0),
//               child: GridView.builder(
//                 itemCount: DocumentType.values.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 14,
//                   mainAxisSpacing: 14,
//                   childAspectRatio: 0.88,
//                 ),
//                 itemBuilder: (context, index) {
//                   final docType = DocumentType.values[index];
//                   final imageFile = _pickedImages[index];

//                   return AnimatedContainer(
//                     duration: const Duration(milliseconds: 220),
//                     curve: Curves.easeOut,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.06),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(18),
//                       onTap: () => _pickImageDialog(docType),
//                       splashColor: Colors.red.shade50,
//                       highlightColor: Colors.red.shade50,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 12,
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               docType.title,
//                               textAlign: TextAlign.center,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 14,
//                                 height: 1.2,
//                               ),
//                             ),
//                             const SizedBox(height: 12),

//                             // Icon block
//                             Container(
//                               width: 55,
//                               height: 55,
//                               decoration: BoxDecoration(
//                                 color: Colors.red.shade50,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.file_upload_outlined,
//                                 size: 32,
//                                 color: Color(0xFFCD1A21),
//                               ),
//                             ),

//                             const SizedBox(height: 12),

//                             if (imageFile != null)
//                               Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.12),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: Image.file(
//                                     imageFile,
//                                     height: 60,
//                                     width: 60,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//     );
//   }
// }

import 'dart:io';
import 'package:ace_taxis/helpers/document_type.dart';
import 'package:ace_taxis/helpers/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import 'home_screen.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final ImagePicker _picker = ImagePicker();

  final Map<int, File?> _pickedImages = {};
  final Map<int, DateTime?> _uploadedDates = {};
  final Set<int> _uploadedDocs = {};

  @override
  void initState() {
    super.initState();
    _loadSavedDocuments();
  }

  Future<void> _loadSavedDocuments() async {
    final savedDocs = await SharedPrefHelper.getUploadedDocuments();
    if (!mounted) return;

    setState(() {
      savedDocs.forEach((index, data) {
        final path = data["filePath"];
        final uploadedAt = data["uploadedAt"];

        if (path != null && File(path).existsSync()) {
          _pickedImages[index] = File(path);
          _uploadedDocs.add(index);
          _uploadedDates[index] = uploadedAt != null
              ? DateTime.tryParse(uploadedAt)
              : null;
        }
      });
    });
  }

  Future<void> _pickImageDialog(DocumentType docType) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: _circleIcon(Icons.camera_alt),
              title: const Text("Upload from Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(docType, ImageSource.camera);
              },
            ),
            ListTile(
              leading: _circleIcon(Icons.photo_library),
              title: const Text("Upload from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(docType, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(DocumentType docType, ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    setState(() => _pickedImages[docType.index] = file);

    final provider = Provider.of<DocumentProvider>(context, listen: false);
    await provider.uploadDocument(type: docType.indexValue, file: file);

    if (!mounted) return;

    if (provider.errorMessage == null) {
      await SharedPrefHelper.saveUploadedDocument(
        docIndex: docType.index,
        filePath: file.path,
      );

      setState(() {
        _uploadedDocs.add(docType.index);
        _uploadedDates[docType.index] = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCD1A21),
        foregroundColor: Colors.white,
        title: const Text(
          "Documents",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(initialIndex: 3),
              ),
            );
          },
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(14),
              child: GridView.builder(
                itemCount: DocumentType.values.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final docType = DocumentType.values[index];
                  final imageFile = _pickedImages[index];
                  final uploadedDate = _uploadedDates[index];
                  final isUploaded = _uploadedDocs.contains(index);
                  final hasFile = imageFile != null && uploadedDate != null;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _pickImageDialog(docType),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.3 : 0.06,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Text(
                                docType.title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),

                              /// BEFORE UPLOAD
                              if (!hasFile)
                                Expanded(
                                  child: Center(child: _uploadIcon(theme)),
                                ),

                              /// AFTER UPLOAD
                              if (hasFile) ...[
                                _uploadIcon(theme),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      imageFile,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Updated ${DateFormat('dd MMM yyyy').format(uploadedDate)}",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),

                          if (hasFile)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _uploadIcon(ThemeData theme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.file_upload_outlined,
        size: 30,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon),
    );
  }
}
