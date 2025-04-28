//
//  ContentView.swift
//  OCRSampleApp
//
//  Created by NanbanTaro on 2025/04/28.
//  
//

import SwiftUI

struct ContentView: View {
    @State var text = ""
    @State var showingScanner = false
    @State var scanningType = ScanningType.text

    var body: some View {
        VStack {
            TextField(text: $text, axis: .vertical) {
                EmptyView()
            }
            .textFieldStyle(.roundedBorder)
            .labelsHidden()
            .lineLimit(10, reservesSpace: true)
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    scanningType = .text
                    showingScanner = true
                } label: {
                    Image(systemName: "text.viewfinder")
                }
                Button {
                    scanningType = .qrCode
                    showingScanner = true
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                }
            }
        }
        .scanner(
            isPresented: $showingScanner,
            value: Binding<String?>(get: { nil }, set: { text += $0 ?? "" }),
            type: scanningType
        )
    }
}

#Preview {
    ContentView()
}
