import Foundation

/// Renders a self-contained HTML preview of a `ScreenshotTemplate`.
///
/// The output is a single `<div>` with inline styles — no external
/// dependencies. Any client can render it directly.
public enum TemplateHTMLRenderer {

    /// Render a complete HTML page that previews a template.
    public static func renderPage(_ template: ScreenshotTemplate) -> String {
        let inner = render(template)
        return """
        <!DOCTYPE html><html><head><meta charset="utf-8">\
        <meta name="viewport" content="width=device-width,initial-scale=1">\
        <title>\(template.name)</title>\
        <style>*{margin:0;padding:0;box-sizing:border-box}body{display:flex;justify-content:center;align-items:center;min-height:100vh;background:#111}\
        .preview{width:320px;aspect-ratio:1320/2868;container-type:inline-size}</style>\
        </head><body><div class="preview">\(inner)</div></body></html>
        """
    }

    /// Render a template as a self-contained HTML div.
    public static func render(_ template: ScreenshotTemplate) -> String {
        let bgCSS = backgroundCSS(template.background)
        let textHTML = template.textSlots.map { renderText($0) }.joined()
        let deviceHTML = template.deviceSlots.map { renderDevice($0) }.joined()

        return """
        <div style="width:100%;height:100%;background:\(bgCSS);position:relative;overflow:hidden;border-radius:12px;font-family:system-ui,-apple-system,sans-serif">\
        \(textHTML)\(deviceHTML)</div>
        """
    }

    // MARK: - Background

    private static func backgroundCSS(_ bg: SlideBackground) -> String {
        switch bg {
        case .solid(let color):
            return color
        case .gradient(let from, let to, let angle):
            return "linear-gradient(\(angle)deg,\(from),\(to))"
        }
    }

    // MARK: - Text

    private static func renderText(_ slot: TemplateTextSlot) -> String {
        let content = slot.preview.replacingOccurrences(of: "\n", with: "<br>")
        let top = String(format: "%.1f", slot.y * 100)
        let size = String(format: "%.1f", slot.fontSize * 100)
        let align = slot.textAlign
        let left = align == "left"
            ? "left:\(String(format: "%.1f", slot.x * 100))%;right:5%"
            : "left:5%;right:5%"

        var style = "position:absolute;top:\(top)%;\(left);text-align:\(align);z-index:2;"
        style += "color:\(slot.color);"
        style += "font-size:\(size)cqi;"
        style += "font-weight:\(slot.fontWeight);"
        style += "line-height:\(slot.lineHeight ?? 1.1);"
        if let ls = slot.letterSpacing { style += "letter-spacing:\(ls);" }
        if let tt = slot.textTransform { style += "text-transform:\(tt);" }
        if let fs = slot.fontStyle { style += "font-style:\(fs);" }
        if let font = slot.font { style += "font-family:'\(font)',system-ui,sans-serif;" }
        style += "white-space:pre-line;"

        return "<div style=\"\(style)\">\(content)</div>"
    }

    // MARK: - Device

    private static func renderDevice(_ slot: TemplateDeviceSlot) -> String {
        let w = String(format: "%.1f", slot.scale * 100)
        let cx = String(format: "%.1f", slot.x * 100)
        let cy = String(format: "%.1f", slot.y * 100)
        let rot = slot.rotation.map { "rotate(\($0)deg)" } ?? ""
        let transform = "translateX(-50%) \(rot)"
        let z = slot.zIndex.map { "z-index:\($0);" } ?? ""

        // Placeholder device — gray rounded rect representing a phone
        let isLight = true // simplified — could check background
        let frameColor = isLight ? "rgba(0,0,0,0.08)" : "rgba(255,255,255,0.1)"
        let borderColor = isLight ? "rgba(0,0,0,0.12)" : "rgba(255,255,255,0.15)"
        let screenColor = isLight ? "rgba(0,0,0,0.04)" : "rgba(255,255,255,0.05)"

        return """
        <div style="position:absolute;left:\(cx)%;top:\(cy)%;width:\(w)%;transform:\(transform);\(z)">\
        <div style="aspect-ratio:1320/2868;background:\(frameColor);border-radius:10%/4.8%;border:1px solid \(borderColor);position:relative;overflow:hidden">\
        <div style="position:absolute;inset:2.5% 2%;background:\(screenColor);border-radius:8%/4%"></div>\
        </div></div>
        """
    }
}
