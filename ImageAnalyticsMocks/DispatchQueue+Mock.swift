//
//  DispatchQueue+Mock.swift
//  ImageAnalyticsMocks
//
//  Created by Subhrajyoti Patra on 10/9/22.
//

import ImageAnalyticsKit

public final class DispatchQueueMock: DispatchQueueType {

    public init() { }

    public func async(execute work: @escaping @convention(block) () -> Void) {
        work()
    }
}
