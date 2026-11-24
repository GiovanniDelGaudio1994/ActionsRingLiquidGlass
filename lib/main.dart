import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

// GlassRing v0.2.2 — prototipo didattico, non un driver.
// I commenti spiegano le responsabilità dei componenti.

/// Dati immutabili di un'azione: l'ID è indipendente dalla UI.
class Azione {
  final String nome, id;
  final IconData icona;
  const Azione(this.nome, this.icona, this.id);
}

const azioni = <Azione>[
  Azione('Codice', Icons.code, 'code'),
  Azione('Terminale', Icons.terminal, 'terminal'),
  Azione('Screenshot', Icons.crop_free, 'screenshot'),
  Azione('Musica', Icons.music_note, 'music'),
  Azione('Appunti', Icons.content_paste, 'clipboard'),
  Azione('Impostazioni', Icons.settings, 'settings'),
  Azione('File', Icons.folder, 'files'),
  Azione('Browser', Icons.public, 'browser'),
];

/// Catalogo previsto, NON elenco dei dispositivi collegati.
const dispositivi = <String>[
  'Logitech MX Master 2S', 'Logitech MX Master 3S',
  'Logitech MX Anywhere 3S', 'Logitech MX Vertical',
  'Logitech MX Master 4', 'Apple Magic Mouse',
  'Function Trackpad K304 (USB 05AC:0265 da verificare)',
];

/// Esegue un comando diverso per ogni sistema operativo.
/// L'avvio di un processo non prova che l'app di destinazione sia operativa.
class EsecutoreAzioni {
  static Future<String> esegui(Azione azione) async {
    if (azione.id == 'clipboard') {
      await Clipboard.setData(
        const ClipboardData(text: 'Ciao da GlassRing!'));
      return 'Messaggio di prova copiato negli appunti.';
    }
    final mac = Platform.isMacOS;
    final windows = Platform.isWindows;
    final List<String> comando;
    switch (azione.id) {
      case 'code':
        comando = mac ? ['open', '-a', 'Visual Studio Code'] : ['code'];
        break;
      case 'terminal':
        comando = mac ? ['open', '-a', 'Terminal']
          : windows ? ['cmd', '/c', 'start', 'cmd'] : ['x-terminal-emulator'];
        break;
      case 'screenshot':
        comando = mac ? ['screencapture', '-i']
          : windows ? ['explorer', 'ms-screenclip:'] : ['gnome-screenshot', '-i'];
        break;
      case 'music':
        comando = mac ? ['open', '-a', 'Music']
          : windows ? ['explorer', 'mswindowsmusic:']
          : ['xdg-open', 'https://music.youtube.com'];
        break;
      case 'settings':
        comando = mac ? ['open', '-a', 'System Settings']
          : windows ? ['explorer', 'ms-settings:'] : ['gnome-control-center'];
        break;
      case 'files':
        comando = mac ? ['open', '.']
          : windows ? ['explorer', '.'] : ['xdg-open', '.'];
        break;
      case 'browser':
        comando = mac ? ['open', 'https://github.com']
          : windows ? ['explorer', 'https://github.com']
          : ['xdg-open', 'https://github.com'];
        break;
      default:
        return 'Azione non implementata.';
    }
    try {
      final processo = await Process.start(
        comando.first, comando.skip(1).toList(),
        mode: ProcessStartMode.detached);
      return 'Comando avviato (PID ' + processo.pid.toString() + ').';
    } catch (errore) {
      return 'Comando non eseguito: ' + errore.toString();
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    const opzioni = WindowOptions(
      size: Size(1430, 900), minimumSize: Size(1100, 730),
      center: true, title: 'GlassRing Studio',
      backgroundColor: Colors.transparent);
    await windowManager.waitUntilReadyToShow(opzioni, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const Applicazione());
}

class Applicazione extends StatelessWidget {
  const Applicazione({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GlassRing Studio', debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: const Studio());
}

/// Uno StatefulWidget conserva lo stato dell'interfaccia tra le ricostruzioni.
class Studio extends StatefulWidget {
  const Studio({super.key});
  @override
  State<Studio> createState() => _StatoStudio();
}

class _StatoStudio extends State<Studio> {
  bool ringVisibile = true;
  bool vetroAttivo = true;
  bool hotkeyAttiva = false;
  int dispositivoScelto = 0;
  int paginaScelta = 0;
  String stato = 'GlassRing pronto.';
  HotKey? tastoRegistrato;

  @override
  void initState() {
    super.initState();
    _registraHotkey();
  }

  Future<void> _registraHotkey() async {
    // Il pulsante superiore del mouse deve inviare Control+Option+G.
    final tasto = HotKey(
      key: PhysicalKeyboardKey.keyG,
      modifiers: [HotKeyModifier.control, HotKeyModifier.alt],
      scope: HotKeyScope.system);
    try {
      await hotKeyManager.register(tasto, keyDownHandler: (_) {
        if (mounted) setState(() => ringVisibile = !ringVisibile);
      });
      tastoRegistrato = tasto;
      if (mounted) setState(() => hotkeyAttiva = true);
    } catch (errore) {
      if (mounted) setState(() => stato = errore.toString());
    }
  }

  @override
  void dispose() {
    if (tastoRegistrato != null) {
      hotKeyManager.unregister(tastoRegistrato!);
    }
    super.dispose();
  }

  Future<void> _esegui(Azione azione) async {
    final risposta = await EsecutoreAzioni.esegui(azione);
    if (mounted) setState(() => stato = risposta);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF079BDB), Color(0xFF315BC8),
          Color(0xFF6C44C7), Color(0xFFD565D0)])),
      padding: const EdgeInsets.all(20),
      child: SafeArea(child: Column(children: [
        Row(children: [
          const Icon(Icons.blur_circular, color: Color(0xFF6CF7FF), size: 36),
          const SizedBox(width: 12),
          const Text('GlassRing', style: TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold)),
          const Spacer(),
          Icon(Icons.circle, size: 10,
            color: hotkeyAttiva ? Colors.greenAccent : Colors.amber),
          const SizedBox(width: 7),
          Text(hotkeyAttiva ? 'Ctrl + Alt + G attiva' : 'Hotkey da verificare'),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () => setState(() => ringVisibile = !ringVisibile),
            child: Text(ringVisibile ? 'Nascondi Ring' : 'Mostra Ring')),
        ]),
        const SizedBox(height: 18),
        Expanded(child: Row(children: [
          SizedBox(width: 200, child: _navigazione()),
          const SizedBox(width: 18),
          Expanded(child: Column(children: [
            Expanded(child: _pannello(Column(children: [
              const Row(children: [
                Text('AZIONI RADIALI', style: TextStyle(
                  letterSpacing: 2, fontWeight: FontWeight.bold)),
                Spacer(), Text('8 AZIONI'),
              ])),
              Expanded(child: LayoutBuilder(builder: (context, misure) {
                final lato = math.min(misure.maxWidth, misure.maxHeight);
                return Center(child: SizedBox(
                  width: lato, height: lato,
                  child: ringVisibile ? _ring(lato)
                    : const Center(child: Text('Ring nascosto'))));
              })),
            ]))),
            const SizedBox(height: 14),
            _pannello(Row(children: [
              Expanded(child: Text(stato, maxLines: 2,
                  overflow: TextOverflow.ellipsis)),
              const Text('Liquid Glass'),
              Switch(value: vetroAttivo, onChanged: (v) =>
                setState(() => vetroAttivo = v)),
            ])),
          ])),
          const SizedBox(width: 18),
          SizedBox(width: 300, child: _dispositivi()),
        ])),
      ]))),
    );

  Widget _navigazione() {
    const voci = <(IconData, String)>[
      (Icons.dashboard, 'Dashboard'),
      (Icons.bolt, 'Azioni'),
      (Icons.layers, 'Profili'),
      (Icons.palette, 'Aspetto'),
    ];
    return _pannello(Column(children: [
      const Align(alignment: Alignment.centerLeft,
        child: Text('STUDIO', style: TextStyle(letterSpacing: 3))),
      const SizedBox(height: 20),
      for (var i = 0; i < voci.length; i++)
        ListTile(
          leading: Icon(voci[i].$1), title: Text(voci[i].$2),
          selected: paginaScelta == i,
          selectedTileColor: Colors.white24,
          onTap: () => setState(() {
            paginaScelta = i;
            stato = i == 0 ? 'Dashboard'
              : 'Editor in programma: ' + voci[i].$2;
          })),
      const Spacer(),
      const Text('v0.2.2 Preview · Open Source',
        style: TextStyle(fontSize: 11)),
    ]));
  }

  Widget _ring(double lato) {
    final diametro = lato * .20;
    final raggio = lato * .35;
    return Stack(alignment: Alignment.center, children: [
      Container(width: lato * .85, height: lato * .85,
        decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(color: Colors.white60))),
      for (var i = 0; i < azioni.length; i++)
        Transform.translate(
          offset: Offset(math.sin(2 * math.pi * i / 8) * raggio,
            -math.cos(2 * math.pi * i / 8) * raggio),
          child: SizedBox(width: diametro, height: diametro,
            child: Material(
              color: vetroAttivo
                ? const Color(0x9976B8EC) : const Color(0xFF34559E),
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white70, width: 1.5)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _esegui(azioni[i]),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(azioni[i].icona, size: diametro * .27),
                    Text(azioni[i].nome, style: TextStyle(
                      fontSize: diametro * .10)),
                  ]))))),
      Container(width: lato * .28, height: lato * .28,
        decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(color: Colors.white),
          gradient: const LinearGradient(
            colors: [Color(0xFF27D6F8), Color(0xFFA348E5)])),
        child: const Center(child: Text('GlassRing',
          style: TextStyle(fontWeight: FontWeight.bold)))),
    ]);
  }

  Widget _dispositivi() => Column(children: [
    Expanded(child: _pannello(Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('DISPOSITIVI · CATALOGO', style: TextStyle(
        letterSpacing: 1.5, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      const Text('La scelta non identifica una connessione.',
        style: TextStyle(fontSize: 12)),
      const SizedBox(height: 10),
      Expanded(child: ListView.builder(
        itemCount: dispositivi.length,
        itemBuilder: (context, i) => ListTile(
          dense: true,
          selected: dispositivoScelto == i,
          selectedTileColor: Colors.white24,
          leading: Icon(i == 6 ? Icons.touch_app : Icons.mouse),
          title: Text(dispositivi[i], style: const TextStyle(fontSize: 12)),
          onTap: () => setState(() => dispositivoScelto = i)))),
      const Divider(),
      Text(dispositivi[dispositivoScelto], style:
        const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Stato reale: non verificato',
        style: TextStyle(color: Colors.amberAccent, fontSize: 12)),
    ]))),
    const SizedBox(height: 14),
    _pannello(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('BLUETOOTH / USB', style:
        TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      const Text('Collega i dispositivi nelle impostazioni di macOS. '
        'Il rilevamento HID è una funzionalità in sviluppo.',
        style: TextStyle(fontSize: 12)),
      const SizedBox(height: 10),
      TextButton.icon(
        onPressed: () async {
          if (Platform.isMacOS) {
            try {
              await Process.start('open',
                ['x-apple.systempreferences:com.apple.Bluetooth'],
                mode: ProcessStartMode.detached);
            } catch (e) {
              if (mounted) setState(() => stato = e.toString());
            }
          }
        },
        icon: const Icon(Icons.bluetooth),
        label: const Text('Impostazioni Bluetooth')),
    ])),
  ]);

  /// Unifica bordi, fondo semitrasparente e raggi dei pannelli.
  Widget _pannello(Widget contenuto) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: vetroAttivo ? .17 : .09),
      border: Border.all(color: Colors.white54),
      borderRadius: BorderRadius.circular(25)),
    child: contenuto);
}
