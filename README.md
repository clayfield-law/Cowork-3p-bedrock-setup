# Claude Cowork (3P) als Kanzlei berufsrechts- und datenschutzkonform einrichten: Schritt-für-Schritt-Anleitung

**Für wen ist diese Anleitung?** Für alle, die Cowork §203 StGB und §43e BRAO konform über Amazon Web Services (AWS) betreiben wollen. Technische Vorkenntnisse sind nicht nötig. Wer online einkaufen kann, schafft auch das hier.

**Was wird eingerichtet:** Ein Konto beim Cloud-Dienst von Amazon (genannt „AWS") und eine automatische Einrichtung von AWS Bedrock, die anschließend in die Claude-Desktop-App eingetragen wird. Das Ganze dauert etwa 10 Minuten.

**Was vorher bereitliegen sollte:**

- [ ] Einen Computer mit Internet-Browser (Chrome, Edge, Firefox oder Safari)
- [ ] Eine **Kanzlei-E-Mail-Adresse** mit Zugriff (idealerweise ein Sammelpostfach wie `aws@ihre-kanzlei.de`)
- [ ] Eine **Firmenkreditkarte** *oder* die **IBAN des Kanzleikontos** (SEPA-Lastschrift wird akzeptiert)
- [ ] Ein **Mobiltelefon** (für Bestätigungscodes)
- [ ] Etwa 10 Minuten ohne Unterbrechung

Neue AWS-Konten erhalten **bis zu 200 US-Dollar Startguthaben** (in der Regel 100 $ sofort, weitere durch optionale Aktivitäten), gültig für 6 Monate. Die ersten Wochen mit Claude kosten damit sehr wahrscheinlich gar nichts. Danach wird nur abgerechnet, was tatsächlich genutzt wird, ähnlich wie bei einer Telefonrechnung. Am Ende dieser Anleitung richten wir zusätzlich eine automatische E-Mail-Warnung ein, damit die Kosten nie überraschen.

**Hinweis:** Diese Anleitung ist auf das deutsche Berufsgeheimnis (§ 203 StGB) hin entworfen. Die Einrichtung hält sämtliche Verarbeitung in EU-Rechenzentren und schaltet jede Form der Inhaltsprotokollierung ab. Die Beantragung der Zusatzvereinbarung für Berufsgeheimnisträger bei AWS (Teil 5) ist nicht Bestandteil dieser Einrichtung. Sie muss von der Kanzlei selbst im eigenen Namen bei AWS angefragt werden, wird aber von AWS ausgestellt.

---

## TEIL 1 — Das AWS-Konto anlegen
*(ca. 5 Minuten — springen Sie zu Teil 2, falls Ihre Kanzlei bereits ein AWS-Konto hat)*

**Schritt 1.** Öffnen Sie Ihren Browser und tippen Sie oben in die Adresszeile:

> **aws.amazon.com**

**Schritt 2.** Klicken Sie oben rechts auf **„Create an AWS Account"** (orangefarbener Button). Sie landen auf einer Seite mit der Überschrift **„Sign up for AWS"**.

**Schritt 3.** Das Formular fragt nach einer **„Root user email address"**:
- Tragen Sie die Sammel-E-Mail-Adresse der Kanzlei ein (z. B. `aws@ihre-kanzlei.de`).
- ⚠️ **Keine private Adresse verwenden.** Wer diese E-Mail-Adresse kontrolliert, kontrolliert das Konto — sie sollte der Kanzlei gehören.
- In das Feld **„AWS account name"** tragen Sie z. B. **Ihre Kanzlei** ein.
- Klicken Sie auf den nächsten Button **„Verify email address"**.

**Schritt 4.** Prüfen Sie das E-Mail-Postfach. Amazon schickt einen **Bestätigungscode** (eine kurze Zahl). Tippen Sie ihn auf der Webseite ein. Kommt binnen 2 Minuten keine E-Mail, schauen Sie in den Spam-Ordner. Nach der Bestätigung erscheint die grüne Meldung *„It's you! Your email address has been successfully verified."*

**Schritt 5.** Nun erstellen Sie das **Passwort** („Create your password"):
- Wählen Sie ein langes, einzigartiges Passwort.
- 🔑 **Tragen Sie dieses Passwort sofort in den Passwort-Manager der Kanzlei ein** (oder notieren Sie es an einem sicheren Ort).
- Klicken Sie auf **Continue**.

**Schritt 6.** Kontoplan wählen („Choose your account plan"). Sie sehen zwei Kacheln: **Free (6 months)** und **Paid**.
- ✅ Wählen Sie **„Choose paid plan"**.
- *Warum nicht „Free"?* Der Free-Plan **schließt das Konto nach 6 Monaten automatisch**, wenn Sie nicht rechtzeitig umstellen, und umfasst nicht alle AWS-Dienste und für eine Kanzlei, die dauerhaft mit Claude arbeiten will, ist das die falsche Grundlage. Das Startguthaben (bis zu 200 $) erhalten Sie **in beiden Fällen**; beim Paid-Plan wird erst nach Verbrauch des Guthabens nach tatsächlicher Nutzung abgerechnet („pay-as-you-go").

**Schritt 7.** Zahlungsdaten („Billing Information"):
- ℹ️ *Warum will Amazon das jetzt schon wissen?* Ohne hinterlegte Zahlungsmethode lassen sich die KI-Modelle nicht freischalten. Abgebucht wird noch nichts. Ihre Nutzung verbraucht zuerst das kostenlose Startguthaben.
- Tragen Sie die Firmenkreditkarte oder IBAN ein und füllen Sie die abgefragten Kontaktdaten aus (Name, Kanzleiname, Adresse).
- Haken setzen bei **„I have read and agree to the terms of the AWS Customer Agreement"**, falls abgefragt.
- Klicken Sie auf **Continue**.

**Schritt 8.** Identität per Telefon bestätigen:
- Geben Sie Ihre Mobilnummer an. Amazon schickt eine SMS (oder ruft an) mit einem Code. Tippen Sie den Code auf der Webseite ein.

**Schritt 9.** Sie sehen eine Bestätigungsseite. Klicken Sie auf **„Go to the AWS Management Console"** und melden Sie sich an:
- **„Root user"** auswählen
- E-Mail-Adresse aus Schritt 3 und Passwort aus Schritt 5 eingeben.

---

## TEIL 2 — Zwei kleine, aber wichtige Einstellungen
*(ca. 5 Minuten)*

### 2a. Das Konto mit Ihrem Telefon absichern (dringend empfohlen)

Damit kommt niemand allein mit dem Passwort ins Konto.

1. Klicken Sie **oben rechts** auf Ihren **Kontonamen**. Ein Menü klappt auf.
2. Klicken Sie auf **„Security credentials"**.
3. Suchen Sie den Abschnitt **„Multi-factor authentication (MFA)"** und klicken Sie **„Assign MFA device"**.
4. Vergeben Sie einen beliebigen Namen (z. B. „kanzlei-handy"), wählen Sie **„Authenticator app"** und klicken Sie auf Next.
5. Installieren Sie auf einem Kanzlei-Handy — falls noch nicht vorhanden — eine kostenlose Authenticator-App (z. B. **Google Authenticator** oder **Microsoft Authenticator**, aus dem normalen App-Store).
6. Tippen Sie in der App auf **„+"** / „QR-Code scannen" und halten Sie die Handykamera auf den quadratischen Code am Bildschirm.
7. Die App zeigt nun 6-stellige Zahlen, die alle 30 Sekunden wechseln. Die Webseite verlangt **zwei davon hintereinander** (eine eintippen, auf die nächste warten, diese auch eintippen). Klicken Sie **„Add MFA"**.

Ab jetzt braucht die Anmeldung das Passwort **plus** die aktuelle Zahl von diesem Handy. Bewahren Sie das Handy sicher auf.

### 2b. Die Region auf Frankfurt stellen

AWS betreibt Rechenzentren auf der ganzen Welt. Alles soll in **Europa (Frankfurt)** stattfinden.

1. Schauen Sie **oben rechts**, direkt links neben Ihrem Kontonamen. Dort steht ein Ortsname (z. B. „N. Virginia" oder „Ireland"). Klicken Sie darauf.
2. Eine Liste von Weltregionen öffnet sich. Klicken Sie auf **„Europe (Frankfurt)"** — daneben steht der Code **eu-central-1**.

✅ **Zwischenstand:** Oben rechts steht jetzt **Frankfurt** (oder eu-central-1). Sollte dort während dieser Anleitung jemals etwas anderes stehen: Anklicken und wieder Frankfurt wählen.

---

## TEIL 3 — Die automatische Einrichtung ausführen
*(ca. 10 Minuten, überwiegend Wartezeit)*

Jetzt kommt der clevere Teil. Statt sich durch Dutzende Einstellungen zu klicken, laden Sie eine **fertige Einrichtungsdatei** herunter (sie liegt in diesem Repository).

**Schritt 1.** Ganz oben auf der AWS-Seite, in der Werkzeugleiste, suchen Sie ein kleines Symbol, das wie ein **Bildschirm mit `>_` darin** aussieht. Es sitzt in der Nähe der Suchleiste und des Notifcations Symbol. Im Zweifel mit der Maus über die Symbole fahren — das richtige heißt **„CloudShell"**.
Klicken Sie es an.

**Schritt 2.** Die untere Bildschirmhälfte wird zu einem schwarzen (bzw. dunklen) Fenster mit Text. Das nennt man ein *Terminal* — eine Art, dem Computer schriftliche Befehle zu geben. Der Start dauert etwa 30 Sekunden. Warten Sie, bis eine Zeile erscheint, die mit einem **`$`**-Zeichen und einem blinkenden Cursor endet.

> 😌 *Keine Sorge, hier können Sie nichts kaputt machen. Das Schlimmste, was passieren kann, ist eine Fehlermeldung, und diese Anleitung sagt Ihnen jeweils, was dann zu tun ist.*

**Schritt 3.** Laden Sie die Einrichtungsdatei herunter: **[hier klicken, um bedrock-bootstrap.sh zu öffnen](bedrock-bootstrap.sh)** (öffnet sich auf dieser Webseite). Auf der Seite, die sich öffnet, finden Sie **oben rechts am Kasten der Datei** ein **Download-Symbol (kleiner Pfeil nach unten ⤓)** — beim Draufzeigen erscheint **„Download raw file"**. Klicken Sie es an. Die Datei landet in Ihrem **Downloads**-Ordner.

**Schritt 4.** Wechseln Sie zurück zum Browser-Tab mit dem dunklen Fenster. **Oben rechts am dunklen Fenster** gibt es ein kleines Menü namens **„Actions"**. Klicken Sie darauf, dann auf **„Upload file"**. Ein Fenster öffnet sich — klicken Sie **„Browse"** (bzw. „Select file"), wählen Sie `bedrock-bootstrap.sh` aus dem Downloads-Ordner und bestätigen Sie. Kurz darauf erscheint **„File upload successful"**.

**Schritt 5.** Kopieren Sie diese kurze Zeile (mit der Maus markieren, dann **Strg+C** unter Windows / **Cmd+C** am Mac):

```
bash bedrock-bootstrap.sh
```

Klicken Sie einmal in das dunkle Fenster, fügen Sie die Zeile ein (**Strg+V** unter Windows — falls das nichts bewirkt: **Umschalt+Strg+V** — bzw. **Cmd+V** am Mac) und drücken Sie **Enter**. Die Einrichtung startet.

**Schritt 6.** Die Einrichtung stellt Ihnen nacheinander zwei Fragen. Tippen Sie die Antwort und drücken Sie jeweils Enter:
- **„Company name:"** → der offizielle Name der Kanzlei (z. B. `Mustermann Rechtsanwälte GmbH`)
- **„Company website:"** → die Webseite der Kanzlei, beginnend mit https:// (z. B. `https://www.mustermann-recht.de`)

*(Warum? Anthropic — das Unternehmen hinter Claude — verlangt von jedem Geschäftskunden einmalig die Angabe, wer er ist und wofür die KI genutzt wird. Das ist genau dieses Formular.)*

**Schritt 7.** Nun läuft Text durch, während die Einrichtung sechs Schritte abarbeitet. Jeder erledigte Schritt zeigt ein grünes **✓**. Verständlich übersetzt passiert Folgendes:

1. Das einmalige Formular wird eingereicht ✓
2. **Berufsgeheimnis-Prüfung:** Es wird sichergestellt, dass „Invocation Logging" — eine Funktion, die Nachrichteninhalte aufzeichnen würde — **überall in Europa ausgeschaltet** ist (und ggf. ausgeschaltet) ✓
3. Ein abgeschotteter „technischer Benutzer" wird angelegt, der ausschließlich mit Claude sprechen darf, sonst keine Zugriffe in Ihrem Konto hat.
4. Ein **API-Key** wird erzeugt, mit dem sich Claude Desktop später authentifiziert.✓
5. Eine winzige Testnachricht an das Modell schaltet die Abrechnung frei ✓
6. Ihre fertige Konfiguration wird ausgegeben ✓

⏳ **Schritt 5 der Einrichtung kann unterbrochen werden.** Bei einem brandneuen Konto kann die Modell-Freischaltung bis zu 15 Minuten dauern. Die Einrichtung wartet und versucht es selbstständig erneut — lassen Sie das Fenster einfach offen.

✅ **Zwischenstand:** Am Ende sehen Sie einen Kasten wie diesen im Output der Cloud-Shell Konsole:

```
════════════════════════════════════════════════════
  COPY THE JSON BELOW INTO YOUR COWORK 3P CONFIGURATION
════════════════════════════════════════════════════
{
  "provider": "bedrock",
  "awsRegion": "eu-central-1",
  ...
  "awsBearerToken": "ABSK...............",
  ...
}
════════════════════════════════════════════════════
```

Dieser Textblock zwischen den Linien ist Ihre Konfiguration. Der lange Code, der mit **ABSK** beginnt, ist der geheime API-Key.

Falls der API-Key je verloren geht: kein Drama, Teil 3 wiederholen (herunterladen, hochladen, ausführen), und Sie erhalten einen neuen.

---

## TEIL 4 — Die Konfiguration in Claude Desktop eintragen
*(ca. 3 Minuten)*

1. Öffnen Sie die **Claude-Desktop**-App.
2. In der **Menüleiste** ganz oben: **Help → Troubleshooting → Enable Developer mode**.
3. In der Menüleiste erscheint ein neues Menü **Developer**. Klicken Sie **Developer → Configure third-party inference**.
4. Wählen Sie **Bedrock** als Anbieter („Choose where Claude Desktop sends inference requests"). Der Bereich **„BEDROCK CREDENTIALS"** öffnet sich.
5. Füllen Sie die Felder mit den Werten aus Ihrem gesicherten Textblock:

| Feld in Claude Desktop | Was eintragen |
|---|---|
| **AWS region** | `eu-central-1` |
| **Bedrock base URL** | **leer** lassen |
| **Bedrock service tier** | so lassen („on-demand") |
| **Credential kind** | **„Static API key"** aus der Liste wählen |
| **AWS bearer token** | den langen `ABSK...`-Code einfügen (der Wert `awsBearerToken`) |

6. ⚠️ Achten Sie beim Einfügen des Schlüssels darauf, dass davor und danach kein Leerzeichen steht und er nicht auf zwei Zeilen verteilt wurde. Er muss eine durchgehende Zeichenkette sein.
7. Scrollen Sie nun zum Abschnitt **MODELS** (unterhalb der Zugangsdaten) und stellen Sie ihn so ein:
   - **Model discovery:** Schalter **AUS** (der Schalter muss grau sein, nicht blau).
   - **Model list:** auf **„+ Add model"** klicken und exakt eintragen:
     ```
     eu.anthropic.claude-opus-4-8
     ```
8. Klicken Sie **„Test connection"** (oben rechts im Zugangsdaten-Bereich).

✅ **Zwischenstand:** Ein grüner Balken erscheint, etwa: **„Inference — 1-token completion in … ms · via static key"**. Claude ist verbunden. 🎉

Bleibt der Test rot, hilft der Abschnitt „Wenn etwas schiefgeht" am Ende.

---

## TEIL 5 — Die Zusatzvereinbarung für Berufsgeheimnisträger bei AWS anfordern

**Dieser Schritt ist für Kanzleien und andere Berufsgeheimnisträger (§ 203 StGB) wichtig — und liegt in der Verantwortung Ihrer Kanzlei.** Die technische Einrichtung in Teil 3 beantragt diese Vereinbarung **nicht** für Sie. AWS bietet deutschen Berufsgeheimnisträgern eine besondere vertragliche Zusatzvereinbarung an (die *„Zusatzvereinbarung für Berufsgeheimnisträger"*). Sie ist kostenlos, wird aber **nicht** automatisch Vertragsbestandteil — Sie müssen sie **im Namen der Kanzlei** beim AWS-Kundenservice anfordern. Das ist üblicherweise unproblematisch. Für die Compliance-Dokumentation Ihrer Kanzlei sollte sie unterzeichnet vorliegen, **bevor** Mandatsinhalte verarbeitet werden.


---

## Den API-Key regelmäßig erneuern

Aus Sicherheitsgründen ist der API-Key nur **30 Tage** gültig — wie ein Zertifikat, das abläuft. Danach läuft dieser ab und muss erneuert werden. 

Wenn es so weit ist: bei AWS anmelden → prüfen, dass oben rechts Frankfurt steht → CloudShell öffnen → die Einrichtungsdatei erneut über den Link in Teil 3, Schritt 3 herunterladen und per **„Actions → Upload file"** hochladen → `bash bedrock-bootstrap.sh` einfügen → die neue Konfiguration in Claude Desktop eintragen (Teil 4).

Das ist die ganze Erneuerung. Fünf Minuten.

---

## Falls Sie sofort den API-Key deaktivieren müssen

Wird ein Laptop gestohlen oder besteht der Verdacht, dass der Schlüssel in falsche Hände geraten ist, können Sie ihn binnen Sekunden abschalten:

1. Bei AWS anmelden, **CloudShell** öffnen (Teil 3, Schritte 1–2).
2. Diese Zeile einfügen und Enter drücken:
   ```
   aws iam list-service-specific-credentials --user-name cowork-bedrock --service-name bedrock.amazonaws.com
   ```
   Sie sehen einen kleinen Textblock, der eine ID enthält, die mit **ACCA** beginnt.
3. Diesen ACCA-Code kopieren, dann diese Zeile einfügen und den Platzhalter am Ende durch den Code ersetzen:
   ```
   aws iam delete-service-specific-credential --user-name cowork-bedrock --service-specific-credential-id ACCA-CODE-HIER
   ```
4. Fertig — der Schlüssel funktioniert ab sofort nicht mehr. Alles andere in Ihrem Konto bleibt unberührt. Für einen neuen Schlüssel einfach Teil 3 wiederholen.

---

## Wenn etwas schiefgeht

**„Im dunklen Fenster erscheint ‚AccessDeniedException' während Schritt 5 der Einrichtung."**
Die Abrechnungsfreischaltung läuft noch (bis zu 15 Minuten bei der ersten Nutzung). 15 Minuten warten, dann erneut `bash bedrock-bootstrap.sh` einfügen und Enter drücken. Beliebig oft wiederholbar, völlig unbedenklich.

**„Die Einrichtung meldet, das Formular sei fehlgeschlagen (‚Form submission failed')."**
Einmal von Hand erledigen: In der AWS-Suchleiste **Bedrock** eintippen, öffnen, im linken Menü **„Chat / Text playground"** anklicken, ein beliebiges Claude-Modell wählen — es erscheint ein Formular mit Fragen zu Ihrem Unternehmen. Ausfüllen, absenden, dann erneut `bash bedrock-bootstrap.sh` einfügen und Enter drücken.

**„Test connection in Claude Desktop bleibt rot."**
Die drei häufigsten Ursachen, in dieser Reihenfolge:
1. Der API-Key wurde mit einem zusätzlichen Leerzeichen oder Zeilenumbruch eingefügt — löschen und noch einmal sorgfältig einfügen.
2. Im Feld „AWS region" steht nicht exakt `eu-central-1`.
3. Schritt 5 der Einrichtung hat nie ein grünes ✓ gezeigt — Teil 3 wiederholen und darauf achten.

**„Beim Modell erscheint eine Fehlermeldung über ‚AWS Marketplace' / ‚Subscribe'."**
Das gewählte Modell wurde noch nicht freigeschaltet. Prüfen Sie, dass im Abschnitt MODELS exakt `eu.anthropic.claude-opus-4-8` eingetragen ist (Teil 4, Schritt 7). Falls ja: Teil 3 wiederholen (der Lauf schaltet das Modell frei) und ca. 5 Minuten warten.

**„AWS meldet ein Zahlungsproblem."**
In der AWS-Suchleiste **Billing** eintippen, **„Payment preferences"** öffnen und prüfen, ob die Zahlungsdaten gültig sind.


---

## Berufsgeheimnis (§ 203 StGB) — was diese Einrichtung leistet und was nicht

Für die Kanzleiakten, und für alle, die nachfragen:

**Was geschützt ist:**

- **Sämtliche Verarbeitung bleibt in der Europäischen Union.** Die Einrichtung nutzt AWS' europäisches „Geo"-Routing: Ihre Anfragen werden in EU-Rechenzentren verarbeitet (Frankfurt und, bei hoher Auslastung, andere EU-Standorte wie Irland oder Paris) — niemals außerhalb der EU.
- **Nachrichteninhalte werden weder protokolliert noch gespeichert.** Amazon Bedrock bewahrt weder Eingaben noch Antworten auf und verwendet Ihre Inhalte nicht zum Training von KI-Modellen. Die Einrichtung prüft zusätzlich, dass die optionale Funktion „Invocation Logging" — die Prompts aufzeichnen *würde* — in **jeder EU-Region ausgeschaltet** ist.
- **Niemand in der Kanzlei kann die Inhaltsprotokollierung mit dem Claude-Schlüssel versehentlich einschalten.** Dem technischen Benutzer hinter dem API-Key ist das Ändern der Protokollierungseinstellungen ausdrücklich *verboten* (nicht bloß „nicht erlaubt").
- **Der API-Key kann genau eines:** Nachrichten an Claude-Modelle senden (plus Modellnamen abrufen). Er kann keine Dateien lesen, keine anderen Amazon-Dienste nutzen, keine Einstellungen ändern und nichts anderes kostenpflichtig auslösen.

