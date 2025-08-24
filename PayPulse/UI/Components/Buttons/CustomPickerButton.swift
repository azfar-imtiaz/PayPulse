//
//  CustomPickerButton.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-08-24.
//

import SwiftUI

struct CustomPickerButton<T: Hashable>: View {
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
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(Color.secondary)
                
                HStack {
                    Text(displayText(selectedValue))
                        .font(.custom("Montserrat-SemiBold", size: 14))
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
        .popover(isPresented: $isShowingDropdown, arrowEdge: .top) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(options.indices, id: \.self) { index in
                    let option = options[index]
                    let isSelected = option == selectedValue
                    
                    Button {
                        onSelectionChange(option)
                        isShowingDropdown = false
                    } label: {
                        HStack {
                            Text(displayText(option))
                                .font(.custom("Montserrat-Regular", size: 16))
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
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
}

#Preview {
    VStack(spacing: 20) {
        CustomPickerButton(
            title: "Parameter",
            selectedValue: ParameterType.totalRent,
            options: ParameterType.allCases,
            displayText: { $0.rawValue },
            onSelectionChange: { _ in }
        )
        
        CustomPickerButton(
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