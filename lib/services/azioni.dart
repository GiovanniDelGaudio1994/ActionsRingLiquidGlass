import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ogni azione ha un ID stabile, non dipendente dalla lingua dei pulsanti.
class AzioneRing {
  const AzioneRing(this.id, this.titolo, this.icona);
  final String id;
  final String titolo;
  final IconData icona;
}

const azioniRing = <AzioneRing>[
  AzioneRing('code', 'Code', Icons.code_rounded),
  AzioneRing('terminal', 'Terminal', Icons.terminal_rounded),
  AzioneRing('screenshot', 'Screenshot', Icons.crop_free_rounded),
  AzioneRing('music', 'Music', Icons.music_note_rounded),
  AzioneRing('clipboard', 'Clipboard', Icons.content_paste_rounded),
  AzioneRing('settings', 'Settings', Icons.settings_rounded),
  AzioneRing('files', 'Finder', Icons.folder_rounded),
  AzioneRing('browser', 'Browser', Icons.explore_rounded),
];

/// Catalogo di modelli per la UI. Non implica una connessione HID rilevata.
class DispositivoCatalogo {
  const DispositivoCatalogo(this.nome, this.tipo, this.ritaglio);
  final String nome;
  final String tipo;

  /// Rettangolo (pixel) dell'illustrazione nel concept originale.
  /// Usiamo il disegno approvato, non immagini esterne con diritti ignoti.
  final Rect? ritaglio;
}

const dispositiviCatalogo = <DispositivoCatalogo>[
  DispositivoCatalogo('MX Master 2S', 'Mouse', Rect.fromLTWH(967, 201, 190, 231)),
  DispositivoCatalogo('MX Master 3S', 'Mouse', Rect.fromLTWH(691, 809, 93, 122)),
  DispositivoCatalogo('MX Anywhere 3', 'Mouse', Rect.fromLTWH(972, 812, 105, 120)),
  DispositivoCatalogo('MX Vertical', 'Mouse', Rect.fromLTWH(1229, 803, 114, 130)),
  DispositivoCatalogo('MX Master 4', 'Mouse', null),
  DispositivoCatalogo('Apple Magic Mouse', 'Mouse', null),
  DispositivoCatalogo('Function Trackpad K304', 'Trackpad', null),
];

/// Gestisce gli effetti sul sistema operativo fuori dai widget Flutter.
/// Non utilizza una shell con interpolazione di testo inserito dall'utente.
class EsecutoreAzioni {
  static Future<String> esegui(AzioneRing azione) async {
    if (azione.id == 'clipboard') {
      await Clipboard.setData(const ClipboardData(
        text: 'Messaggio di prova copiato da GlassRing Studio.'));
      return 'Testo di prova copiato negli appunti.';
    }

    final mac = Platform.isMacOS;
    final win = Platform.isWindows;
    final List<String> comando;
    switch (azione.id) {
      case 'code':
        comando = mac ? ['open', '-a', 'Visual Studio Code'] : ['code'];
        break;
      case 'terminal':
        comando = mac ? ['open', '-a', 'Terminal']
          : win ? ['cmd', '/c', 'start', 'cmd'] : ['x-terminal-emulator'];
        break;
      case 'screenshot':
        comando = mac ? ['screencapture', '-i']
          : win ? ['explorer', 'ms-screenclip:']
          : ['gnome-screenshot', '-i'];
        break;
      case 'music':
        comando = mac ? ['open', '-a', 'Music']
          : win ? ['explorer', 'https://music.youtube.com']
          : ['xdg-open', 'https://music.youtube.com'];
        break;
      case 'settings':
        comando = mac ? ['open', '-a', 'System Settings']
          : win ? ['explorer', 'ms-settings:']
          : ['gnome-control-center'];
        break;
      case 'files':
        comando = mac ? ['open', '.'] : win
          ? ['explorer', '.'] : ['xdg-open', '.'];
        break;
      case 'browser':
        comando = mac ? ['open', 'https://github.com']
          : win ? ['explorer', 'https://github.com']
          : ['xdg-open', 'https://github.com'];
        break;
      default:
        return 'Azione non implementata.';
    }
    try {
      final processo = await Process.start(
        comando.first,
        comando.skip(1).toList(),
        mode: ProcessStartMode.detached,
      );
      return 'Avvio ' + azione.titolo + ' (PID ' +
          processo.pid.toString() + ').';
    } catch (errore) {
      return 'Impossibile avviare ' + azione.titolo + ': ' +
          errore.toString();
    }
  }
}
