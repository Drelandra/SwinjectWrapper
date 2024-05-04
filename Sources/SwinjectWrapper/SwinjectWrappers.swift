//
//  File.swift
//
//
//  Created by Andre Elandra on 04/05/24.
//

import Swinject

/// Get injected instance of the given service type by resolver from ``Container``.
///
/// - Parameters:
///   - serviceType: The service type to resolve.
///   - resolve:     The registration name.
///
/// - Returns: The resolved service type instance.
public func inject<Service>(_ serviceType: Service.Type = Service.self, name: String? = nil) -> Service {
    try! Container.shared.resolveThrowIfError(serviceType, name: name)
}

/// Get optional injected instance of the given service type by resolver from ``Container``.
///
/// - Parameters:
///   - serviceType: The service type to resolve.
///   - resolve:     The registration name.
///
/// - Returns: The resolved service type instance or nil if no registration for the service type and name are found in the ``Container``.
public func safeInject<Service>(_ serviceType: Service.Type = Service.self, name: String? = nil) -> Service? {
    try? Container.shared.resolveThrowIfError(serviceType, name: name)
}

/// A property wrapper to inject service type with the dependencies and an option to initialize the registration name.
///
/// Usage example:
/// ```
///     Container.shared.autoRegister(ProfileManagerProtocol.self, for: ProfileManager())
///     @Inject var profileManager: ProfileManagerProtocol
///     print(profileManager.username)
/// ```
@propertyWrapper
public class Inject<Service> {
    public lazy var wrappedValue: Service = inject(Service.self, name: name)
    
    public private(set) var name: String?
    
    public init(_ name: String? = nil) {
        self.name = name
    }
}

/// A property wrapper to safely inject service type with the dependencies and an option to initialize the registration name.
///
/// Usage example:
/// ```
///     Container.shared.autoRegister(ProfileManagerProtocol.self, for: ProfileManager())
///     @SafeInject var profileManager: ProfileManagerProtocol?
///     print(profileManager?.username)
/// ```
@propertyWrapper
public class SafeInject<Service> {
    public lazy var wrappedValue: Service? = safeInject(Service.self, name: name)
    
    public private(set) var name: String?
    
    public init(_ name: String? = nil) {
        self.name = name
    }
    
    public func tryToResolve() -> Service? {
        safeInject(Service.self, name: name)
    }
}
