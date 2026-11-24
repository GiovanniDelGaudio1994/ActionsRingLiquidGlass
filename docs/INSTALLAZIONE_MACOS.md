# Installazione macOS (M1 Pro e Apple Silicon)

Nel terminale:

```bash
git clone https://github.com/GiovanniDelGaudio1994/ActionsRingLiquidGlass.git
cd ActionsRingLiquidGlass
flutter doctor
flutter create --platforms=macos,windows,linux .
flutter pub get
flutter analyze
flutter run -d macos
```

Se Xcode rifiuta il deployment target 10.15, impostare `MACOSX_DEPLOYMENT_TARGET = 12.0` nel progetto Runner e `platform :osx, '12.0'` nel Podfile, aggiornando anche i target CocoaPods nel blocco `post_install`. Poi eseguire `flutter clean`, `flutter pub get` e `pod install` nella cartella macos.

**Scorciatoia del mouse:** con Logitech Options/Options+ assegnare al pulsante superiore «Control + Option + G». La presenza del mouse nel catalogo non indica uno stato Bluetooth effettivo.

**Nota di verifica:** compilazione e test di questa revisione v0.2.2 ancora da eseguire su macOS. Una versione precedente è stata avviata su Mac M1 Pro.
