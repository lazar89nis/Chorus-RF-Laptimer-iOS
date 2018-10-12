//
//  Identifiers.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 8/22/18.
//  Copyright © 2018 Lazar. All rights reserved.
//

import Foundation

struct CellId
{
    static let freqTVC = "FreqTVC"
    static let bluetoothTVC = "BluetoothTVC"
    static let racePilotLapTVC = "RacePilotLapTVC"
    static let racePilotTVC = "RacePilotTVC"
    static let pilotTVC = "PilotTVC"
}

struct UserDefaultsId
{
    static let timeToPrepareForRace = "TimeToPrepareForRace"
    static let lapsToGo = "LapsToGo"
    static let speakMessages = "SpeakMessages"
    static let speakLapTimes = "SpeakLapTimes"
    static let voltageAdjustment = "VoltageAdjustment"
    static let voltageMonitorOn = "VoltageMonitorOn"
    static let isBTMode = "IsBTMode"
    static let phoneSleep = "PhoneSleep"
    
}

struct NotificationCenterId
{
    static let reloadTableData = "ReloadTableData"
    static let setScanButtonState = "SetScanButtonState"
    static let showHudWithText = "ShowHudWithText"
    static let serialDidDisconnect = "SerialDidDisconnect"
    static let startBTRSSI = "StartBTRSSI"
    static let hideHud = "HideHud"
    static let setStatusText = "SetStatusText"
    static let UDPConnected = "UDPConnected"
    static let RSSIchanged = "RSSIchanged"
    static let RSSIchangedSpectrum = "RSSIchangedSpectrum"
    static let newTimeRecorded = "NewTimeRecorded"
    static let thresholdUpdated = "ThresholdUpdated"
    static let voltageUpdated = "VoltageUpdated"
    static let calibrationTimeReceved = "CalibrationTimeReceved"
    static let reportStageChanged = "ReportStageChanged"
    static let frequencyChangedSpectrum = "FrequencyChangedSpectrum"
    static let RSSISupdated = "RSSISupdated"
}

enum ViewControllerId
{
    static let navController = "navController"
    static let graphVC = "GraphVC"
}

enum StoryboardId
{
    static let mainStoryboard = "Main"
}
