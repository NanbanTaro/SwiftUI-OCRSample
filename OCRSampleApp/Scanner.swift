//
//  Scanner.swift
//  OCRSampleApp
//
//  Created by NanbanTaro on 2025/04/28.
//  
//

import SwiftUI
import VisionKit

private struct Scanner: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var value: String?
    var type: ScanningType

    func makeUIViewController(context: Context) -> DataScannerViewController {
        // ここでスキャナーの仕様をいろいろ設定する
        let controller = DataScannerViewController(
            recognizedDataTypes: [type.dataType],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isHighlightingEnabled: true
        )
//        controller.regionOfInterest = CGRect(x: 0, y: 0, width: 200, height: 200)
        controller.delegate = context.coordinator
        try? controller.startScanning()
        return controller
    }

    func updateUIViewController(
        _ controller: DataScannerViewController,
        context: Context
    ) {}

    static func dismantleUIViewController(
        _ controller: DataScannerViewController,
        coordinator: Coordinator
    ) {
        controller.stopScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator { value in
            self.value = value
            dismiss()
        }
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onScan: (String?) -> Void

        init(onScan: @escaping (String?) -> Void) {
            self.onScan = onScan
        }

        // 認識した対象物をタップした時に呼び出されるdelegate関数
        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didTapOn item: RecognizedItem
        ) {
            switch item {
            case let .barcode(value):
                onScan(value.payloadStringValue)
            case let .text(value):
                onScan(value.transcript)
            @unknown default:
                break
            }
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            let midX = dataScanner.view.bounds.midX
            var leftText = [String]()
            var rightText = [String]()
            for item in allItems {
                guard case .text(let text) = item else { continue }
                let box = item.bounds
                if box.topRight.x < midX {
                    leftText.append(text.transcript)
                } else if box.topLeft.x <= midX {
                    rightText.append(text.transcript)
                }
            }
            print("leftText: ", leftText)
            print("rightText: ", rightText)
        }
    }
}

// 今回はテキストとQRコードの両方に対応するため、Type Safeを意識してenumにした
enum ScanningType {
    case text
    case qrCode

    var dataType: DataScannerViewController.RecognizedDataType {
        switch self {
            case .text:
            return .text(languages: ["ja"])
        case .qrCode:
            return .barcode(symbologies: [.qr])
        }
    }
}


extension View {
    func scanner(isPresented: Binding<Bool>, value: Binding<String?>, type: ScanningType) -> some View {
        sheet(isPresented: isPresented) {
            Scanner(value: value, type: type)
        }
    }
}
