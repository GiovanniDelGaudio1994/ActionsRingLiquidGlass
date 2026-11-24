import 'package:flutter_test/flutter_test.dart';
import 'package:glassring/services/azioni.dart';

// Niente MyApp generata dallo starter: GlassRing usa GlassRingApp.
// Il test è indipendente dalla finestra macOS e dalle API HID.
void main() {
  test('Tutte le azioni hanno una etichetta visibile', () {
    for (final azione in azioniRing) {
      expect(azione.titolo.isNotEmpty, isTrue);
    }
  });
}
