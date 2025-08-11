//
//  TrimmingOverlayView.swift
//  PostCreation
//
//  Created by Artem Vasin on 05.03.25.
//

import SwiftUI
import DesignSystem

struct TrimmingOverlayView: View {
    @Binding var trimStartTime: Double
    @Binding var trimEndTime: Double
    let videoDuration: Double

    @State private var dragOffset: CGFloat = 0
    private let minTrimDuration: Double = 5

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width

            ZStack {
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: width(for: totalWidth), height: geometry.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                HStack {
                    dragHandle(isStart: true)
                    Spacer()
                    dragHandle(isStart: false)
                }
                .frame(width: width(for: totalWidth), height: geometry.size.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func width(for totalWidth: CGFloat) -> CGFloat {
        let relativeStart = CGFloat(trimStartTime / videoDuration)
        let relativeEnd = CGFloat(trimEndTime / videoDuration)
        return (relativeEnd - relativeStart) * totalWidth
    }

    private func dragHandle(isStart: Bool) -> some View {
        Rectangle()
            .fill(Colors.whitePrimary)
            .frame(width: 8, height: 40)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let step = videoDuration / UIScreen.main.bounds.width
                        let timeChange = step * Double(value.translation.width)

                        if isStart {
                            let newStart = max(0, min(trimEndTime - minTrimDuration, trimStartTime + timeChange))
                            trimStartTime = newStart
                        } else {
                            let newEnd = min(videoDuration, max(trimStartTime + minTrimDuration, trimEndTime + timeChange))
                            trimEndTime = newEnd
                        }
                    }
            )
    }
}

