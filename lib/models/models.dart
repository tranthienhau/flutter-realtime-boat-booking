/// Domain models for Boatingo.
///
/// Inventory is modelled per departure (boat + date + time slot) because that is
/// the unit operators sell and the unit that must never be overbooked.
library;

enum SyncSource { nausys, ankor, manual }

extension SyncSourceLabel on SyncSource {
  String get label => switch (this) {
        SyncSource.nausys => 'Nausys',
        SyncSource.ankor => 'Ankor',
        SyncSource.manual => 'Manual',
      };
}

enum BoatKind { catamaran, motorYacht, phinisi, fastBoat, sailingYacht }

extension BoatKindLabel on BoatKind {
  String get label => switch (this) {
        BoatKind.catamaran => 'Catamaran',
        BoatKind.motorYacht => 'Motor yacht',
        BoatKind.phinisi => 'Traditional phinisi',
        BoatKind.fastBoat => 'Fast boat',
        BoatKind.sailingYacht => 'Sailing yacht',
      };
}

class Destination {
  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.image,
    required this.boatCount,
    required this.region,
  });

  final String id;
  final String name;
  final String country;
  final String image;
  final int boatCount;
  final String region;
}

class Boat {
  const Boat({
    required this.id,
    required this.name,
    required this.kind,
    required this.destinationId,
    required this.operator,
    required this.location,
    required this.image,
    required this.source,
    required this.capacity,
    required this.pricePerGuest,
    required this.currency,
    required this.rating,
    required this.reviews,
    required this.lengthM,
    required this.cabins,
    required this.berths,
    required this.year,
    required this.description,
    this.skipperIncluded = true,
  });

  final String id;
  final String name;
  final BoatKind kind;
  final String destinationId;
  final String operator;
  final String location;
  final String image;
  final SyncSource source;
  final int capacity;
  final int pricePerGuest;
  final String currency;
  final double rating;
  final int reviews;
  final double lengthM;
  final int cabins;
  final int berths;
  final int year;
  final String description;
  final bool skipperIncluded;
}

class Departure {
  const Departure({
    required this.id,
    required this.boatId,
    required this.date,
    required this.time,
    required this.label,
    required this.durationHours,
    required this.capacity,
  });

  final String id;
  final String boatId;
  final DateTime date;
  final String time;
  final String label;
  final double durationHours;
  final int capacity;
}

class SeatHold {
  SeatHold({
    required this.id,
    required this.departureId,
    required this.seats,
    required this.holder,
    required this.expiresAt,
  });

  final String id;
  final String departureId;
  final int seats;
  final String holder;
  final DateTime expiresAt;
}

enum BookingStatus { confirmed, weatherWatch, cancelled, weatherCancelled }

class Booking {
  Booking({
    required this.id,
    required this.departureId,
    required this.boatId,
    required this.guests,
    required this.total,
    required this.currency,
    required this.holder,
    required this.createdAt,
    this.status = BookingStatus.confirmed,
  });

  final String id;
  final String departureId;
  final String boatId;
  final int guests;
  final int total;
  final String currency;
  final String holder;
  final DateTime createdAt;
  BookingStatus status;
}

enum InventoryEventKind { held, released, booked, cancelled, blocked, unblocked, expired }

class InventoryEvent {
  const InventoryEvent(this.kind, this.departureId, this.seats, this.source);

  final InventoryEventKind kind;
  final String departureId;
  final int seats;
  final String source;
}

enum NotificationKind { weather, seatOpened, reminder, confirmed }

class AppNotification {
  const AppNotification({
    required this.kind,
    required this.title,
    required this.body,
    required this.when,
    this.image,
  });

  final NotificationKind kind;
  final String title;
  final String body;
  final String when;
  final String? image;
}
