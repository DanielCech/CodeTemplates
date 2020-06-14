import Stencil
import ScriptToolkit

var context: Context = ["name": "emergencyContacts"]

// Project setup
context["author"] = "Daniel Cech"
context["projectName"] = "Harbor"
context["copyright"] = "Copyright © 2020 25MP Corp. All rights reserved."

context["cases"] = [
    "blue", "green", "yellow"
]




print("⌚️ Processing")

// Code generation

do {
    //try generate(template: .viewControllerRxSwift, context: context)
    try Generator.shared.generate(combo: .sceneControllerRxSwiftWithTableView, context: context)
    try Reviewer.shared.review(mode: .individual, context: context)
}
catch {
    print("Error: generation failed: \(error)")
}



print("✅ Done")


