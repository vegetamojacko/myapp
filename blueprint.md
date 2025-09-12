# Project Overview

This document outlines the project structure, features, and implementation details of the claims management application. It serves as a single source of truth for the application's design and functionality.

## Style and Design

The application follows the Material Design guidelines, with a clean and modern user interface. The color scheme is based on a primary color of deep purple, with a light and dark theme available to the user. The typography uses the Oswald, Roboto, and Open Sans fonts from Google Fonts to create a clear and readable hierarchy.

## Implemented Features

### User Authentication

- **Login and Registration:** Users can create an account and log in to the application.
- **User Profile:** Users can view and edit their profile information.

### Claims Management

- **Create Claim:** Users can create a new claim, either for a car wash or an event.
- **View Claims:** Users can view a list of their existing claims.
- **Claim Details:** Users can view the details of a specific claim.
- **Claim Status:** The status of each claim is displayed, and users can track its progress.
- **Conditional Claim Buttons:** The "Claim Event" and "Claim Car Wash" buttons are enabled only when the user has an active subscription, sufficient funds (R100 or more), and has provided their banking details.

### Subscription Management

- **View Subscriptions:** Users can view their current subscription plan.
- **Select Plan:** Users can select a subscription plan that suits their needs.

### Navigation

- **Dashboard Navigation:** After submitting their banking details, users are automatically navigated to the dashboard.

### User Data

- **Dummy Data:** The application uses dummy data for user information, including the user's name, email, and available funds.

## Code Refactoring

### Objective

To improve code organization and maintainability by refactoring the `main.dart` file.

### Implementation Steps

1.  **Extract Theme Data:** The `ThemeData` for both light and dark themes has been moved to a separate file, `lib/utils/app_themes.dart`.
2.  **Move `MainScreen`:** The `MainScreen` widget has been moved to its own file, `lib/screens/main_screen.dart`.
3.  **Clean up `main.dart`:** The `main.dart` file has been updated to import the themes and `MainScreen` from their new locations, making the file more concise and focused on its primary role as the app's entry point.