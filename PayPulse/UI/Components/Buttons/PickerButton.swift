//
//  CustomPickerButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-08-24.
//

import SwiftUI

// MARK: - PickerButtonContent
struct PickerButtonContent: View {
    let displayText: String
    let isShowingDropdown: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(Color.secondary)
            
            HStack {
                Text(displayText)
                    .font(.buttonSmall)
                    .foregroundStyle(Color.secondaryDarkGray)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.secondaryDarkGray)
                    .rotationEffect(.degrees(isShowingDropdown ? 180 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isShowingDropdown)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 50)
    }
}

// MARK: - PickerDropdownItem
struct PickerDropdownItem: View {
    let displayText: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Text(displayText)
                    .font(.bodyStandard)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondaryDarkGray)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - PickerDropdownMenu
struct PickerDropdownMenu<T: Hashable>: View {
    let options: [T]
    let selectedValue: T
    let displayText: (T) -> String
    let onSelectionChange: (T) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                let isSelected = option == selectedValue
                
                PickerDropdownItem(
                    displayText: displayText(option),
                    isSelected: isSelected,
                    onTap: {
                        onSelectionChange(option)
                    }
                )
                
                if index < options.count - 1 {
                    Divider()
                        .background(Color.secondary.opacity(0.3))
                }
            }
        }
        .frame(minWidth: 140)
        .presentationCompactAdaptation(.popover)
    }
}

// MARK: - Main PickerButton
struct PickerButton<T: Hashable>: View {
    let title: String
    let selectedValue: T
    let options: [T]
    let displayText: (T) -> String
    let onSelectionChange: (T) -> Void
    
    @State private var isShowingDropdown = false
    
    var body: some View {
        Button {
            isShowingDropdown.toggle()
        } label: {
            PickerButtonContent(
                displayText: displayText(selectedValue),
                isShowingDropdown: isShowingDropdown
            )
        }
        .popover(isPresented: $isShowingDropdown, arrowEdge: .top) {
            PickerDropdownMenu(
                options: options,
                selectedValue: selectedValue,
                displayText: displayText,
                onSelectionChange: { option in
                    onSelectionChange(option)
                    isShowingDropdown = false
                }
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PickerButton(
            title: "Parameter",
            selectedValue: ParameterType.totalRent,
            options: ParameterType.allCases,
            displayText: { $0.rawValue },
            onSelectionChange: { _ in }
        )
        
        PickerButton(
            title: "Year",
            selectedValue: nil as Int?,
            options: [nil, 2023, 2024, 2025],
            displayText: { value in
                value == nil ? "Quarterly" : String(value!)
            },
            onSelectionChange: { _ in }
        )
    }
    .padding()
}
