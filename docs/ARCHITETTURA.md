# Architettura GlassRing v0.3.0 (italiano)

## 1. Punto di avvio
\`lib/main.dart\` inizializza Flutter, usa \`window_manager\` per la finestra desktop e mostra \`ConceptDashboard\`.

## 2. Dati e servizi
\`lib/services/azioni.dart\` definisce \`AzioneRing\`, \`DispositivoCatalogo\`, le liste di catalogo e \`EsecutoreAzioni\`.
I modelli contengono dati immutabili. L'esecuzione dei comandi resta separata dai widget.
Il catalogo è illustrativo: la selezione di un mouse **non prova una connessione hardware**.

## 3. Stato dell'interfaccia
\`ConceptDashboard\` conserva nella propria \`State\` la visibilità della ruota, l'effetto vetro, la voce selezionata, il modello visualizzato e la posizione nello scaffale.
\`setState()\` aggiorna solo i widget interessati dal nuovo stato.

## 4. Menu radiale con tracciato vettoriale
\`_PittoreSpicchi\` disegna gli otto settori con i raggi interno/esterno e le funzioni trigonometriche, usando \`Path.arcTo\`.
\`RingUfficiale\` dispone sopra il disegno gli otto widget interattivi: l'utente seleziona un'azione e \`EsecutoreAzioni\` invoca il comando del sistema operativo.
Il cerchio centrale è un widget, non un'immagine fittizia.

## 5. Riferimento al concept
La vista usa una tavola di 1585×992 punti scalata con \`FittedBox\` per mantenere il posizionamento progettato.
\`_SfondoLiquidGlass\` crea sfondo e nastri con \`CustomPainter\`.
I pannelli impiegano \`BackdropFilter\`, \`ImageFilter.blur\`, bordi e trasparenze.
\`ConceptMouse\` ritaglia alcune rappresentazioni di mouse da \`assets/glassring-official-concept.jpg\`; i modelli senza ritaglio mostrano un'icona.

## 6. Scorciatoia e limiti
\`hotkey_manager\` registra Ctrl+Option+G dove supportato. Il pulsante fisico Logitech va configurato separatamente per emettere questa scorciatoia.
Nessuna gesture HID globale, lettura batteria o pairing Bluetooth è implementata in v0.3.
Lo stato di connessione resta dichiarato come non verificato. Non confondere il concept con un prodotto ultimato.

## 7. Verifica
Eseguire \`flutter create --platforms=macos,windows,linux .\`, \`flutter pub get\`, \`dart format lib\`, \`flutter analyze\` e \`flutter run -d macos\` sul Mac di test.
