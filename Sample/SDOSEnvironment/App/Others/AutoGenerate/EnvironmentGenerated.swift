//  This is a generated file, do not edit!
//  EnvironmentGenerated.swift
//
//  Created by SDOS
//

import Foundation
import SDOSEnvironment

/// This Environment is generated and contains static references to 5 variables
/// Reference file: /App/Configuration/Properties/Environments.plist
public struct Environment {
	private init() { }
	/// Variable reference: EnvironmentDescription
	public static var environmentDescription: String { return SDOSEnvironment.getValue(key: "EnvironmentDescription") }
	/// Variable reference: googleAnalyticsKey
	public static var googleAnalyticsKey: String { return SDOSEnvironment.getValue(key: "googleAnalyticsKey") }
	/// Variable reference: octopushMode
	public static var octopushMode: String { return SDOSEnvironment.getValue(key: "octopushMode") }
	/// Variable reference: showSelectedEnvironmentsOnLoad
	public static var showSelectedEnvironmentsOnLoad: String { return SDOSEnvironment.getValue(key: "showSelectedEnvironmentsOnLoad") }
	/// Variable reference: wsBaseUrl
	public static var wsBaseUrl: String { return SDOSEnvironment.getValue(key: "wsBaseUrl") }
}