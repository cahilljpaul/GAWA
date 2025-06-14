//
//  LoginView.swift
//  GAWA
//
//  Created by Paul Cahill on 04/05/2025.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Text("GAA Login").font(.largeTitle)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            }

            Button("Login or Register") {
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        Auth.auth().createUser(withEmail: email, password: password) { _, createErr in
                            errorMessage = createErr?.localizedDescription ?? error.localizedDescription
                        }
                    }
                }
            }
        }
        .padding()
    }
}
