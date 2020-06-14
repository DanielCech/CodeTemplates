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
    try generate(combo: .sceneControllerRxSwiftWithTableView, context: context)
}
catch {
    print("Error: generation failed: \(error)")
}

let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" \"" + generatedPath + "\" \"" + targetPath + "\""
shell(command)

print("✅ Done")


