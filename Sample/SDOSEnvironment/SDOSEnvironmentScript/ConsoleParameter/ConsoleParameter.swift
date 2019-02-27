//
//  ConsoleParameter.swift
//  SDOSEnvironmentScript
//
//  Created by Rafael Fernandez Alvarez on 27/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation

typealias ConsoleAction = ([String]) -> Bool

struct ConsoleParameter {
    var option: String?
    var numArgs: Int
    var actionExecute: ConsoleAction
    
    init(numArgs: Int, actionExecute: @escaping ConsoleAction) {
        self.numArgs = numArgs
        self.actionExecute = actionExecute
    }
    
    init(numArgs: Int, option: String, actionExecute: @escaping ConsoleAction) {
        self.init(numArgs: numArgs, actionExecute: actionExecute)
        self.option = option
    }
}
