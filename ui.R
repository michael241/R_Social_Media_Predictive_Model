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

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    #title
    titlePanel('Bayer Facebook Post Optimization Interface'),
    htmlOutput("authors"),
    
    # Show a plot of the generated distribution
    mainPanel(
      
      fileInput("file1", "Choose CSV File"),
                #accept = c(
                #  "text/csv",
                #  "text/comma-separated-values,text/plain",
                #  ".csv")

      #output shower - remove later
      
      textAreaInput(inputId = 'textInput', 
                    label = 'Text of Facebook Post', 
                    value = '',
                    height = 150, #good size for up to 150 words, more than we need
                    width = 1000,
                    placeholder = 'Please enter the text of your proposed facebook post'),
      
      #### timing ####
      #month of the year input
      radioButtons(inputId ='monthInput',selected = 'Jan',
                   label = 'Please select the month of the post',
                   choices = c('Jan', 'Feb','Mar','Apr','May','June','July','Aug','Sept','Oct','Nov','Dec'),
                   inline = TRUE),
      
      #input day of the week
      radioButtons(inputId ='dayInput',selected = 'Sunday',
                   label = 'Please select the day of the week of the post',
                   choices = c('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'),
                   inline = TRUE),
      
      #hour of the day
      numericInput(inputId='hourOfDayInput', 
                   label = 'Hour of the Day: 0=12AM -> 23=11PM',
                   min=0,
                   max = 23,
                   step = 1,
                   value = 0),
      
      #### misc features ####
      
      #video
      radioButtons(inputId = 'videoInput',selected = 'No',
                   label = 'Does this post contain a video?',
                   choices = c('Yes','No'),
                   inline=TRUE),
      
      #photo
      radioButtons(inputId = 'photoInput',selected = 'No',
                   label = 'Does this post contain a photo?',
                   choices = c('Yes','No'),
                   inline=TRUE),
      
      #question
      radioButtons(inputId = 'questionInput',selected = 'No',
                   label = 'Does this post ask a question?',
                   choices = c('Yes','No'),
                   inline=TRUE),
      
      #question
      radioButtons(inputId = 'linkInput',selected = 'No',
                   label = 'Does this post contain a link?',
                   choices = c('Yes','No'),
                   inline=TRUE),
      
      #result
      #renderText('holder'),
      tableOutput('contents')
    )
  )
)
