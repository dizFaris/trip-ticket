# trip-ticket

Seminarski rad iz predmeta Razvoj softvera II

## Upute za pokretanje

Nakon kloniranja repozitorija uraditi sljedeće:

- **Extractovati:** `fit-build-2025-08-24-env`
- **Postaviti `.env` fajl u:** `\tripTicket\tripTicket`
- **Otvoriti `\tripTicket\tripTicket` u terminalu i pokrenuti komandu: `docker compose up --build`**

Prije korištenja aplikacije pročitati napomene koje se mogu pronaći u ovom readme-u:

- **Extractovati:** `fit-build-2025-08-24-desktop`
- **Pokrenuti** `tripticket_desktop.exe` koji se nalazi u folderu "Release"
- **Unijeti desktop kredencijale** koji se mogu pronaći u ovom readme-u

- Prije pokretanja mobilne aplikacije pobrinuti se da aplikacija već ne postoji na Android emulatoru; ukoliko postoji, uraditi deinstalaciju iste
- **Extractovati:** `fit-build-2025-08-24-mobile`
- Nakon extractovanja, prevući `.apk` fajl koji se nalazi u folderu "flutter-apk" i sačekati da se aplikacija instalira
- Nakon što je aplikacija instalirana, pokrenuti je i unijeti mobilne kredencijale koji se mogu pronaći u ovom readme-u

## Napomene

- Novi korisnik koji se registruje inicijalno neće imati preporuka u "For you" sekciji na mobilnoj aplikaciji. Tek nakon što kupi karte za putovanje će dobiti preporuke.
- Korisnička narudžba se smatra završenom onda kada je administrator aktivira. Aktivacija podrazumijeva unošenje ID narudžbe u formi za aktivaciju na desktop aplikaciji (što je zamišljeno da se u maloprodaji radi skeniranjem QR koda). Tom prilikom administratoru se pruža opcija da isprinta karte za putovanje. Karte se mogu isprintati samo jednom. Administrator ima opciju da ih isprinta naknadno, a dugme za print se nalazi u detaljima narudžbe. Iz tog razloga imamo prikazan ID narudžbe u detaljima, prema kojem također radimo filtriranje.
- Statistike uzimaju u obzir samo narudžbe sa statusom COMPLETE i EXPIRED jer su to statusi na kojima je iznos zarade finalan
- Samo korisnik koji je kupio karte za neko putovanje može ostaviti recenziju na isto, i to tek nakon što je to putovanje završeno.
- Administrator prilikom pregleda završenih putovanja (status COMPLETE) može pristupiti i recenzijama tog putovanja. Neželjene recenzije se mogu ukloniti.
- Ikone zastava odgovaraju stvarnim kodovima zemalja
- Sve notifikacije unutar aplikacije se šalju **isključivo putem e-maila.**

## Kredencijali

### Desktop aplikacija

#### Administrator

- **Korisničko ime:** `admin`
- **Lozinka:** `Test123!`

### Mobilna aplikacija

#### Korisnik

- **Korisničko ime:** `test`
- **Lozinka:** `Test123!`

### Stripe

- **Broj kartice:** `4242 4242 4242 4242`
- **Datum isteka:** `12/34` (proizvoljno)
- **CVC:** `123` (proizvoljno)
- **ZIP Code:** `12345` (proizvoljno)

## RabbitMQ

- **RabbitMQ** je korišten za slanje mailova korisnicima za obavještenje o akcijama koje se dešavaju na njegovoj narudžbi.
- Salje se u slučaju da je narudžba prihvaćena, otkazana, istekla ili završena.
- Također se u slučaju otvaranja support tiketa, administratorski odgovor šalje korisniku putem maila.
