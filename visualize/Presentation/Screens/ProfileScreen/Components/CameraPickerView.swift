//
//  CameraPickerView.swift
//  visualize
//
//  Created by Mariana Islas on 21/05/26.
//

import SwiftUI
import UIKit

// MARK: - Camera Picker View

struct CameraPickerView: UIViewControllerRepresentable {

    // MARK: - Internal properties

    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    // MARK: - Internal methods

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

    // MARK: - Coordinator

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        // MARK: - Internal properties

        let parent: CameraPickerView

        // MARK: - Initialization

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        // MARK: - Internal methods

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
