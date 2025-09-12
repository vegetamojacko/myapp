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

### Subscription Management

- **View Subscriptions:** Users can view their current subscription plan.
- **Select Plan:** Users can select a subscription plan that suits their needs.

### Navigation

- **Dashboard Navigation:** After submitting their banking details, users are automatically navigated to the dashboard.

## Current Task: Navigate to Dashboard After Banking Details Submission

### Objective

Improve the user experience by automatically navigating the user to the dashboard after they have successfully submitted their banking details.

### Implementation Steps

1.  **Update `banking_details_modal.dart`:**
    -   In the `_submitForm` function, after the banking information is successfully submitted, add a call to `context.read<NavigationProvider>().navigateToPage(0);` to navigate to the dashboard.