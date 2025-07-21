import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ResourcePage extends StatefulWidget {
  const ResourcePage({Key? key}) : super(key: key);

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  final DateFormat _dateFormat = DateFormat.yMMMMd().add_jm();
  bool _uploading = false;

  Future<void> _showUploadDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? message;
    PlatformFile? pickedFile;
    final TextEditingController _controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Upload Resource'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Message:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter a message',
                      ),
                      maxLines: null,
                      onChanged: (val) => message = val.trim(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Attachment (optional):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          setState(() {
                            pickedFile = result.files.first;
                          });
                        }
                      },
                      child: Text(
                        pickedFile == null ? 'Attach File' : 'Change File',
                      ),
                    ),
                    if (pickedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          pickedFile!.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _uploading = true);

                    String? fileUrl;
                    String? fileName;
                    if (pickedFile != null) {
                      final storageRef = FirebaseStorage.instance.ref().child(
                        'resources/${DateTime.now().millisecondsSinceEpoch}_${pickedFile!.name}',
                      );
                      final snapshot = await storageRef.putData(
                        pickedFile!.bytes!,
                      );
                      fileUrl = await snapshot.ref.getDownloadURL();
                      fileName = pickedFile!.name;
                    }

                    await FirebaseFirestore.instance
                        .collection('resources')
                        .add({
                          'message': message,
                          'fileName': fileName,
                          'fileUrl': fileUrl,
                          'uploadedBy': user.email,
                          'timestamp': Timestamp.now(),
                        });

                    setState(() => _uploading = false);
                  },
                  child: Text(_uploading ? 'Uploading...' : 'Upload'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) =>
      _dateFormat.format(timestamp.toDate());

  Future<void> _handleMenuSelection(
    String choice,
    String docId,
    String? fileUrl,
  ) async {
    if (choice == 'Download' && fileUrl != null) {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } else if (choice == 'Delete') {
      await FirebaseFirestore.instance
          .collection('resources')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/AppBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header with single upload button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFBE90D4),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 228, 208, 239),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('BACK'),
                  ),
                  Text(
                    'Resources',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'lexend',
                      color: Colors.white,
                      letterSpacing: 5,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE90D4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _uploading ? null : _showUploadDialog,
                    child: Text(_uploading ? 'Uploading...' : 'Upload'),
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('resources')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No resources shared yet.',
                          style: TextStyle(color: Colors.black38, fontSize: 18),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final fileUrl = data['fileUrl'] as String?;
                        return Card(
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data['message'] != null)
                                  Text(
                                    data['message'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                if (fileUrl != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    data['fileName'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'By ${data['uploadedBy']} on ${_formatTimestamp(data['timestamp'] as Timestamp)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (choice) =>
                                          _handleMenuSelection(
                                            choice,
                                            doc.id,
                                            fileUrl,
                                          ),
                                      itemBuilder: (context) => [
                                        if (fileUrl != null)
                                          const PopupMenuItem(
                                            value: 'Download',
                                            child: Text('Download'),
                                          ),
                                        const PopupMenuItem(
                                          value: 'Delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                      icon: const Icon(Icons.more_vert),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
