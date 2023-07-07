//
//  MangaDescription.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 30/11/2022.
//

import SwiftUI

struct MangaDescription: View{
    
    let selectedManga : Manga
        
    var body: some View{
        let selectedManga = selectedManga
        ZStack{
            GeometryReader { geometry in
                Manga.getCover(item: selectedManga)
                    .opacity(0.1)
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    
            }.ignoresSafeArea()
            
            VStack {
            
                    if let title = selectedManga.attributes.title.en{
                        Text(title).font(.title).padding()
                    }
        
                
                if let desc = selectedManga.attributes.description?.en{
                    Text(desc).font(.body).padding()
                }
                
                NavigationLink(destination: ChaptersView(chosenManga: selectedManga)){
                    Text("Read")
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
            }//V Stack ends here
        }//ZStack Ends Here
    }
    
}

struct MangaDescription_Previews: PreviewProvider {
    static let PreviewManga = Manga.produceExampleManga()
    static var previews: some View {
        MangaDescription(selectedManga: PreviewManga)
    }
}
