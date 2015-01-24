import Foundation
import AssetsLibrary
import AVFoundation
import UIKit

@objc(VideoEditor) class VideoEditor : CDVPlugin {
    func edit(command: CDVInvokedUrlCommand) {
        
        var option:NSDictionary = command.argumentAtIndex(0)! as NSDictionary
        var sourcePath = option.objectForKey("path")! as String
        var opt = option.objectForKey("opt")! as String
        
        NSLog("SOURCE URL: \(sourcePath)")
        NSLog("operation \(opt)")
        
        switch opt {
            case "screenshot":
                capture(sourcePath,command: command)
            case "transcode":
                transcode(sourcePath,command: command)
            default:
                var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
                commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        }
        
    }

    
    
    func capture(sourcePath:String,command: CDVInvokedUrlCommand){
        var outputPath = sourcePath
        outputPath = outputPath.stringByDeletingPathExtension
        outputPath = outputPath.stringByAppendingString(".jpg")
        
        var videoAsset:AVAsset = AVURLAsset.assetWithURL(NSURL.fileURLWithPath(sourcePath)) as AVAsset
        
        var generator:AVAssetImageGenerator = AVAssetImageGenerator(asset: videoAsset)
        
        var cgImage:CGImage = generator.copyCGImageAtTime(CMTimeMake(0, 1) , actualTime: nil, error: nil)
        
        var image = UIImage(CGImage: cgImage)
        
        var binaryImageData:NSData = UIImageJPEGRepresentation(image,0.5);
        
        var result = binaryImageData.writeToFile(outputPath, atomically: true)
        
        NSLog("capture video status :\(result)")
        if result {
            var data = NSDictionary(dictionary:["screenshot":outputPath])
            var pluginResult = CDVPluginResult(status: CDVCommandStatus_OK,messageAsDictionary:data)
            commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        }else{
            var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
            commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        }
        
//
//        var library:ALAssetsLibrary = ALAssetsLibrary()
//        library.writeImageToSavedPhotosAlbum(cgImage, orientation: ALAssetOrientation.Up) { (saved, err) -> Void in
//            NSLog("saved url : \(saved)")
//        }
    }
    
    
    func transcode(sourceURL:String,command: CDVInvokedUrlCommand){
        
        //        var compatiblePresets:[AnyObject] = AVAssetExportSession.exportPresetsCompatibleWithAsset(videoAsset)
        
        var assetUrl = NSURL(fileURLWithPath: sourceURL)
        
        var video_quality:String = AVAssetExportPresetLowQuality;
        
        var optimizeForNetworkUse:Bool = true
        
        var stringOutputFileType:String = AVFileTypeMPEG4
        
        var presetName = AVAssetExportPresetLowQuality;
        
        var manager:NSFileManager = NSFileManager.defaultManager()
        var ext = manager.fileExistsAtPath(sourceURL)
        
        var outputURL = sourceURL
        outputURL = outputURL.stringByDeletingPathExtension
        outputURL = outputURL.stringByAppendingString(".mp4")
        
        var assetOutputURL = NSURL.fileURLWithPath(outputURL)
        var videoAsset:AVAsset = AVURLAsset.assetWithURL(assetUrl) as AVAsset
        
        
        var exportSession = AVAssetExportSession(asset: videoAsset,presetName: AVAssetExportPresetLowQuality)
        
        exportSession.outputURL = assetOutputURL;
        
        exportSession.outputFileType = stringOutputFileType;
        exportSession.shouldOptimizeForNetworkUse = optimizeForNetworkUse;
        
        var _self = self
        exportSession.exportAsynchronouslyWithCompletionHandler(){
            () -> Void in
            switch(exportSession.status){
            case .Completed:
                var data = NSDictionary(dictionary:["target":outputURL])
                var pluginResult = CDVPluginResult(status: CDVCommandStatus_OK,messageAsDictionary:data)
                _self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
                return
                //                self.writeVideoToPhotoLibrary(assetOutputURL!)
            case .Unknown:
                NSLog("Unknown")
            case .Waiting:
                NSLog("Waiting")
            case .Exporting:
                NSLog("Exporting")
            case .Failed:
                NSLog("Failed : \(exportSession.error)")
            case .Cancelled:
                NSLog("Cancelled")
            default:
                NSLog("\(exportSession.status)")
            }
            
            var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
            _self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            
        }
    }
    
//    func writeVideoToPhotoLibrary(url:NSURL) {
//        var library:ALAssetsLibrary = ALAssetsLibrary()
//        if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(url){
//            library.writeVideoAtPathToSavedPhotosAlbum(url, completionBlock: nil)
//        }
//    }
    
}