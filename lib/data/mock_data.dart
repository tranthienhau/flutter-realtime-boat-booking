import '../models/models.dart';

/// Demo "today". Fixed so screenshots and tests are deterministic.
final kToday = DateTime(2026, 10, 1);

/// The trip the demo walks through: Lagoon 380, Sat 17 Oct.
final kTripDay = DateTime(2026, 10, 17);

const kGuestName = 'Olivia Hart';

String img(String name) => 'assets/images/$name.jpg';

final kDestinations = <Destination>[
  Destination(
      id: 'fiji', name: 'Fiji', country: 'Fiji', image: img('dest-fiji'), boatCount: 24, region: 'Mamanuca Islands'),
  Destination(
      id: 'bali', name: 'Bali', country: 'Indonesia', image: img('dest-bali'), boatCount: 31, region: 'Bali + Lombok'),
  Destination(
      id: 'singapore',
      name: 'Singapore',
      country: 'Singapore',
      image: img('dest-singapore'),
      boatCount: 18,
      region: 'One15 Marina, Sentosa'),
  Destination(
      id: 'palawan',
      name: 'Palawan',
      country: 'Philippines',
      image: img('dest-palawan'),
      boatCount: 12,
      region: 'MIMAROPA, Sulu Sea'),
  Destination(
      id: 'tahiti',
      name: 'Tahiti',
      country: 'French Polynesia',
      image: img('dest-tahiti'),
      boatCount: 9,
      region: 'Society Islands'),
  Destination(
      id: 'maldives',
      name: 'Maldives',
      country: 'Maldives',
      image: img('dest-maldives'),
      boatCount: 15,
      region: 'North Male Atoll'),
  Destination(
      id: 'phuket',
      name: 'Phuket',
      country: 'Thailand',
      image: img('dest-phuket'),
      boatCount: 21,
      region: 'Phang Nga Bay'),
  Destination(
      id: 'whitsundays',
      name: 'Whitsundays',
      country: 'Australia',
      image: img('dest-whitsundays'),
      boatCount: 16,
      region: 'Coral Sea, QLD'),
];

Destination destinationById(String id) => kDestinations.firstWhere((d) => d.id == id, orElse: () => kSydney);

final kSydney = Destination(
    id: 'sydney',
    name: 'Sydney Harbour',
    country: 'Australia',
    image: img('boat-prometheus-cool'),
    boatCount: 22,
    region: 'NSW');

final kBoats = <Boat>[
  Boat(
    id: 'lagoon380',
    name: 'Lagoon 380 - 4 cab.',
    kind: BoatKind.catamaran,
    destinationId: 'whitsundays',
    operator: 'Dream Yacht Charter',
    location: 'Airlie Beach, Whitsundays',
    image: img('boat-lagoon380-hero'),
    source: SyncSource.nausys,
    capacity: 10,
    pricePerGuest: 360,
    currency: 'A\$',
    rating: 4.88,
    reviews: 126,
    lengthM: 11.6,
    cabins: 4,
    berths: 8,
    year: 2019,
    description:
        'A stable, roomy sailing catamaran for sunset sails around Whitsunday Passage. Shaded flybridge, swim platform, snorkel gear and a local skipper on board.',
  ),
  Boat(
    id: 'blue-horizon',
    name: 'Blue Horizon',
    kind: BoatKind.catamaran,
    destinationId: 'whitsundays',
    operator: 'Coral Sea Charters',
    location: 'Abell Point Marina',
    image: img('boat-blue-horizon'),
    source: SyncSource.nausys,
    capacity: 10,
    pricePerGuest: 330,
    currency: 'A\$',
    rating: 4.7,
    reviews: 88,
    lengthM: 12.4,
    cabins: 4,
    berths: 8,
    year: 2021,
    description: 'Modern 40ft catamaran with a wide saloon, ideal for small groups exploring Whitehaven Beach.',
  ),
  Boat(
    id: 'prometheus',
    name: 'Prometheus Cool',
    kind: BoatKind.motorYacht,
    destinationId: 'sydney',
    operator: 'Marine Yachts',
    location: 'Sydney Harbour, NSW',
    image: img('boat-prometheus-cool'),
    source: SyncSource.ankor,
    capacity: 12,
    pricePerGuest: 1450,
    currency: 'A\$',
    rating: 4.95,
    reviews: 61,
    lengthM: 25.6,
    cabins: 3,
    berths: 6,
    year: 2022,
    description: 'An 84ft luxury motor yacht for harbour cruises, corporate events and New Year fireworks.',
  ),
  Boat(
    id: 'vedanta',
    name: 'Vedanta',
    kind: BoatKind.phinisi,
    destinationId: 'bali',
    operator: 'Archipelago Expeditions',
    location: 'Serangan Harbour, Bali',
    image: img('boat-vedanta-phinisi'),
    source: SyncSource.ankor,
    capacity: 12,
    pricePerGuest: 240,
    currency: 'A\$',
    rating: 4.98,
    reviews: 203,
    lengthM: 30,
    cabins: 5,
    berths: 10,
    year: 2018,
    description:
        'Handcrafted Indonesian phinisi schooner for day trips to Nusa Penida and overnight voyages to Komodo.',
  ),
  Boat(
    id: 'gili-express',
    name: 'Gili Express',
    kind: BoatKind.fastBoat,
    destinationId: 'bali',
    operator: 'Gili Fast Lines',
    location: 'Padang Bai, Bali',
    image: img('boat-gili-express'),
    source: SyncSource.manual,
    capacity: 24,
    pricePerGuest: 85,
    currency: 'A\$',
    rating: 4.5,
    reviews: 412,
    lengthM: 14,
    cabins: 0,
    berths: 0,
    year: 2020,
    description: 'Twice-daily fast boat transfer from Bali to the Gili Islands and Lombok.',
    skipperIncluded: true,
  ),
  Boat(
    id: 'lombok-sunset',
    name: 'Lombok Sunset Cruise',
    kind: BoatKind.catamaran,
    destinationId: 'bali',
    operator: 'Lombok Sunset Co.',
    location: 'Senggigi, Lombok',
    image: img('boat-lombok-sunset-cruise'),
    source: SyncSource.ankor,
    capacity: 16,
    pricePerGuest: 190,
    currency: 'A\$',
    rating: 4.8,
    reviews: 157,
    lengthM: 15,
    cabins: 2,
    berths: 4,
    year: 2017,
    description: 'Golden-hour catamaran cruise along the Senggigi coast with canapes and Champagne.',
  ),
  Boat(
    id: 'bali46',
    name: 'Bali 4.6',
    kind: BoatKind.catamaran,
    destinationId: 'bali',
    operator: 'Dream Yacht Charter',
    location: 'Benoa Marina, Bali',
    image: img('fleet-bali-46'),
    source: SyncSource.nausys,
    capacity: 8,
    pricePerGuest: 410,
    currency: 'A\$',
    rating: 4.9,
    reviews: 34,
    lengthM: 13.8,
    cabins: 4,
    berths: 8,
    year: 2023,
    description: 'Open-plan catamaran with a forward cockpit lounge.',
  ),
  Boat(
    id: 'lagoon400-palawan',
    name: 'Lagoon 400 - 4 cab.',
    kind: BoatKind.catamaran,
    destinationId: 'palawan',
    operator: 'Europa Yachts',
    location: 'El Nido, Palawan',
    image: img('fleet-lagoon'),
    source: SyncSource.nausys,
    capacity: 10,
    pricePerGuest: 420,
    currency: 'US\$',
    rating: 4.9,
    reviews: 72,
    lengthM: 12,
    cabins: 4,
    berths: 8,
    year: 2020,
    description: 'Island-hopping catamaran through the Bacuit Archipelago lagoons.',
  ),
  Boat(
    id: 'sulu-spirit',
    name: 'Sulu Spirit',
    kind: BoatKind.phinisi,
    destinationId: 'palawan',
    operator: 'Europa Yachts',
    location: 'Coron, Palawan',
    image: img('boat-lagoon380-anchored'),
    source: SyncSource.ankor,
    capacity: 12,
    pricePerGuest: 310,
    currency: 'US\$',
    rating: 4.85,
    reviews: 49,
    lengthM: 28,
    cabins: 5,
    berths: 10,
    year: 2016,
    description: 'Classic wooden sailing yacht for Coron reef and wreck tours.',
  ),
  Boat(
    id: 'island-hopper',
    name: 'Island Hopper',
    kind: BoatKind.fastBoat,
    destinationId: 'palawan',
    operator: 'Europa Yachts',
    location: 'El Nido, Palawan',
    image: img('fleet-superyacht'),
    source: SyncSource.manual,
    capacity: 18,
    pricePerGuest: 95,
    currency: 'US\$',
    rating: 4.6,
    reviews: 230,
    lengthM: 11,
    cabins: 0,
    berths: 0,
    year: 2019,
    description: 'Fast transfer between El Nido and Coron.',
  ),
  Boat(
    id: 'moana-nui',
    name: 'Moana Nui',
    kind: BoatKind.catamaran,
    destinationId: 'tahiti',
    operator: 'Tahiti Yacht Charter',
    location: 'Papeete Marina',
    image: img('dest-tahiti'),
    source: SyncSource.nausys,
    capacity: 12,
    pricePerGuest: 390,
    currency: 'A\$',
    rating: 4.8,
    reviews: 41,
    lengthM: 13.7,
    cabins: 4,
    berths: 8,
    year: 2021,
    description: 'Lagoon cruising around Tahiti and Moorea.',
  ),
  Boat(
    id: 'te-ava',
    name: 'Te Ava',
    kind: BoatKind.motorYacht,
    destinationId: 'tahiti',
    operator: 'Tahiti Yacht Charter',
    location: 'Bora Bora',
    image: img('boat-blue-horizon'),
    source: SyncSource.ankor,
    capacity: 12,
    pricePerGuest: 520,
    currency: 'A\$',
    rating: 4.9,
    reviews: 22,
    lengthM: 18,
    cabins: 3,
    berths: 6,
    year: 2022,
    description: 'Private motor yacht for Bora Bora lagoon tours.',
  ),
  Boat(
    id: 'bora-breeze',
    name: 'Bora Breeze',
    kind: BoatKind.catamaran,
    destinationId: 'tahiti',
    operator: 'Polynesia Sail',
    location: 'Raiatea',
    image: img('boat-lagoon380-anchored'),
    source: SyncSource.nausys,
    capacity: 12,
    pricePerGuest: 350,
    currency: 'A\$',
    rating: 4.7,
    reviews: 18,
    lengthM: 13,
    cabins: 4,
    berths: 8,
    year: 2019,
    description: 'Sailing catamaran for the Leeward Islands.',
  ),
  Boat(
    id: 'mamanuca-explorer',
    name: 'Mamanuca Explorer',
    kind: BoatKind.catamaran,
    destinationId: 'fiji',
    operator: 'South Pacific Charters',
    location: 'Port Denarau, Fiji',
    image: img('dest-fiji'),
    source: SyncSource.ankor,
    capacity: 14,
    pricePerGuest: 280,
    currency: 'A\$',
    rating: 4.8,
    reviews: 96,
    lengthM: 15,
    cabins: 4,
    berths: 8,
    year: 2020,
    description: 'Day sails to Cloud 9 and Monuriki.',
  ),
  Boat(
    id: 'one15-classic',
    name: 'One15 Classic',
    kind: BoatKind.motorYacht,
    destinationId: 'singapore',
    operator: 'One15 Marina Charters',
    location: 'Sentosa Cove',
    image: img('dest-singapore'),
    source: SyncSource.ankor,
    capacity: 20,
    pricePerGuest: 180,
    currency: 'S\$',
    rating: 4.7,
    reviews: 64,
    lengthM: 21,
    cabins: 2,
    berths: 4,
    year: 2018,
    description: 'Sunset cruise past the Southern Islands and the city skyline.',
  ),
  Boat(
    id: 'atoll-dream',
    name: 'Atoll Dream',
    kind: BoatKind.motorYacht,
    destinationId: 'maldives',
    operator: 'Atoll Voyages',
    location: 'North Male Atoll',
    image: img('dest-maldives'),
    source: SyncSource.nausys,
    capacity: 12,
    pricePerGuest: 640,
    currency: 'US\$',
    rating: 4.95,
    reviews: 27,
    lengthM: 24,
    cabins: 4,
    berths: 8,
    year: 2023,
    description: 'Sandbank picnics and manta snorkelling.',
  ),
  Boat(
    id: 'phang-nga-spirit',
    name: 'Phang Nga Spirit',
    kind: BoatKind.catamaran,
    destinationId: 'phuket',
    operator: 'Asia Global Yachting',
    location: 'Ao Po Grand Marina',
    image: img('dest-phuket'),
    source: SyncSource.ankor,
    capacity: 16,
    pricePerGuest: 210,
    currency: 'A\$',
    rating: 4.8,
    reviews: 118,
    lengthM: 14,
    cabins: 4,
    berths: 8,
    year: 2021,
    description: 'Limestone islands of Phang Nga Bay and James Bond Island.',
  ),
];

Boat boatById(String id) => kBoats.firstWhere((b) => b.id == id);

/// Slots every boat sells per day; the demo boat also sells a private charter.
const _slots = [('08:00', 'Half day', 4.0), ('13:30', 'Sunset', 3.5)];

String depId(String boatId, DateTime day, String time) =>
    '$boatId-${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}-${time.replaceAll(':', '')}';

List<Departure> buildDepartures() {
  final out = <Departure>[];
  for (final b in kBoats) {
    for (var i = 0; i < 92; i++) {
      final day = kToday.add(Duration(days: i));
      for (final s in _slots) {
        out.add(Departure(
            id: depId(b.id, day, s.$1),
            boatId: b.id,
            date: day,
            time: s.$1,
            label: s.$2,
            durationHours: s.$3,
            capacity: b.capacity));
      }
      if (b.id == 'lagoon380' || b.id == 'prometheus') {
        out.add(Departure(
            id: depId(b.id, day, '17:00'),
            boatId: b.id,
            date: day,
            time: '17:00',
            label: 'Private charter',
            durationHours: 3,
            capacity: b.capacity));
      }
    }
  }
  return out;
}

/// Deterministic starting occupancy, plus the hand-set departures the demo
/// relies on (last seats, sold out, fully booked Tahiti).
Map<String, int> buildInitialBooked(List<Departure> deps) {
  final m = <String, int>{};
  for (final d in deps) {
    final h = d.id.codeUnits.fold(7, (a, c) => (a * 31 + c) & 0x7fffffff) % 100;
    m[d.id] = (d.capacity * (h < 15 ? 1.0 : h / 140)).round();
  }
  void set(String boat, DateTime day, String time, int booked) => m[depId(boat, day, time)] = booked;

  // Lagoon 380 on the trip day: 6 left, 3 left (last seats), full.
  set('lagoon380', kTripDay, '08:00', 4);
  set('lagoon380', kTripDay, '13:30', 7);
  set('lagoon380', kTripDay, '17:00', 10);
  set('lagoon380', DateTime(2026, 10, 18), '13:30', 6);
  set('blue-horizon', kTripDay, '13:30', 5);
  // Next 7 days strip on boat detail.
  final week = [3, 7, 10, 9, 2, 10, 5];
  for (var i = 0; i < 7; i++) {
    final day = kToday.add(Duration(days: i));
    for (final t in ['08:00', '13:30', '17:00']) {
      set('lagoon380', day, t, week[i]);
    }
  }
  // Bali, Sat 18 Oct.
  set('vedanta', kTripDay, '08:00', 6);
  set('vedanta', kTripDay, '13:30', 6);
  set('gili-express', kTripDay, '08:00', 10);
  set('gili-express', kTripDay, '13:30', 14);
  set('lombok-sunset', kTripDay, '08:00', 16);
  set('lombok-sunset', kTripDay, '13:30', 12);
  set('bali46', kTripDay, '08:00', 0);
  // Today: Prometheus has 2 seats left, Island Hopper sold out.
  set('prometheus', kToday, '08:00', 12);
  set('prometheus', kToday, '13:30', 10);
  set('prometheus', kToday, '17:00', 12);
  set('island-hopper', kToday, '08:00', 18);
  set('island-hopper', kToday, '13:30', 18);
  set('lagoon400-palawan', kToday, '08:00', 7);
  set('lagoon400-palawan', kToday, '13:30', 9);
  set('sulu-spirit', kToday, '08:00', 4);
  // Tahiti: no boat fits 10 guests on Sun 18, some do on Mon 19 / Tue 20.
  final sun = DateTime(2026, 10, 18), mon = DateTime(2026, 10, 19), tue = DateTime(2026, 10, 20);
  for (final b in ['moana-nui', 'te-ava', 'bora-breeze']) {
    for (final t in ['08:00', '13:30']) {
      set(b, sun, t, 5);
      set(b, mon, t, b == 'te-ava' ? 6 : 1);
      set(b, tue, t, 0);
    }
  }
  return m;
}

/// Bookings the guest already had before the demo.
List<Booking> seededBookings() => [
      Booking(
          id: 'BTG-26-1105-2M8P',
          departureId: depId('vedanta', DateTime(2026, 11, 5), '08:00'),
          boatId: 'vedanta',
          guests: 4,
          total: 960,
          currency: 'A\$',
          holder: kGuestName,
          createdAt: DateTime(2026, 9, 12),
          status: BookingStatus.weatherWatch),
      Booking(
          id: 'BTG-26-1212-4H9X',
          departureId: depId('prometheus', DateTime(2026, 12, 12), '13:30'),
          boatId: 'prometheus',
          guests: 2,
          total: 2900,
          currency: 'A\$',
          holder: kGuestName,
          createdAt: DateTime(2026, 9, 20)),
    ];

const kNotifications = [
  AppNotification(
      kind: NotificationKind.weather,
      title: 'Weather cancellation - Vedanta',
      body: 'Thu 5 Nov. Strong winds forecast for the Lombok Strait. Full refund issued.',
      when: 'Thu 5 Nov',
      image: 'assets/images/boat-vedanta-phinisi.jpg'),
  AppNotification(
      kind: NotificationKind.seatOpened,
      title: 'A seat opened on Tahiti, Sun 18 Oct',
      body: 'Moana Nui - Papeete Coastal Cruise - 1 spot available',
      when: '2 min ago'),
  AppNotification(
      kind: NotificationKind.reminder,
      title: 'Reminder: Lagoon 380 tomorrow at 13:30',
      body: 'Boarding pass ready - Pier C, Airlie Beach',
      when: '1 h ago'),
  AppNotification(
      kind: NotificationKind.confirmed,
      title: 'Booking confirmed - email and SMS sent',
      body: 'Whitsundays Sunset Charter - 3 guests',
      when: '1 Oct'),
];
