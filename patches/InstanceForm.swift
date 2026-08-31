import SwiftUI

struct InstanceForm: View {
    @Binding var savedInstanceID: Instance.ID?

    @State private var selectedApp: VideosApp = .piped
    @State private var name = "Piped"
    @State private var url = "https://api.piped.private.coffee"

    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var accounts = AccountsModel.shared

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                header
                form
                footer
            }
            .frame(maxWidth: 1000)
        }
        #if os(iOS)
            .padding(.vertical)
        #elseif os(tvOS)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        #else
            .frame(width: 420, height: 240)
            .padding(.vertical)
        #endif
    }

    private var header: some View {
        HStack {
            Text("Add Location")
                .font(.title2.bold())

            Spacer()

            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            #if !os(tvOS)
            .keyboardShortcut(.cancelAction)
            #endif
        }
        .padding(.horizontal)
    }

    private var form: some View {
        Form {
            Picker("Backend", selection: $selectedApp) {
                Text("Piped").tag(VideosApp.piped)
                Text("Invidious").tag(VideosApp.invidious)
            }
            .onChange(of: selectedApp) { app in
                if name.isEmpty || name == "Piped" || name == "Invidious" {
                    name = app.name
                }
            }

            TextField("Name", text: $name)

            TextField("Address", text: $url)
            #if !os(macOS)
                .autocapitalization(.none)
                .keyboardType(.URL)
            #endif
                .disableAutocorrection(true)

            Section {
                Text("The location can be saved without the legacy Rick Astley validation check. If a public server later stops working, edit or add another server here.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var footer: some View {
        HStack {
            Spacer()

            Button("Save", action: submitForm)
                .disabled(!canSave)
            #if !os(tvOS)
                .keyboardShortcut(.defaultAction)
            #endif
        }
        .padding(.horizontal)
    }

    private var normalizedURL: String {
        url.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        guard let components = URLComponents(string: normalizedURL),
              let scheme = components.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              !(components.host?.isEmpty ?? true)
        else {
            return false
        }

        return true
    }

    private func submitForm() {
        guard canSave else { return }

        let displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedInstance = InstancesModel.shared.insert(
            app: selectedApp,
            name: displayName.isEmpty ? selectedApp.name : displayName,
            url: normalizedURL
        )

        savedInstanceID = savedInstance.id
        accounts.setCurrent(savedInstance.anonymousAccount)
        presentationMode.wrappedValue.dismiss()
    }
}

struct InstanceFormView_Previews: PreviewProvider {
    static var previews: some View {
        InstanceForm(savedInstanceID: .constant(nil))
    }
}
