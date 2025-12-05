//
//  ImagePickerView.swift
//  MediFamily
//
//  Created by Cường Trần on 05/12/25.
//

import SwiftUI
import PhotosUI

// MARK: - Camera Image Picker (UIKit wrapper)
struct CameraImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraImagePicker
        
        init(_ parent: CameraImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Multi-Image Camera Picker
struct MultiCameraImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: MultiCameraImagePicker
        
        init(_ parent: MultiCameraImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.images.append(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Photo Source Action Sheet
struct PhotoSourceSheet: View {
    let onCameraSelected: () -> Void
    let onLibrarySelected: () -> Void
    @ObservedObject private var lang = LanguageManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            Text(lang.localized("photo.source.title"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.Colors.text)
                .padding(.bottom, 16)
            
            VStack(spacing: 12) {
                // Camera option
                Button(action: onCameraSelected) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.primary.opacity(0.15))
                                .frame(width: 50, height: 50)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.Colors.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lang.localized("photo.source.camera"))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.Colors.text)
                            Text(lang.localized("photo.source.camera.desc"))
                                .font(.system(size: 13))
                                .foregroundColor(Theme.Colors.text.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.Colors.text.opacity(0.3))
                    }
                    .padding(16)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
                
                // Library option
                Button(action: onLibrarySelected) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.accent.opacity(0.15))
                                .frame(width: 50, height: 50)
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.Colors.accent)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lang.localized("photo.source.library"))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.Colors.text)
                            Text(lang.localized("photo.source.library.desc"))
                                .font(.system(size: 13))
                                .foregroundColor(Theme.Colors.text.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.Colors.text.opacity(0.3))
                    }
                    .padding(16)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Theme.Colors.background)
        .cornerRadius(Theme.CornerRadius.large, corners: [.topLeft, .topRight])
    }
}

// MARK: - Photos Picker Sheet (Single Image)
struct PhotosPickerSheet: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Text("Select Photo")
        }
        .photosPickerStyle(.inline)
        .photosPickerAccessoryVisibility(.hidden)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Photos Picker Sheet (Multiple Images)
struct MultiPhotosPickerSheet: View {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: [PhotosPickerItem] = []
    @ObservedObject private var lang = LanguageManager.shared

    var body: some View {
        NavigationStack {
            PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images) {
                Text("Select Photos")
            }
            .photosPickerStyle(.inline)
            .photosPickerAccessoryVisibility(.hidden)
            .onChange(of: selectedItems) { _, newItems in
                Task {
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run {
                                if !selectedImages.contains(where: { $0.pngData() == image.pngData() }) {
                                    selectedImages.append(image)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(lang.localized("photo.source.library"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.localized("button.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

