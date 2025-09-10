# Blueprint

## Overview

This document outlines the project structure, design, and features of the Candibean app. The app allows users to claim tickets for events, manage their profile, and choose a subscription plan.

## Style and Design

- **Theme:** The app uses a Material 3 design with a primary color of deep purple. It supports both light and dark modes.
- **Typography:** The app uses Google Fonts for a modern and readable look. Oswald is used for display text, Roboto for titles, and Open Sans for body text.
- **Components:** The app uses custom-styled widgets for a consistent and branded feel. Buttons, text fields, and cards have been designed to match the overall theme.

## Features

### Implemented

- **Home Screen:** A landing page for the app that displays user information and the currently selected subscription plan.
- **Claims Screen:** Users can view and manage their claimed tickets.
- **Profile Screen:** Users can view and edit their profile information.
- **Subscription Screen:** Users can view and choose from different subscription plans.
- **Subscription Management:**
    - When a user selects a subscription plan from the `SubscriptionScreen`, the `UserProvider` is updated with the selected plan's details.
    - The `HomeScreen` listens for changes in the `UserProvider` and displays the name and benefits of the selected plan.
    - If no plan is selected, the `HomeScreen` prompts the user to choose one.
- **Layout Bug Fix:**
    - Resolved a `RenderFlex` overflow error on the `HomeScreen` by wrapping a `Wrap` widget with a `Flexible` widget to ensure it correctly constrains its children.
    - Fixed an initial `RenderFlex` overflow by wrapping a `Text` widget in an `Expanded` widget.

### Current Plan: Add Car Wash Screen

- [x] Create a new `car_wash_screen.dart` file in the `lib/screens` directory.
- [x] Implement a basic layout for the car wash screen, including an image, title, description, and a "Book Now" button.
- [x] Add navigation to the `CarWashScreen` from a button on the `HomeScreen`.
