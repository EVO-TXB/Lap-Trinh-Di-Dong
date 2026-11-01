import 'package:flutter_test/flutter_test.dart';
import 'package:timass/main.dart';

void main() {
  testWidgets('TimassApp smoke test - kiem tra render man hinh lich tuan', (WidgetTester tester) async {
    await tester.pumpWidget(const TimassApp());
    await tester.pumpAndSettle();

    // Xác nhận tiêu đề Timass và nút Thêm việc được hiển thị
    expect(find.text('Timass'), findsOneWidget);
    expect(find.text('Thêm việc'), findsOneWidget);
  });
}
