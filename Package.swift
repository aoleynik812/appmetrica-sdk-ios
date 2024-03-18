// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

enum AppMetricaTarget: String {
    case core = "AppMetricaCore"
    case crashes = "AppMetricaCrashes"
    case coreExtension = "AppMetricaCoreExtension"
    case adSupport = "AppMetricaAdSupport"
    case webKit = "AppMetricaWebKit"
    case log = "AppMetricaLog"
    case coreUtils = "AppMetricaCoreUtils"
    case testUtils = "AppMetricaTestUtils"
    case network = "AppMetricaNetwork"
    case hostState = "AppMetricaHostState"
    case platform = "AppMetricaPlatform"
    case protobufUtils = "AppMetricaProtobufUtils"
    case storageUtils = "AppMetricaStorageUtils"
    case encodingUtils = "AppMetricaEncodingUtils"
    
    case protobuf = "AppMetrica_Protobuf"
    case fmdb = "AppMetrica_FMDB"
    
    var name: String { rawValue }
    var testsName: String { rawValue + "Tests" }
    var path: String { "\(rawValue)/Sources" }
    var testsPath: String { "\(rawValue)/Tests" }
    var dependency: Target.Dependency { .target(name: rawValue) }
}

enum AppMetricaProduct: String, CaseIterable {
    case core = "AppMetricaCore"
    case crashes = "AppMetricaCrashes"
    case adSupport = "AppMetricaAdSupport"
    case webKit = "AppMetricaWebKit"
    
    static var allProducts: [Product] { allCases.map { $0.product } }
    
    var targets: [AppMetricaTarget] {
        switch self {
        case .core: [.core, .coreExtension]
        case .crashes: [.crashes]
        case .adSupport: [.adSupport]
        case .webKit: [.webKit]
        }
    }
    
    var product: Product { .library(name: rawValue, targets: targets.map { $0.name }) }
}

enum ExternalDependency: String, CaseIterable {
    case kiwi = "Kiwi"
    case ksCrash = "KSCrash"

    static var allDependecies: [Package.Dependency] { allCases.map { $0.package } }
    
    var dependency: Target.Dependency { .byName(name: rawValue) }
    
    var package: Package.Dependency {
        switch self {
        case .ksCrash: .package(url: "https://github.com/kstenerud/KSCrash", .upToNextMinor(from: "1.16.1"))
        case .kiwi: .package(url: "https://github.com/appmetrica/Kiwi", .upToNextMinor(from: "3.0.1-spm"))
        }
    }
}

let package = Package(
    name: "AppMetrica",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
    ],
    products: AppMetricaProduct.allProducts,
    dependencies: ExternalDependency.allDependecies,
    targets: [
        //MARK: - AppMetrica SDK -
        .target(
            target: .core,
            dependencies: [
                .network, .log, .coreUtils, .hostState, .protobufUtils, .platform, .storageUtils, .encodingUtils, .protobuf, .fmdb
            ],
            searchPaths: [
                "../../AppMetricaCoreExtension/Sources/include/AppMetricaCoreExtension"
            ]
        ),
        .testTarget(
            target: .core,
            dependencies: [
                .core, .coreExtension, .webKit, .testUtils, .hostState, .protobufUtils, .platform
            ],
            externalDependencies: [.kiwi],
            searchPaths: [
                "../../AppMetricaCoreExtension/Sources/include/AppMetricaCoreExtension"
            ],
            resources: [.process("Resources")]
        ),
        
        //MARK: - AppMetrica Crashes
        .target(
            target: .crashes,
            dependencies: [
                .core, .log, .coreExtension, .hostState, .protobufUtils, .platform, .storageUtils, .encodingUtils, .protobuf
            ],
            externalDependencies: [.ksCrash],
            searchPaths: []
        ),
        .testTarget(
            target: .crashes,
            dependencies: [.crashes, .testUtils],
            externalDependencies: [.kiwi],
            searchPaths: ["./Helpers"],
            resources: [.process("Resources")]
        ),
        
        //MARK: - AppMetrica CoreExtension
        .target(
            target: .coreExtension,
            dependencies: [.core, .storageUtils],
            searchPaths: []
        ),
        
        //MARK: - AppMetrica Log
        .target(target: .log),
        .testTarget(
            target: .log,
            dependencies: [.log],
            searchPaths: [""]
        ),
        
        //MARK: - AppMetrica Protobuf
        .target(target: .protobuf),
        
        //MARK: - AppMetrica ProtobufUtils
        .target(target: .protobufUtils, dependencies: [.protobuf]),
        .testTarget(
            target: .protobufUtils,
            dependencies: [.protobufUtils]
        ),
        
        //MARK: - AppMetrica CoreUtils
        .target(
            target: .coreUtils,
            dependencies: [.log],
            searchPaths: ["./**"]
        ),
        .testTarget(
            target: .coreUtils,
            dependencies: [.coreUtils, .testUtils],
            externalDependencies: [.kiwi],
            searchPaths: ["Utilities", "../Sources/include/AppMetricaCoreUtils"]
        ),
        
        //MARK: - AppMetrica TestUtils
        .target(
            target: .testUtils,
            dependencies: [.coreUtils, .network, .storageUtils, .hostState],
            externalDependencies: [.kiwi],
            includePrivacyManifest: false
        ),
        
        //MARK: - AppMetrica Network
        .target(
            target: .network,
            dependencies: [.log, .coreUtils, .platform]
        ),
        .testTarget(
            target: .network,
            dependencies: [.network, .platform, .coreExtension, .testUtils],
            externalDependencies: [.kiwi],
            searchPaths: ["Utilities", "../Sources/include/AppMetricaNetwork"]
        ),
        
        //MARK: - AppMetrica AdSupport
        .target(target: .adSupport, dependencies: [.core, .coreExtension]),
        .testTarget(
            target: .adSupport,
            dependencies: [.adSupport, .testUtils],
            externalDependencies: [.kiwi],
            searchPaths: ["../Sources/**"]
        ),
        
        //MARK: - AppMetrica WebKit
        .target(target: .webKit, dependencies: [.core, .log, .coreUtils]),
        .testTarget(
            target: .webKit,
            dependencies: [.webKit, .testUtils],
            externalDependencies: [.kiwi],
            searchPaths: ["../Sources/**"]
        ),
        
        //MARK: - AppMetrica HostState
        .target(target: .hostState, dependencies: [.coreUtils, .log]),
        .testTarget(
            target: .hostState,
            dependencies: [.hostState, .testUtils],
            externalDependencies: [.kiwi],
            searchPaths: ["../Sources/**"]
        ),
        
        //MARK: - AppMetrica Platform
        .target(target: .platform, dependencies: [.log, .coreUtils]),
        .testTarget(
            target: .platform,
            dependencies: [.platform, .testUtils],
            externalDependencies: [.kiwi],
            searchPaths: ["../Sources/**"]
        ),
        
        //MARK: - AppMetrica StorageUtils
        .target(target: .storageUtils, dependencies: [.log, .coreUtils]),
        .testTarget(
            target: .storageUtils,
            dependencies: [.storageUtils, .testUtils],
            externalDependencies: [.kiwi],
            searchPaths: ["../Sources/**"]
        ),
        
        //MARK: - AppMetrica EncodingUtils
        .target(target: .encodingUtils, dependencies: [.log, .platform, .coreUtils]),
        .testTarget(
            target: .encodingUtils,
            dependencies: [.encodingUtils, .testUtils],
            externalDependencies: [.kiwi],
            searchPaths: ["../Sources/**"]
        ),
        
        //MARK: - AppMetrica FMDB
        .target(target: .fmdb),
    ]
)

extension Target {
    static func target(target: AppMetricaTarget,
                       dependencies: [AppMetricaTarget] = [],
                       externalDependencies: [ExternalDependency] = [],
                       searchPaths: [String] = [],
                       includePrivacyManifest: Bool = true) -> Target {
        var resources: [Resource] = []
        if includePrivacyManifest {
            resources.append(.copy("Resources/PrivacyInfo.xcprivacy"))
        }
        
        var resultSearchPath: Set<String> = .init()
        resultSearchPath.formUnion(target.headerPaths)
        resultSearchPath.formUnion(searchPaths)

        return .target(
            name: target.name,
            dependencies: dependencies.map { $0.dependency } + externalDependencies.map { $0.dependency },
            path: target.path,
            resources: resources,
            cSettings: resultSearchPath.sorted().map { .headerSearchPath($0) }
        )
    }
    
    static func testTarget(target: AppMetricaTarget,
                           dependencies: [AppMetricaTarget] = [],
                           testUtils: [AppMetricaTarget] = [],
                           externalDependencies: [ExternalDependency] = [],
                           searchPaths: [String] = [],
                           resources: [Resource]? = nil) -> Target {
        
        var resultSearchPath: Set<String> = .init()
        resultSearchPath.formUnion(target.testsHeaderPaths)
        resultSearchPath.formUnion(target.headerPaths.map { "../Sources/\($0)" })
        resultSearchPath.formUnion(searchPaths)
        
        return .testTarget(
            name: target.testsName,
            dependencies: dependencies.map { $0.dependency } + externalDependencies.map { $0.dependency },
            path: target.testsPath,
            resources: resources,
            cSettings: resultSearchPath.sorted().map { .headerSearchPath($0) }
        )
    }
    
}

extension AppMetricaTarget {
    
    var headerPaths: Set<String> {
        var customPaths: Set<String> = .init()
        
        switch self {
        case .core:
            customPaths = Set(HeaderPaths.core)
        case .coreUtils:
            customPaths = Set(HeaderPaths.coreUtils)
        case .crashes:
            customPaths = Set(HeaderPaths.crashes)
        default:
            break
        }
        
        customPaths.insert(".")
        customPaths.insert("include")
        customPaths.insert("include/\(name)")
        
        return customPaths
    }
    
    var testsHeaderPaths: Set<String> {
        var customPaths: Set<String> = .init()
        
        switch self {
        case .core:
            customPaths = Set(TestHeaderPaths.core)
        case .coreUtils:
            customPaths = Set(TestHeaderPaths.coreUtils)
        case .crashes:
            customPaths = Set(TestHeaderPaths.crashes)
        case .encodingUtils:
            customPaths = Set(TestHeaderPaths.encodingUtils)
        case .log:
            customPaths = Set(TestHeaderPaths.log)
        case .network:
            customPaths = Set(TestHeaderPaths.network)
        case .platform:
            customPaths = Set(TestHeaderPaths.platform)
        case .protobufUtils:
            customPaths = Set(TestHeaderPaths.protobufUtils)
        default:
            break
        }
        
        customPaths.insert(".")
        
        return customPaths
    }
    
}

enum HeaderPaths {
    
    static let core = [
        ".",
        "./Generated",
        "./AdRevenue",
        "./AdRevenue/Serialization",
        "./AdRevenue/Formatting",
        "./AdRevenue/Model",
        "./AdRevenue/Validation",
        "./Database",
        "./Database/Scheme",
        "./Database/Trimming",
        "./Database/IntegrityManager",
        "./Database/KeyValueStorage",
        "./Database/KeyValueStorage/DataProviders",
        "./Database/KeyValueStorage/Converters",
        "./Database/Migration",
        "./Database/Migration/Scheme",
        "./Database/Migration/Library",
        "./Database/Migration/Utilities",
        "./Database/Migration/ApiKey",
        "./Configuration",
        "./Core",
        "./ECommerce",
        "./Privacy",
        "./Reporter",
        "./Reporter/FirstOccurrence",
        "./Limiters",
        "./Strategies",
        "./Location",
        "./include",
        "./include/AppMetricaCore",
        "./Resources",
        "./Network",
        "./Network/File",
        "./Network/Report",
        "./Network/Startup",
        "./Dispatcher",
        "./Permissions",
        "./StartupPermissions",
        "./Attribution",
        "./Model",
        "./Model/Reporter",
        "./Model/Reporter/Serialization",
        "./Model/Truncation",
        "./Model/Event",
        "./Model/Event/Value",
        "./Model/Session",
        "./Profiles",
        "./Profiles/Truncation",
        "./Profiles/Models",
        "./Profiles/Updates",
        "./Profiles/Updates/Factory",
        "./Profiles/Attributes",
        "./Profiles/Attributes/Complex",
        "./Profiles/Validation",
        "./ExtensionsReport",
        "./Revenue",
        "./Revenue/AutoIAP",
        "./Revenue/AutoIAP/Models",
        "./SearchAds",
        "./SearchAds/AdServices",
        "./Logging",
        "./DeepLink",
    ]

    static let coreUtils = [
        ".",
        "./include",
        "./include/AppMetricaCoreUtils",
        "./Truncation",
        "./Utilities",
        "./Execution",
    ]

    
    static let crashes = [
        ".",
        "./Generated",
        "./Plugins",
        "./include",
        "./include/AppMetricaCrashes",
        "./Resources",
        "./LibraryCrashes",
        "./CrashModels",
        "./CrashModels/Crash",
        "./CrashModels/Crash/Thread",
        "./CrashModels/Crash/Error",
        "./CrashModels/System",
        "./Error",
    ]

}

enum TestHeaderPaths {
    
    static let core = [
        "Resources",
        "Utilities",
    ]
    
    
    static let coreUtils = [
        "Utilities",
    ]
    
    static let crashes = [
        "Helpers",
    ]
    
    static let encodingUtils = [
        "Utilities",
    ]
    
    static let log = [
        "Mocks",
    ]
    
    static let network = [
        "Utilities",
    ]
    
    static let platform = [
        "Mocks",
    ]
    
    static let protobufUtils = [
        "Mocks",
    ]
    
}
