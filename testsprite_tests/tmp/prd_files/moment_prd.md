# Moment Product Requirements Document (PRD)

## 1. Ziele und Hintergrundkontext

### Ziele

*   Eine erfolgreiche Pilotphase in den Partner-Locations (Bar & Eventfirma) durchführen.
*   Eine Adoptionsrate von über 50 % der Gäste bei den Pilot-Events erreichen.
*   Das Geschäftsmodell für Veranstalter (z. B. Lizenzgebühr) validieren.
*   Eine hohe Teilnahmequote (>70 %) am "Moment"-Feature sicherstellen.
*   Soziale Hürden für Nutzer spürbar reduzieren und die Kontaktaufnahme erleichtern.

### Hintergrundkontext

In sozialen Live-Situationen wie Bars oder auf Konzerten scheitert die Kontaktaufnahme oft an der anfänglichen Hürde, eine fremde Person anzusprechen. Dies führt zu verpassten Gelegenheiten. "Moment" schließt diese Lücke, indem es einen exklusiven, sicheren und zeitlich begrenzten digitalen Raum für die Anwesenden schafft. Durch die Kombination eines Event-Check-ins, einer temporären Kontaktliste und eines einzigartigen, KI-gestützten "Moment"-Features zur Erstellung geteilter Erinnerungen, wird nicht nur die Interaktion gefördert, sondern auch ein starker Anreiz zur Teilnahme und zum Teilen geschaffen.

### Change Log

| Datum      | Version | Beschreibung              | Autor |
| :--------- | :------ | :------------------------ | :---- |
| 2025-07-17 | 1.0     | Initialer Entwurf des PRD | John  |

## 2. Anforderungen

### Funktionale Anforderungen (FR)

1.  **FR1:** Der Nutzer muss einen Account mit seinem Namen und einem Selfie erstellen können.
2.  **FR2:** Der Nutzer muss optional seinen Instagram-Benutzernamen in seinem Profil hinterlegen können.
3.  **FR3:** Der Nutzer muss sich bei einem Event durch das Scannen eines QR-Codes einchecken können.
4.  **FR4:** Das System muss beim Check-in den Standort des Nutzers überprüfen (Geo-Fencing), um sicherzustellen, dass er sich physisch am Veranstaltungsort befindet.
5.  **FR5:** Nach einem erfolgreichen Check-in muss dem Nutzer eine Liste aller anderen aktuell bei diesem Event eingecheckten Nutzer angezeigt werden.
6.  **FR6:** Die Event-Liste muss für den Nutzer nur für eine vordefinierte, begrenzte Zeit (z. B. 24 Stunden) zugänglich sein.
7.  **FR7:** Der Nutzer muss in der Event-Liste durch eine **Swipe-Rechts-Bewegung** auf einem Profil Interesse signalisieren ("Liken") können. Eine **Swipe-Links-Bewegung** verwirft das Profil für diese Sitzung.
8.  **FR8:** Wenn zwei Nutzer sich gegenseitig liken, wird dies als "Match" im System vermerkt.
9.  **FR9:** Der Nutzer muss durch ein **Tippen (Tap)** auf ein Profil in der Event-Liste direkt zu dem hinterlegten Instagram-Profil des jeweiligen Nutzers weitergeleitet werden.
10. **FR10:** Die App muss zu einem festgelegten Zeitpunkt einen synchronisierten Countdown für alle eingecheckten Nutzer anzeigen.
11. **FR11:** Nach dem Countdown muss die App die Aufnahme eines Fotos mit der Front- und Rückkamera initiieren.
12. **FR12:** Das System muss die aufgenommenen Fotos aller teilnehmenden Nutzer serverseitig zu einer dynamischen Foto-Collage zusammenfügen.

### Nicht-funktionale Anforderungen (NFR)

1.  **NFR1:** Die Anwendung muss als native iOS-App mit Swift entwickelt werden.
2.  **NFR2:** Das Backend-System muss in der Lage sein, die Lastspitzen während der Check-in-Phasen und des "Moment"-Features ohne signifikante Latenz zu bewältigen.
3.  **NFR3:** Alle Nutzerdaten, insbesondere Selfies und Social-Media-Kennungen, müssen unter strikter Einhaltung der DSGVO verarbeitet werden. Eine explizite Zustimmung des Nutzers zur Datenverarbeitung ist für die Nutzung der App zwingend erforderlich.
4.  **NFR4:** Der Onboarding- und Check-in-Prozess muss so einfach und schnell sein, dass er in unter 60 Sekunden abgeschlossen werden kann, um eine hohe Akzeptanz am Veranstaltungsort zu gewährleisten.
5.  **NFR5:** Die Cloud-Infrastruktur soll, wo immer möglich, auf kosteneffiziente, serverlose Komponenten setzen, um die Betriebskosten zu minimieren.
6.  **NFR6:** Der Check-in-Prozess muss robust gegen einfache Fälschungsversuche (z. B. das Teilen eines Screenshots des QR-Codes) geschützt sein.

## 3. User Interface Design Goals

### Overall UX Vision

Die User Experience muss schnell, intuitiv und aufregend sein. Der Fokus liegt auf der Minimierung von Reibung bei der Kontaktaufnahme und der Maximierung des "Wow-Faktors" beim "Moment"-Feature. Die App soll sich wie ein natürlicher Teil des Event-Erlebnisses anfühlen, nicht wie eine separate, aufdringliche Anwendung. Die Interaktionen sollen spielerisch und direkt sein, um die Hemmschwelle für soziale Interaktionen zu senken.

### Key Interaction Paradigms

*   **Listen-Interaktion:** Die zentrale Event-Liste wird durch vertikales Scrollen navigiert. Horizontales Swipen (links/rechts) dient der primären Bewertungsaktion (Liken/Verwerfen), während ein Tippen (Tap) die sekundäre Aktion (Profil-Detail/Weiterleitung) auslöst.
*   **Der "Moment":** Diese Interaktion wird durch einen bildschirmfüllenden, synchronisierten Countdown eingeleitet, der ein Gefühl der Dringlichkeit und Gemeinschaft erzeugt. Die Aufnahme selbst ist ein "One-Shot"-Ereignis, um die Authentizität zu wahren.

### Core Screens and Views

*   **Onboarding/Login:** Minimalistische Ansicht zur Account-Erstellung und zum Login.
*   **Event Check-in:** Eine einfache Kamera-Ansicht zum Scannen des QR-Codes.
*   **Event-Liste:** Die Hauptansicht nach dem Check-in, die die Profile der anderen Gäste als scrollbare Karten oder Kacheln darstellt.
*   **"Moment"-Ansicht:** Eine bildschirmfüllende Ansicht für den Countdown und die Kameraaufnahme.
*   **Content-Ansicht:** Eine Ansicht zur Darstellung der generierten "Moment"-Collage.

### Accessibility: WCAG AA

Die App soll den WCAG 2.1 Level AA Standards entsprechen, um eine breite Nutzbarkeit zu gewährleisten. Dies beinhaltet ausreichende Farbkontraste, klare Touch-Ziele und Unterstützung für Screenreader.

### Branding

*   **Annahme:** Da noch kein explizites Branding definiert ist, streben wir ein modernes, klares und dunkles Design an ("Dark Mode"), das gut zur Atmosphäre von Bars, Clubs und Konzerten passt. Akzentfarben sollten lebendig sein, um Aktionen wie Matches oder Benachrichtigungen hervorzuheben. Die visuelle Identität soll Vertrauen und einen Hauch von Exklusivität vermitteln.

### Target Device and Platforms: Mobile Only

Die Anwendung wird ausschließlich für Apple iOS (iPhone) entwickelt und muss für alle gängigen iPhone-Modelle der letzten 3-4 Jahre optimiert sein.

## 4. Technische Annahmen

### Repository Structure: Polyrepo

*   **Rationale:** Da wir eine native iOS-App und ein separates Backend entwickeln, bietet sich eine Polyrepo-Struktur an. Dies ermöglicht eine saubere Trennung der Technologien, Build-Prozesse und Abhängigkeiten zwischen dem Frontend (iOS-App) und dem Backend (Serverless-Dienste).

### Service Architecture: Serverless

*   **Rationale:** Die Nutzung der App wird stark eventbasiert sein, mit extremen Lastspitzen während der Check-in- und "Moment"-Phasen und sehr geringer Last dazwischen. Eine serverlose Architektur (z. B. mit AWS Lambda oder Google Cloud Functions) ist hierfür ideal. Sie skaliert automatisch bei Bedarf und ist in den Ruhephasen äußerst kosteneffizient, was perfekt zu NFR5 (Kosteneffizienz) passt.

### Testing Requirements: Unit + Integration

*   **Rationale:** Um eine hohe Qualität und Stabilität zu gewährleisten, ist eine zweistufige Teststrategie erforderlich.
    *   **Unit-Tests:** Jede einzelne Funktion und UI-Komponente wird isoliert getestet.
    *   **Integrationstests:** Das Zusammenspiel zwischen der App und den Backend-Services (z. B. der Check-in-Prozess, das Hochladen der Fotos) wird durch dedizierte Tests überprüft.

### Additional Technical Assumptions and Requests

*   **Echtzeit-Kommunikation:** Für den synchronisierten Countdown des "Moment"-Features (FR10) wird ein Echtzeit-Kommunikationsprotokoll wie WebSockets oder ein vergleichbarer Dienst (z. B. AWS IoT Core, Google Firebase Realtime Database) benötigt, um die Latenz zu minimieren.
*   **Bildverarbeitung:** Die serverseitige Erstellung der Foto-Collage (FR12) erfordert eine dedizierte Bildverarbeitungsbibliothek (z. B. Sharp für Node.js) oder einen spezialisierten Cloud-Dienst (z. B. AWS Lambda Layer für Bildverarbeitung), um die Fotos effizient zu bearbeiten und zusammenzufügen.
*   **Datenschutz durch Technik:** Die GPS-Daten der Nutzer (FR4) dürfen ausschließlich für die Check-in-Validierung verwendet und dürfen unter keinen Umständen dauerhaft gespeichert oder mit dem Nutzerprofil verknüpft werden.

## 5. Epic-Struktur

### Epic List

*   **Epic 1: Fundament & Kernprofil**
    *   **Ziel:** Aufbau der grundlegenden App-Struktur, des Backend-Setups und der Kernfunktionalität für die Nutzerprofilerstellung und den sicheren Check-in. Nach diesem Epic haben wir eine funktionierende Basis, auf der alles Weitere aufbaut.
*   **Epic 2: Die Event-Liste & Soziale Interaktion**
    *   **Ziel:** Implementierung der zentralen Funktion der App – der Anzeige der temporären Event-Liste und der Möglichkeit zur Interaktion (Swipen, Weiterleitung zu Instagram). Nach diesem Epic ist der Kern-Loop der sozialen Kontaktaufnahme vollständig funktionsfähig.
*   **Epic 3: Der kollektive "Moment"**
    *   **Ziel:** Implementierung des Alleinstellungsmerkmals – des synchronisierten Foto-Events und der serverseitigen Erstellung der finalen Foto-Collage. Nach diesem Epic ist das MVP vollständig und liefert den vollen, einzigartigen Wert für Nutzer und Veranstalter.

### Epic 1: Fundament & Kernprofil

**Ziel:** Dieses Epic legt das gesamte technische und funktionale Fundament der Anwendung. Es umfasst die Ersteinrichtung des Projekts, die Möglichkeit für Nutzer, einen Account zu erstellen und zu verwalten, sowie den sicheren Check-in-Prozess für ein Event. Nach Abschluss dieses Epics hat ein Nutzer eine vollständige, testbare Kernfunktionalität zur Verfügung, die ihn von der Installation der App bis zum erfolgreichen Eintritt in ein Event führt.

#### Story 1.1: Nutzer-Onboarding und Profilerstellung

> **As a** new user,
> **I want** to create a simple profile with my name, a selfie, and my Instagram handle,
> **so that** I can join events and other users know who I am.

##### Acceptance Criteria

1.  Der Nutzer kann seinen Vornamen in ein Textfeld eingeben.
2.  Der Nutzer kann die App-Kamera öffnen, um ein Selfie als Profilbild aufzunehmen.
3.  Der Nutzer kann optional seinen Instagram-Benutzernamen in ein separates Feld eintragen.
4.  Vor dem Speichern des Profils muss der Nutzer den Datenschutzbestimmungen (DSGVO) explizit zustimmen.
5.  Nach dem Speichern werden die Profildaten (Name, Foto-URL, Instagram-Handle) sicher im Backend gespeichert.
6.  Der Nutzer wird nach der erfolgreichen Erstellung seines Profils automatisch in der App angemeldet.

#### Story 1.2: Sicherer Event-Check-in

> **As a** registered user,
> **I want** to scan a QR-code at a venue and have my location verified,
> **so that** I can securely check into an event and gain access to the exclusive guest list.

##### Acceptance Criteria

1.  Der Nutzer kann eine "Check-in"-Funktion in der App starten, die die Kamera öffnet.
2.  Die App fordert beim Start des Check-in-Vorgangs die Berechtigung zur Standortermittlung an.
3.  Beim Scannen eines QR-Codes werden die Code-Informationen und die aktuellen GPS-Koordinaten des Geräts an das Backend gesendet.
4.  Das Backend validiert, ob der QR-Code für das Event gültig ist UND ob sich die GPS-Koordinaten innerhalb eines vordefinierten Radius (z. B. 100 Meter) um den Veranstaltungsort befinden.
5.  Bei erfolgreicher Validierung wird der Nutzer im System als "eingecheckt" für dieses spezifische Event markiert.
6.  Bei ungültigem Code oder wenn der Nutzer zu weit entfernt ist, wird eine klare und verständliche Fehlermeldung angezeigt.

#### Story 1.3: Platzhalter-Ansicht nach Check-in

> **As a** checked-in user,
> **I want** to be navigated to a confirmation screen after a successful check-in,
> **so that** I know I am successfully part of the event.

##### Acceptance Criteria

1.  Unmittelbar nach dem erfolgreichen Check-in (gemäß Story 1.2) wird der Nutzer auf eine neue Ansicht weitergeleitet.
2.  Diese Ansicht zeigt den Namen des Events an (z. B. "Willkommen im 'Club Fusion'").
3.  Die Ansicht enthält einen Platzhaltertext, der anzeigt, dass hier die Event-Liste erscheinen wird (z. B. "Die Gästeliste wird geladen...").
4.  Diese Ansicht ist der definierte Endpunkt für den Flow in Epic 1 und dient als Ausgangspunkt für Epic 2.

### Epic 2: Die Event-Liste & Soziale Interaktion

**Ziel:** Dieses Epic implementiert die zentrale Funktion der App: die Anzeige der temporären Event-Liste. Es ermöglicht den Nutzern, die Profile anderer anwesender Gäste zu sehen und auf intuitive Weise mit ihnen zu interagieren, um die Kontaktaufnahme über Instagram zu erleichtern. Nach Abschluss dieses Epics ist der primäre soziale Kreislauf der App – vom Sehen über das Bewerten bis zur potenziellen Kontaktaufnahme – vollständig funktionsfähig.

#### Story 2.1: Anzeige der Event-Teilnehmerliste

> **As a** checked-in user,
> **I want** to see a list of profiles of all other guests who are currently checked into the same event,
> **so that** I can discover who else is there.

##### Acceptance Criteria

1.  Die Platzhalter-Ansicht aus Story 1.3 wird durch eine dynamische Liste ersetzt.
2.  Die App ruft vom Backend die Liste aller Nutzer ab, die für das aktuelle Event eingecheckt sind.
3.  Jeder Eintrag in der Liste zeigt mindestens das Profilbild (Selfie) und den Vornamen des Nutzers.
4.  Die Liste ist vertikal scrollbar, falls mehr Nutzer vorhanden sind, als auf den Bildschirm passen.
5.  Die eigene Person wird nicht in der Liste angezeigt.
6.  Die Liste wird in einer vordefinierten, zufälligen Reihenfolge geladen, um Fairness zu gewährleisten.

#### Story 2.2: Interaktive Profil-Bewertung (Swipen)

> **As a** user viewing the event list,
> **I want** to swipe right on profiles I find interesting and left on others,
> **so that** I can quickly sort the list and signal my interest.

##### Acceptance Criteria

1.  Die Profile in der Liste (aus Story 2.1) reagieren auf horizontale Swipe-Gesten.
2.  Ein Swipe nach rechts wird im System als "Like" für das entsprechende Profil gespeichert.
3.  Ein Swipe nach links verwirft das Profil; es wird für die Dauer der Eventsession nicht erneut in der Hauptliste angezeigt.
4.  Die Interaktion (Like/Dislike) wird asynchron an das Backend gesendet.
5.  Die UI gibt ein subtiles visuelles Feedback für die Swipe-Aktion (z. B. leichte Neigung der Karte).
6.  Nach einem Swipe wird das nächste Profil in der Liste ohne Verzögerung angezeigt.

#### Story 2.3: Weiterleitung zu Instagram

> **As a** user viewing the event list,
> **I want** to tap on a profile to be taken directly to their Instagram page,
> **so that** I can easily connect with them outside of the app.

##### Acceptance Criteria

1.  Ein Tippen (Tap) auf ein beliebiges Profil in der Liste löst eine Aktion aus.
2.  Wenn für das angetippte Profil ein Instagram-Benutzername hinterlegt ist, öffnet die App die Instagram-App (falls installiert) oder den Browser und navigiert zur entsprechenden Profilseite (`instagram.com/username`).
3.  Wenn für das angetippte Profil kein Instagram-Benutzername hinterlegt ist, passiert nichts oder es wird ein dezenter Hinweis angezeigt (z. B. "Kein Instagram-Profil hinterlegt").
4.  Die Aktion wird auch für Profile ausgelöst, die bereits nach links oder rechts geswiped wurden.

### Epic 3: Der kollektive "Moment"

**Ziel:** Dieses Epic implementiert das Alleinstellungsmerkmal der App. Es schafft ein gemeinsames, synchronisiertes Erlebnis für alle Event-Teilnehmer und produziert einen einzigartigen, teilbaren Inhalt, der den "Vibe" des Events einfängt. Nach Abschluss dieses Epics ist das MVP vollständig und liefert den maximalen Wert für Nutzer und Veranstalter, indem es nicht nur die Kontaktaufnahme erleichtert, sondern auch eine bleibende, kollektive Erinnerung schafft.

#### Story 3.1: Synchronisierter "Moment"-Countdown

> **As a** checked-in user,
> **I want** to receive a notification and see a synchronized countdown in the app,
> **so that** I know it's time to participate in the collective "Moment".

##### Acceptance Criteria

1.  Das Backend kann zu einem festgelegten Zeitpunkt einen "Moment"-Event für eine Veranstaltung auslösen.
2.  Alle bei diesem Event eingecheckten und aktiven App-Nutzer sehen einen bildschirmfüllenden Countdown (z. B. von 10 Sekunden).
3.  Die Synchronisation des Countdowns über die Geräte hinweg wird durch eine Echtzeit-Verbindung zum Server (z. B. WebSockets) sichergestellt.
4.  Nutzer, die die App im Hintergrund haben, erhalten eine Push-Benachrichtigung, die sie zur Teilnahme auffordert.
5.  Der Countdown ist prominent und unmissverständlich gestaltet.

#### Story 3.2: Dual-Kamera-Aufnahme

> **As a** user participating in the "Moment",
> **I want** the app to take a photo with my front and back camera simultaneously when the countdown ends,
> **so that** a complete picture of me and my surroundings is captured.

##### Acceptance Criteria

1.  Wenn der Countdown aus Story 3.1 null erreicht, löst die App die Kameras aus.
2.  Es wird gleichzeitig (oder in sehr schneller Abfolge) ein Bild von der Frontkamera und ein Bild von der Rückkamera aufgenommen.
3.  Die aufgenommenen Bilder werden nach der Aufnahme zur Bestätigung kurz angezeigt.
4.  Nach der Bestätigung (oder automatisch nach einer kurzen Verzögerung) werden beide Bilder sicher an das Backend hochgeladen.
5.  Der Upload-Prozess ist robust und wird bei einer vorübergehenden Unterbrechung der Netzwerkverbindung fortgesetzt.

#### Story 3.3: Erstellung und Anzeige der "Moment"-Collage

> **As a** user who participated in the "Moment",
> **I want** to see the final, combined photo-collage from the event,
> **so that** I can see the collective memory we created and share it.

##### Acceptance Criteria

1.  Das Backend sammelt alle hochgeladenen Bilder eines "Moment"-Events.
2.  Nach einer festgelegten Zeit (z. B. 15 Minuten nach dem Event) startet ein serverseitiger Prozess, der die Bilder verarbeitet.
3.  Die Bilder (Vorder- und Rückkameras) werden zu einer einzigen, großen Foto-Collage in einem vordefinierten Raster-Layout zusammengefügt.
4.  Sobald die Collage fertig ist, erhalten alle Teilnehmer eine Push-Benachrichtigung.
5.  Die finale Collage kann in einer dedizierten Ansicht in der App betrachtet werden.
6.  Der Nutzer hat die Möglichkeit, die Collage in seiner Handy-Galerie zu speichern oder über die nativen Share-Funktionen von iOS zu teilen.

## 6. Nächste Schritte

### UX Expert Prompt

> **An Sally (UX Expert):** Bitte erstelle auf Basis dieses PRD das detaillierte UI/UX Specification Document (`front-end-spec.md`). Konzentriere dich dabei besonders auf die in Abschnitt 3 definierten "User Interface Design Goals" und die Interaktionsmuster aus den User Stories (z. B. Swipen/Tippen). Definiere die User Flows für die drei Epics und erarbeite eine konsistente visuelle Sprache, die zum "Dark Mode"-Ansatz passt.

### Architect Prompt

> **An Winston (Architect):** Bitte erstelle auf Basis dieses PRD das umfassende Architecture Document (`architecture.md`). Die technologischen Leitplanken sind in Abschnitt 4, "Technische Annahmen", definiert (Polyrepo, Serverless, Swift-nativ). Deine Aufgabe ist es, eine robuste, skalierbare und kosteneffiziente Architektur für die Backend-Dienste, die Datenbank, die Echtzeit-Kommunikation und die serverseitige Bildverarbeitung zu entwerfen, die alle funktionalen und nicht-funktionalen Anforderungen erfüllt.

## 7. Checklist Results Report

### Executive Summary

Das Product Requirements Document wurde anhand der PM-Master-Checkliste validiert und hat eine **Gesamtbewertung von 100 %** erreicht. Der MVP-Umfang ist klar definiert und angemessen. Alle Anforderungen sind logisch strukturiert und auf die Geschäfts- und Nutzerziele ausgerichtet. Es wurden keine kritischen Lücken oder Blocker identifiziert.

**Final Decision: READY FOR ARCHITECT & UX EXPERT**

### Category Statuses

| Category                         | Status | Critical Issues                                       |
| :------------------------------- | :----- | :---------------------------------------------------- |
| 1. Problem Definition & Context  | ✅ PASS | None                                                  |
| 2. MVP Scope Definition          | ✅ PASS | None                                                  |
| 3. User Experience Requirements  | ✅ PASS | None                                                  |
| 4. Functional Requirements       | ✅ PASS | None                                                  |
| 5. Non-Functional Requirements   | ✅ PASS | None                                                  |
| 6. Epic & Story Structure        | ✅ PASS | None                                                  |
| 7. Technical Guidance            | ✅ PASS | None                                                  |
| 8. Cross-Functional Requirements | ✅ PASS | None                                                  |
| 9. Clarity & Communication       | ✅ PASS | None                                                  |

### Critical Deficiencies

*   Keine kritischen Mängel festgestellt.

### Recommendations

*   **Empfehlung:** Während der Architekturphase sollten die nicht-funktionalen Anforderungen (NFRs) bezüglich System-Verfügbarkeit und Backup-Strategien weiter konkretisiert werden. Dies ist jedoch kein Blocker für den nächsten Schritt.