import Foundation
import AssetsLibrary
import AVFoundation
import UIKit

@objc(VideoEditor) class VideoEditor : CDVPlugin {
    func edit(command: CDVInvokedUrlCommand) {
        var sourceURL:String = command.argumentAtIndex(0) as String
        NSLog("SOURCE URL: \(sourceURL)")
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
    }

    
    
    func capture(sourcePath:String){
        
        var outputPath = sourcePath
        outputPath = outputPath.stringByDeletingPathExtension
        outputPath = outputPath.stringByAppendingString(".jpg")
        
        var assetURL = NSURL.fileURLWithPath(sourcePath)
        
        var videoAsset:AVAsset = AVURLAsset.assetWithURL(assetURL) as AVAsset
        
        var generator:AVAssetImageGenerator = AVAssetImageGenerator(asset: videoAsset)
        
        var cgImage:CGImage = generator.copyCGImageAtTime(CMTimeMake(0, 1) , actualTime: nil, error: nil)
        
        var image = UIImage(CGImage: cgImage)
        
        var binaryImageData:NSData = UIImageJPEGRepresentation(image,0.5);
        binaryImageData.writeToFile(outputPath, atomically: true)
        
        var library:ALAssetsLibrary = ALAssetsLibrary()
        library.writeImageToSavedPhotosAlbum(cgImage, orientation: ALAssetOrientation.Up) { (saved, err) -> Void in
            NSLog("saved url : \(saved)")
        }
    }
    
    
    func transfer(sourceURL:String){
        
        //        var compatiblePresets:[AnyObject] = AVAssetExportSession.exportPresetsCompatibleWithAsset(videoAsset)
        
        var assetUrl = NSURL(fileURLWithPath: sourceURL)
        
        var video_quality:String = AVAssetExportPresetLowQuality;
        
        var optimizeForNetworkUse:Bool = true
        
        var stringOutputFileType:String = AVFileTypeMPEG4
        
        var presetName = AVAssetExportPresetLowQuality;
        
        var manager:NSFileManager = NSFileManager.defaultManager()
        var ext = manager.fileExistsAtPath(sourceURL)
        NSLog(" file is exist \(ext)")
        
        var outputURL = sourceURL
        outputURL = outputURL.stringByDeletingPathExtension
        outputURL = outputURL.stringByAppendingString(".mp4")
        
        var assetOutputURL = NSURL.fileURLWithPath(outputURL)
        var videoAsset:AVAsset = AVURLAsset.assetWithURL(assetUrl) as AVAsset
        
        
        var exportSession = AVAssetExportSession(asset: videoAsset,presetName: AVAssetExportPresetLowQuality)
        
        exportSession.outputURL = assetOutputURL;
        
        exportSession.outputFileType = stringOutputFileType;
        exportSession.shouldOptimizeForNetworkUse = optimizeForNetworkUse;
        
        
        exportSession.exportAsynchronouslyWithCompletionHandler(){
            () -> Void in
            switch(exportSession.status){
            case .Completed:
                NSLog("Success")
                ext = manager.fileExistsAtPath(outputURL)
                NSLog("output file is exist \(ext)")
                self.writeVideoToPhotoLibrary(assetOutputURL!)
            case .Unknown:
                NSLog("Unknown")
            case .Waiting:
                NSLog("Waiting")
            case .Exporting:
                NSLog("Exporting")
            case .Failed:
                var _error = exportSession.error
                
                NSLog("Failed : \(_error)")
            case .Cancelled:
                NSLog("Cancelled")
            default:
                NSLog("ddd\(exportSession.status)")
            }
            
        }
    }
    
    func writeVideoToPhotoLibrary(url:NSURL) {
        var library:ALAssetsLibrary = ALAssetsLibrary()
        if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(url){
            library.writeVideoAtPathToSavedPhotosAlbum(url, completionBlock: nil)
        }
    }
    
}