//
//  Utility.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/28/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import AVFoundation
import AudioPlayer

class CRFUtility: NSObject {

    private static var sound1: AudioPlayer?
    private static var sound2: AudioPlayer?
    private static let speechSynthesizer = AVSpeechSynthesizer()
    
    static func speak(_ text: String)
    {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice  = AVSpeechSynthesisVoice(language: "en-US")
        speechUtterance.rate = 0.5
        
        CRFUtility.speechSynthesizer.speak(speechUtterance)
    }
    
    static func stopSpeak()
    {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    static func setupAudioSounds()
    {
        do {
            CRFUtility.sound1 = try AudioPlayer(fileName: "beep1.mp3")
            CRFUtility.sound1!.volume = 1
            CRFUtility.sound2 = try AudioPlayer(fileName: "beep2.mp3")
            CRFUtility.sound2!.volume = 1
        } catch {
            print("Sound initialization failed")
        }
    }
    static func playBeepSound(_ playSound1: Bool)
    {
        if playSound1 {
            CRFUtility.sound1?.play()
        } else {
            CRFUtility.sound2?.play()
        }
    }
}


