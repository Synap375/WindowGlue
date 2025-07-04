//
//  Settings.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 04.07.2025.
//

import SwiftUI

struct Settings {
    @AppStorage("tolerance") var tolerance: Int = 24
}

var settings = Settings()
var glueActive: Bool = false
