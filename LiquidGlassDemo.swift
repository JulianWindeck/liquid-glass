// LiquidGlassDemo.swift
// An interactive playground for testing LiquidGlassBackground

import SwiftUI
import AppKit


private struct GlassPreview: View {
    @Binding var variant: Int
    @Binding var cornerRadius: Double

    var body: some View {
        LiquidGlassBackground(
            variant: GlassVariant(rawValue: variant) ?? .v11,
            cornerRadius: cornerRadius
        ) {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                Text("Variant \(variant)")
                    .font(.title3.weight(.semibold))
            }
            .padding()
        }
        .frame(width: 180, height: 180)
    }
}



private struct ControlPanel: View {
    @Binding var variant: Int
    @Binding var cornerRadius: Double

    var body: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading) {
                Text("Glass Variant")
                Slider(value: Binding(
                    get: { Double(variant) },
                    set: { variant = Int($0) }
                ), in: 0...19, step: 1)
                Text("Current: \(variant)")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            VStack(alignment: .leading) {
                Text("Corner Radius")
                Slider(value: $cornerRadius, in: 0...60, step: 1)
                Text("Current: \(Int(cornerRadius)) pt")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}



struct LiquidGlassDemo: View {
    @State private var variant: Int = 11
    @State private var cornerRadius: Double = 12
    @State private var showPreview: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            Text("Liquid Glass Playground")
                .font(.title.weight(.bold))

            ControlPanel(variant: $variant, cornerRadius: $cornerRadius)

            Toggle("Show Floating Preview", isOn: $showPreview)
                .toggleStyle(.switch)
        }
        .padding(48)
        .background(FloatingPreviewHolder(
            variant: $variant,
            cornerRadius: $cornerRadius,
            showPreview: $showPreview
        ))
    }
}

private struct FloatingPreviewHolder: View {
    @Binding var variant: Int
    @Binding var cornerRadius: Double
    @Binding var showPreview: Bool

    // Use @State to hold the panel and keep it alive.
    @State private var previewPanel: FloatingPanel<GlassPreview>?

    func makePanel() -> FloatingPanel<GlassPreview> {
        let panel = FloatingPanel(
            view: {
                GlassPreview(
                    variant: $variant,
                    cornerRadius: $cornerRadius
                )
            },
            contentRect: NSRect(
                origin: CGPoint(x: 1200, y: 800),
                size: CGSize(width: 220, height: 220)
            ),
            isPresented: $showPreview
        )
        return panel
    }
    
    var body: some View {
     
        EmptyView()
            .onAppear {
                // Create the panel when the view first appears.
                previewPanel = makePanel()
                if showPreview {
                    previewPanel?.orderFront(nil)
                }
            }
            .onChange(of: showPreview) { show in
                if show {
                    // If the panel doesn't exist, create it.
                    if previewPanel == nil {
                        previewPanel = makePanel()
                    }
                    previewPanel?.orderFront(nil)
                } else {
                    previewPanel?.close()
                }
            }
    }
}


final class FloatingPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool

    init(@ViewBuilder view: () -> Content,
         contentRect: NSRect,
         isPresented: Binding<Bool>) {
        self._isPresented = isPresented

        super.init(contentRect: contentRect,
                   styleMask: [.utilityWindow],
                   backing: .buffered,
                   defer: false)

        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces]
        animationBehavior = .utilityWindow
        isMovableByWindowBackground = false
        hidesOnDeactivate = true
        backgroundColor = .clear

        contentView = NSHostingView(rootView: view())
    }

    override func resignMain() {
        super.resignMain()
        close()
    }

    override func close() {
        super.close()
        isPresented = false
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}



@main
struct LiquidGlassDemoApp: App {
    var body: some Scene {
        WindowGroup(id: "main") {
            LiquidGlassDemo()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
        }
        .defaultSize(width: 700, height: 300)
    }
}
