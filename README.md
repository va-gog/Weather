# A SwiftUI Weather App with Location Access, Secure Authentication, and Persistent Favorites
1. When the user opens the application, a request is made for access to their current location.
   If the user grants permission, the authentication screen is displayed. If the user denies permission,
   a screen with a button appears, prompting them to go to the app settings to enable location access.
2. When the user grants access to retrieve their current location, the Authentication screen opens.
   Here, the user can sign in using their email and password. If the user does not yet have an account,
   they can navigate to the Sign-Up page using a button on this screen. When the user signs up for the
   first time by entering a password, the password is securely stored in the keychain. Each time the user
   returns to the sign-in page, the stored password is automatically retrieved from the keychain when they fill in their email.
3. When the user signs in, the Favorites Weather page opens. If the user has previously marked any weather locations as favorites,
   they are saved in storage. Each time the user returns to the application, these favorites are loaded from storage using the user
   identifier retrieved during authentication.The Favorites Weather page includes a search feature,
   allowing the user to look up locations and view their weather. To fetch weather data, the application uses the OpenWeather API.
4. When the user taps on a weather card from the favorites or search results, the Details screen opens. Here, an additional request
   is made to the OpenWeather API to fetch daily and weekly weather information.The Details screen includes a tab bar with options to:
       * Sign Out: Returns the user to the Authentication screen.
       * Remove: Deletes the weather location from favorites and removes it from storag
5. The first time the user sends the app to the background, a background task is registered to provide daily notifications at 10:00 AM
   with the day’s high and low temperatures. Notification permissions are requested when the user initially opens the Weather app.

## **APIs Used**
- OpenWeather One Call API
- OpenWeather Current Weather Data API
- OpenWeather Geocoding API

## **External Libraries**
- Realm for data persistence
- Firebase for authentication and user data management

## **Native SDKs**
- CoreLocation for location handling
- BackgroundTasks for scheduling daily updates
- UserNotifications for delivering weather notifications
- Keychain for securely storing sensitive data

## **Architecture**
- Coordinator Pattern for managing navigation
- MVVM + C (Model-View-ViewModel + Coordinator) for a clean and testable structure
- Feature-Based Structure for modular and organized code

## **Testing**
- Unit Testing for verifying core functionality

# SwiftUI Navigation Flow with Coordinators

This project implements a navigation flow in SwiftUI using the Coordinator pattern, designed to provide flexible, structured navigation within the app. Inspired by UIKit's `UIViewController`-based navigation, this approach establishes a clean, modular navigation stack management system where each screen has its own Coordinator. The Coordinators communicate, maintain hierarchical relationships, and manage the navigation path for a seamless and dynamic navigation experience.

## Project Overview

The navigation flow is managed by a `BaseCoordinator`, which holds a `path` property representing the navigation stack. This path is responsible for pushing and popping screens dynamically. Each screen (analogous to a `UIViewController` in UIKit) has an individual Coordinator with a specific identifier or type. The Coordinators communicate with each other through a parent-child relationship, allowing for organized transitions between screens.

### Key Components

- **BaseCoordinator**:  
  The central coordinator that keeps track of the navigation path, handling push and pop actions across the navigation stack. It acts as a mediator between the root Coordinator and individual child Coordinators.

- **Screen Coordinators**:  
  Each screen is managed by a dedicated Coordinator that:
    - Has a unique identifier or type.
    - Maintains a parent-child relationship with other Coordinators.
    - Is added to the `children` array of its parent when a screen is pushed and removed on pop.

### Path Management

- **Pushing a Screen**:  
  When a screen is pushed, the respective Coordinator is added to the parent's children, and the navigation path is updated in the root Coordinator.
  
- **Updating the Navigation Stack**:  
  The root Coordinator updates the navigation stack based on the new path, prompting the appropriate Coordinator to return its associated view.
  
- **Popping a Screen**:  
  A similar process occurs for pops, where the relevant Coordinator is removed, and the view stack is updated accordingly.

### Workflow

- **Pushing a Screen**:  
  When a screen is pushed, the Coordinator responsible for it is set as a child of the current Coordinator. This hierarchy bubbles up to the `BaseCoordinator`, which updates the navigation path and instructs the navigation stack to present the correct view.

- **Popping a Screen**:  
  The same hierarchy-based logic applies for popping screens, with the `BaseCoordinator` updating the navigation path and triggering the stack to revert to the previous view.

---
