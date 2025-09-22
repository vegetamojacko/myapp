# Project Blueprint

## Overview

This document outlines the structure and features of the Claims App, a Flutter application designed to streamline the process of submitting and managing claims.

## Style and Design

The app uses the Material Design 3 theme, with a color scheme generated from a seed color. It supports both light and dark modes and uses the `google_fonts` package for custom typography.

## Features

### Authentication

- **Password Visibility Toggle:** The login and registration screens now feature an "eye" icon that allows users to toggle the visibility of the password they are typing.

### Car Wash Claims

- Users can submit claims for car washes.
- The car wash claim form includes a dropdown to select the car wash name from a predefined list.
- The selected car wash name is stored in the `Claim` model and displayed in the claim details.

### Firebase Integration

- **Project Connection:** The IDE is connected to the `candibean-android-app` Firebase project.
- **Realtime Database Security Rules:** The rules in `database.rules.json` have been updated to allow authenticated users to read the `carWashes` data, while keeping other data private and secure.

### Security

- **Firestore Security Rules:** Implemented rules in `firestore.rules` to ensure that users can only create, read, update, or delete their own user data and claims.

### Current Plan

- **Implement Car Wash Name Dropdown:**
    - Add a `carWashName` field to `lib/models/claim.dart`.
    - Modify `lib/widgets/car_wash_claim_form.dart` to add a new dropdown field for "Car Wash Name" and save the selected value to the new `carWashName` field in the `Claim` object.
    - Update `lib/widgets/claim_item.dart` to display the `carWashName` in the claim details.