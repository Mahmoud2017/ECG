import 'package:ecg_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validators return l10n keys', () {
    expect(Validators.email('bad'), 'error_email');
    expect(Validators.email('a@b.co'), isNull);
    expect(Validators.age('131'), 'error_age');
    expect(Validators.password('12345'), 'error_password_short');
    expect(Validators.confirm(() => 'x')('y'), 'error_password_match');
  });
}
