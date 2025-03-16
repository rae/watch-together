//
//  DocuemtnPickerDelegateHandler.swift
//  WatchTogether
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

struct DocumentPickerViewController: UIDocumentPickerViewController {
    var delegate: UIDocumentPickerDelegate?
    
    override var documentPickerDelegate: UIDocumentPickerDelegate? {
        get { return delegate }
        set { delegate = newValue }
    }
}
