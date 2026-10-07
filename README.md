# WaEnhancer + Material chat

Build personale di [WaEnhancer](https://github.com/Dev4Mod/waenhancer) con lo stile chat Material (Google Messages) sopra la modalità Monet.

Il repository contiene solo le modifiche, come patch. Il codice di WaEnhancer viene scaricato da Dev4Mod a ogni build.

## Come funziona

1. Due volte al giorno il workflow `Build WaEnhancer + Material chat` controlla l'ultima release di Dev4Mod.
2. Se per quella release non esiste ancora `<tag>-material`:
   - clona il tag;
   - applica `patches/*.patch`;
   - compila `assembleWhatsappDebug` con la nostra chiave;
   - pubblica l'APK nelle **Releases** di questo repository.
3. Se una patch non si applica più (upstream ha cambiato gli stessi file), non pubblica niente e apre una **issue** con i file in conflitto. Se le patch si applicano ma la compilazione fallisce, apre una issue "Build fails on <tag>" con gli errori e la fine del log di Gradle (i log dei job li scaricano solo gli admin). Quando la build successiva riesce, le issue vengono chiuse.

Il controllo aggiornamenti dell'app (popup in WhatsApp e scheda nella home) legge le release di **questo** repository. Per questo il repository deve essere **pubblico**: l'app interroga l'API di GitHub senza autenticazione. Il workflow scrive il tag della release nel `versionName` (per esempio `1.6.0 (7EA3867C) 1.6.0-a160ff41-material`), così l'app non segnala aggiornamenti finché non esce una nostra build nuova.

Il workflow si avvia anche a mano da *Actions → Run workflow*: puoi indicare un tag e forzare la ricompilazione. Parte anche a ogni push che modifica `patches/`.

## Secret necessari (Settings → Secrets and variables → Actions)

L'APK va firmato con la stessa chiave della build installata, altrimenti non si installa sopra. La build attuale è firmata con la debug key di Android Studio (`%USERPROFILE%\.android\debug.keystore`).

| Secret | Valore |
|---|---|
| `KEY_STORE` | il keystore in base64 |
| `KEY_STORE_PASSWORD` | `android` (debug key) |
| `ALIAS` | `androiddebugkey` |
| `KEY_PASSWORD` | `android` |

Per ottenere il base64 in PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\.android\debug.keystore")) | Set-Clipboard
```

## Risolvere un conflitto

Nel clone locale `E:\waenhancer` (branch `material-chat`, remote `origin` = Dev4Mod):

```bash
cd /e/waenhancer
git fetch origin --tags
git rebase <nuovo tag>            # risolvi i conflitti, compila e prova
/e/waenhancer-material/scripts/update-patches.sh <nuovo tag>
cd /e/waenhancer-material && git add -A && git commit -m "patches: rebase on <nuovo tag>" && git push
```

Il push su `patches/` avvia subito la build.
