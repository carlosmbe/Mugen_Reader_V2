//
//  ContentView.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 23/10/2022.
//

import SwiftUI

struct ContentView: View {
    
  //  @StateObject private var chosenMangaAlt = MangaClass()
  
 //   @State private var chosenManga = Manga.produceExampleManga()
    
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    
    @State private var searchText = ""
    
    @State private var title = "Seasonal"
    
    @State private var mangaResults = [Manga]()
    var animateMangaResults : [Manga]{
        get{mangaResults}
        set{mangaResults = newValue}
    }
    
    @State private var homeMangaResults = [Manga]()//This is more of a cache cause I put search results manga in MangaResults sometimes
    let seasonId = "4be9338a-3402-4f98-b467-43fb56663927"
    
    var MangaListView : some View{
        List(mangaResults){ manga in
            NavigationLink(destination: MangaDescription(selectedManga: manga)){
                HStack{
                    MangaView(item: manga)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            //HStack, Spacer and .contentShape make on tap gesture apply on entire list row area
        }
    }
    
    var body: some View {
        
        if mangaResults.isEmpty{
            ProgressView()
        }
        
        NavigationView{
            
            MangaListView
            
            .searchable(text: $searchText)
            
            .onChange(of: searchText) { _ in
                if searchText.isEmpty{
                    mangaResults = homeMangaResults
                    title = "Seasonal"
                }
            }
            
            .onSubmit(of: .search) {
                Task{   await tryAPICallAgain()    }
            }
            
            .toolbar{
                NavigationLink(destination: ReadingList()){
                    Image(systemName: "bookmark")
                }
            }
            
            .navigationTitle(title)
            
            .alert(isPresented: $showingErrorAlert){
                Alert(
                    title: Text("There was an error :<")
                    ,primaryButton: Alert.Button.default(Text("Try Again")){
                        Task{   await tryAPICallAgain() }
                    }
                    ,secondaryButton: .cancel()
                )}//Alert Closure Ends Here
            
        }//Nav View Ends here
        .task{  await getHomePageManga()    }
    }
    
    //This function checks if we're trying to a search again or a inital homepage load
    func tryAPICallAgain() async{
        if searchText.isEmpty{
            if homeMangaResults.isEmpty{
                await getHomePageManga()
            }else{
                mangaResults = homeMangaResults
                title = "Seasonal"
            }
            
            
        }//if search is empty it means the call was not done by a search error. Thus it was trying to get home page.
        else{
            let searchURL = Manga.buildSearchLink(for: searchText)
            do{
                mangaResults = try await Manga.callMangaDexAPI(for: searchURL)
                title = "Search Results"
            }catch{
                print("error is \(error.localizedDescription.debugDescription)")
                errorMessage = "I need to figure out how to display custom Error Enums Messages Here"
                showingErrorAlert = true
            }
        }//Else Try Searching Again
        
    }//func ends here
    
    func getHomePageManga() async{
        do{
            let builtLink = try  await Manga.buildSeasonalMangaCall(seasonListId: seasonId)
            homeMangaResults =  try await Manga.callMangaDexAPI(for: builtLink )
            withAnimation{ mangaResults = homeMangaResults }
            title = "Seasonal"
        }catch{
            errorMessage = "I need to figure out how to display custom Error Enums Messages Here"
            showingErrorAlert = true
        }
        
    }
    
}//Home View Ends here

struct MangaView: View{
    
    let item: Manga
    
    var body: some View{
        
        HStack {
        
            Manga.getCover(item: item)
                .frame(width: 75, height: 112.5)
                .cornerRadius(10)
           
            VStack(alignment: .leading){
                if let title = item.attributes.title.en{
                    
                    Text(title)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .padding(.bottom, 5)
                }else {
                    Text("<<Title Comes Here UwU>>\n Placeholder TxT")
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .padding(.bottom, 5)
                }
                
                Text("Status: \(item.attributes.status.capitalized)").padding(.leading, 5)
                
                if let mangaYear = item.attributes.year{
                    Text("Year: \(String(mangaYear))").padding(.leading, 5)
                } //Not all have years hence if let
                else{ Text("Year: N/A").padding(.leading, 5) }
                
            }//VStack Ends Here
        }//HStack Ends Here
        
    }
}//MangaView Ends Here


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

