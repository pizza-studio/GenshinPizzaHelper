//
//  WidgetsBoundle.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/10.
//

import WidgetKit
import SwiftUI

@main
struct WidgetLauncher {
    static func main() {
        if #available(iOSApplicationExtension 16.0, *) {
            WidgetsBundleiOS16.main()
        } else {
            WidgetsBundleLowerThaniOS16.main()
        }
    }
}

@available(iOSApplicationExtension 16.0, *)
struct WidgetsBundleiOS16: WidgetBundle {
    var body: some Widget {
        MainWidget()
        LockScreenResinWidget()
        LockScreenHomeCoinWidget()
    }
}

struct WidgetsBundleLowerThaniOS16: WidgetBundle {
    var body: some Widget {
        MainWidget()
    }
}
