import 'package:flutter_test/flutter_test.dart';
import 'package:glassring/services/azioni.dart';

// Test eseguibile anche senza una periferica collegata.
// Verifica l'invariante dell'architettura: otto sezioni nel menu radiale.
void main() {
  test('Il Ring presenta esattamente otto azioni distinte', () {
    expect(azioniRing, hasLength(8));
    expect(azioniRing.map((azione) => azione.id).toSet(), hasLength(8));
  });

  test('La selezione dei dispositivi e solo un catalogo di modelli', () {
    expect(dispositiviCatalogo, isNotEmpty);
    expect(dispositiviCatalogo.first.nome, 'MX Master 2S');
    expect(dispositiviCatalogo.last.tipo, 'Trackpad');
  });
}
