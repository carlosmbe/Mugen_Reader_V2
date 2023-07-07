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
                .frame(width: 75, height: 112.5)
                .cornerRadius(10)
                .shadow(radius: 10)
            
            VStack(alignment: .leading){
                
                Text(item.attributes.title.en ?? "No Title UwU")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .padding(.bottom, 5)
                
                
                Text("Status: \(item.attributes.status.capitalized)")
                    .padding(.leading, 5)
                    .shadow(radius: 2)
                
                //TODO: Figure out how to elegently turn 0000 into N/A
                HStack {
                    Image(systemName: "calendar")
                    
                    Text("Year: \(item.attributes.year ?? 0000)")
                        
                }
                
           
                
            }//VStack Ends Here
            
            
        }//HStack Ends Here
        .padding()
        
    }
}//MangaView Ends Here

