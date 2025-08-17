# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PayPulse is an iOS app built with SwiftUI for tracking invoices. It's a personal invoice management application that connects to a backend API to fetch and manage rental invoices.

## Architecture

### Core Structure
- **PayPulseApp.swift**: Main app entry point with dependency injection setup
- **ContentView.swift**: Main navigation hub with modular service access
- **Services/**: Contains API client, authentication, and business logic services
- **ViewModels/**: ObservableObject classes managing UI state (AuthViewModel, InvoicesViewModel)
- **UI/**: SwiftUI views organized by feature areas and reusable components
- **Models/**: Data models for API responses and app state

### Key Architectural Patterns
- **MVVM**: ViewModels handle business logic, Views focus on UI
- **Dependency Injection**: Services injected through app initialization
- **Protocol-based Design**: APIClientProtocol, AuthManagerProtocol for testability
- **Environment Objects**: AuthManager shared across view hierarchy
- **Navigation**: NavigationStack with programmatic navigation

### Service Layer
- **PayPulseAPIClient**: Handles all HTTP requests with Alamofire
- **AuthService**: Authentication and token management
- **InvoiceService**: Invoice-related API operations
- **UserService**: User profile operations
- **AuthManager**: Centralized authentication state management

### UI Organization
- **Components/**: Reusable UI elements (buttons, containers, icons, shapes, tables, text fields)
- **Views/**: Feature-specific view groups (AuthViews, RentalInvoiceViews, AnimatedViews)
- **ViewModifiers/**: Custom view modifiers for consistent styling
- **Fonts/**: Custom font files (Gotham, Montserrat)

## Development Commands

Since this is an iOS project, development is primarily done through Xcode. Key operations:

- **Build**: Use Xcode's Product → Build (⌘+B)
- **Run**: Use Xcode's Product → Run (⌘+R) 
- **Test**: Use Xcode's Product → Test (⌘+U)
- **Clean**: Use Xcode's Product → Clean Build Folder (⌘+Shift+K)

## Key Dependencies

- **SwiftUI**: UI framework
- **Alamofire**: HTTP networking
- **Toasts**: Toast notification library
- **AWS SDK**: For push notifications (currently commented out)

## Important Implementation Details

### Authentication Flow
- App conditionally shows AuthView or ContentView based on AuthManager.isAuthenticated
- Token management handled through KeychainHelper for secure storage
- API client automatically attaches bearer tokens to requests

### Error Handling
- Custom APIError enum with specific error cases
- Centralized error handling in APIClient with logging
- UI feedback through toast notifications and error states

### State Management
- @StateObject for ViewModels
- @EnvironmentObject for shared state (AuthManager)
- @Published properties for UI reactivity

### Navigation
- TabView for main navigation within rental invoice section
- NavigationStack for hierarchical navigation
- Custom back button implementation with disabled states during loading

### Styling
- Custom fonts (Gotham, Montserrat) with specific weights
- Color scheme awareness for dark/light mode icons
- Consistent component styling through custom UI components