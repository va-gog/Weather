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

APIs Used
OpenWeather One Call API
OpenWeather Current Weather Data API
OpenWeather Geocoding API
External Libraries
Realm for data persistence
Firebase for authentication and user data management
Native SDKs
CoreLocation for location handling
BackgroundTasks for scheduling daily updates
UserNotifications for delivering weather notifications
Keychain for securely storing sensitive data
Architecture
Coordinator Pattern for managing navigation
MVVM (Model-View-ViewModel) for a clean and testable structure
Feature-Based Structure for modular and organized code
Testing
Unit Testing for verifying core functionality
