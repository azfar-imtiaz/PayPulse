//
//  ProfileView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-08-24.
//

import SwiftUI

struct ProfileView: View {
    let userService : UserService
    @ObservedObject var viewModel : UserViewModel
    
    @State private var showDeleteConfirmation = false
    @State private var showLogoutConfirmation = false
    @State private var isDeleting = false
    @State private var showSpinner = false
    @State private var loadingText = "Loading user information..."
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager
    
    init(userService: UserService) {
        _viewModel = ObservedObject(wrappedValue: UserViewModel(userService: userService))
        self.userService = userService
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
        // TODO: Move this implementation into the view model
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
    
    private func loadUserInfo() {
        showSpinner = true
        
        Task {
            defer {
                showSpinner = false
            }
            
            do {
                _ = try await viewModel.getUserInfo()
            } catch {
                // show toast notification here
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
    ProfileView(userService: UserService(apiClient: PayPulseAPIClient(authManager: AuthManager.shared)))
        .environmentObject(AuthManager.shared)
}
