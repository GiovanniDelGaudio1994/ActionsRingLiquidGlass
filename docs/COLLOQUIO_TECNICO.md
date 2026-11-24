# Guida ai colloqui — studiare GlassRing

## Presentazione di 60 secondi
«GlassRing è un prototipo open source di launcher radiale sviluppato in Flutter. Ho studiato l'integrazione fra eventi di input e desktop, e realizzato un menu con otto azioni configurate nel codice. Le responsabilità sono separate: un modello dati per ogni azione, un esecutore per i comandi di sistema e uno StatefulWidget per la UI. Il menu viene aperto con una hotkey globale; il supporto multipiattaforma e al K304 è una roadmap, non una funzionalità collaudata.»

## Domande tecniche
**Perché uno StatefulWidget?** Il booleano `ringVisibile` cambia e deve riflettersi nel widget tree.

**Cosa fa setState()?** Segnala a Flutter che uno stato mutato richiede la ricostruzione dei widget dipendenti.

**Perché separare Azione da EsecutoreAzioni?** Il modello descrive l'azione; il servizio esegue l'effetto sul sistema. Evita di mischiare UI e comandi.

**Come funziona il cerchio?** Ogni pulsante ha angolo `2πi/8`; le coordinate sono calcolate con seno e coseno.

**Cos'è una hotkey globale?** Una combinazione registrata a livello di sistema, utilizzabile mentre la finestra non ha il focus, nei limiti di macOS e dei permessi.

**Perché Process.start?** Permette di avviare eseguibili esterni; bisogna gestire errori, validare parametri e non scambiare l'avvio del processo per il successo dell'azione.

**Il K304 è già supportato?** No: gesti macOS funzionanti secondo il test manuale, ma il rilevamento nativo e le gesture nell'app sono da implementare.

## Esercizio pratico
Aggiungi l'azione «Apri Calcolatrice» con ID `calcolatrice`: una voce nella lista, un ramo nello switch, un test manuale. Spiega come hai evitato di collocare `Process.start` direttamente nel widget.

## Trasparenza
Non attribuire a te funzioni non testate o codice scritto da altri. Spiega ciò che hai studiato, modificato, verificato e puoi riprodurre.
