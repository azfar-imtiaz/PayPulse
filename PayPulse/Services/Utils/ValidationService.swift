//
//  ValidationService.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-09-14.
//

import Foundation

class ValidationService {
    public static func validateName(_ name: String) -> Bool {
        let lettersAndSpacesCharacterSet = CharacterSet.letters.union(.whitespaces).inverted

        guard name.count > 2 && name.rangeOfCharacter(from: lettersAndSpacesCharacterSet) == nil else {
            return false
        }
        return true
    }
    
    public static func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    public static func validatePassword(_ password: String) -> Bool {
        // TODO: Add better password validation here
        return password.count >= 8
    }
    
    public static func validateLoginFields(email: String, password: String) -> (status: Bool, message: String) {
        // Run validations for all the fields in login view
        guard validateEmail(email) else {
            return (false, "Please enter a valid email.")
        }
        
        guard validatePassword(password) else {
            return (false, "Password must be at least 8 characters.")
        }
        return (true, "")
    }
    
    public static func validateSignupFields(name: String, email: String, password: String) -> (status: Bool, message: String) {
        // Run validations for all the fields in signup view
        guard validateName(name) else {
            return (false, "Please enter a valid name.")
        }
        
        guard validateEmail(email) else {
            return (false, "Please enter a valid email.")
        }
        
        guard validatePassword(password) else {
            return (false, "Password must be at least 8 characters.")
        }
        return (true, "")
    }
}
