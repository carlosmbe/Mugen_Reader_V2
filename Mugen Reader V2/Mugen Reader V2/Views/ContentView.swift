//
//  ContentView.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 23/10/2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var chosenMangaAlt = MangaClass()
  
    @State private var chosenManga = Manga.produceExampleManga()
    
    @State private var showMangaDescription = false
    @State private var showThirdView = false
    
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    
    @State private var searchText = ""
    
    @State private var title = "Seasonal"
    
    @State private var mangaResults = [Manga]()
    var animatableData : [Manga]{
        get{mangaResults}
        set{mangaResults = newValue}
    }
    
    @State private var homeMangaResults = [Manga]()//This is more of a cache cause I put search results manga in MangaResults sometimes
    let seasonId = "4be9338a-3402-4f98-b467-43fb56663927"
    
    var body: some View {
        
        if mangaResults.isEmpty{
            ProgressView()
        }
        
        NavigationView{
            
            List(mangaResults){ manga in
                HStack{
                    MangaView(item: manga)
                    Spacer()
                }
                .contentShape(Rectangle())
                //HStack, Spacer and .contentShape make on tap gesture apply on entire list row area
                    .onTapGesture {
                        chosenManga = manga
                        chosenMangaAlt.manga = manga
                        showMangaDescription = true
                    }
            }//List ends here
            
            .searchable(text: $searchText)
            
            .onChange(of: searchText) { _ in
                if searchText.isEmpty{
                    mangaResults = homeMangaResults
                    title = "Seasonal"
                }
            }//On Change Ends Here
            
            .onSubmit(of: .search) {
                Task{   await tryAPICallAgain()    }
            }// On Sumbit Ends Here
            
            .navigationTitle(title)
          /*  .toolbar{
                Button("Reset User Data"){
                    let defaults = UserDefaults.standard
                    let dictionary = defaults.dictionaryRepresentation()
                    dictionary.keys.forEach { key in
                        let _ = print("reseting")
                        defaults.removeObject(forKey: key)
                    }
                }
            }*/
            
            .sheet(isPresented: $showMangaDescription){ MangaDescription(showNext: $showThirdView ,selectedManga: chosenMangaAlt)    }
           
            .background(
                        NavigationLink(destination: ChaptersView(chosenManga: chosenManga), isActive: $showThirdView) {
                              ChaptersView(chosenManga: chosenManga)
                        }
                  )
           //Allows sheet to open Manga Chapter List Directly
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
    
}//Content View Ends here

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
                
                Text("Status: \(item.attributes.status)").padding(.leading, 5)
                
                if let mangaYear = item.attributes.year{
                    Text("Year: \(String(mangaYear))").padding(.leading, 5)
                } //Not all have years hence if let
                else{ Text("Year: N/A").padding(.leading, 5) }
                
            }//VStack Ends Here
        }//HStach Ends Here
        
    }
}//MangaView Ends Here

struct MangaDescription: View{
    
    @Binding var showNext: Bool
    let selectedManga : MangaClass
    
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View{
        let selectedMangaItem = selectedManga.manga
        ZStack{
            GeometryReader { geometry in
                Manga.getCover(item: selectedMangaItem)
                    .opacity(0.1)
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    
            }.ignoresSafeArea()
            
            VStack {
                HStack{
                  /*
                    Manga.getCover(item: selectedMangaItem)
                        .frame(width: 75, height: 112.5)
                        .cornerRadius(10)
                        .padding()
                    */
                    
                    if let title = selectedMangaItem.attributes.title.en{
                        Text(title).font(.title).padding()
                    }
                }//H Stacks Ends Here
                
                if let desc = selectedMangaItem.attributes.description?.en{
                    Text(desc).font(.body).padding()
                }
                
                if selectedMangaItem.id == "Blah"{
                    //Then this is a dummy Manga I use an example. Meaning either an error or still loading
                    Button("Ok"){   dismiss()   }
                        .buttonStyle(.borderedProminent)
                        .padding()
                }
                else{
                    Button("Read"){
                        dismiss()
                        DispatchQueue.main.async {
                            self.showNext = true
                        }
                        //Show Chapter List
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }//V Stack ends here
        }//ZStack Ends Here
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

