//
//  main.swift
//  SDOSEnvironmentScript
//
//  Created by Rafael Fernandez Alvarez on 27/02/2019.
//  Copyright © 2019 SDOS. All rights reserved.
//

import Foundation

extension String {
    func lowerCaseFirstLetter() -> String {
        return prefix(1).lowercased() + self.dropFirst()
    }
    
    mutating func lowerCaseFirstLetter() {
        self = self.lowerCaseFirstLetter()
    }
}

class ScriptAction {
    var pwd: String!
    var input: String!
    var output: String!
    var outputFile: String!
    var password: String!
    var validateEnvironment: String?
    
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
        validateInputOutput()
        validateFile()
        encrypt()
        generateFile()
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
        
        let parameter5 = ConsoleParameter(numArgs: 1, option: "-of") { values in
            var result = values[1]
            if let pwd = self.pwd, !result.hasPrefix("/") {
                result = "\(pwd)/\(result)"
            }
            self.outputFile = result
            return true
        }
        parameters.append(parameter5)
        
        let parameter6 = ConsoleParameter(numArgs: 1, option: "-validate") { values in
            let result = values[1]
            self.validateEnvironment = result
            return true
        }
        parameters.append(parameter6)
        
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
            let urlFinal = URL(fileURLWithPath: output)
            unlockFile(output)
            try encryptData.write(to: urlFinal)
            lockFile(output)
            print("Fichero \(input!) encriptado correctamente en la ruta \(output!)")
        } catch {
            print("Fallo durante la encriptación. Comprueba que el fichero de entrada es correcto. Ruta de entrada: \"\(input!)\"")
            exit(6)
        }
    }
    
    func printUsage() {
        print("Los valores válidos son los siguientes")
        print("-i Ruta del fichero de entrada. Debe ser un .plist (Ejemplo: environments.plist)")
        print("-o Ruta del fichero encriptado de salida. Debe incluir el nombre del fichero a generar (Ejemplo: environments.bin)")
        print("-b Bundle identifier de la aplicación. Se usará para generar la contraseña del fichero encriptado en base a éste")
        print("-p Contraseña usada para encriptar el fichero. Si se indica el parámetro -b, éste no tendrá efecto")
        print("-of Ruta del fichero autogenerado de salida. Debe incluir el nombre del fichero a generar (Ejemplo: SDOSEnvironment.swift)")
        print("-validate String correspondiente al entorno que se quiere validar. La validación comprobará que todas las claves indicadas en el fichero tengan un valor para el entorno definido")
    }
    
    //MARK: - Parse plist
    
    func readPropertyList() -> [String]? {
        var keys: [String]? = nil
        do {
            var propertyListForamt =  PropertyListSerialization.PropertyListFormat.xml
            let url = URL(fileURLWithPath: input)
            let data = try Data(contentsOf: url)
            let plistData = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &propertyListForamt) as? [String: AnyObject]
            if let plistData = plistData {
                keys = Array(plistData.keys)
            }
        } catch {
            print("Fallo durante el tratamiento del plist. Comprueba que el fichero de entrada es correcto. Ruta de entrada: \"\(input!)\"")
            exit(5)
        }
        keys = keys?.sorted { $0 < $1 }
        return keys
    }
    
    func generateFile() {
        let keys = readPropertyList()
        var file = ""
        file.append(contentsOf: generateComment())
        file.append(contentsOf: generateImplementation(keys: keys))
        
        do {
            unlockFile(outputFile)
            try file.write(to: URL(fileURLWithPath: outputFile), atomically: true, encoding: .utf8)
            lockFile(outputFile)
        } catch {
            print("Fallo durante la generación del fichero autogenerado. Comprueba que el fichero de entrada es correcto. Ruta de entrada: \"\(input!)\"")
            exit(4)
        }
        
    }
    
    func generateComment() -> String {
        var name = ""
        if let url = URL(string: self.outputFile) {
            name = url.lastPathComponent
        }
        var result = ""
        result.append(contentsOf: "//  This is a generated file, do not edit!\n")
        result.append(contentsOf: "//  \(name)\n")
        result.append(contentsOf: "//\n")
        result.append(contentsOf: "//  Created by SDOS\n")
        result.append(contentsOf: "//\n")
        result.append(contentsOf: "\n")
        result.append(contentsOf: "import Foundation\n")
        result.append(contentsOf: "import SDOSEnvironment\n")
        result.append(contentsOf: "\n")
        return result
    }
    
    func generateImplementation(keys: [String]?) -> String {
        var result = ""
        if let keys = keys {
            var fileRelativePath = input!
            fileRelativePath = fileRelativePath.replacingOccurrences(of: self.pwd, with: "")
            
            result.append(contentsOf: "")
            result.append(contentsOf: "/// This Environment is generated and contains static references to \(keys.count) variables\n")
            result.append(contentsOf: "/// Reference file: \(fileRelativePath.replacingOccurrences(of: pwd, with: ""))\n")
            result.append(contentsOf: "struct Environment {\n")
            result.append(contentsOf: "\tprivate init() { }\n")
            
            for item in keys {
                result.append(contentsOf: "\t/// Variable reference: \(item)\n")
                result.append(contentsOf: "\tstatic var \(item.lowerCaseFirstLetter()): String { return SDOSEnvironment.getValue(key: \"\(item)\") }\n")
            }
        }
        result.append(contentsOf: "}")
        return result
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

extension ScriptAction {
    
    typealias EnvironmentType = [String: [String: Any]]
    
    func validateFile() {
        if let validateEnvironment = validateEnvironment {
            do {
                let url = URL(fileURLWithPath: input)
                let data = try Data(contentsOf: url)
                if let values = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? EnvironmentType {
                    values.forEach { (key, value) in
                        let finalValue = normalizeValue(value: value[validateEnvironment])
                        guard !finalValue.isEmpty else {
                            print("Falta el valor para la clave \"\(key)\" en el entorno \"\(validateEnvironment)\"")
                            exit(2)
                        }
                    }
                }
                print("Fichero \(input!) válido para el entorno \"\(validateEnvironment)\"")
            } catch {
                print("Fallo durante la inicialización. Comprueba el fichero \(input!) tiene un formato correcto")
                exit(3)
            }
        }
    }
    
    func normalizeValue(value: Any?) -> String {
        var finalValue = ""
        switch value {
        case let value as String:
            finalValue = String(value)
        case let value as Int:
            finalValue = String(value)
        case let value as Float:
            finalValue = String(value)
        case let value as Double:
            finalValue = String(value)
        case let value as Bool:
            finalValue = String(value)
        default: break
        }
        return finalValue
    }

}

extension ScriptAction {
    enum TypeParams: String {
        case INPUT
        case OUTPUT
    }
    
    func validateInputOutput() {
        checkInput(params: parseParams(type: .INPUT), sources: [self.input])
        checkOutput(params: parseParams(type: .OUTPUT), sources: [self.output, self.outputFile])
    }
    
    func parseParams(type: TypeParams) -> [String] {
        var params = [String]()
        if let numString = ProcessInfo.processInfo.environment["SCRIPT_\(type.rawValue)_FILE_COUNT"] {
            if let num = Int(numString) {
                for i in 0...num {
                    if let param = ProcessInfo.processInfo.environment["SCRIPT_\(type.rawValue)_FILE_\(i)"] {
                        params.append(param)
                    }
                }
            }
        }
        return params
    }
    
    func checkInput(params: [String], sources: [String]) {
        checkInputOutput(params: params, sources: sources, message: "Build phase Intput Files does not contain")
    }
    
    func checkOutput(params: [String], sources: [String]) {
        checkInputOutput(params: params, sources: sources, message: "Build phase Output Files does not contain")
    }
    
    func checkInputOutput(params: [String], sources: [String], message: String) {
        for source in sources {
            if !params.contains(source) {
                print("[SDOSEnvironment] - \(message) '\(source.replacingOccurrences(of: pwd, with: "${SRCROOT}"))'.")
                exit(7)
            }
        }
    }
}

extension ScriptAction {
    func unlockFile(_ path: String) {
        shell("chflags", "-R", "nouchg", path)
    }
    
    func lockFile(_ path: String) {
        shell("chflags", "uchg", path)
    }
    
    @discardableResult
    func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}

ScriptAction().start(args: CommandLine.arguments)
