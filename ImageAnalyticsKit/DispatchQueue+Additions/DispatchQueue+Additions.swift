//
//  DispatchQueue+Additions.swift
//  ImageAnalyticsKit
//
//  Created by Subhrajyoti Patra on 10/9/22.
//

public protocol DispatchQueueType {
    func async(execute work: @escaping @convention(block) () -> Void)
}

extension DispatchQueue: DispatchQueueType {
    public func async(execute work: @escaping @convention(block) () -> Void) {
        async(group: nil, qos: .unspecified, flags: [], execute: work)
    }
}
