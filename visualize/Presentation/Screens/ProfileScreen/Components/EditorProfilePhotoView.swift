//
//  EditProfilePhotoView.swift
//  visualize
//
//  Created by Mariana Islas on 22/05/26.
//

import SwiftUI
import UIKit

// MARK: - Main View

struct EditProfilePhotoView: View {

    // MARK: - Internal properties

    let image: UIImage
    let onCancel: () -> Void
    let onSave: (UIImage) -> Void

    // MARK: - Private properties

    @Environment(\.displayScale) private var displayScale

    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Angle = .zero
    @State private var isReady = false

    @GestureState private var dragDelta: CGSize = .zero
    @GestureState private var scaleDelta: CGFloat = 1.0

    private let circleSize: CGFloat = 300

    private var effectiveOffset: CGSize {
        CGSize(
            width: offset.width + dragDelta.width,
            height: offset.height + dragDelta.height
        )
    }

    private var effectiveScale: CGFloat {
        scale * scaleDelta
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isReady {
                VStack(spacing: 0) {
                    Text("Move and Scale")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.top, 16)

                    Spacer()

                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(effectiveScale)
                            .rotationEffect(rotation)
                            .offset(effectiveOffset)
                            .frame(width: circleSize, height: circleSize)

                        CircleCutoutOverlay(size: circleSize)
                            .allowsHitTesting(false)

                        Circle()
                            .strokeBorder(.white.opacity(0.8), lineWidth: 1)
                            .frame(width: circleSize, height: circleSize)
                            .allowsHitTesting(false)
                    }
                    .frame(width: circleSize, height: circleSize)
                    .clipped()
                    .gesture(dragGesture)
                    .gesture(magnifyGesture)

                    Spacer()

                    bottomBar
                        .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isReady = true
            }
        }
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragDelta) { value, state, _ in
                state = clampedTranslation(value.translation)
            }
            .onEnded { value in
                let clamped = clampedTranslation(value.translation)
                offset = CGSize(
                    width: offset.width + clamped.width,
                    height: offset.height + clamped.height
                )
            }
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .updating($scaleDelta) { value, state, _ in
                state = value
            }
            .onEnded { value in
                scale = min(4.0, max(1.0, scale * value))
                let maxOff = maxAllowedOffset(for: scale)
                offset = CGSize(
                    width: min(max(offset.width, -maxOff.width), maxOff.width),
                    height: min(max(offset.height, -maxOff.height), maxOff.height)
                )
            }
    }

    // MARK: - Offset Clamping

    private func scaledImageSize(for currentScale: CGFloat) -> CGSize {
        let degrees = rotation.degrees.truncatingRemainder(dividingBy: 360)
        let normalized = degrees < 0 ? degrees + 360 : degrees
        let isTransposed = (normalized > 45 && normalized < 135) || (normalized > 225 && normalized < 315)

        let rawW = isTransposed ? image.size.height : image.size.width
        let rawH = isTransposed ? image.size.width  : image.size.height
        let aspect = rawW / rawH

        let filled: CGSize = aspect > 1
            ? CGSize(width: circleSize * aspect, height: circleSize)
            : CGSize(width: circleSize, height: circleSize / aspect)
        return CGSize(
            width: filled.width * currentScale,
            height: filled.height * currentScale
        )
    }

    private func maxAllowedOffset(for currentScale: CGFloat) -> CGSize {
        let sized = scaledImageSize(for: currentScale)
        return CGSize(
            width: max(0, (sized.width - circleSize) / 2),
            height: max(0, (sized.height - circleSize) / 2)
        )
    }

    private func clampedTranslation(_ translation: CGSize) -> CGSize {
        let maxOff = maxAllowedOffset(for: effectiveScale)
        let clampedX = min(max(offset.width  + translation.width,  -maxOff.width),  maxOff.width)
        let clampedY = min(max(offset.height + translation.height, -maxOff.height), maxOff.height)
        return CGSize(
            width: clampedX - offset.width,
            height: clampedY - offset.height
        )
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button("Cancel", action: onCancel)
                .foregroundStyle(.white)
                .font(.body)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    rotation += .degrees(90)
                }
                DispatchQueue.main.async {
                    let maxOff = maxAllowedOffset(for: scale)
                    offset = CGSize(
                        width: min(max(offset.width, -maxOff.width), maxOff.width),
                        height: min(max(offset.height, -maxOff.height), maxOff.height)
                    )
                }
            } label: {
                Label("Rotate", systemImage: "rotate.left")
                    .font(.body)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))

            Spacer()

            Button("Choose") {
                savePhoto()
            }
            .foregroundStyle(.white)
            .font(.body)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Save

    private func savePhoto() {
        let editedView = Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .scaleEffect(effectiveScale)
            .rotationEffect(rotation)
            .offset(effectiveOffset)
            .frame(width: circleSize, height: circleSize)
            .clipShape(Circle())

        let renderer = ImageRenderer(content: editedView)
        renderer.scale = displayScale

        if let uiImage = renderer.uiImage {
            onSave(uiImage)
        }
    }
}

// MARK: - Circle Cutout Overlay

struct CircleCutoutOverlay: View {
    let size: CGFloat

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(Color.black.opacity(0.55))
                .mask(
                    Rectangle()
                        .overlay(
                            Circle()
                                .frame(width: size, height: size)
                                .blendMode(.destinationOut)
                        )
                        .compositingGroup()
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}
