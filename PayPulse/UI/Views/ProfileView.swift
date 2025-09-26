//
//  ProfileView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-08-24.
//

import SwiftUI
import Toasts
import GoogleSignInSwift

struct ProfileView: View {
    let userService : UserService
    let gmailService: GmailAuthService
    @StateObject var viewModel : UserViewModel
    
    @State private var showDeleteConfirmation = false
    @State private var showLogoutConfirmation = false
    @State private var isDeleting = false
    @State private var showSpinner = false
    @State private var loadingText = "Loading user information..."
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentToast) var presentToast
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager
    
    init(userService: UserService, gmailService: GmailAuthService) {
        _viewModel = StateObject(wrappedValue: UserViewModel(userService: userService, gmailAuthService: gmailService))
        self.userService = userService
        self.gmailService = gmailService
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 30) {
                    // User Information Card
                    AuthCard(content:
                                VStack(alignment: .leading, spacing: 20) {
                        Text("Account Information")
                            .font(.headingSmall)
                            .foregroundStyle(Color.secondaryDarkGray)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            UserInfoRow(label: "Name:", value: viewModel.username)
                            UserInfoRow(label: "Email:", value: viewModel.userEmail)
                            UserInfoRow(label: "Created on:", value: viewModel.userCreatedOn)
                            UserInfoRow(label: "Gmail connection:", value: viewModel.gmailConnectionStatus ? "✔️" : "❌")
                        }
                    })
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondaryDarkGray, lineWidth: 1)
                    )
                    .padding()
                    
                    Spacer()
                    
                    if !viewModel.gmailConnectionStatus {
                        GoogleButton {
                            connectToGmail()
                        }
                        
                        Spacer()
                    
                    }
                    
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
                .onAppear {
                    loadUserInfo()
                }
                .background(Color.primaryOffWhite)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                
                LoadingDotsView(isLoading: $showSpinner, loadingText: loadingText)
            }
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
                let logoutToast = ToastValue(
                    icon: Icon(name: "circle-check"),
                    message: "You have been logged out"
                )
                authManager.setPendingToast(logoutToast)
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                let logoutToast = ToastValue(
                    icon: Icon(name: "circle-check"),
                    message: "Sad to see you go!"
                )
                authManager.setPendingToast(logoutToast)
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. Your account and all data will be permanently deleted.")
        }
    }
    
    private func deleteAccount() {
        loadingText = "Deleting user account..."
        showSpinner = true
        
        Task {
            defer {
                showSpinner = false
            }
            
            do {
                try await viewModel.deleteUser(authManager: authManager)
                let successToast = ToastValue(
                    icon: Icon(name: "circle-check"),
                    message: "User account deleted successfully!"
                )
                authManager.setPendingToast(successToast)
            } catch let apiError as APIError {
                Utils.handleAPITokenExpiration(apiError, authManager: authManager) {
                    let toastValue = ToastValue(
                        icon: Icon(name: "circle-x"),
                        message: viewModel.errorMessage ?? "Error loading user information"
                    )
                    presentToast(toastValue)
                }
            }
        }
    }
    
    private func loadUserInfo() {
        loadingText = "Loading user information..."
        showSpinner = true
        
        Task {
            defer {
                showSpinner = false
            }
            
            do {
                try await viewModel.getUserInfo()
            } catch let apiError as APIError {
                Utils.handleAPITokenExpiration(apiError, authManager: authManager) {
                    let toastValue = ToastValue(
                        icon: Icon(name: "circle-x"),
                        message: viewModel.errorMessage ?? "Error loading user information"
                    )
                    presentToast(toastValue)
                }
            }
        }
    }
    
    private func connectToGmail() {
        loadingText = "Connecting to Gmail..."
        showSpinner = true
        
        Task {
            defer {
                showSpinner = false
            }
            
            do {
                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                    let response = try await viewModel.connectToGmail(presentingViewController: rootVC)
                    print(response.googleEmail)
                    let toastValue = ToastValue(
                        icon: Icon(name: "circle-check"),
                        message: "Gmail account connected successfully!"
                    )
                    presentToast(toastValue)
                    loadUserInfo()
                }
            } catch {
                let toastValue = ToastValue(
                    icon: Icon(name: "circle-x"),
                    message: viewModel.errorMessage ?? "Connection to Gmail failed"
                )
                presentToast(toastValue)
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
                .font(.tableKey)
                .foregroundStyle(Color.secondaryDarkGray.opacity(0.7))
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.tableValue)
                .foregroundStyle(Color.secondaryDarkGray)
            
            Spacer()
        }
    }
}

#Preview {
    ProfileView(userService: UserService(apiClient: PayPulseAPIClient(authManager: AuthManager.shared)), gmailService: GmailAuthService())
        .environmentObject(AuthManager.shared)
}
