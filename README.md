# Boatingo - Real-time Boat Charter Booking (Flutter)

Book yachts, catamarans and fast boats across Asia Pacific with **live availability**. Inventory from operator systems (Nausys, Ankor, manual calendars) flows into one availability engine that holds seats during payment, releases them on failure or timeout, puts cancelled seats straight back on sale, and **never overbooks** - even when two guests go for the last seat at the same moment.

Flutter + Riverpod, iOS + Android from one codebase, designed first in Google Stitch.

## Demo

| iOS | Android |
|---|---|
| ![iOS demo](screenshots/demo.gif) | ![Android demo](screenshots/demo-android.gif) |

Same codebase running on both platforms (iPhone 17 Pro simulator, Pixel 7a).

## What it shows

- **Live availability everywhere** - every listing carries a pulsing "Live - synced from Nausys 8s ago" pill. Nausys / Ankor feeds push bookings and cancellations in the background and the UI updates without a refresh.
- **Search only shows boats with space** - pick destination, date and party size; "Only show boats with space" filters by real seats left per departure. A fully booked date shows nearby dates that still have capacity.
- **Departure picker** - month calendar with available / limited / full dots, time slots with "6 of 10 seats left", guest steppers.
- **Seat hold with countdown** - holding seats removes them from sale for 10 minutes. Declined card or timeout releases them instantly.
- **Last-seat race (RTB-001)** - in the demo a Nausys booking arrives for the same last seats in the same instant. The engine lets exactly one through; the guest sees "No seats available", is not charged, and gets live alternatives.
- **Unique booking IDs** (`BTG-YY-MMDD-XXXX`) plus email + SMS confirmation.
- **Manage + cancel** - cancellation shows the refund and returns seats to inventory in real time.
- **Weather / operational cancellation** alerts with refund status.
- **Operator console** - feed health per source, today's fleet capacity, "0 overbookings" counter, and a block toggle that removes a boat from every listing immediately.

## Screenshots (iOS)

| | | |
|---|---|---|
| **Onboarding** | **Sign in** | **Explore** |
| ![Onboarding](screenshots/01-onboarding.png) | ![Sign in](screenshots/02-sign-in.png) | ![Explore](screenshots/03-explore.png) |
| **Destination** | **Search (only boats with space)** | **Fully booked state** |
| ![Destination](screenshots/04-destination.png) | ![Search (only boats with space)](screenshots/05-search.png) | ![Fully booked state](screenshots/06-search-empty.png) |
| **Boat detail + 7-day strip** | **Live departure picker** | **Lost the last seat (RTB-001)** |
| ![Boat detail + 7-day strip](screenshots/07-boat-detail.png) | ![Live departure picker](screenshots/08-availability.png) | ![Lost the last seat (RTB-001)](screenshots/09-last-seat-taken.png) |
| **Checkout with 10:00 seat hold** | **Confirmed + unique booking ID** | **My trips** |
| ![Checkout with 10:00 seat hold](screenshots/10-checkout-hold.png) | ![Confirmed + unique booking ID](screenshots/11-booking-confirmed.png) | ![My trips](screenshots/12-my-trips.png) |
| **Booking detail** | **Cancel = seats back on sale** | **Weather cancellation alert** |
| ![Booking detail](screenshots/13-booking-detail.png) | ![Cancel = seats back on sale](screenshots/14-cancel-booking.png) | ![Weather cancellation alert](screenshots/15-notifications.png) |
| **Operator console** | **Profile** | **No trips yet** |
| ![Operator console](screenshots/16-operator-console.png) | ![Profile](screenshots/17-profile.png) | ![No trips yet](screenshots/18-my-trips-empty.png) |

### Android (Pixel 7a)

| | | | | | |
|---|---|---|---|---|---|
| ![Onboarding](screenshots/android-01-onboarding.png) | ![Sign in](screenshots/android-02-sign-in.png) | ![Explore](screenshots/android-03-explore.png) | ![Destination](screenshots/android-04-destination.png) | ![Search (only boats with space)](screenshots/android-05-search.png) | ![Fully booked state](screenshots/android-06-search-empty.png) |
| ![Boat detail + 7-day strip](screenshots/android-07-boat-detail.png) | ![Live departure picker](screenshots/android-08-availability.png) | ![Lost the last seat (RTB-001)](screenshots/android-09-last-seat-taken.png) | ![Checkout with 10:00 seat hold](screenshots/android-10-checkout-hold.png) | ![Confirmed + unique booking ID](screenshots/android-11-booking-confirmed.png) | ![My trips](screenshots/android-12-my-trips.png) |
| ![Booking detail](screenshots/android-13-booking-detail.png) | ![Cancel = seats back on sale](screenshots/android-14-cancel-booking.png) | ![Weather cancellation alert](screenshots/android-15-notifications.png) | ![Operator console](screenshots/android-16-operator-console.png) | ![Profile](screenshots/android-17-profile.png) | ![No trips yet](screenshots/android-18-my-trips-empty.png) |

## Flow

```mermaid
flowchart TD
    A[Onboarding] --> B[Sign in]
    B --> C[Explore]
    C --> D[Destination]
    C --> E[Search: date + guests]
    E -->|no boat fits| E2[Fully booked: nearby dates]
    D --> F[Boat detail]
    E --> F
    F --> G[Choose departure: live seats left]
    G -->|Hold seats| H{Availability engine}
    N[Nausys / Ankor feeds] -->|remote bookings + cancellations| H
    H -->|seats held 10:00| I[Checkout]
    H -->|someone took the last seats| J[No seats available + live alternatives]
    J --> I
    I -->|payment ok| K[Confirmed: BTG booking ID, email + SMS]
    I -->|declined or timeout| G
    K --> L[My trips]
    L --> M[Booking detail]
    M --> O[Cancel: seats back on sale]
    O --> H
    P[Operator console] -->|block boat| H
```

## Architecture

```
lib/
  engine/availability_engine.dart  # seat inventory: hold, confirm, release, cancel, block, remote bookings
  models/models.dart               # Boat, Departure, SeatHold, Booking, InventoryEvent, SyncSource
  data/mock_data.dart              # 17 boats, 8 destinations, 3 months of departures
  state/providers.dart             # Riverpod: engine, live tick, sync feeds, search, checkout, bookings
  screens/                         # 18 screens matching the Stitch design
  widgets/common.dart              # pill buttons, cards, Live pill, seats chip, tab bar
  theme/app_theme.dart             # graphite + brass tokens, Montserrat + Playfair Display
design/                            # Stitch screens (HTML + PNG), DESIGN.md, logo
test/availability_engine_test.dart # inventory rules as unit tests
integration_test/                  # drives the real app on device
```

**Availability engine.** Inventory is tracked per departure (boat + date + slot). Seats left = `capacity - booked - held (unexpired)`. Every mutation is one synchronous critical section, so two requests for the last seat are serialized and exactly one wins. On a backend the same rule is a single conditional `UPDATE ... WHERE seats_left >= :n` inside a transaction, with holds as rows carrying an expiry. Remote bookings from Nausys / Ankor go through the same hold + confirm path, so operator-side and in-app guests compete fairly. Every change is published on an event stream that drives the live UI and an audit trail.

**Tested rules** (`flutter test`):

| Test | Rule |
|---|---|
| RTB-001 | Two simultaneous requests for the last seat: one succeeds, one gets "No seats available", final booked = capacity |
| Search | Departures with fewer seats than the party are hidden |
| Confirm | Availability drops at hold time and stays down after payment |
| Payment failure | Seats return to sale |
| Timeout | Expired holds release seats and cannot be confirmed |
| Cancellation | Seats are released instantly and an event is emitted; double cancel is a no-op |
| Admin block | Blocked boat shows 0 seats and rejects holds |
| Remote bookings | Operator feed bookings compete for the same seats |
| Booking IDs | 10,000 bookings, all unique |
| Load | 500 concurrent hold / pay / cancel operations never exceed capacity |

## Run

```sh
flutter pub get
flutter run            # pick an iOS simulator or Android device
flutter test           # availability engine rules
```

`--dart-define=LIVE_FEED=false` turns off the simulated operator feeds.

## Stack

Flutter 3.44, Dart 3, flutter_riverpod 2.6, intl. Fonts bundled (Montserrat, Playfair Display). All imagery bundled locally.
