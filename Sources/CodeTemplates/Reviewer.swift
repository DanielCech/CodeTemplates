//
//  Reviewer.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 14/06/2020.
//

import Foundation
import ScriptToolkit

func review(mode: ReviewMode) {
    switch mode {
    case .overall:
        let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" \"" + generatedPath + "\" \"" + targetPath + "\""
        shell(command)
        
    case .individual:
        let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" -3 \"/Users/danielcech/Documents/[Development]/[Projects]/CodeTemplates/Templates/viewControllerRxSwiftWithTableView/{{Name}}ViewController.swift.stencil\" \"/Users/danielcech/Documents/[Development]/[Projects]/CodeTemplates/Generated/EmergencyContactsViewController.swift\" \"/Users/danielcech/Documents/[Development]/[Projects]/harbor-iOS/Harbor/Scenes/HouseholdScene/EmergencyContacts/EmergencyContactsViewController.swift\""
        shell(command)
    }
}
