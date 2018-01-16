#import libraries 
library(shiny)
library(class)
library(hash)
library(stringr)
library(tm)
library(openxlsx)
library(lubridate)
library(zoo)
library(ggplot2) 
library(ggridges)
library(ROCR)
library(e1071)
library(SnowballC)
library(rpart)
library(caret)
library(rsconnect)

# Define server logic
shinyServer(function(input, output) {
  #allows larger csvs
  options(shiny.maxRequestSize=30*1024^2)
  
  output$authors <- renderUI({
    HTML(paste("Developed By:", 
               "David Mitre Becerril - MSPPM, Tejas Bisen - MISM, Annesha Ganguly - MAM, and Michael G Turner - MSPPM-DA", 
               "",
               "Developed At:",
               "H. John Heinz III College of Information Systems and Public Policy at Carnegie Mellon University in Measuring Social under Professor Ari Lightman",
               "",
               "Last Update:",
               "December 6, 2017",
               " ",
               " ",
               sep="<br/>"))
  })
  
  output$contents <- renderTable({
    #### model training inport ####
    
    #reads in input if it exists
    inFile <- input$file1
    
    #NULL handler
    if (is.null(inFile)){
      return(NULL)
    }
  
    #read csv 
    datTrain = read.csv(inFile$datapath)
    
    #adds in sunday if not present
    if('sunday1' %in% names(datTrain)){
      #do nothing
    } else {
      sunday1 <- c(rep(0,nrow(datTrain)))
      datTrain <- cbind(datTrain,sunday1)
    }

    #user input : datTrain <- read.csv('copperMaster.csv')
    
    #### user input generation ####
    
    # initial setup #
    
    #placeholder of input 
    datTest = datTrain[0,]
    datTest[1,] <- 0
    
    #sets copper1 or claritin1, other firms will always be off
    if('copper1' %in% names(datTest)){
      datTest$copper1[1] <- 1
    }
    
    if('claritin1"' %in% names(datTest)){
      datTest$claritin1[1] <- 1
    }
    
    #populates p90 likes - does not utilize in knn model
    datTest$p90likes[1] <- 1
    
    #reads input Text
    inputText <- input$textInput #inputText <- 'Hello, my name is georgia #' for example
    
    #handles hashtags
    
    datTest$hashtag1 <- str_count(inputText, "#")
    
    #cleans raw text #
    txt<-Corpus(VectorSource(inputText))
    txt <- tm_map(txt, content_transformer(tolower)) #to lower case
    trans <- content_transformer(function (x , pattern, replace) gsub(pattern, replace, x))
    txt <- tm_map(txt, trans, "http.*", " ") #remove links
    txt <- tm_map(txt, trans, "bit.ly.*", " ") #remove links
    txt <- tm_map(txt, trans, "www.*", " ") #remove links
    txt <- tm_map(txt, trans, "\\n", " ") #remove new lines
    #inspect(txt)
    
    #Change the name of the brand to "brand"
    txt <- tm_map(txt, trans, "coppertone", "brand") 
    txt <- tm_map(txt, trans, "tropicana", "brand") 
    txt <- tm_map(txt, trans, "neutrogena", "brand")
    
    txt <- tm_map(txt, trans, "claritin", "brand") 
    txt <- tm_map(txt, trans, "allegra", "brand") 
    txt <- tm_map(txt, trans, "flonase", "brand") 
    txt <- tm_map(txt, trans, "zyrtec", "brand") 
    
    #More data cleaning
    txt <- tm_map(txt, trans, "[[:punct:]]", " ") #remove punctuation
    txt <- tm_map(txt, trans, "[[:digit:]]", " ") #remove numbers
    txt <- tm_map(txt, trans, " . ", " ") #remove one character words
    txt <- tm_map(txt, trans, " . ", " ") #it has to be applied twice
    txt <- tm_map(txt, removeWords, stopwords("en")) #remove stop words; we could keep the stopwords if we want to keep more info
    txt <- tm_map(txt, stripWhitespace) #remove white spaces
    
    #Stemming
    txt <- tm_map(txt, stemDocument) #the stemming create some weirds words
    
    #Build the DocumentTermMatrix (each column is unique term; each row count how many times the word appears in each post) 
    dtm <- DocumentTermMatrix(txt)
    dat1 <- as.data.frame(as.matrix(dtm))
    
    #Merge with the dataframe of each post
    if(length(names(dat1))>=1){
      dat1<-dat1[,order(names(dat1))]
      dat<-dat1
    } else {
      dat <- data.frame('georgia'=1)
    }
    
    #reads back into code 
    inputText2 <- dat
    
    #placeholder if there is nothing read in yet
    if(length(inputText2)==0){
      holder <- data.frame('georgia'=1)
      inputText2 <- cbind(inputText2,1)
    }
    
    #for each terms, assigns values into the data frame by position
    for(i in 1:ncol(inputText2)){
      #find the postion to update
      pos =  match(names(inputText2)[i],names(datTest))

      #for non na values populates the datTest
      if(!is.na(pos)){
        datTest[1,pos] <- inputText2[1,names(inputText2)[i]]
      }
    }
    
    #sets time #
    
    #sets day of the week 
    if(input$dayInput=='Sunday'){
      datTest$sunday1[1] = 1
    } else {
      datTest$sunday1[1] = 0
    }
    
    if(input$dayInput=='Monday'){
      datTest$monday1[1] = 1
    } else {
      datTest$monday1[1] = 0
    }
    
    if(input$dayInput=='Tuesday'){
      datTest$tuesday1[1] = 1
    } else {
      datTest$tuesday1[1] = 0
    }
    
    if(input$dayInput=='Wednesday'){
      datTest$wednesday1[1] = 1
    } else {
      datTest$wednesday1[1] = 0
    }
    
    if(input$dayInput=='Thursday'){
      datTest$thursday1[1] = 1
    } else {
      datTest$thursday1[1] = 0
    }
    
    if(input$dayInput=='Friday'){
      datTest$friday1[1] = 1
    } else {
      datTest$friday1[1] = 0
    }
    
    if(input$dayInput=='Saturday'){
      datTest$saturday1[1] = 1
    } else {
      datTest$saturday1[1] = 0
    }
    
    #sets hour of day
    datTest$hour1[1] <- input$hourOfDayInput
    
    #sets month of year
    months = c('Jan', 'Feb','Mar','Apr','May','June','July','Aug','Sept','Oct','Nov','Dec')
    monthNum = 1:12
    monthDictionary <- hash(months,monthNum) # hash table for fast selection
    datTest$month1[1] <- monthDictionary[[input$monthInput]]
    
    #artifically sets year = 2013 - closet approxmiation to future based on past results according to post history
    datTest$year13 = 1
    
    #sets misc#
    #video
    if(input$videoInput=='Yes'){
      datTest$video1[1] <- 1
    }

    #photo
    if(input$photoInput=='Yes'){
      datTest$photo1[1] <- 1
    }
    
    #question
    if(input$questionInput=='Yes'){
      datTest$question1[1] <- 1
    }
    
    #links
    if(input$linkInput=='Yes'){
      datTest$links1[1] <- 1
    }
    
    #handles length of text
    wordLength <- input$textInput
    datTest$words1 <- length(unlist(strsplit(wordLength," ")))
    
    #isolates labels and fixes the number of featutres 
    c1Holder <- datTrain[,1]
    datTrain <- datTrain[,-1]
    datTest <- datTest[,-1]
    
    #model execution - reruns in full with each change 
    model <- knn(train = datTrain,test = datTest, cl = c1Holder, k=3)
    
    #result of model
    
    print('iteration complete')
    
    #reviewer
    modelHolder <- datTest[1,]
    modelHolder <- modelHolder
    for(i in ncol(datTest):25){
      if(sum(modelHolder[1,i])==0){
        modelHolder <- modelHolder[,-i]
      }
    }
    
    #output developer - takes model outcome and makes easier to understand
    if(model==0){
      outputter = data.frame(
        Prediction = 'Bottom 80% Post'
      )
    } 
    if(model==1){
      outputter = data.frame(
        Prediction = 'Top 20% Post'
      )
    }
    
    #returns result to UI
    outputter
  })
})
