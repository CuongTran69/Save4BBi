//
//  FullScreenPhotoViewer.swift
//  Save4BBi
//
//  Created by Cường Trần on 28/11/25.
//

import SwiftUI

struct FullScreenPhotoViewer: View {
    let images: [UIImage]
    let initialIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentIndex: Int
    
    init(images: [UIImage], initialIndex: Int = 0) {
        self.images = images
        self.initialIndex = initialIndex
        _currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if !images.isEmpty {
                TabView(selection: $currentIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        ZoomableImageView(image: image)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 3)
                    }
                    .padding()
                }
                Spacer()
            }
            
            // Photo counter
            VStack {
                Spacer()
                Text("\(currentIndex + 1) / \(images.count)")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(Theme.CornerRadius.medium)
                    .padding(.bottom, Theme.Spacing.xl)
            }
        }
    }
}

// MARK: - Zoomable Image View
struct ZoomableImageView: View {
    let image: UIImage
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale = min(max(scale * delta, 1), 4)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            if scale < 1 {
                                withAnimation(.spring()) {
                                    scale = 1
                                    offset = .zero
                                }
                            }
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if scale > 1 {
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        if scale > 1 {
                            scale = 1
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2
                        }
                    }
                }
        }
    }
}

// #Preview {
//     FullScreenPhotoViewer(
//         images: [
//             UIImage(systemName: "photo")!,
//             UIImage(systemName: "photo.fill")!,
//             UIImage(systemName: "photo.circle")!
//         ],
//         initialIndex: 0
//     )
// }
