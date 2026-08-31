import Defaults
import SwiftUI

struct LocationsSettings: View {
    @State private var presentingInstanceForm = false
    @State private var savedFormInstanceID: Instance.ID?

    @ObservedObject private var accounts = AccountsModel.shared
    @Default(.instances) private var instances

    var body: some View {
        VStack(alignment: .leading) {
            #if os(macOS)
                settings
                Spacer()
            #else
                List {
                    settings
                }
                #if os(tvOS)
                .listStyle(.plain)
                #elseif os(iOS)
                .listStyle(.insetGrouped)
                #endif
            #endif
        }
        .sheet(isPresented: $presentingInstanceForm) {
            InstanceForm(savedInstanceID: $savedFormInstanceID)
        }
        #if os(tvOS)
        .buttonStyle(.plain)
        .toggleStyle(TVOSPlainToggleStyle())
        .frame(maxWidth: 1000)
        #endif
        .navigationTitle("Locations")
    }

    @ViewBuilder var settings: some View {
        Section(header: SettingsHeader(text: "Quick Setup".localized()), footer: quickSetupFooter) {
            Button {
                usePiped(name: "Piped - Private Coffee", url: "https://api.piped.private.coffee")
            } label: {
                Label("Use recommended Piped server", systemImage: "bolt.fill")
            }

            Button {
                usePiped(name: "Piped - Wireway", url: "https://pipedapi.wireway.ch")
            } label: {
                Label("Use backup Piped server", systemImage: "arrow.triangle.2.circlepath")
            }
        }

        Section(header: SettingsHeader(text: "Custom Locations".localized())) {
            #if os(macOS)
                InstancesSettings()
            #else
                ForEach(instances) { instance in
                    AccountsNavigationLink(instance: instance)
                }

                Button {
                    presentingInstanceForm = true
                } label: {
                    Label("Add Location...", systemImage: "plus")
                }
            #endif
        }
    }

    @ViewBuilder var quickSetupFooter: some View {
        if let account = accounts.current, let instance = account.instance {
            Text("Current: \(instance.name)\n\(instance.apiURLString)")
                .foregroundColor(.secondary)
        } else {
            Text("Choose a server once. The old locations-manifest and strict pre-save validation have been removed from this build.")
                .foregroundColor(.secondary)
        }
    }

    private func usePiped(name: String, url: String) {
        let instance = InstancesModel.shared.insert(app: .piped, name: name, url: url)
        savedFormInstanceID = instance.id
        accounts.setCurrent(instance.anonymousAccount)
    }
}

struct LocationsSettings_Previews: PreviewProvider {
    static var previews: some View {
        LocationsSettings()
    }
}
