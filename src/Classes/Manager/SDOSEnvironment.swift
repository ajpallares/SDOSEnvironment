//
//  SDOSEnvironment.swift
//  Pods-SDOSEnvironmentExample
//
//  Created by Rafael Fernandez Alvarez on 26/02/2019.
//

import Foundation
import RNCryptor

/// Entorno por defecto: Production
public let defaultEnvironmentKey = "Production"
private typealias EnvironmentType = [String: [String: Any]]
private let EnvionmentKeyInfoPlist = "EnvironmentKey"

/**
Clase que permite el uso de variables de entorno a partir de un fichero .plist previamente encriptado por el script SDOSEnviroment.

La librería consultará el fichero indicado durante la configuración, el cual deberá estar encriptado y se deberá usar la misma clave para desencriptarlo.
La estructura del .plist deberá ser la siguiente:

 ```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>wsBaseUrl</key>
    <dict>
        <key>Debug</key>
        <string>http://debug.es</string>
        <key>Preproduction</key>
        <string>http://preproduction.es</string>
        <key>Production</key>
        <string>http://production.es</string>
    </dict>
</dict>
</plist>
```
(Dictionaty)variable->(Dictionary)environment->(String)value
 */
@objc public class SDOSEnvironment: NSObject {
    
    private static let userDefaultEnvironmentkey = "SDOSEnvironment.key"
    private static let sharedInstance = SDOSEnvironment()
    private var environmentValues: EnvironmentType!
    private var _activeLogging: Bool = false
    private var activeLogging: Bool {
        get {
            var result = _activeLogging
            if environmentKey == defaultEnvironmentKey {
                result = false
            }
            return result
        }
        set {
            _activeLogging = newValue
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
    
    /// Obtiene el entorno que actualmente está seleccionado
    @objc static public var environmentKey: String {
        return sharedInstance.environmentKey
    }
    
    private override init() { }
    
    static private func environmentKeyConfigFile(bundle: Bundle) -> String {
        var result = defaultEnvironmentKey
        if let key = bundle.object(forInfoDictionaryKey: EnvionmentKeyInfoPlist) as? String {
            result = key
        }
        return result
    }
    
    /// Configura los parámetros usados para poder usar las variables de entorno
    ///
    /// - Parameters:
    ///   - bundle: Bundle desde donde se deben cargar los recursos
    ///   - file: Fichero encriptado para extraer las variables de entorno. Default: Environments.bin
    ///   - password: Contraseña para desencriptar las variables de entorno. Default: Contraseña generada a partir del paquete de la aplicación
    ///   - environmentKey: Nombre del entorno del que se deberán recuperar los valores de las variables. Default: Production
    ///   - activeLogging: Indica si se debe activar el log del uso de la librería. No se imprimirán logs si el environmentKey es "Production". Default: false
    @objc public static func configure(bundle: Bundle = Bundle.main, file: String = "Environments.bin", password: String? = nil, environmentKey: String? = nil, activeLogging: Bool = false) {
        var key: String
        if let environmentKey = environmentKey {
            key = environmentKey
        } else {
            key = environmentKeyConfigFile(bundle: bundle)
        }
        sharedInstance.activeLogging(activeLogging: activeLogging)
        sharedInstance.configure(bundle: bundle, file: file, password: password, environmentKey: key)
    }
    
    /// Cambia el actual entorno del que se deben recuperar las variables de entorno
    ///
    /// - Parameter environmentKey: Nuevo entorno
    @objc public static func changeEnvironmentKey(_ environmentKey: String) {
        sharedInstance.changeEnvironmentKey(environmentKey)
    }
    
    /// Obtiene el valor de una variable a partir de la configuración realizada
    ///
    /// - Parameter key: Clave para recupera su valor
    /// - Returns: Valor del entorno configurado
    @objc public static func getValue(key: String) -> String {
        return sharedInstance.getValue(key: key)
    }
    
    /// Activa o desactiva el log de la librería
    ///
    /// - Parameter activeLogging: Nuevo valor
    @objc public static func activeLogging(activeLogging: Bool) {
        sharedInstance.activeLogging(activeLogging: activeLogging)
    }
    
    private func configure(bundle: Bundle, file: String, password pwd: String?, environmentKey: String) {
        var password: String
        if let key = pwd {
            password = key
        } else {
            password = generateDefaultPassword()
        }
        //decrypt the saved environments.bin to get environments.json contents
        let environmentsFilePath = bundle.path(forResource: file, ofType: "")
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
        if activeLogging {
            print("[\(type(of: self))] Selected environment: \"\(self.environmentKey)\"")
        }
    }
    
    private func checkEnvironmentValues() {
        if self.activeLogging {
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
    
    @objc private func activeLogging(activeLogging: Bool) {
        self.activeLogging = activeLogging
    }
    
    private func normalizeValue(value: Any?) -> String {
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
    
    private func getValue(key: String) -> String {
        var finalValue = ""
        if let obj = self.environmentValues[key] {
            finalValue = normalizeValue(value: obj[environmentKey])
        }
        if activeLogging {
            print("[\(type(of: self))] Get key \"\(key)\" for environment \"\(self.environmentKey)\"")
        }
        
        return finalValue
    }
    
    private func generateDefaultPassword(bundle: Bundle = Bundle.main) -> String {
        let bundle = bundle.bundleIdentifier
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
        if let string = String(bytes: bytes, encoding: .ascii) {
            password = string
        }
        
        return password
    }
}
