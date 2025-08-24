//
//  ProfileView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-08-24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showDeleteConfirmation = false
    @State private var showLogoutConfirmation = false
    @State private var isDeleting = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // User Information Card
                AuthCard(content: 
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Account Information")
                            .font(.custom("Montserrat-Bold", size: 18))
                            .foregroundStyle(Color.secondaryDarkGray)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            UserInfoRow(label: "Name", value: "John Doe")
                            UserInfoRow(label: "Email", value: "john.doe@example.com")
                            UserInfoRow(label: "Status", value: "Active")
                        }
                    }
                )
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondaryDarkGray, lineWidth: 1)
                )
                .padding()
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    SecondaryButton(
                        buttonView: Text("Logout"),
                        action: {
                            showLogoutConfirmation = true
                        }
                    )
                    
                    DestructiveButton(
                        buttonView: Text("Delete Account"),
                        action: {
                            showDeleteConfirmation = true
                        },
                        isDisabled: isDeleting
                    )
                }
            }
            .background(Color.primaryOffWhite)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    let iconName = "circle-arrow-left"
                    Button {
                        dismiss()
                    } label: {
                        Utils.getIconColored(colorScheme: colorScheme, iconName: iconName)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle( colorScheme == .light ? Color.secondaryDarkGray : Color.primaryOffWhite )
                }
            }
        }
        .alert("Confirm Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. Your account and all data will be permanently deleted.")
        }
    }
    
    private func deleteAccount() {
        guard let userService = authManager.userService else { return }
        
        isDeleting = true
        
        Task {
            do {
                _ = try await userService.deleteUser()
                await MainActor.run {
                    authManager.logout()
                }
            } catch {
                await MainActor.run {
                    isDeleting = false
                    // Could add toast notification here for error
                }
            }
        }
    }
}

struct UserInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.custom("Montserrat-Medium", size: 14))
                .foregroundStyle(Color.secondaryDarkGray.opacity(0.7))
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.custom("Montserrat-Regular", size: 14))
                .foregroundStyle(Color.secondaryDarkGray)
            
            Spacer()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager.shared)
}
