# LittleCakesNLOrderBook

Welcome to **LittleCakesNLOrderBook**! This app is designed to streamline order management for your bakery, making it easier to handle customer submissions, track orders, and manage events. With features like calendar integration, automatic data fetching from the Fillout API, and submission management, LittleCakesNLOrderBook helps you stay organized and efficient.test

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Technical Overview](#technical-overview)

## Features

- **Order Management**: View and manage customer submissions with detailed order information.
- **Calendar Integration**: Automatically save submission dates to your device's calendar.
- **Firebase Integration**: Store and fetch submissions using Firebase Firestore for secure data management.
- **Customizable Backend**: Easily switch between development and release configurations using environment variables.
- **Rich Media Support**: Display images, files, and text submissions with seamless user experience.
- **Secure**: Supports secure data handling practices without user authentication.

## Installation

To run this app on your local machine, follow these steps:

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/LittleCakesNLOrderBook.git
cd LittleCakesNLOrderBook
```

## Usage
To use the app, simply run it on the simulator or your device:

- Select a Target: Choose either a simulator or a connected device from the Xcode toolbar.
- Build and Run: Click the “Run” button in Xcode or press Cmd + R.

## Features

- View Submissions: Browse through the list of customer submissions.
- Manage Orders: Confirm orders and add events to your calendar.
- Calendar Integration: Automatically save order dates to your device’s calendar for better tracking.

## Technical Overview
The app is built using SwiftUI:

- SwiftUI: For building a declarative user interface.
- Firebase Firestore: To store and fetch submission data.
- Environment Variables: Manage development and release configurations using .env files.
- AsyncImage: Handles asynchronous image loading and caching.
