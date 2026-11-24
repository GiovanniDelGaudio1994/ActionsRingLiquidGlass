import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../services/azioni.dart';

// GlassRing Studio — interfaccia ufficiale in Flutter.
// Il riferimento visivo è assets/glassring-official-concept.jpg.
// Tutti i pulsanti principali sono widget reali, non un'immagine cliccabile.

const _inchiostro = Color(0xFF061A50);
const _azzurro = Color(0xFF28DBFF);
const _violetto = Color(0xFFB46BFF);

class ConceptDashboard extends StatefulWidget {
  const ConceptDashboard({super.key});

  @override
  State<ConceptDashboard> createState() => _StatoConceptDashboard();
}

class _StatoConceptDashboard extends State<ConceptDashboard> {
  final HotKey _hotkey = HotKey(
    key: PhysicalKeyboardKey.keyG,
    modifiers: [HotKeyModifier.control, HotKeyModifier.alt],
    scope: HotKeyScope.system,
  );

  bool _visibile = true;
  bool _vetro = true;
  bool _hotkeyAttiva = false;
  int _azione = 0;
  int _dispositivo = 0;
  int _inizioCatalogo = 0;
  int _sezione = 0;
  String _messaggio = 'Scorciatoia: Control + Option + G';

  @override
  void initState() {
    super.initState();
    _registraHotkey();
  }

  /// Logitech Options può assegnare Ctrl+Alt+G a un pulsante del mouse.
  /// Il rilevamento diretto dei pulsanti HID non è ancora implementato.
  Future<void> _registraHotkey() async {
    try {
      await hotKeyManager.register(_hotkey, keyDownHandler: (_) async {
        await windowManager.show();
        await windowManager.focus();
        if (mounted) setState(() => _visibile = !_visibile);
      });
      if (mounted) setState(() => _hotkeyAttiva = true);
    } catch (errore) {
      if (mounted) {
        setState(() => _messaggio = 'Hotkey non registrata: ' +
            errore.toString());
      }
    }
  }

  @override
  void dispose() {
    if (_hotkeyAttiva) hotKeyManager.unregister(_hotkey);
    super.dispose();
  }

  Future<void> _esegui(int indice) async {
    setState(() {
      _azione = indice;
      _messaggio = 'Esecuzione di ' + azioniRing[indice].titolo + '…';
    });
    final risposta = await EsecutoreAzioni.esegui(azioniRing[indice]);
    if (mounted) setState(() => _messaggio = risposta);
  }

  void _scegliDispositivo(int indice) {
    setState(() {
      _dispositivo = indice;
      _messaggio = dispositiviCatalogo[indice].nome +
          ': selezionato nel catalogo; connessione da verificare.';
    });
  }

  void _spostaCatalogo(int delta) {
    setState(() {
      _inizioCatalogo = (_inizioCatalogo + delta)
          .clamp(0, dispositiviCatalogo.length - 4);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Il concept è stato progettato su una tavola 1585×992.
    // FittedBox conserva le proporzioni senza spostare gli spicchi del Ring.
    // Le dimensioni della finestra nativa restano modificabili.
    return Scaffold(
      backgroundColor: const Color(0xFF173FAF),
      body: LayoutBuilder(builder: (context, vincoli) {
        return Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 1585,
              height: 992,
              child: Stack(children: [
                const Positioned.fill(child: CustomPaint(
                    painter: _SfondoLiquidGlass())),
                _barraTitolo(),
                Positioned(
                  left: 98, top: 150,
                  child: _visibile
                      ? RingUfficiale(
                          diametro: 575,
                          attivo: _azione,
                          onSelezione: _esegui,
                        )
                      : SizedBox(
                          width: 575, height: 575,
                          child: Center(child: _testo(
                            'Premi Ctrl + Alt + G per aprire GlassRing',
                            18, Colors.white,
                          )),
                        ),
                ),
                Positioned(
                  left: 710, top: 96, width: 830, height: 632,
                  child: _pannelloStudio(),
                ),
                Positioned(
                  left: 36, top: 776, width: 1504, height: 170,
                  child: _scaffaleDispositivi(),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  Widget _barraTitolo() => Positioned(
    top: 0, left: 0, right: 0, height: 44,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF193B82).withValues(alpha: .4),
        border: Border(bottom: BorderSide(
            color: Colors.white.withValues(alpha: .18))),
      ),
      child: Row(children: [
        const SizedBox(width: 14),
        for (final colore in [
          const Color(0xFFFF605C),
          const Color(0xFFFFBD44),
          const Color(0xFF00CA4E),
        ]) ...[
          Container(width: 17, height: 17, decoration:
              BoxDecoration(color: colore, shape: BoxShape.circle)),
          const SizedBox(width: 12),
        ],
        const SizedBox(width: 12),
        _testo('GlassRing Studio', 18, Colors.white, FontWeight.w800),
        const Spacer(),
        _testo(_hotkeyAttiva ? '● Hotkey attiva' : '● Hotkey da verificare',
            14, Colors.white),
        const SizedBox(width: 25),
      ]),
    ),
  );

  Widget _pannelloStudio() => _vetro(
    raggio: 34,
    opacita: _vetro ? .26 : .70,
    child: Row(children: [
      SizedBox(width: 210, child: _barraLaterale()),
      Expanded(child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 17, 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .09),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(34),
            bottomRight: Radius.circular(34),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _testo('GlassRing Studio', 30, _inchiostro, FontWeight.w800),
          const SizedBox(height: 2),
          _testo('Universal Actions for Your Desktop',
              16, const Color(0xFF355181)),
          const SizedBox(height: 18),
          SizedBox(height: 235, child: _schedaMouse()),
          const SizedBox(height: 16),
          SizedBox(height: 79, child: _rigaImpostazione(
            Icons.blur_circular, 'Liquid Glass',
            'Interfaccia traslucida e moderna',
            trailing: Switch(
              value: _vetro,
              onChanged: (value) => setState(() => _vetro = value),
              activeColor: const Color(0xFF1679FF),
            ),
          )),
          const SizedBox(height: 10),
          SizedBox(height: 75, child: _rigaImpostazione(
            Icons.hub_outlined, 'Radial Layout',
            '8 azioni · Menu circolare nella dashboard',
            trailing: const Icon(Icons.chevron_right,
                color: Color(0xFF42649A)),
            onTap: () => setState(() => _visibile = !_visibile),
          )),
          const SizedBox(height: 10),
          SizedBox(height: 75, child: _rigaImpostazione(
            Icons.layers_outlined, 'Profiles',
            'Profili contestuali: in sviluppo',
            trailing: const Icon(Icons.chevron_right,
                color: Color(0xFF42649A)),
            onTap: () => setState(() =>
              _messaggio = 'Profili configurabili: funzionalità in roadmap.'),
          )),
          const Spacer(),
          Text(_messaggio, maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF254879), fontSize: 11)),
        ]),
      )),
    ]),
  );

  Widget _barraLaterale() {
    const titoli = [
      'Dashboard', 'Actions', 'Profiles', 'Devices',
      'Appearance', 'Settings',
    ];
    const icone = [
      Icons.home_outlined, Icons.grid_view_rounded,
      Icons.layers_outlined, Icons.mouse_outlined,
      Icons.palette_outlined, Icons.settings_outlined,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 98, 8, 18),
      child: Column(children: [
        for (var i = 0; i < titoli.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Material(
              color: _sezione == i
                  ? Colors.white.withValues(alpha: .47)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  setState(() {
                    _sezione = i;
                    _messaggio = i == 0
                      ? 'Dashboard principale.'
                      : titoli[i] + ': pannello avanzato in sviluppo.';
                  });
                },
                child: SizedBox(height: 47, child: Row(children: [
                  const SizedBox(width: 15),
                  Icon(icone[i], color: const Color(0xFF284B8C), size: 25),
                  const SizedBox(width: 12),
                  _testo(titoli[i], 15, _inchiostro,
                    _sezione == i ? FontWeight.w700 : FontWeight.w500),
                ])),
              ),
            ),
          ),
        const Spacer(),
        Row(children: [
          Container(width: 13, height: 13, decoration:
            const BoxDecoration(
              color: Color(0xFF25E995), shape: BoxShape.circle)),
          const SizedBox(width: 7),
          _testo('GlassRing v0.3.0', 12, _inchiostro,
              FontWeight.w700),
        ]),
        const SizedBox(height: 4),
        _testo('macOS · Windows · Linux (roadmap)',
            10, const Color(0xFF365887)),
      ]),
    );
  }

  Widget _schedaMouse() {
    final dispositivo = dispositiviCatalogo[_dispositivo];
    return _riquadroInterno(
      Row(children: [
        SizedBox(
          width: 215, height: 215,
          child: Center(child: ConceptMouse(
            dispositivo: dispositivo, width: 190, height: 210)),
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 14, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _testo(dispositivo.nome.startsWith('MX')
                  ? 'Logitech ' + dispositivo.nome
                  : dispositivo.nome, 21, _inchiostro, FontWeight.w800),
              const SizedBox(height: 10),
              Row(children: [
                Container(width: 10, height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFBF47), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                _testo('Stato connessione non verificato',
                  12, const Color(0xFF25416C)),
              ]),
              const SizedBox(height: 9),
              _testo('Batteria: non disponibile',
                12, const Color(0xFF365683)),
              const Divider(height: 26, color: Color(0x663E6CA8)),
              _testo('Trigger', 17, _inchiostro, FontWeight.w800),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: Colors.white.withValues(alpha: .37),
                  border: Border.all(color: Colors.white70),
                ),
                child: Row(children: [
                  const Icon(Icons.mouse_outlined,
                    color: Color(0xFF27477D), size: 19),
                  const SizedBox(width: 7),
                  Expanded(child: _testo(
                    'Ctrl + Option + G · Tasto configurabile',
                    11, _inchiostro,
                  )),
                  const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF27477D)),
                ]),
              ),
            ],
          ),
        )),
      ]),
    );
  }

  Widget _rigaImpostazione(
    IconData icona, String titolo, String sottotitolo, {
    Widget? trailing, VoidCallback? onTap,
  }) {
    final contenuto = Row(children: [
      Container(
        height: 56, width: 71,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: const Color(0xFFA1BDF9).withValues(alpha: .39),
          border: Border.all(color: Colors.white70),
        ),
        child: Icon(icona, size: 32, color: const Color(0xFF4556A3)),
      ),
      const SizedBox(width: 17),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _testo(titolo, 20, _inchiostro, FontWeight.w800),
          _testo(sottotitolo, 13, _inchiostro),
        ],
      )),
      if (trailing != null) trailing,
      const SizedBox(width: 4),
    ]);
    return _riquadroInterno(
      onTap == null ? contenuto
          : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20),
              child: contenuto),
      padding: const EdgeInsets.fromLTRB(14, 7, 10, 7),
    );
  }

  Widget _scaffaleDispositivi() {
    return _vetro(
      raggio: 35, opacita: _vetro ? .23 : .65,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 22, 21, 21),
        child: Row(children: [
          SizedBox(width: 270, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _testo('Dispositivi Compatibili', 21,
                  Colors.white, FontWeight.w800),
              const SizedBox(height: 9),
              _testo('Seleziona e personalizza\nil tuo mouse',
                  15, Colors.white),
            ],
          )),
          _freccia(Icons.chevron_left, () => _spostaCatalogo(-1)),
          const SizedBox(width: 10),
          for (var offset = 0; offset < 4; offset++) ...[
            Expanded(child: _schedaScaffale(_inizioCatalogo + offset)),
            const SizedBox(width: 13),
          ],
          _freccia(Icons.chevron_right, () => _spostaCatalogo(1)),
        ]),
      ),
    );
  }

  Widget _freccia(IconData icona, VoidCallback callback) => Material(
    color: Colors.white.withValues(alpha: .22),
    shape: const CircleBorder(),
    child: IconButton(
      onPressed: callback,
      icon: Icon(icona, color: const Color(0xFF2653AE)),
      tooltip: icona == Icons.chevron_left
        ? 'Dispositivi precedenti' : 'Altri dispositivi',
    ),
  );

  Widget _schedaScaffale(int indice) {
    final modello = dispositiviCatalogo[indice];
    final selezionato = indice == _dispositivo;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _scegliDispositivo(indice),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white.withValues(alpha: selezionato ? .24 : .14),
            border: Border.all(
              color: selezionato ? const Color(0xFF93FCFF) : Colors.white38,
              width: selezionato ? 2 : 1,
            ),
            boxShadow: selezionato
              ? [BoxShadow(color: _azzurro.withValues(alpha: .55),
                blurRadius: 23)] : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Row(children: [
            SizedBox(width: 92, height: 115,
              child: ConceptMouse(dispositivo: modello,
                width: 89, height: 107)),
            const SizedBox(width: 4),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _testo(modello.nome, 15, Colors.white, FontWeight.w800),
                const SizedBox(height: 7),
                _testo(selezionato ? '● Selezionato' : '○ Nel catalogo',
                    12, Colors.white),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  Widget _vetro({
    required Widget child,
    required double raggio,
    required double opacita,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(raggio),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: _vetro ? 18 : 0,
            sigmaY: _vetro ? 18 : 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(raggio),
            color: const Color(0xFF9CD1FF).withValues(alpha: opacita),
            border: Border.all(color: Colors.white.withValues(alpha: .6),
                width: 1.3),
            boxShadow: [BoxShadow(
              color: _azzurro.withValues(alpha: .20),
              blurRadius: 36)],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _riquadroInterno(Widget child, {
    EdgeInsets padding = const EdgeInsets.all(12),
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: const Color(0xFFDCEBFF).withValues(alpha: .50),
      border: Border.all(color: Colors.white.withValues(alpha: .75),
          width: 1.3),
    ),
    child: child,
  );
}

/// Ruota a otto SPICCHI, non otto cerchi.
/// Il disegno è separato dai target GestureDetector affinché il click resti
/// un evento Flutter testabile e non dipenda dai pixel dell'immagine.
class RingUfficiale extends StatelessWidget {
  const RingUfficiale({
    super.key,
    required this.diametro,
    required this.attivo,
    required this.onSelezione,
  });

  final double diametro;
  final int attivo;
  final ValueChanged<int> onSelezione;

  @override
  Widget build(BuildContext context) {
    final centro = diametro / 2;
    final raggioPulsanti = diametro * .342;
    return SizedBox(
      width: diametro, height: diametro,
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(
          painter: _PittoreSpicchi(selezionato: attivo),
        )),
        for (var indice = 0; indice < azioniRing.length; indice++)
          Positioned(
            left: centro +
                math.cos(-math.pi / 2 + indice * math.pi / 4) *
                raggioPulsanti - 69,
            top: centro +
                math.sin(-math.pi / 2 + indice * math.pi / 4) *
                raggioPulsanti - 54,
            width: 138, height: 108,
            child: InkWell(
              onTap: () => onSelezione(indice),
              borderRadius: BorderRadius.circular(35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(azioniRing[indice].icona,
                    size: 43, color: Colors.white,
                    shadows: const [Shadow(
                      color: Color(0xCC12439C), blurRadius: 12)]),
                  const SizedBox(height: 9),
                  _testo(azioniRing[indice].titolo, 17,
                    Colors.white, FontWeight.w700),
                ],
              ),
            ),
          ),
        Positioned(
          left: centro - 94, top: centro - 94,
          width: 188, height: 188,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [
                Color(0xFF08CEFF), Color(0xFF4864ED),
                Color(0xFF9E41E8),
              ]),
              border: Border.all(color: Colors.white70, width: 2.5),
              boxShadow: [
                BoxShadow(color: _violetto, blurRadius: 45,
                  spreadRadius: 6),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.blur_circular_rounded,
                  size: 56, color: Colors.white),
                _testo('GlassRing', 25, Colors.white, FontWeight.w800),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _PittoreSpicchi extends CustomPainter {
  const _PittoreSpicchi({required this.selezionato});
  final int selezionato;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raggioEsterno = size.width * .49;
    final raggioInterno = size.width * .175;
    final esterno = Rect.fromCircle(
      center: centro, radius: raggioEsterno);
    final interno = Rect.fromCircle(
      center: centro, radius: raggioInterno);

    canvas.drawCircle(centro, raggioEsterno + 4,
      Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28)
        ..color = const Color(0xFF3CDFFF).withValues(alpha: .25));

    for (var i = 0; i < 8; i++) {
      const apertura = math.pi / 4;
      final inizio = -math.pi / 2 - apertura / 2 + i * apertura;
      final separazione = .036;
      final a = inizio + separazione;
      final ampiezza = apertura - separazione * 2;
      final primo = Offset(centro.dx + raggioInterno * math.cos(a),
        centro.dy + raggioInterno * math.sin(a));
      final profilo = Path()
        ..moveTo(primo.dx, primo.dy)
        ..arcTo(interno, a, ampiezza, false)
        ..lineTo(centro.dx + raggioEsterno * math.cos(a + ampiezza),
          centro.dy + raggioEsterno * math.sin(a + ampiezza))
        ..arcTo(esterno, a + ampiezza, -ampiezza, false)
        ..close();
      final base = i == selezionato
        ? <Color>[const Color(0xFF22DFFF), const Color(0xFF416FE9)]
        : i >= 4
          ? <Color>[const Color(0xFFA383EB), const Color(0xFF416FD6)]
          : <Color>[const Color(0xFF79C7FF), const Color(0xFF455BCE)];
      final shader = ui.Gradient.linear(
        Offset(centro.dx - raggioEsterno, centro.dy - raggioEsterno),
        Offset(centro.dx + raggioEsterno, centro.dy + raggioEsterno),
        base,
      );
      canvas.drawPath(profilo, Paint()..shader = shader);
      canvas.drawPath(profilo, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(0xFFCCF6FF));
    }
  }

  @override
  bool shouldRepaint(covariant _PittoreSpicchi oldDelegate) =>
      oldDelegate.selezionato != selezionato;
}

/// Ritaglia dal concept originale SOLO la zona illustrativa del mouse.
/// Non dipende da URL esterni. Se manca l'asset mostra un'icona semantica.
class ConceptMouse extends StatelessWidget {
  const ConceptMouse({
    super.key, required this.dispositivo,
    required this.width, required this.height,
  });

  final DispositivoCatalogo dispositivo;
  final double width;
  final double height;

  static Future<ui.Image>? _immagineCondivisa;

  static Future<ui.Image> _caricaImmagine() async {
    final dati = await rootBundle.load('assets/glassring-official-concept.jpg');
    final codec = await ui.instantiateImageCodec(
        dati.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    if (dispositivo.ritaglio == null) {
      return SizedBox(width: width, height: height,
        child: Icon(dispositivo.tipo == 'Trackpad'
          ? Icons.touch_app_rounded : Icons.mouse_rounded,
          color: const Color(0xFF2D477F), size: width * .65));
    }
    _immagineCondivisa ??= _caricaImmagine();
    return FutureBuilder<ui.Image>(
      future: _immagineCondivisa,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(width: width, height: height,
            child: const Icon(Icons.mouse_rounded,
              size: 46, color: Color(0xFF284981)));
        }
        return SizedBox(
          width: width, height: height,
          child: CustomPaint(painter: _PittoreRitaglio(
            immagine: snapshot.data!,
            origine: dispositivo.ritaglio!,
          )),
        );
      },
    );
  }
}

class _PittoreRitaglio extends CustomPainter {
  const _PittoreRitaglio({required this.immagine, required this.origine});
  final ui.Image immagine;
  final Rect origine;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      immagine, origine,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(covariant _PittoreRitaglio oldDelegate) =>
      oldDelegate.origine != origine ||
      oldDelegate.immagine != immagine;
}

/// Sfondo interamente vettoriale: gradiente e nastri luminosi curvi.
class _SfondoLiquidGlass extends CustomPainter {
  const _SfondoLiquidGlass();

  @override
  void paint(Canvas canvas, Size size) {
    final quadro = Offset.zero & size;
    canvas.drawRect(quadro, Paint()..shader = ui.Gradient.linear(
      Offset.zero, Offset(size.width, size.height),
      const [
        Color(0xFF06519C),
        Color(0xFF2955D2),
        Color(0xFF7553D3),
        Color(0xFF077AC8),
      ],
      const [.0, .32, .68, 1],
    ));

    final raggi = <(Offset, double, Color)>[
      (const Offset(230, 200), 460, const Color(0xFF00CFFF)),
      (const Offset(780, 285), 550, const Color(0xFFE7A7FF)),
      (const Offset(1410, 140), 610, const Color(0xFF61DCFF)),
      (const Offset(65, 760), 580, const Color(0xFFBE61FD)),
    ];
    for (final (centro, raggio, colore) in raggi) {
      canvas.drawCircle(centro, raggio,
        Paint()..shader = ui.Gradient.radial(
          centro, raggio,
          [colore.withValues(alpha: .55), Colors.transparent],
        ));
    }
    for (var i = 0; i < 3; i++) {
      final percorso = Path()
        ..moveTo(-220, 270 + i * 148)
        ..cubicTo(310, 680 - i * 94,
          635, 45 + i * 100,
          860, -120 + i * 100)
        ..quadraticBezierTo(1200, 430 + i * 50, 1690, 45 + i * 250);
      canvas.drawPath(percorso, Paint()
        ..color = Colors.white.withValues(alpha: i == 1 ? .16 : .29)
        ..strokeWidth = i == 1 ? 70 : 12
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Text _testo(String testo, double grandezza, Color colore,
    [FontWeight peso = FontWeight.w500]) =>
  Text(testo, style: TextStyle(
    fontSize: grandezza, color: colore, fontWeight: peso,
    height: 1.12,
  ));
