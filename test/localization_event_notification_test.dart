import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timass/core/bo_nho/bo_nho_dich_vu.dart';
import 'package:timass/features/cai_dat/controllers/settings_controller.dart';
import 'package:timass/features/cong_viec/models/cong_viec_model.dart';
import 'package:timass/features/cong_viec/widgets/conflict_warning_dialog.dart';
import 'package:timass/features/cong_viec/widgets/event_form_bottom_sheet.dart';
import 'package:timass/features/cong_viec/widgets/recurring_choice_dialog.dart';
import 'package:timass/features/thong_bao/controllers/thong_bao_controller.dart';
import 'package:timass/features/thong_bao/widgets/hop_thoai_thong_bao.dart';
import 'package:timass/features/thong_bao/widgets/messenger_notification_banner.dart';
import 'package:timass/features/thong_bao/widgets/popup_nhac_nho_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BoNhoDichVu boNhoDichVu;
  late SettingsController settingsController;

  setUp(() async {
    BoNhoDichVu.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    boNhoDichVu = await BoNhoDichVu.getInstance();
    settingsController = SettingsController(boNhoDichVu: boNhoDichVu);
    await settingsController.khoiTao();
    await settingsController.capNhatNgonNgu('English');
  });

  Widget wrapWithEnglishSettings(Widget child) {
    return ChangeNotifierProvider<SettingsController>.value(
      value: settingsController,
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('English Localization - Add / Edit Event & Dialogs', () {
    testWidgets('EventFormBottomSheet renders English strings in Add Mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'),
              Locale('en', 'US'),
            ],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    EventFormBottomSheet.show(
                      context,
                      ngayMacDinh: DateTime(2026, 11, 2),
                    );
                  },
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Check Add Mode Header & Labels
      expect(find.text('Add New Task'), findsOneWidget);
      expect(find.text('Task Title'), findsOneWidget);
      expect(find.text('Enter task name or subject...'), findsOneWidget);
      expect(find.text('Task Type'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Essential /\nPassive'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Time Frame'), findsOneWidget);
      expect(find.text('Location / Classroom'), findsOneWidget);
      expect(find.text('Enter location, classroom (e.g., A3... )'), findsOneWidget);
      expect(find.text('Weekly Repeat'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Task'), findsOneWidget);

      // Toggle Weekly Repeat and check English days
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Repeat from'), findsOneWidget);
      expect(find.text('Until'), findsOneWidget);
    });

    testWidgets('Dark Mode renders date and time numbers in pure white', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await settingsController.capNhatCheDoGiaoDien('Tối');

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'),
              Locale('en', 'US'),
            ],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    EventFormBottomSheet.show(
                      context,
                      ngayMacDinh: DateTime(2026, 11, 2),
                    );
                  },
                  child: const Text('Open Dark Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dark Modal'));
      await tester.pumpAndSettle();

      // Check date and time text colors in Dark Mode (Must be Colors.white)
      final dateTexts = tester.widgetList<Text>(find.text('02/11/2026')).toList();
      expect(dateTexts.isNotEmpty, isTrue);
      for (final dt in dateTexts) {
        expect(dt.style?.color, equals(Colors.white));
      }

      final mondayText = tester.widget<Text>(find.text('Monday,'));
      expect(mondayText.style?.color, equals(Colors.white));

      final startTimeText = tester.widget<Text>(find.text('08:00'));
      expect(startTimeText.style?.color, equals(Colors.white));

      final endTimeText = tester.widget<Text>(find.text('10:00'));
      expect(endTimeText.style?.color, equals(Colors.white));
    });

    testWidgets('Date and Time Picker dialogs render translated labels and buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // English DatePicker & TimePicker
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'),
              Locale('en', 'US'),
            ],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    EventFormBottomSheet.show(
                      context,
                      ngayMacDinh: DateTime(2026, 11, 2),
                    );
                  },
                  child: const Text('Open Pickers'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Pickers'));
      await tester.pumpAndSettle();

      // Open DatePicker
      await tester.tap(find.text('02/11/2026').first);
      await tester.pumpAndSettle();

      expect(find.text('SELECT TASK DATE'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('SELECT'), findsOneWidget);

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      // Open Start TimePicker
      await tester.tap(find.text('08:00'));
      await tester.pumpAndSettle();

      expect(find.text('SELECT START TIME'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('SELECT'), findsOneWidget);

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
    });

    testWidgets('Vietnamese Date and Time Picker dialogs render Vietnamese labels', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await settingsController.capNhatNgonNgu('Tiếng Việt');

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'),
              Locale('en', 'US'),
            ],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    EventFormBottomSheet.show(
                      context,
                      ngayMacDinh: DateTime(2026, 11, 2),
                    );
                  },
                  child: const Text('Open VN Pickers'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open VN Pickers'));
      await tester.pumpAndSettle();

      // Open DatePicker in Vietnamese
      await tester.tap(find.text('02/11/2026').first);
      await tester.pumpAndSettle();

      expect(find.text('CHỌN NGÀY THỰC HIỆN'), findsOneWidget);
      expect(find.text('HỦY'), findsOneWidget);
      expect(find.text('CHỌN'), findsOneWidget);

      await tester.tap(find.text('HỦY'));
      await tester.pumpAndSettle();
    });

    testWidgets('ConflictWarningDialog renders English text', (tester) async {
      final sampleJob = CongViecModel(
        id: 101,
        maNguoiDung: 1,
        tenCongViec: 'Team Sync Meeting',
        thoiGianBatDau: DateTime(2026, 11, 2, 9, 0),
        thoiGianKetThuc: DateTime(2026, 11, 2, 10, 30),
        loaiSuKien: 'CHU_DONG',
        ngayTao: DateTime(2026, 11, 2),
      );

      await tester.pumpWidget(
        wrapWithEnglishSettings(
          ConflictWarningDialog(
            congViecBiTrung: sampleJob,
            onSuaLai: () {},
            onVanTiepTucLuu: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Schedule Conflict Warning!'), findsOneWidget);
      expect(find.text('Adjust Time'), findsOneWidget);
      expect(find.text('Save Anyway'), findsOneWidget);
    });

    testWidgets('RecurringChoiceDialog renders English text for edit & delete', (tester) async {
      // Edit mode
      await tester.pumpWidget(
        wrapWithEnglishSettings(
          RecurringChoiceDialog(
            actionType: RecurringActionType.sua,
            onScopeSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Recurring Task'), findsOneWidget);
      expect(find.text('Apply to this event only'), findsOneWidget);
      expect(find.text('Apply to all recurring events'), findsOneWidget);

      // Delete mode
      await tester.pumpWidget(
        wrapWithEnglishSettings(
          RecurringChoiceDialog(
            actionType: RecurringActionType.xoa,
            onScopeSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete Recurring Task'), findsOneWidget);
      expect(find.text('Delete this event only'), findsOneWidget);
      expect(find.text('Delete all recurring events'), findsOneWidget);
    });
  });

  group('English Localization - Notifications & Banners', () {
    testWidgets('PopupNhacNhoDialog renders English strings', (tester) async {
      final sampleJob = CongViecModel(
        id: 102,
        maNguoiDung: 1,
        tenCongViec: 'Advanced Web Dev',
        thoiGianBatDau: DateTime(2026, 11, 2, 14, 0),
        thoiGianKetThuc: DateTime(2026, 11, 2, 16, 0),
        loaiSuKien: 'BI_DONG',
        diaDiem: 'Room B204',
        nhacNhoTruocPhut: 15,
        ngayTao: DateTime(2026, 11, 2),
      );

      await tester.pumpWidget(
        wrapWithEnglishSettings(
          PopupNhacNhoDialog(
            congViec: sampleJob,
            animate: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Timass • Upcoming Reminder'), findsOneWidget);
      expect(find.text('Advanced Web Dev'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('Remind in 5 mins (Snooze)'), findsOneWidget);
    });

    testWidgets('HopThoaiThongBao renders English strings', (tester) async {
      final thongBaoCtrl = ThongBaoController();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
          child: ChangeNotifierProvider<ThongBaoController>.value(
            value: thongBaoCtrl,
            child: const MaterialApp(
              home: Scaffold(
                body: HopThoaiThongBao(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications & Reminders'), findsOneWidget);
      expect(find.text('Auto-scan 15 mins prior & essential tasks'), findsOneWidget);
      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets('MessengerNotificationBanner renders English strings', (tester) async {
      final sampleJob = CongViecModel(
        id: 103,
        maNguoiDung: 1,
        tenCongViec: 'Machine Learning Class',
        thoiGianBatDau: DateTime(2026, 11, 2, 15, 30),
        thoiGianKetThuc: DateTime(2026, 11, 2, 17, 30),
        loaiSuKien: 'BI_DONG',
        diaDiem: 'Lab 301',
        ngayTao: DateTime(2026, 11, 2),
      );

      await tester.pumpWidget(
        wrapWithEnglishSettings(
          Stack(
            children: [
              MessengerNotificationBanner(
                congViec: sampleJob,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(' • REMINDER'), findsOneWidget);
      expect(find.text('Just now'), findsOneWidget);
      expect(find.text('Snooze 5m'), findsOneWidget);
      expect(find.text('View now'), findsOneWidget);
      expect(find.text('Starts at 15:30 at Lab 301'), findsOneWidget);
    });

    testWidgets('Add Task SnackBar is localized in English (Task saved successfully!)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'),
              Locale('en', 'US'),
            ],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    EventFormBottomSheet.show(
                      context,
                      ngayMacDinh: DateTime(2026, 11, 2),
                      danhSachHienCo: const [],
                    );
                  },
                  child: const Text('Open Add Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Add Modal'));
      await tester.pumpAndSettle();

      // Enter task title in TextField
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'New English Task');
      await tester.pumpAndSettle();

      // Tap Save Task button
      await tester.tap(find.text('Save Task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // SnackBar MUST display English success message
      expect(find.text('Task saved successfully!'), findsOneWidget);
    });

    testWidgets('Edit Task SnackBar is localized in English (Task updated successfully!)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final existingTask = CongViecModel(
        id: 701,
        maNguoiDung: 1,
        tenCongViec: 'Existing Task',
        thoiGianBatDau: DateTime(2026, 11, 2, 8, 0),
        thoiGianKetThuc: DateTime(2026, 11, 2, 9, 30),
        ngayTao: DateTime(2026, 11, 2),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'),
              Locale('en', 'US'),
            ],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    EventFormBottomSheet.show(
                      context,
                      congViec: existingTask,
                      danhSachHienCo: const [],
                    );
                  },
                  child: const Text('Open Edit Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Edit Modal'));
      await tester.pumpAndSettle();

      // Tap Save Task button
      await tester.tap(find.text('Save Task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // SnackBar MUST display English update success message
      expect(find.text('Task updated successfully!'), findsOneWidget);
    });

    testWidgets('Form validation error SnackBar is localized in English', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'),
              Locale('en', 'US'),
            ],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    EventFormBottomSheet.show(
                      context,
                      ngayMacDinh: DateTime(2026, 11, 2),
                    );
                  },
                  child: const Text('Open Modal Empty'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal Empty'));
      await tester.pumpAndSettle();

      // Tap Save Task without title
      await tester.tap(find.text('Save Task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Error message in English
      expect(find.text('Please enter a task or subject name.'), findsOneWidget);
    });
  });
}
