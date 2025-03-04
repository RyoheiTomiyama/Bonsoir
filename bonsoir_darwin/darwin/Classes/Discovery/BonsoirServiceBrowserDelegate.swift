#if canImport(Flutter)
    import Flutter
#endif
#if canImport(FlutterMacOS)
    import FlutterMacOS
#endif
import Foundation

/// Allows to find net services on local network.
class BonsoirServiceBrowserDelegate: NSObject, NetServiceBrowserDelegate, NetServiceDelegate, FlutterStreamHandler {
    /// The delegate identifier.
    let id: Int

    /// Whether to print debug logs.
    let printLogs: Bool

    /// Triggered when this instance is being disposed.
    let onDispose: (Bool) -> Void

    /// The current event channel.
    var eventChannel: FlutterEventChannel?

    /// The current event sink.
    var eventSink: FlutterEventSink?
    
    /// Contains all found services.
    var services: [String: NetService] = [:]

    /// Initializes this class.
    public init(id: Int, printLogs: Bool, onDispose: @escaping (Bool) -> Void, messenger: FlutterBinaryMessenger) {
        self.id = id
        self.printLogs = printLogs
        self.onDispose = onDispose
        super.init()
        eventChannel = FlutterEventChannel(name: "\(SwiftBonsoirPlugin.package).discovery.\(id)", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }

    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        if printLogs {
            SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir discovery started : \(browser)")
        }
        eventSink?(SuccessObject(id: "discoveryStarted").toJson())
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch error: [String: NSNumber]) {
        if printLogs {
            SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has encountered an error during discovery : \(error)")
        }
        eventSink?(FlutterError.init(code: "discoveryError", message: "Bonsoir has encountered an error during discovery.", details: error))
        dispose(stopDiscovery: true)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if printLogs {
            SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has found a service : \(service)")
        }
        eventSink?(SuccessObject(id: "discoveryServiceFound", service: service).toJson())
        
        service.delegate = self
        services[service.name] = service
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if printLogs {
            SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "A Bonsoir service has been lost : \(service)")
        }
        eventSink?(SuccessObject(id: "discoveryServiceLost", service: services[service.name] ?? service).toJson())
        services.removeValue(forKey: service.name)
    }
    
    func netServiceDidResolveAddress(_ service: NetService) {
        services[service.name] = service
        if printLogs {
            SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has resolved a service : \(service)")
        }
        eventSink?(SuccessObject(id: "discoveryServiceResolved", service: service).toJson())
    }
    
    func netService(_ service: NetService, didNotResolve error: [String: NSNumber])  {
        services.removeValue(forKey: service.name)
        if printLogs {
            SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has failed to resolve a service : \(error)")
        }
        eventSink?(SuccessObject(id: "discoveryServiceResolveFailed", service: service).toJson())
    }

    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        if printLogs {
            SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir discovery stopped : \(browser)")
        }
        eventSink?(SuccessObject(id: "discoveryStopped").toJson())
        dispose()
    }
    
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
      self.eventSink = eventSink
      return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
      eventSink = nil
      return nil
    }
    
    /// Resolves a service.
    public func resolveService(name: String, type: String) -> Bool? {
        let service: NetService? = services[name]
        service?.resolve(withTimeout: 10.0)
        return service != nil
    }

    /// Disposes the current class instance.
    public func dispose(stopDiscovery: Bool = true) {
        services.removeAll()
        onDispose(stopDiscovery)
    }
}
