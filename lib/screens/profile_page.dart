import 'dart:io';
import 'package:cipher_schools_assignment/helpers/services/auth_service.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/color_consts.dart';
import '../helpers/providers/transaction_provider.dart';
import '../main.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<bool> _requestStoragePermissions(BuildContext context) async {
    if (Platform.isAndroid) {
      var storageStatus = await Permission.storage.status;
      var manageStorageStatus = await Permission.manageExternalStorage.status;
      var mediaStatus = await Permission.mediaLibrary.status;

      if (storageStatus.isGranted || manageStorageStatus.isGranted || mediaStatus.isGranted) {
        return true;
      }

      if (storageStatus.isPermanentlyDenied ||
          manageStorageStatus.isPermanentlyDenied ||
          mediaStatus.isPermanentlyDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Storage permission is required to export data. Please enable it in settings.'),
              backgroundColor: kRed,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }
        return false;
      }

      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.mediaLibrary,
      ].request();

      bool anyPermissionGranted = statuses.values.any((status) => status.isGranted);

      if (anyPermissionGranted) {
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission denied. Cannot export data.'),
              backgroundColor: kRed,
            ),
          );
        }
        return false;
      }
    }

    // On iOS or other platforms
    return true;
  }

  Future<void> _exportData(BuildContext context, String userId, WidgetRef ref) async {
    final hasPermission = await _requestStoragePermissions(context);
    if (!hasPermission) return;

    try {
      final databaseHelper = ref.read(databaseProvider);
      final transactions = await databaseHelper.getTransactions(userId);

      if (transactions.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No transactions to export.'),
              backgroundColor: kRed,
            ),
          );
        }
        return;
      }

      List<List<dynamic>> rows = [
        ['ID', 'Category', 'Description', 'Type', 'Amount', 'Date'],
      ];

      for (var transaction in transactions) {
        rows.add([
          transaction.id,
          transaction.category,
          transaction.description,
          transaction.transactionType,
          transaction.amount,
          DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.dateTime),
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      String filePath;
      if (Platform.isAndroid) {
        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        filePath = '${directory.path}/transactions_$userId.csv';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/transactions_$userId.csv';
      }

      final file = File(filePath);
      await file.writeAsString(csv);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Transactions exported successfully to ${Platform.isAndroid ? 'Downloads' : 'Documents'}!'),
            backgroundColor: kGreen,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                final result = await OpenFile.open(filePath);
                if (result.type != ResultType.done && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open file: ${result.message}'),
                      backgroundColor: kRed,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: kRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthService authService = AuthService();
    final userIdAsync = ref.watch(userIdProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(color: kDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: userIdAsync.when(
        data: (userId) => FutureBuilder<Map<String, dynamic>?>(
          future: authService.getUserData(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Error loading user data'));
            }
            final userData = snapshot.data!;
            final userName = userData['name'] ?? 'Unknown User';
            final userEmail = userData['email'] ?? 'example@email.com';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                          'assets/user.png',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              userEmail,
                              style: TextStyle(
                                color: kGrey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Paperclip Icon
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: kPrimaryColor,
                          size: 32,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile picture upload not implemented yet'),
                              backgroundColor: kRed,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x1A000000),
                          blurRadius: 8.0,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: kFocusColor,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: const Icon(
                              Icons.account_box,
                              color: kPrimaryColor,
                              size: 32,
                            ),
                          ),
                          title: const Text(
                            'Account',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: kDark,
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account screen not implemented yet'),
                                backgroundColor: kRed,
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Divider(
                          color: kGrey.withValues(alpha: 0.2),
                        ),
                        ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: kFocusColor,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: kPrimaryColor,
                              size: 32.0,
                            ),
                          ),
                          title: const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: kDark,
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Settings screen not implemented yet'),
                                backgroundColor: kRed,
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Divider(
                          color: kGrey.withValues(alpha: 0.2),
                        ),
                        ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: kFocusColor,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: const Icon(
                              Icons.upload,
                              color: kPrimaryColor,
                              size: 32.0,
                            ),
                          ),
                          title: const Text(
                            'Export Data',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: kDark,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(
                                  "Export Data Confirmation",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: kDark,
                                  ),
                                ),
                                content: Text(
                                  "Are you sure you want to export your transaction data to a CSV file?",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                    color: kDark,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: kDark,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(dialogContext);
                                      await _exportData(context, userId, ref);
                                    },
                                    child: Text(
                                      "Export",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        color: kGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Divider(
                          color: kGrey.withValues(alpha: 0.2),
                        ),
                        ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFDD5D7),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: kRed,
                              size: 32.0,
                            ),
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: kDark,
                            ),
                          ),
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(
                                  "Logout Confirmation",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: kDark,
                                  ),
                                ),
                                content: Text(
                                  "Are you sure you want to logout?",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                    color: kDark,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: kDark,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(dialogContext);

                                      try {
                                        await authService.signOut();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('You have been logged out.'),
                                              backgroundColor: kGreen,
                                            ),
                                          );

                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            MyApp.loginRoute,
                                            (route) => false,
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Logout failed. Please try again.'),
                                              backgroundColor: kRed,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        color: kRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
