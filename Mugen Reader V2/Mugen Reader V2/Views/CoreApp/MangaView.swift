//
//  MangaView.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 2023-07-06.
//

import SwiftUI

struct MangaView: View{
    
    let item: Manga
    
    var body: some View{
        
        HStack {
            
            Manga.getCover(item: item)
                .scaledToFit()
                .frame(width: 75, height: 112.5)
                .cornerRadius(10)
                .shadow(color: .gray, radius: 5, x: 0, y: 2) // Subtle shadow
            
            VStack(alignment: .leading){
                
                Text(item.attributes.title.en ?? "No Title UwU")
                    .font(.headline) 
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text("Status: \(item.attributes.status.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Year: \(item.attributes.year.map { $0 != 0 ? String($0) : "N/A" } ?? "N/A")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            
            }//VStack Ends Here
            
            
        }//HStack Ends Here
        .padding([.top, .bottom])
        
    }
}//MangaView Ends Here

