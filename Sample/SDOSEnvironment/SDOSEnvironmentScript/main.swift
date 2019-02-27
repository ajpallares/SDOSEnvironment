//
//  main.swift
//  SDOSEnvironmentScript
//
//  Created by Rafael Fernandez Alvarez on 27/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation

class ScriptAction {
    var pwd: String!
    var input: String!
    var output: String!
    var password: String!
    
    var parameters = [ConsoleParameter]()
    
    
    func start(args: [String]) {
        registerParameters()
        
        if managerArgs(args: args) {
            executeAction()
        } else {
            printUsage()
        }
    }
    
    func executeAction() {
        encrypt()
    }
    
    func registerParameters() {
        let parameter0 = ConsoleParameter(numArgs: 0) { values in
            self.pwd = FileManager.default.currentDirectoryPath
            return true
        }
        parameters.append(parameter0)
        
        let parameter1 = ConsoleParameter(numArgs: 1, option: "-i") { values in
            var result = values[1]
            if let pwd = self.pwd, !result.hasPrefix("/") {
                result = "\(pwd)/\(result)"
            }
            self.input = result
            return true
        }
        parameters.append(parameter1)
        
        let parameter2 = ConsoleParameter(numArgs: 1, option: "-o") { values in
            var result = values[1]
            if let pwd = self.pwd, !result.hasPrefix("/") {
                result = "\(pwd)/\(result)"
            }
            self.output = result
            return true
        }
        parameters.append(parameter2)
        
        let parameter3 = ConsoleParameter(numArgs: 1, option: "-b") { values in
            let result = values[1]
            self.password = self.generatePassword(bundle: result)
            return true
        }
        parameters.append(parameter3)
        
        let parameter4 = ConsoleParameter(numArgs: 1, option: "-p") { values in
            let result = values[1]
            if self.password != nil {
                self.password = result
            }
            return true
        }
        parameters.append(parameter4)
        
    }
    
    func generatePassword(bundle: String) -> String {
        var password = ""
        var bytes = [UInt8]()
        let characters = Array(bundle)
        characters.forEach { (character) in
            var char = character.asciiValue ?? 0
            char += 7
            bytes.append(char)
        }
        if let string = String(bytes: bytes, encoding: .utf8) {
            password = string
        }
        
        return password
    }
    
    func encrypt() {
        do {
            let url = URL(fileURLWithPath: input)
            let data = try Data(contentsOf: url)
            let encryptor = RNCryptor.EncryptorV3(password: password)
            let encryptData = encryptor.encrypt(data: data)
            try encryptData.write(to: URL(fileURLWithPath: output))
        } catch {
            print("Fallo durante la encriptación. Comprueba que el fichero de entrada es correcto. Ruta de entrada: \"\(input!)\"")
            exit(1)
        }
    }
    
    func printUsage() {
        print("Los valores validos son los siguientes")
        print("-i ruta del fichero de entrada. Debe ser un .plist (Ejemplo: environments.plist)")
        print("-o ruta del fichero de salida. Debe incluir el nombre del fichero a generar (Ejemplo: environments.bin)")
        print("-b Bundle identifier de la aplicación. Se usará para generar la contraseña del fichero encriptado en base a éste")
        print("-p Contraseña usada para encriptar el fichero. Si se indica el parámetro -b, éste no tendrá efecto")
    }
    
    
    //MARK: - Manager arguments
    
    func managerArgs(args: [String]) -> Bool {
        var result = true
        
        var i = 0
        while (i < args.count) {
            var isCorrect = true
            let option = args[i]
            var consoleParameter: ConsoleParameter?
            if i == 0 {
                consoleParameter = getConsoleParameter(option: nil)
            } else {
                if(isArg(option: option)) {
                    consoleParameter = getConsoleParameter(option: option)
                }
            }
            
            if let consoleParameter = consoleParameter {
                var arrayValues = [String]()
                arrayValues.append(option)
                for _ in 0..<consoleParameter.numArgs {
                    i += 1
                    if i < args.count {
                        arrayValues.append(args[i])
                    } else {
                        isCorrect = false
                        break
                    }
                }
                
                if isCorrect {
                    isCorrect = consoleParameter.actionExecute(arrayValues)
                }
            } else {
                isCorrect = false
            }
            
            if !isCorrect {
                result = false
                break
            }
            i += 1
        }
        return result
    }
    
    func getConsoleParameter(option: String?) -> ConsoleParameter? {
        var result: ConsoleParameter? = nil
        
        for consoleParameter in parameters {
            if let option = option {
                if option == consoleParameter.option {
                    result = consoleParameter
                    break
                }
            } else if consoleParameter.option == nil {
                result = consoleParameter
                break
            }
        }
        return result
    }
    
    func isArg(option: String) -> Bool {
        var result = false
        if option.hasPrefix("-") {
            result = true
        }
        return result
    }
    
}

ScriptAction().start(args: CommandLine.arguments)
