//
//  FontFamily.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-08-24.
//

import SwiftUI

// MARK: - Typography System
extension Font {
    
    // MARK: - Headings
    
    /// Large headings - Main app titles, page headers
    /// Used for: App title "PayPulse", main screen titles
    static let headingLarge = Font.custom(Typography.FontName.bold, size: Typography.Size.largeTitle)
    
    /// Medium headings - Section headers, large summaries
    /// Used for: Invoice summaries, important section titles
    static let headingMedium = Font.custom(Typography.FontName.semiBold, size: Typography.Size.display)
    
    /// Standard headings - Subsection headers
    /// Used for: "All your invoices, one place", section headers
    static let headingStandard = Font.custom(Typography.FontName.bold, size: Typography.Size.title)
    
    /// Small headings - Minor section titles
    /// Used for: "Invoice ID", "Payment Details", "Rent Breakdown"
    static let headingSmall = Font.custom(Typography.FontName.medium, size: Typography.Size.headline)
    
    // MARK: - Body Text
    
    /// Large body text - Main content, input fields
    /// Used for: Form inputs, important content text
    static let bodyLarge = Font.custom(Typography.FontName.regular, size: Typography.Size.callout)
    
    /// Standard body text - Secondary content, descriptions
    /// Used for: General content, list items, descriptions
    static let bodyStandard = Font.custom(Typography.FontName.regular, size: Typography.Size.body)
    
    /// Small body text - Captions, metadata
    /// Used for: Chart labels, small text, help text
    static let bodySmall = Font.custom(Typography.FontName.light, size: Typography.Size.caption)
    
    // MARK: - Interactive Elements
    
    /// Large buttons - Primary action buttons
    /// Used for: Login, Signup, Delete Account buttons
    static let buttonLarge = Font.custom(Typography.FontName.bold, size: Typography.Size.headline)
    
    /// Standard buttons - Secondary action buttons
    /// Used for: Secondary buttons, form labels
    static let buttonStandard = Font.custom(Typography.FontName.semiBold, size: Typography.Size.callout)
    
    /// Small buttons - Picker buttons, small interactive elements
    /// Used for: Picker buttons, small controls
    static let buttonSmall = Font.custom(Typography.FontName.semiBold, size: Typography.Size.body)
    
    // MARK: - Table & Data Elements
    
    /// Table headers - Bold table headings
    /// Used for: Table headers, data labels
    static let tableHeader = Font.custom(Typography.FontName.bold, size: Typography.Size.callout)
    
    /// Table content - Medium weight for keys in key-value pairs
    /// Used for: Table row keys, form field labels  
    static let tableKey = Font.custom(Typography.FontName.medium, size: Typography.Size.body)
    
    /// Table values - Regular weight for values in key-value pairs
    /// Used for: Table row values, data display
    static let tableValue = Font.custom(Typography.FontName.regular, size: Typography.Size.body)
    
    // MARK: - Special Use Cases
    
    /// Navigation elements - Extra bold for navigation bars
    /// Used for: UINavigationBar titles (UIKit)
    static let navigationLarge = Font.custom(Typography.FontName.extraBold, size: Typography.Size.navigation)
    
    /// Navigation standard - Medium weight for navigation
    /// Used for: UINavigationBar standard titles
    static let navigationStandard = Font.custom(Typography.FontName.medium, size: Typography.Size.headline)
    
    /// Form labels - Special case for form field labels
    /// Used for: Labeled text fields, form elements
    static let formLabel = Font.custom(Typography.FontName.semiBold, size: Typography.Size.callout)
    
    /// UI labels - Navigation items, list labels
    /// Used for: "Rental invoices" navigation text
    static let uiLabel = Font.custom(Typography.FontName.regular, size: 15)
}

// MARK: - Typography Helper
struct Typography {
    
    /// Font name constants for internal use
    struct FontName {
        static let regular = "Montserrat-Regular"
        static let medium = "Montserrat-Medium" 
        static let semiBold = "Montserrat-SemiBold"
        static let bold = "Montserrat-Bold"
        static let extraBold = "Montserrat-ExtraBold"
        static let light = "Montserrat-Light"
    }
    
    /// Standard size scale for consistency
    struct Size {
        static let caption: CGFloat = 12
        static let body: CGFloat = 14
        static let callout: CGFloat = 16
        static let headline: CGFloat = 18
        static let title: CGFloat = 22
        static let display: CGFloat = 24
        static let largeTitle: CGFloat = 26
        static let navigation: CGFloat = 36
    }
}
