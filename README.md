# PayPulse

PayPulse is an iOS app built with SwiftUI for tracking and managing rental invoices. The app provides a clean, intuitive interface for users to view their rental payment history, analyze spending patterns, and manage invoice data.

## Features

- **Authentication**: Secure user login and registration
- **Invoice Management**: View and track rental invoices with detailed breakdowns
- **Data Visualization**: Interactive charts showing rental payment trends over time
- **Smart Aggregation**: Automatic grouping of invoice data by month/year for better analysis
- **Toast Notifications**: User-friendly feedback for actions like copying invoice details
- **Dark/Light Mode**: Adaptive UI that supports both color schemes

## Architecture

PayPulse follows the MVVM (Model-View-ViewModel) architectural pattern with SwiftUI:

- **Models**: Data structures for invoices, users, and API responses
- **ViewModels**: Business logic and state management using `@ObservableObject`
- **Views**: SwiftUI components organized by feature areas
- **Services**: API client, authentication, and business logic services
- **Components**: Reusable UI elements for consistent design

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Alamofire**: HTTP networking library
- **Toasts**: User notification system
- **Swift Collections**: Advanced data structures

## Backend Integration

PayPulse connects to a cloud-based backend infrastructure:

**Backend Repository**: [PayPulse-Cloud](https://github.com/azfar-imtiaz/PayPulse-Cloud)

### Backend Technologies
- **AWS Cloud Services**: Lambda, API Gateway, DynamoDB, S3, SNS, Cognito
- **Terraform**: Infrastructure as Code
- **Python**: Lambda function runtime

### API Endpoints

#### Authentication
- `POST /auth/signup` - User registration
- `POST /auth/login` - User authentication

#### Invoice Operations
- `GET /user/get_rental_invoices` - Fetch user's rental invoices
- `POST /user/fetch_invoices` - Trigger invoice ingestion from Gmail
- `DELETE /user/delete_user` - Delete user account

#### Authentication Flow
- JWT token-based authentication
- Bearer token required for protected endpoints
- Automatic token refresh handling

## Project Structure

```
PayPulse/
├── PayPulse/
│   ├── Models/                 # Data models
│   ├── Services/              # API and business logic
│   ├── ViewModels/           # MVVM view models
│   ├── UI/
│   │   ├── Components/       # Reusable UI components
│   │   ├── Views/           # Feature-specific views
│   │   └── Fonts/           # Custom typography
│   ├── Extensions/          # Swift extensions
│   └── Assets.xcassets/     # Images and colors
└── PayPulse.xcodeproj/      # Xcode project files
```

## Setup and Installation

### Prerequisites

- Xcode 15.0 or later
- iOS 16.0 or later
- macOS 13.0 or later for development

### Dependencies

The project uses Swift Package Manager for dependency management:

- **Alamofire** (5.10.2): HTTP networking
- **Toasts** (0.2.0): Toast notifications
- **SwiftUI Collections** (1.2.0): Advanced data structures
- **Lottie** (4.5.2): Animations

## Development

### Typography System

PayPulse uses a centralized typography system with Montserrat fonts:

- **Headings**: `.headingLarge`, `.headingMedium`, `.headingStandard`, `.headingSmall`
- **Body Text**: `.bodyLarge`, `.bodyStandard`, `.bodySmall`
- **Interactive**: `.buttonLarge`, `.buttonStandard`, `.buttonSmall`
- **Data Display**: `.tableHeader`, `.tableKey`, `.tableValue`

### Code Style Guidelines

- Follow SwiftUI and Swift naming conventions
- Use MVVM architecture patterns
- Leverage the centralized typography system
- Implement proper error handling
- Write meaningful commit messages

## Future Enhancements

- Add support for other types of invoices
- Fetch all invoices from user's Gmail account
- Add support for signing in with Gmail
- User should be able to upload invoices using photos

## Support

For issues, questions, or contributions, please create an issue in this repository or the backend repository as appropriate.

## License

This project is intended for personal use and portfolio demonstration.
