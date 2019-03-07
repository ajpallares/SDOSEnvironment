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

@objc public class SDOSEnvironment: NSObject {
    
    private static let userDefaultEnvironmentkey = "\(type(of: self))\(#keyPath(environmentKey))"
    private static let sharedInstance = SDOSEnvironment()
    private var environmentValues: EnvironmentType!
    private var isDebug: Bool = false
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
    
    private override init() { }
    
    @objc public static func configure(file: String = "environments.bin", password: String? = nil, environmentKey: String? = defaultEnvironmentKey, debug: Bool = false) {
        sharedInstance.isDebug(debug: debug)
        sharedInstance.configure(file: file, password: password, environmentKey: environmentKey)
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
    
    private func configure(file: String, password pwd: String?, environmentKey: String?) {
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
                    var finalKey = self.environmentKey
                    if let environmentKey = environmentKey {
                        finalKey = environmentKey
                    }
                    changeEnvironmentKey(finalKey)
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
            environmentValues.forEach { (key, value) in
                if let value = value[environmentKey] as? String, value.isEmpty {
                    #if !RELEASE
                    fatalError("Falta el valor para la clave \"\(key)\" en el entorno \"\(self.environmentKey)\"")
                    #endif
                }
            }
        }
    }
    
    @objc public func isDebug(debug: Bool) {
        self.isDebug = debug
    }
    
    func getValue(key: String) -> String {
        var finalValue = ""
        if let obj = self.environmentValues[key] {
            switch obj[environmentKey] {
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
