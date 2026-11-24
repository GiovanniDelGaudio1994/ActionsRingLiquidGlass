# Architettura di GlassRing (italiano)

## Obiettivo
Menu radiale per azioni desktop con una UI Flutter e integrazione tramite scorciatoia di sistema. Il progetto è un **prototipo**, non un driver per mouse.

## Componenti del codice
- `main()`: inizializza il framework e la finestra desktop con `window_manager`.
- `Applicazione`: definisce il tema Flutter e la schermata iniziale.
- `Studio` / `_StatoStudio`: gestisce stati modificabili come visibilità del ring e mouse selezionato. `setState()` informa Flutter che occorre ricostruire i widget.
- `Azione`: rappresenta i dati immutabili per una voce del ring.
- `EsecutoreAzioni`: trasforma l'ID di una voce in comando per macOS, Windows o Linux usando `Process.start`.
- `_registraHotkey()`: tenta di registrare Control + Alt + G tramite `hotkey_manager`; il pulsante superiore del MX Master 2S va configurato per inviare la stessa scorciatoia.
- `_ring()`: dispone otto pulsanti sul cerchio con seno e coseno.
- `_dispositivi()`: catalogo illustrativo, **non** scanner Bluetooth/HID.

## Flusso di input
Pulsante configurato → scorciatoia globale → callback → `setState` → menu visibile/nascosto → clic su azione → `EsecutoreAzioni.esegui`.

## Limitazioni
Il menu non è ancora un overlay indipendente; gesture globali, rilevamento automatico e batteria non sono implementati. `05AC:0265` è un identificativo candidato osservato durante test di scollegamento del K304, non prova di compatibilità esclusiva.

## Roadmap tecnica
1. Spostare il menu in una finestra overlay nativa sopra le altre app.
2. Introdurre una interfaccia `DeviceDiscovery` con implementazioni macOS IOKit/HID, Windows e Linux.
3. Separare i profili configurabili in file e aggiungere test unitari.
4. Documentare permessi Accessibility e limitazioni Wayland.
