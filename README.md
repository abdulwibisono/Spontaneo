# Spontaneo

Spontaneo is an iOS application designed to facilitate spontaneous social activities and connections. This README provides an overview of the project structure, setup instructions, and usage guidelines.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Features](#features)
3. [Project Structure](#project-structure)
4. [Setup Instructions](#setup-instructions)
5. [Usage](#usage)
6. [Dependencies](#dependencies)
7. [Contributing](#contributing)

## Project Overview

Spontaneo is a social platform that allows users to create, join, and manage spontaneous activities in their local area. The app includes features such as real-time activity discovery, in-app messaging, user profiles, and a reward system.

## Features

- User authentication (sign up, login, logout)
- Activity creation and management
- Real-time activity discovery with map integration
- In-app messaging for activity participants
- User profiles with customization options
- Reward system for active users
- Category-based activity filtering
- Nearby activity notifications

## Project Structure

The Spontaneo project consists of the following main components:

- **Spontaneo**: The main iOS app target
- **Spontaneo Watch Watch App**: A companion watchOS app

Key files and directories:

- [`SpontaneoApp.swift`](Spontaneo/SpontaneoApp.swift): The main entry point of the iOS app
- [`View/`](Spontaneo/View): Contains all SwiftUI views
  - [`Authentication/`](Spontaneo/View/Authentication): Login and SignUp views
  - [`Activity/`](Spontaneo/View/Activity): Activity-related views
  - [`Home/`](Spontaneo/View/Home): Home view
  - [`Profile/`](Spontaneo/View/Profile): User profile views
  - [`Chat/`](Spontaneo/View/Chat): Chat functionality
  - [`NavBar/`](Spontaneo/View/NavBar): Custom navigation bar components
- [`Model/`](Spontaneo/Model): Contains data models
- [`Services/`](Spontaneo/Services): Contains service classes for authentication, activities, etc.
- [`ViewModels/`](Spontaneo/ViewModels): Contains view models
- [`Assets.xcassets/`](Spontaneo/Assets.xcassets): Contains app icons and other assets

## Setup Instructions

1. Clone the repository to your local machine.
2. Open the `Spontaneo.xcodeproj` file in Xcode.
3. Ensure you have the latest version of Xcode installed (Xcode 15.0 or later).
4. Select the desired target (Spontaneo for iOS or Spontaneo Watch Watch App for watchOS).
5. Choose a simulator or connect a physical device.
6. Click the "Run" button or press `Cmd + R` to build and run the project.

## Usage

After launching the app, you'll be presented with a login screen. Use the following credentials for testing:

- Email: test@example.com
- Password: password123

Once logged in, you can explore the various features of the app:

1. **Home**: Discover nearby activities and hotspots.
2. **Activities**: Create, join, or manage activities.
3. **Rewards**: View your earned rewards and achievements.
4. **Profile**: Customize your profile and view your activity history.

To create a new activity:
1. Navigate to the Activities tab.
2. Tap the "+" button in the bottom right corner.
3. Fill in the activity details and tap "Create Activity".

To join an activity:
1. Find an activity you're interested in.
2. Tap on the activity to view details.
3. Tap the "Join Activity" button.

## Dependencies

Spontaneo uses the following main dependencies:

- Firebase SDK: For backend services and authentication
- SDWebImageSwiftUI: For efficient image loading and caching

These dependencies are managed through Swift Package Manager and should be automatically resolved when building the project in Xcode.

## Contributing

We welcome contributions to the Spontaneo project. Please follow these steps to contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with clear, descriptive messages.
4. Push your changes to your fork.
5. Submit a pull request to the main repository.