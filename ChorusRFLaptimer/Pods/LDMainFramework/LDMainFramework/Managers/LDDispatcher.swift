//
//  LDDispatcher.swift
//
//  Created by Lazar on 6/12/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import Foundation


/// LDDispatcher class which handles number of tasks which are in progress in order to perform some operation when all tasks are finished.
open class LDDispatcher: NSObject {

    /// Number of tasks which are in progress.
    open var tasksToFinish: Int = 0
    
    /// Completion handler, i.e. operation which has to be performed when all tasks are finished (when tasksToFinish = 0)
    open var completionHandler: () -> Void = {}

    /// Method for setting completion handler.
    ///
    /// - Parameter handler: Operation which has to be performed when all tasks are finished.
    open func setCompletitionHandler(handler: @escaping () -> Void)
    {
        completionHandler = handler
    }
    
    /// Signal that a task has started.
    open func startTask()
    {
        tasksToFinish += 1
    }
    
    /// Signal that a task is done and to check if all tasks are done.
    open func endTask()
    {
        tasksToFinish -= 1
        
        checkIfAllTasksDone()
    }
    
    /// Check if all tasks are done. If it is true, then completion handler is performed.
    open func checkIfAllTasksDone()
    {
        if tasksToFinish == 0
        {
            completionHandler()
        } else if tasksToFinish < 0
        {
            print("***************************************************************** tasksToFinish NEGATIVE *****************************************************************")
        }
    }
}
