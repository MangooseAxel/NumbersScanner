//
//  ChartView.swift
//  NumbersScanner
//
//  Created by Oleksandr Dolomanov on 03.04.2023.
//

import SwiftUI
import Charts

struct ChartView<Content: View>: View {
    let data: [[Double?]]
    let content: Content

    init(data: [[Double?]],
         @ViewBuilder content: @escaping () -> Content
    ) {
        self.data = data
        self.content = content()
    }

    var body: some View {
        VStack {
            Chart {
                if let columnsCount = data.first?.count, columnsCount > 1 {
                    let rowLength = data.count

                    ForEach(1..<columnsCount, id: \.self) { column in
                        ForEach(0..<rowLength, id: \.self) { row in
                            if let y = data[row][column], let x = data[row].first as? Double {
                                LineMark(
                                    x: .value("X", x),
                                    y: .value("Y", y)
                                )
                                .foregroundStyle(by: .value("Type", "Y \(column)"))

                                PointMark(
                                    x: .value("X", x),
                                    y: .value("Y", y)
                                )
                                .foregroundStyle(by: .value("Type", "Y \(column)"))
                            }
                        }
                    }
                }
            }
            .chartLegend(position: .bottom, alignment: .center)
            .frame(height: 250)
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).stroke(.secondary))
            .padding()

            content.padding()
        }
        .navigationTitle("Chart")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(data: [
            [0, 1, 1, 3],
            [1, 2, 3, 2],
            [2, 1, 2, 1],
            [3, 4, 1, 5]
        ]) {
            EmptyView()
        }
    }
}
