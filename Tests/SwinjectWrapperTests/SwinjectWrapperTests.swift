import XCTest
import Swinject
@testable import SwinjectWrapper

final class SwinjectWrapperTests: XCTestCase {
    func test_swinjectWrapper_shouldValidateAllFunctionalities() {
        let customContainer: Container = Container()
        Container.switchContainer(to: customContainer)
        
        customContainer.autoRegister(
            TestFirstProtocol.self,
            componentType: .firstType,
            for: TestA()
        )
        
        let testFirst: TestFirstProtocol? = try? customContainer.resolveThrowIfError(TestFirstProtocol.self, name: "firstType")
        
        do {
            _ = try customContainer.resolveThrowIfError(TestSecondProtocol.self, name: "secondType")
        } catch {
            XCTAssertNotNil(error.localizedDescription.errorDescription)
        }
        
        do {
            _ = try customContainer.resolveThrowIfError(TestThirdProtocol.self)
        } catch {
            XCTAssertNotNil(error.localizedDescription.errorDescription)
        }
        
        XCTAssertNotNil(testFirst)
        
        Container.switchToDefaultContainer()
        
        Container.switchToDefaultContainer()
        Container.shared.autoRegister(
            TestFirstProtocol.self,
            componentType: .firstType,
            for: TestA()
        )
        
        Container.shared.autoRegister(
            TestFirstProtocol.self,
            componentType: .secondType,
            for: TestB()
        )
        
        Container.shared.autoRegister(
            TestSecondProtocol.self,
            componentType: .firstType,
            for: TestC()
        )
        
        @Inject(.firstType) var testA: TestFirstProtocol
        @Inject(.secondType) var testB: TestFirstProtocol
        @Inject(.firstType) var testC: TestSecondProtocol
        
        Container.shared.autoRegister(
            TestThirdProtocol.self,
            name: "testD",
            for: TestD(testFirst: testA)
        )
        
        @Inject("testD") var testD: TestThirdProtocol
        @SafeInject("testE") var testE: TestThirdProtocol?
        
        testA.play()
        testB.play()
        testC.play()
        testD.play()
        testD.testFirst.play()
        testE?.play()
        
        XCTAssertNil(testE)
        
        Container.shared.autoRegister(
            TestThirdProtocol.self,
            name: "testE",
            for: TestE(testFirst: testA)
        )
        testE = _testE.tryToResolve()
        testE?.play()
        
        XCTAssertNotNil(testE)
        
        XCTAssertTrue(_testA.name == ComponentType.firstType.rawValue)
        XCTAssertTrue(_testB.name == ComponentType.secondType.rawValue)
        XCTAssertTrue(_testC.name == ComponentType.firstType.rawValue)
        XCTAssertTrue(_testD.name == "testD")
    }
}

//MARK: - Mocks

protocol TestFirstProtocol {
    func play()
}

protocol TestSecondProtocol {
    func play()
}

protocol TestThirdProtocol {
    var testFirst: TestFirstProtocol { get }
    
    func play()
}

class TestA: TestFirstProtocol {
    func play() {
        print("Test A")
    }
}

class TestB: TestFirstProtocol {
    func play() {
        print("Test B")
    }
}

class TestC: TestSecondProtocol {
    func play() {
        print("Test C")
    }
}

class TestD: TestThirdProtocol {
    
    var testFirst: TestFirstProtocol
    
    init(testFirst: TestFirstProtocol) {
        self.testFirst = testFirst
    }
    
    func play() {
        print("Test D")
    }
}

class TestE: TestThirdProtocol {
    
    var testFirst: TestFirstProtocol
    
    init(testFirst: TestFirstProtocol) {
        self.testFirst = testFirst
    }
    
    func play() {
        print("Test E")
    }
}

//MARK: - Helpers

public extension Container {
    func autoRegister<Service>(
        _ serviceType: Service.Type,
        componentType: ComponentType? = nil,
        for factory: @autoclosure @escaping () -> Service
    ) {
        Container.shared.register(serviceType, name: componentType?.rawValue) { _ in
            factory()
        }
    }
}

public extension Inject {
    convenience init(_ componentType: ComponentType? = nil) {
        self.init(componentType?.rawValue)
    }
}

public enum ComponentType: String {
    case firstType
    case secondType
}
