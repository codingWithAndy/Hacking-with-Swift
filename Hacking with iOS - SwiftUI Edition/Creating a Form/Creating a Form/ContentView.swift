//
//  ContentView.swift
//  Creating a Form
//
//  Created by Andy Gray on 18/12/2019.
//  Copyright © 2019 Andy Gray. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var name = ""
    
    var body: some View {
        Form {
            TextField("Enter your name!", text: $name)
            Text("Hello World!")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
