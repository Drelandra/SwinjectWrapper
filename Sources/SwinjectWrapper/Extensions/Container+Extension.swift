//
//  File.swift
//  
//
//  Created by Andre Elandra on 04/05/24.
//

import Swinject

public typealias SwinjectWrapperContainer = Container

public extension Container {
    
    //MARK: Private Static
    
    private static let sharedContainer: Container = Container()
    private static var customContainer: Container?
    
    //MARK: Public Static
    
    /// Shared instance of active container.
    static var shared: Container {
        customContainer ?? sharedContainer
    }
    
    /// Switch shared container with your custom container.
    /// - Parameter newContainer: new Container that will replace shared instance.
    static func switchContainer(to newContainer: Container) {
        self.customContainer = newContainer
    }
    
    /// Switch shared to default Container.
    static func switchToDefaultContainer() {
        self.customContainer = nil
    }
    
    //MARK: Public Methods
    
    /// Adds an auto registration for the specified service with the factory autoclosure to add the service's dependencies.
    /// - Parameters:
    ///   - serviceType: The service type to register.
    ///   - name:        A registration name, which is used to differentiate from other registrations
    ///                  that have the same service and factory types.
    ///   - factory:     The autoclosure to add the service's dependencies that can be automatically resolved
    ///                  or resolved with the dependencies of the type from outside of this scope.
    ///   - objectScope: A configuration how an instance provided by a ``Container`` is shared in the system. Defaults to `graph`.
    @discardableResult
    func autoRegister<Service>(
        _ serviceType: Service.Type,
        name: String? = nil,
        for factory: @autoclosure @escaping () -> Service,
        objectScope: ObjectScope = .graph
    ) -> ServiceEntry<Service> {
        Container.shared.register(serviceType, name: name) { _ in
            factory()
        }.inObjectScope(objectScope)
    }
    
    /// Adds an auto registration for the specified service with the factory autoclosure to add the service's dependencies.
    /// - Parameters:
    ///   - serviceType: The service type to register.
    ///   - name:        A registration name type, which is used to differentiate from other registrations
    ///                  that have the same service and factory types.
    ///   - factory:     The autoclosure to add the service's dependencies that can be automatically resolved
    ///                  or resolved with the dependencies of the type from outside of this scope.
    ///   - objectScope: A configuration how an instance provided by a ``Container`` is shared in the system. Defaults to `graph`.
    @discardableResult
    func autoRegister<Service>(
        _ serviceType: Service.Type,
        name: InjectIdentifiable?,
        for factory: @autoclosure @escaping () -> Service,
        objectScope: ObjectScope = .graph
    ) -> ServiceEntry<Service> {
        Container.shared.register(serviceType, name: name?.injectID) { _ in
            factory()
        }.inObjectScope(objectScope)
    }
    
    /// Retrieves the instance with the specified service type and registration name.
    ///
    /// - Parameters:
    ///   - serviceType: The service type to resolve.
    ///   - name:        The registration name.
    ///
    /// - Returns: The resolved service type instance, or throws `errorDescription` 
    ///            if no registration for the service type and name are found in the ``Container``.
    func resolveThrowIfError<Service>(
        _ serviceType: Service.Type,
        name: String? = nil
    ) throws -> Service {
        guard let resolvedInstance: Service = resolve(serviceType, name: name) else {
            throw "Please make sure you register \(serviceType) with its component\(name == nil ? "." : " and name: \(name!).")"
        }
        return resolvedInstance
    }
}
