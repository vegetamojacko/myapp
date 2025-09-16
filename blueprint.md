# Project Blueprint

## Overview

This document outlines the structure and features of the Claims App, a Flutter application designed to streamline the process of submitting and managing claims.

## Style and Design

The app uses the Material Design 3 theme, with a color scheme generated from a seed color. It supports both light and dark modes and uses the `google_fonts` package for custom typography.

## Features

### Car Wash Claims

- Users can submit claims for car washes.
- The car wash claim form includes a dropdown to select the car wash name from a predefined list.
- The selected car wash name is stored in the `Claim` model and displayed in the claim details.

### Current Plan

- **Implement Car Wash Name Dropdown:**
    - Add a `carWashName` field to `lib/models/claim.dart`.
    - Modify `lib/widgets/car_wash_claim_form.dart` to add a new dropdown field for "Car Wash Name" and save the selected value to the new `carWashName` field in the `Claim` object.
    - Update `lib/widgets/claim_item.dart` to display the `carWashName` in the claim details.