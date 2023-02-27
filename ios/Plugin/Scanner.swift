//
//  Scanner.swift
//  plugin_dataScanner
//
//

import Foundation
import VisionKit
import SwiftUI

@available(iOS 16.0, *)
@objc(DataScannerTest)
class DataScannerTest : NSObject {
    
    @MainActor @objc func scanningIsSupported() ->Bool {
        return DataScannerViewController.isSupported
    }
    
    @MainActor @objc func scanningIsAvailable() ->Bool {
        return DataScannerViewController.isAvailable
    }
}

@available(iOS 16.0, *)
@objc(Scanner)
class Scanner : NSObject {

    
    @MainActor var myCon : DataScannerViewController
    @MainActor static var myCoordinator: Coordinator = Coordinator()
    @MainActor static var myScannerHolder: scannerHolder = scannerHolder()
    
    @MainActor @objc override init() {
        self.myCon = DataScannerViewController(recognizedDataTypes:[])
    }
    
    
    @MainActor @objc func makeUIViewController(_ isHighFrameRateTrackingEnabled: Bool, isHighlightingEnabled:Bool, recognizesMultipleItems:Bool, supportBarCode:Bool, supportText:Bool) ->UIViewController {
        var dataType: Set<DataScannerViewController.RecognizedDataType> = [];
        if(supportBarCode){
            dataType.insert(.barcode())
        }
        if(supportText){
            dataType.insert(.text())
        }
        self.myCon = DataScannerViewController(
            recognizedDataTypes: dataType,
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isHighFrameRateTrackingEnabled: isHighFrameRateTrackingEnabled,
            isGuidanceEnabled: false,
            isHighlightingEnabled: isHighlightingEnabled
        )
        self.myCon.delegate = Scanner.myCoordinator
        self.myCon.isModalInPresentation = false
        self.myCon.presentationController?.delegate = Scanner.myCoordinator
        
        return self.myCon
    }
    @MainActor @objc func startScanning(){
        try? self.myCon.startScanning()
    }
    @MainActor @objc func stopScanning(){
        self.myCon.stopScanning()
    }
    
    @MainActor @objc func scanningIsSupported() ->Bool {
        return DataScannerViewController.isSupported
    }
    
    @MainActor @objc func scanningIsAvailable() ->Bool {
        return DataScannerViewController.isAvailable
    }
    
    class Coordinator: UIViewController, DataScannerViewControllerDelegate,UIAdaptivePresentationControllerDelegate {
            
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
                case .text(let text):
                    myScannerHolder.gotText(text.transcript)
                case .barcode(let code):
                    myScannerHolder.gotBarcode(code.payloadStringValue)
                default:
                    break
            }
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
//            print("PRESENTATIONCONTROLLER: presentationControllerDidDismiss:")
            myScannerHolder.closeDataScanner()
        }
        
    }
}

/// Delegate methods for `DataScannerViewController`
