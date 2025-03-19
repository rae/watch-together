//
//  DocuemtnPickerDelegateHandler.swift
//  WatchItTogether
//
//  Created by Reid Ellis on 2025-03-15.
//

import SwiftUI
import UniformTypeIdentifiers

class DocumentPickerDelegateHandler: NSObject, UIDocumentPickerDelegate {
    private let completion: ([URL]) -> Void
    
    init(completion: @escaping ([URL]) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        completion(urls)
    }
}

// Helper extension to simplify document picker creation
extension UIDocumentPickerViewController {
    static func createPicker(forContentTypes contentTypes: [UTType],
                            completion: @escaping ([URL]) -> Void) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        let delegate = DocumentPickerDelegateHandler(completion: completion)
        // Store the delegate as an associated object to prevent it from being deallocated
        picker.delegate = delegate
        objc_setAssociatedObject(picker, &AssociatedObjectKey.delegateKey, delegate, .OBJC_ASSOCIATION_RETAIN)
        return picker
    }
}

// Define a key for associated objects
private enum AssociatedObjectKey {
    static var delegateKey: UInt8 = 0
}
