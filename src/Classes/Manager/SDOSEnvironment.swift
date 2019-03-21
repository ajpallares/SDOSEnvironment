//
//  SDOSEnvironment.swift
//  Pods-SDOSEnvironmentExample
//
//  Created by Rafael Fernandez Alvarez on 26/02/2019.
//

import Foundation
import RNCryptor

typealias EnvironmentType = [String: [String: Any]]
public let defaultEnvironmentKey = "Production"
let EnvionmentKeyInfoPlist = "EnvironmentKey"

@objc public class SDOSEnvironment: NSObject {
    
    private static let userDefaultEnvironmentkey = "SDOSEnvironment.key"
    private static let sharedInstance = SDOSEnvironment()
    private var environmentValues: EnvironmentType!
    private var _isDebug: Bool = false
    private var isDebug: Bool {
        get {
            var result = _isDebug
            if environmentKey == defaultEnvironmentKey {
                result = false
            }
            return result
        }
        set {
            _isDebug = newValue
        }
    }
    @objc private var environmentKey: String {
        get {
            let value = UserDefaults.standard.string(forKey: SDOSEnvironment.userDefaultEnvironmentkey)
            if let value = value {
                return value
            } else {
                return defaultEnvironmentKey
            }
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: SDOSEnvironment.userDefaultEnvironmentkey)
        }
    }
    
    @objc static public var environmentKey: String {
        return sharedInstance.environmentKey
    }
    
    private override init() { }
    
    static private func environmentKeyConfigFile() -> String {
        var result = defaultEnvironmentKey
        if let key = Bundle.main.object(forInfoDictionaryKey: EnvionmentKeyInfoPlist) as? String {
            result = key
        }
        return result
    }
    
    @objc public static func configure(file: String = "Environments.bin", password: String? = nil, environmentKey: String? = nil, debug: Bool = false) {
        var key: String
        if let environmentKey = environmentKey {
            key = environmentKey
        } else {
            key = environmentKeyConfigFile()
        }
        sharedInstance.isDebug(debug: debug)
        sharedInstance.configure(file: file, password: password, environmentKey: key)
    }
    
    @objc public static func changeEnvironmentKey(_ environmentKey: String) {
        sharedInstance.changeEnvironmentKey(environmentKey)
    }
    
    @objc public static func getValue(key: String) -> String {
        return sharedInstance.getValue(key: key)
    }
    
    @objc public static func isDebug(debug: Bool) {
        sharedInstance.isDebug(debug: debug)
    }
    
    private func configure(file: String, password pwd: String?, environmentKey: String) {
        var password: String
        if let key = pwd {
            password = key
        } else {
            password = generateDefaultPassword()
        }
        //decrypt the saved environments.bin to get environments.json contents
        let environmentsFilePath = Bundle.main.path(forResource: file, ofType: "")
        if let path = environmentsFilePath {
            do {
                let url = URL(fileURLWithPath: path)
                let data = try Data(contentsOf: url)
                let decryptor = RNCryptor.DecryptorV3(password: password)
                let xmlData = try decryptor.decrypt(data: data)
                if let values = try PropertyListSerialization.propertyList(from: xmlData, options: .mutableContainers, format: nil) as? EnvironmentType {
                    //Asignación de valores
                    environmentValues = values
                    
                    //Asignación de la clave de entorno
                    changeEnvironmentKey(environmentKey)
                }
            } catch {
                fatalError("Fallo durante la inicialización. Comprueba que la clave de desencriptación es correcta")
            }
        } else {
            fatalError("No existe el fichero \(file)")
        }
    }
    
    private func changeEnvironmentKey(_ environmentKey: String) {
        self.environmentKey = environmentKey
        checkEnvironmentValues()
        if isDebug {
            print("[\(type(of: self))] Selected environment: \"\(self.environmentKey)\"")
        }
    }
    
    private func checkEnvironmentValues() {
        if self.isDebug {
            #if !RELEASE
            environmentValues.forEach { (key, value) in
                var finalValue = ""
                if let obj = self.environmentValues[key] {
                    finalValue = normalizeValue(value: obj[environmentKey])
                }
                guard !finalValue.isEmpty else {
                    fatalError("Falta el valor para la clave \"\(key)\" en el entorno \"\(self.environmentKey)\"")
                }
            }
            #endif
        }
    }
    
    @objc public func isDebug(debug: Bool) {
        self.isDebug = debug
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
    
    func getValue(key: String) -> String {
        var finalValue = ""
        if let obj = self.environmentValues[key] {
            finalValue = normalizeValue(value: obj[environmentKey])
        }
        if isDebug {
            print("[\(type(of: self))] Get key \"\(key)\" for environment \"\(self.environmentKey)\"")
        }
        
        return finalValue
    }
    
    func generateDefaultPassword() -> String {
        let bundle = Bundle.main.bundleIdentifier
        var password = ""
        var bytes = [UInt8]()
        if let bundle = bundle {
            let characters = Array(bundle)
            characters.forEach { (character) in
                var char = character.asciiValue ?? 0
                char += 7
                bytes.append(char)
            }
        }
        if let string = String(bytes: bytes, encoding: .utf8) {
            password = string
        }
        
        return password
    }
}
