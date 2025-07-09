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
///   - name: The registration name.
/// - Returns: The resolved service type instance.
///
/// Example:
/// ```
///     // Will try to resolve the injected dependency based on the type and name if any.
///     let myService: MyService = inject(MyService.self)
/// ```
public func inject<Service>(_ serviceType: Service.Type = Service.self, name: String? = nil) -> Service {
    try! Container.shared.resolveThrowIfError(serviceType, name: name)
}

/// Get optional injected instance of the given service type by resolver from ``Container``.
///
/// - Parameters:
///   - serviceType: The service type to resolve.
///   - name: The registration name.
/// - Returns: The resolved service type instance or nil if no registration for the service type and name are found in the ``Container``.
///
/// Example:
/// ```
///     // Will try to resolve the injected dependency based on the type and name if any.
///     let myService: MyService? = safeInject(MyService.self)
/// ```
public func safeInject<Service>(_ serviceType: Service.Type = Service.self, name: String? = nil) -> Service? {
    try? Container.shared.resolveThrowIfError(serviceType, name: name)
}

/// A property wrapper to inject service type with the dependencies and an option to initialize the registration name.
///
/// Because the wrapped value is a lazy variable, be careful when you declare this as it will only throw error when accessed.
///
/// Example:
/// ```
///     Container.shared.autoRegister(MyClassProtocol.self, for: MyClass())
///     @Inject var myClass: MyClassProtocol
///     print(myClass.myProperty)
/// ```
@propertyWrapper
public class Inject<Service> {
    public lazy var wrappedValue: Service = inject(Service.self, name: name ?? id?.injectID)
    
    public private(set) var name: String?
    public private(set) var id: InjectIdentifiable?
    
    public init(_ name: String? = nil) {
        self.name = name
    }
    
    init(_ id: InjectIdentifiable) {
        self.id = id
    }
}

/// A property wrapper to safely inject service type with the dependencies and an option to initialize the registration name.
///
/// Example:
/// ```
///     Container.shared.autoRegister(MyClassProtocol.self, for: MyClass())
///     @SafeInject var myClass: MyClassProtocol?
///     print(myClass?.myProperty)
/// ```
@propertyWrapper
public class SafeInject<Service> {
    public lazy var wrappedValue: Service? = safeInject(Service.self, name: name ?? id?.injectID)
    
    public private(set) var name: String?
    public private(set) var id: InjectIdentifiable?
    
    public init(_ name: String? = nil) {
        self.name = name
    }
    
    init(_ id: InjectIdentifiable) {
        self.id = id
    }
    
    public func tryToResolve() -> Service? {
        safeInject(Service.self, name: name)
    }
}
