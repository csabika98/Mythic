//
//  Auth.swift
//  Mythic
//
//  Created by Esiayo Alegbe on 29/9/2023.
//

import SwiftUI

struct AuthView: View {
    @Binding var isPresented: Bool
    @Binding var authSuccessful: Bool
    
    @State private var code: String = String()
    @State private var isLoggingIn: Bool = false
    @State private var progressViewPresented = false
    @State private var isProgressViewSheetPresented = false
    @State private var isError = false
    
    func submitToLegendary() async {
        if !code.isEmpty {
            isLoggingIn = true
            progressViewPresented = true
            
            let command = await Legendary.command(args: ["auth", "--code", code], useCache: false)
            
            if let commandStderrString = String(data: command.stderr, encoding: .utf8), commandStderrString.contains("Successfully logged in as") {
                authSuccessful = true
                $isPresented.wrappedValue = false
                progressViewPresented = false
            } else {
                authSuccessful = false
                isError = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    code = String()
                    progressViewPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 /* Just to be safe */) {
                        isError = false
                    }
                }
            }
        }
    }
    
    init(isPresented: Binding<Bool>, authSuccessful: Binding<Bool> = .constant(false)) {
        _isPresented = isPresented
        _authSuccessful = authSuccessful
    }
    
    var body: some View {
        HStack {
            TextField("Enter auth key...", text: $code)
                .onSubmit {
                    Task { await submitToLegendary() }
                }
                .frame(width: 350, alignment: .center)
            
            Button(action:{
                Task { await submitToLegendary() }
            }) {
                Text("Submit")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .fixedSize()
        
        .sheet(isPresented: $progressViewPresented) {
            ProgressViewSheetWithError(isError: $isError, isPresented: $isProgressViewSheetPresented)
        }
    }
}

#Preview {
    HomeView()
}
