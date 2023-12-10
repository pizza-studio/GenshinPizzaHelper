//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/12/9.
//

import Foundation

// MARK: - CalculableWithDifferentTime

protocol CalculableWithDifferentTime {
    func after(_ timeInterval: TimeInterval) -> Self
}

// MARK: - NoDifferenceAfterTime

protocol NoDifferenceAfterTime: CalculableWithDifferentTime {}

extension NoDifferenceAfterTime {
    func after(_ timeInterval: TimeInterval) -> Self { self }
}
