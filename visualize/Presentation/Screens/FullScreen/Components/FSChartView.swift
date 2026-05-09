//
//  FSChartView.swift
//  visualize
//
//  Created by Maria Regina Orduño Lopez on 28/04/26.
//

import SwiftUI

struct FSChartView: View {
    let imageName: String
    
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0
    @State private var imageOffset: CGSize = .zero
    @State private var lastImageOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .scaleEffect(zoomScale)
                .offset(imageOffset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = lastZoomScale * value
                                zoomScale = min(max(newScale, 1.0), 5.0)
                            }
                            .onEnded { _ in
                                lastZoomScale = zoomScale
                            },
                        
                        DragGesture()
                            .onChanged { value in
                                imageOffset = CGSize(
                                    width: lastImageOffset.width + value.translation.width,
                                    height: lastImageOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastImageOffset = imageOffset
                            }
                    )
                )
                .animation(.spring(), value: zoomScale)
        }
    }
}

#Preview {
    FSChartView(imageName: "MockChart")
}
