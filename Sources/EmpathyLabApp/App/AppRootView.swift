import SwiftUI

struct AppRootView: View {
    enum Route: Hashable {
        case home
        case selection
        case lab
        case results
        case designFix
        case debrief
        case about
    }

    @State private var path = NavigationPath()
    @State private var isSafetySheetPresented = false
    @State private var pendingRouteAfterSafety: Route?

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                onStartExperience: {
                    push(.selection)
                },
                onShowAbout: {
                    push(.about)
                }
            )
            .navigationDestination(for: Route.self) { route in
                destination(for: route)
            }
            .sheet(isPresented: $isSafetySheetPresented) {
                SafetySheetView(
                    onContinue: {
                        isSafetySheetPresented = false
                        if let pendingRouteAfterSafety {
                            push(pendingRouteAfterSafety)
                            self.pendingRouteAfterSafety = nil
                        }
                    },
                    onCancel: {
                        isSafetySheetPresented = false
                        pendingRouteAfterSafety = nil
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .home:
            HomeView(
                onStartExperience: {
                    push(.selection)
                },
                onShowAbout: {
                    push(.about)
                }
            )
        case .selection:
            SelectionView(
                onContinueToLab: {
                    pendingRouteAfterSafety = .lab
                    isSafetySheetPresented = true
                },
                onShowAbout: {
                    push(.about)
                }
            )
        case .lab:
            LabView(
                onFinish: {
                    push(.results)
                },
                onBack: {
                    pop()
                }
            )
        case .results:
            ResultsView(
                onContinue: {
                    push(.designFix)
                },
                onBackToHome: {
                    popToRoot()
                }
            )
        case .designFix:
            DesignFixView(
                onContinue: {
                    push(.debrief)
                },
                onBack: {
                    pop()
                }
            )
        case .debrief:
            DebriefView(
                onDone: {
                    popToRoot()
                }
            )
        case .about:
            AboutView()
        }
    }

    private func push(_ route: Route) {
        path.append(route)
    }

    private func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    private func popToRoot() {
        path = NavigationPath()
    }
}
