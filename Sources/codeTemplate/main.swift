import Files
import Foundation
import Moderator
import ScriptToolkit
import Stencil

var programMode: ProgramMode

var mainContext = MainContext()

do {
    print("⌚️ Processing")

    MainContext.setupParameters()
    try MainContext.parseParameters()

    switch MainContext.stringValue(.mode) {
    case "generate":
        guard let reviewMode = ReviewMode(rawValue: MainContext.stringValue(.reviewMode)) else {
            throw ScriptError.argumentError(message: "invalid review mode")
        }

        try Generator.shared.generateCode(reviewMode: reviewMode)

    case "updateAll":
        try Updater.shared.updateTemplates(updateMode: .all, scriptPath: MainContext.stringValue(.scriptPath))

    case "updateNew":
        try Updater.shared.updateTemplates(updateMode: .new, scriptPath: MainContext.stringValue(.scriptPath))

    case "validate":
        if let unwrappedTemplate = MainContext.optionalStringValue(.template) {
            try Validator.shared.validate(
                template: unwrappedTemplate,
                scriptPath: MainContext.stringValue(.scriptPath)
            )
        } else {
            try Validator.shared.validateTemplates(scriptPath: MainContext.stringValue(.scriptPath))
        }

    case "prepare":
        try Preparator.shared.prepareTemplate(context: MainContext.getContext())

    default:
        throw ScriptError.argumentError(message: "invalid mode value")
    }

    print("✅ Done")
} catch {
    if let printableError = error as? PrintableError { print(printableError.errorDescription) }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
