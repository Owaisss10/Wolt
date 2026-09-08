# Wolt iOS App

A native iOS application that fetches and displays nearby Wolt venues, built with **Swift and UIKit** with a focus on clean architecture, networking, persistence, and testability.

> A small, production-oriented iOS implementation demonstrating how a location-aware restaurant discovery experience can be structured from API layer to UI.

## ✨ Features

* 📍 Fetches restaurants/venues based on the user's location
* 🍔 Displays nearby Wolt venues in a clean list interface
* 🌐 Communicates with the Wolt restaurant API
* 💾 Persists restaurant data locally using Core Data
* 🖼️ Asynchronously loads restaurant images
* ⚡ Handles loading, empty, and error states
* 🧩 Separates networking, services, persistence, models, and UI concerns
* 🧪 Includes unit tests for core application logic and response models

## 🛠 Tech Stack

| Technology         | Usage                        |
| ------------------ | ---------------------------- |
| **Swift**          | Primary programming language |
| **UIKit**          | User interface               |
| **Core Data**      | Local persistence            |
| **URLSession**     | Networking                   |
| **JSON / Codable** | API response parsing         |
| **XCTest**         | Unit testing                 |
| **Xcode**          | Development environment      |

## 🏗 Architecture

The project is structured into separate layers to keep responsibilities isolated and make the application easier to maintain and test.

```text
Wolt
├── Model
│   ├── RestaurantsResponse.swift
│   └── Errors
│
├── Networking
│   ├── Networking.swift
│   └── NetworkImageView.swift
│
├── Persistence
│   └── Core Data
│
├── Services
│   ├── RestaurantsService.swift
│   ├── RestaurantsServiceError.swift
│   └── ImageLoaderService.swift
│
├── Screens
│   ├── Welcome
│   └── VenueList
│
├── View
├── Extensions
├── Utilities
│
└── WoltTests
    ├── WoltTests.swift
    └── RestaurantResponseModelTests.swift
```

The main flow can be summarized as:

```text
User
  │
  ▼
Venue List UI
  │
  ▼
Restaurants Service
  │
  ├──────────────► Networking
  │                    │
  │                    ▼
  │                 Wolt API
  │
  ▼
Persistence
  │
  ▼
Core Data
```

This separation keeps API communication and persistence independent from the view layer and makes the individual components easier to test and evolve.

## 🚀 Getting Started

### Requirements

* macOS
* Xcode
* iOS Simulator or a physical iOS device
* A valid Wolt API endpoint/configuration used by the project

### Clone the repository

```bash
git clone https://github.com/Owaisss10/Wolt.git
cd Wolt
```

### Open the project

Open:

```text
Wolt.xcodeproj
```

in Xcode.

Select an iOS Simulator or connected device and run the application with:

```text
⌘ + R
```

## 🧪 Testing

The project includes an XCTest target covering application logic and restaurant response models.

Run the test suite from Xcode:

```text
⌘ + U
```

Tests are located in:

```text
WoltTests/
├── WoltTests.swift
└── RestaurantResponseModelTests.swift
```

## 📡 Networking

Networking is encapsulated behind dedicated networking and service layers rather than being performed directly inside view controllers.

The restaurant service is responsible for retrieving venue data and exposing application-level results to the UI.

This keeps the UI independent of the underlying HTTP implementation and makes the service layer easier to mock or replace.

## 💾 Persistence

Restaurant data is backed by **Core Data**, allowing the application to maintain locally persisted venue information.

The persistence layer is kept separate from the networking and presentation layers, providing a clear boundary between remote data and locally stored data.

## 🖼 Image Loading

Restaurant images are loaded asynchronously through a dedicated `ImageLoaderService`.

The project also includes a reusable `NetworkImageView`, keeping image-loading concerns out of individual screens and views.

## 🎯 Engineering Focus

This project was designed with particular attention to:

* Separation of concerns
* Reusable services
* Testable business logic
* Clear networking boundaries
* Local persistence
* Error handling
* Maintainable UIKit code
* Simple and understandable project structure

The goal is not to reproduce the complete Wolt application, but to demonstrate how a focused restaurant-discovery experience can be implemented as a maintainable native iOS application.

## 📁 Project Structure

### `Model`

Contains the application's data models and error definitions used when decoding and processing restaurant responses.

### `Networking`

Contains the lower-level networking implementation and reusable network image functionality.

### `Services`

Provides application-level services such as restaurant fetching and image loading.

### `Persistence`

Contains Core Data related functionality and the local restaurant data model.

### `Screens`

Contains the main application flows, including the welcome experience and venue list.

### `View`

Contains reusable UI components used throughout the application.

### `WoltTests`

Contains unit tests covering application behavior and model parsing.

## 🔮 Possible Improvements

Some natural next steps for the project would be:

* Add dependency injection for networking and persistence
* Introduce protocol-based abstractions for easier mocking
* Add UI tests for the main user flows
* Improve offline-first behavior
* Add pagination or incremental loading
* Add image caching
* Introduce a more formal MVVM presentation layer
* Add accessibility improvements
* Add CI using Xcode Cloud or GitHub Actions
* Expand test coverage around networking and persistence failures

## 📄 License

This project is intended as a technical demonstration and learning project.

---

**Built with Swift & UIKit 🇫🇮**
