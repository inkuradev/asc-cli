import Foundation
import Testing
@testable import Domain

@Suite("ScreenshotTemplate")
struct ScreenshotTemplateTests {

    @Test func `template has id, name, and category`() {
        let template = MockRepositoryFactory.makeScreenshotTemplate()
        #expect(template.id == "top-hero")
        #expect(template.name == "Top Hero")
        #expect(template.category == .bold)
    }

    @Test func `template reports supported sizes`() {
        let template = MockRepositoryFactory.makeScreenshotTemplate(
            supportedSizes: [.portrait, .landscape]
        )
        #expect(template.supportedSizes.contains(.portrait))
        #expect(template.supportedSizes.contains(.landscape))
    }

    @Test func `portrait template is portrait`() {
        let template = MockRepositoryFactory.makeScreenshotTemplate(
            supportedSizes: [.portrait]
        )
        #expect(template.isPortrait)
        #expect(!template.isLandscape)
    }

    @Test func `landscape template is landscape`() {
        let template = MockRepositoryFactory.makeScreenshotTemplate(
            supportedSizes: [.landscape]
        )
        #expect(!template.isPortrait)
        #expect(template.isLandscape)
    }

    @Test func `template reports device count`() {
        let single = MockRepositoryFactory.makeScreenshotTemplate(deviceCount: 1)
        #expect(single.deviceCount == 1)

        let duo = MockRepositoryFactory.makeScreenshotTemplate(
            id: "duo",
            deviceCount: 2
        )
        #expect(duo.deviceCount == 2)
    }

    @Test func `template affordances include preview, apply, and list`() {
        let template = MockRepositoryFactory.makeScreenshotTemplate(id: "top-hero")
        #expect(template.affordances["apply"] == "asc app-shots templates apply --id top-hero --screenshot screen.png")
        #expect(template.affordances["detail"] == "asc app-shots templates get --id top-hero")
        #expect(template.affordances["listAll"] == "asc app-shots templates list")
        #expect(template.affordances["preview"]?.contains("<div") == true)
    }

    @Test func `previewHTML contains background and text`() {
        let template = MockRepositoryFactory.makeScreenshotTemplate()
        let html = template.previewHTML
        #expect(html.contains("linear-gradient"))
        #expect(html.contains("Your"))
        #expect(html.contains("Headline"))
    }

    @Test func `apply produces a ScreenshotDesign with user content`() {
        let template = MockRepositoryFactory.makeScreenshotTemplate(id: "top-hero")
        let design = template.apply(
            appName: "MyApp",
            headline: "Ship Faster",
            subtitle: "One command away",
            screenshotFile: "screen-1.png"
        )
        #expect(design.appName == "MyApp")
        #expect(design.tagline == "Ship Faster")
        #expect(design.screens.count == 1)
        #expect(design.screens[0].heading == "Ship Faster")
        #expect(design.screens[0].subheading == "One command away")
        #expect(design.screens[0].screenshotFile == "screen-1.png")
    }

    @Test func `apply maps template category to tone`() {
        let bold = MockRepositoryFactory.makeScreenshotTemplate(category: .bold)
        #expect(bold.apply(appName: "A", headline: "H", screenshotFile: "s.png").tone == .bold)

        let minimal = MockRepositoryFactory.makeScreenshotTemplate(category: .minimal)
        #expect(minimal.apply(appName: "A", headline: "H", screenshotFile: "s.png").tone == .minimal)
    }

    @Test func `template is codable`() throws {
        let template = MockRepositoryFactory.makeScreenshotTemplate()
        let data = try JSONEncoder().encode(template)
        let decoded = try JSONDecoder().decode(ScreenshotTemplate.self, from: data)
        #expect(decoded == template)
    }
}
