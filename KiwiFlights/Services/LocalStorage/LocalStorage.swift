//
//  LocalStorage.swift
//  KiwiFlights
//
//  Created by Tomas Baculák on 24/07/2023.
//

import Foundation
import Combine

final class LocalStorage {
    func reset() {
        takenDestinations = []
        takenDepartures = []
    }
    
    @UserDefault(wrappedValue: [], "takenDestinations")
    var takenDestinations: [PlaceResponse.Node]
    
    @UserDefault(wrappedValue: [], "takenDepartures")
    var takenDepartures: [PlaceResponse.Node]
}

@propertyWrapper
final class UserDefault<T: Codable>: NSObject {
    var wrappedValue: T {
        get {
            if let data = userDefaults.object(forKey: key) as? Data,
               let user = try? JSONDecoder().decode(T.self, from: data) {
                return user
            }
            return subject.value
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                userDefaults.setValue(encoded, forKey: key)
            }
        }
    }
    var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }
    
    private let key: String
    private let userDefaults: UserDefaults
    private var observerContext = 0
    private let subject: CurrentValueSubject<T, Never>
    
    init(wrappedValue defaultValue: T,
         _ key: String,
         userDefaults: UserDefaults = .standard
    ) {
        self.key = key
        self.userDefaults = userDefaults
        self.subject = CurrentValueSubject(defaultValue)
        super.init()
        userDefaults.register(defaults: [key: defaultValue])
        userDefaults.addObserver(self, forKeyPath: key, options: .new, context: &observerContext)
        subject.value = wrappedValue
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if context == &observerContext {
            subject.value = wrappedValue
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        userDefaults.removeObserver(self, forKeyPath: key, context: &observerContext)
    }
}
