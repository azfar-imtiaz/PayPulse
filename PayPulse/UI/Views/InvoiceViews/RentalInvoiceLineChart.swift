//
//  LineChartView.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-02-20.
//

import SwiftUI
import Toasts

struct RentalInvoiceLineChart: View {
    let data: [(String, Int)]
    @State private var animationProgress: CGFloat = 0.0
    @State private var showAmountToast: Bool = false
    
    @Environment(\.presentToast) var presentToast
    
    private var dataIdentifier: String {
        data.map { "\($0.0):\($0.1)" }.joined(separator: ",")
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            // TODO: This fucks up when min and max are the same (hyra amount being same in the latest year, for example)
            let minValue = data.map { $0.1 }.min() ?? 0
            let maxValue = data.map { $0.1 }.max() ?? 1 == minValue ? data.map { $0.1 }.max() ?? 1 + 10 : data.map { $0.1 }.max() ?? 1
            
            let yStep = (Int(maxValue) - minValue) / 5
            let leftPadding: CGFloat = max(width * 0.08, 20)
            
            let spacing = (width - leftPadding) / CGFloat(max(1, data.count - 1))
            
            // convert data points to coordinates
            let points = data.enumerated().map { index, entry in
                let x = leftPadding + CGFloat(index) * spacing
                let y = height - ((CGFloat(entry.1 - minValue) / CGFloat(Double(maxValue) - Double(minValue))) * height)
                return CGPoint(x: x, y: y)
            }
            
            ZStack {
                // this is the background lines with labels
                ForEach(0..<6) { i in
                    let gridY = height - (CGFloat(i) * (height / 5))
                    let gridValue = minValue + (Int(CGFloat(i)) * yStep)
                    
                    // draw grid lines
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: gridY))
                        path.addLine(to: CGPoint(x: width + 5, y: gridY))
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    
                    // draw the Y-axis labels
                    let label = Utils.formatNumber(gridValue)
                    Text(label)
                        .font(.caption)
                        .foregroundColor(Color.secondaryDarkGray)
                        .frame(width: 40, alignment: .center)
                        .position(y: gridY - 10)
                        .padding(.leading, 5)
                    
                }
                
                // draw the line graph
                Path { path in
                    if let firstPoint = points.first {
                        path.move(to: firstPoint)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                }
                .trim(from: 0, to: animationProgress)
                .stroke(Color.secondaryDarkGray, lineWidth: 2)
                
                // draw points with labels
                ForEach(points.indices, id: \.self) { i in
                    let point = points[i]
                    let value = data[i].1
                    
                    // draw dotted line from x-axis label to point
                    Path { path in
                        path.move(to: CGPoint(x: point.x, y: height))
                        path.addLine(to: CGPoint(x: point.x, y: point.y))
                    }
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 10, height: 10)
                        .position(x: point.x, y: point.y)
                        .onTapGesture {
                            showAmountToast(value: value)
                        }
                }
                
                // draw x-axis labels
                ForEach(data.indices, id: \.self) { i in
                    let x = leftPadding + CGFloat(i) * spacing
                    let label: String = data[i].0
                    
                    // this means all years is selected, the label is year
                    if isNumeric(text: label) {
                        if i == 0 || data[i].0 != data[i-1].0 {
                            Text(label)
                                .font(.custom("Gotham-Light", size: 12))
                                .foregroundStyle(Color.secondaryDarkGray)
                                .position(x: x, y: height + 15)
                        }
                    }
                    // this means a specific year is selected, the label is month
                    else {
                        Text(label.prefix(3))
                            .font(.custom("Gotham-Light", size: 12))
                            .foregroundStyle(Color.secondaryDarkGray)
                            .position(x: x, y: height + 15)
                    }
                }
            }
            .frame(height: 300)
        }
        .onAppear {
            animateLine()
        }
        .onChange(of: dataIdentifier) {
            animateLine()
        }
    }
    
    func animateLine() {
        animationProgress = 0.0
        DispatchQueue.main.async {
            withAnimation(.smooth(duration: 1.25)) {
                    animationProgress = 1.0
                }
            }
    }
    
    func showAmountToast(value: Int) {
        let toast = ToastValue(
            message: "\(Utils.formatNumber(value)) SEK",
            duration: 2
        )
        presentToast(toast)
    }
    
    func isNumeric(text: String) -> Bool {
        return Double(text) != nil
    }
}

#Preview {
    RentalInvoiceLineChart(data: [])
}
