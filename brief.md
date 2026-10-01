# Boatingo - Source Brief

## Title
Boatingo - Real-time Boat Charter Booking

## Description
Boatingo is a mobile marketplace for booking yachts, sailing catamarans, traditional phinisi boats and fast-boat transfers across Asia Pacific. Guests browse destinations such as Bali, Palawan, Fiji, Tahiti and the Whitsundays, search by date and party size, and see only boats that still have space. Availability comes live from the operators' own charter systems, so the seat counts a guest sees are the seat counts that exist. When a guest picks a departure, the app holds their seats for ten minutes while they pay; if the card is declined or the timer runs out the seats go straight back on sale, and if another guest takes the last seats first the app says so clearly, charges nothing and offers the closest alternatives. After booking, guests get a unique booking reference by email and SMS, can manage or cancel the trip (cancelled seats return to inventory instantly) and receive weather or operational cancellation alerts. Charter agents get an operator console showing feed health, today's fleet capacity and a switch to block a boat from all listings.

## Store links
Not yet published (proof of concept).

## Platform
Both - iOS and Android from one Flutter codebase.

## Category
Travel

## Features
- Destination discovery with live boat counts and featured charters
- Search by destination, date and guests, filtered to boats with enough seats
- Fully booked state with nearby dates that still have space
- Boat profiles with specs, ratings and a 7-day availability strip
- Departure picker: month calendar (available / limited / full) and time slots with seats left
- Live sync indicators per listing (Nausys, Ankor, manual calendars)
- Ten-minute seat hold with countdown during checkout
- Automatic release of seats on declined payment or hold timeout
- Last-seat race handling: exactly one booking wins, the other guest is not charged and sees live alternatives
- Unique booking references (BTG-YY-MMDD-XXXX) with email and SMS confirmation
- My trips (upcoming / past), booking detail with itinerary, skipper and meeting point
- Cancellation with refund breakdown, seats returned to sale instantly
- Weather and operational cancellation notifications
- Operator console: feed status, fleet capacity, overbooking counter, block / unblock a boat
- Empty states for search and trips

## Tech stack
- Flutter 3.44 / Dart 3 for iOS and Android
- flutter_riverpod 2.6 for state (Notifier + StreamProvider)
- Availability engine in pure Dart: per-departure inventory, seat holds with expiry, atomic hold / confirm / release / cancel, event stream for live UI
- intl for dates and currency
- Bundled Montserrat and Playfair Display fonts, bundled imagery
- flutter_test unit tests for the inventory rules; integration_test driving the real app for screenshots
- Google Stitch design system (graphite + brass)

## Industry
Marine tourism, yacht and boat charter, travel booking

## Metrics
Unpublished proof of concept, so no store ratings or downloads. Scope: 18 screens, 17 boats across 9 destinations, about 3 months of departures, 10 inventory unit tests including a 500-operation concurrency test with zero overbookings.

## Research notes
- Verified in tests: last seat cannot be double-booked, seats leave sale at hold time, declined payment and hold timeout release seats, cancellation releases seats instantly, blocked boats show zero availability, booking IDs stay unique across 10,000 bookings, and concurrent load never exceeds capacity.
- Mocked: Nausys and Ankor feeds are simulated in-app (timed polls that push remote bookings and cancellations through the same engine); payments, email and SMS are simulated; boats, operators, prices and ratings are fixture data.
- The demo's "lost the last seat" moment is a scripted remote booking arriving in the same instant as the guest's hold, resolved by the real engine.
- Future expansion: real Nausys / Ankor API connectors with webhooks, server-side inventory with transactional seat holds, Stripe payments, push notifications, multi-currency pricing, operator web portal, offline-safe booking passes.
